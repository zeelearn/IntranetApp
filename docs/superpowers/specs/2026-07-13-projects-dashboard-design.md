# Projects Dashboard Module — Design Spec

**Date:** 2026-07-13  
**Status:** Approved for implementation planning  
**Scope:** `lib/modules/projects/` only  
**Approach:** A — Self-contained GetX module with constructor args + callbacks

---

## 1. Goals

Build a production-ready, offline-first **Projects Dashboard** that:

- Matches the attached Figma (Material 3, enterprise styling)
- Is responsive for **mobile, tablet, and web/desktop**
- Opens independently via `Navigator.push` / `Get.to` (no named URL / deep link required)
- Calls `GetDashboardCountv1` with dynamic `user_Id` and `Business_id`
- Parses nested JSON-in-string responses safely
- Caches parsed data in Hive and works offline
- Uses GetX only (no `setState`)
- Does **not** include bottom navigation
- Fires callbacks for card / quick-action navigation (parent wires destinations)

---

## 2. Non-Goals

- Bottom navigation bar
- Project List / Task List screen implementations
- Real activity time-series chart data (UI empty state only for v1)
- Modifying existing BPMS Riverpod screens
- Hardcoding `user_Id`
- Registering a required GetX named route / deep link

---

## 3. Entry Contract

### Widget

```dart
ProjectsDashboardPage({
  required int userId,
  int? businessId, // null => All Business
  required String displayName,
  required List<BusinessApplications> businesses,
  void Function(int statusId, String statusName)? onCardTap,
  void Function(QuickActionType action)? onQuickAction,
  VoidCallback? onMenuTap,       // optional; default Get.back / drawer
  VoidCallback? onSearchTap,     // optional visual callback
  VoidCallback? onNotificationTap,
})
```

### Example open

```dart
Get.to(
  () => ProjectsDashboardPage(
    userId: userId,
    businessId: selectedBusinessId, // or null
    displayName: displayName,
    businesses: businessApplications,
    onCardTap: (statusId, statusName) { /* parent navigates */ },
    onQuickAction: (action) { /* parent navigates */ },
  ),
  binding: DashboardBinding(
    userId: userId,
    businessId: selectedBusinessId,
    displayName: displayName,
    businesses: businessApplications,
  ),
);
```

`BusinessApplications` is the existing login model (`lib/api/response/login_response.dart`).

---

## 4. Folder Structure

```
lib/modules/projects/
  bindings/
    dashboard_binding.dart
  controllers/
    dashboard_controller.dart
  models/
    dashboard_response.dart
    dashboard_summary.dart
    project_status.dart
    dashboard_card_model.dart
    quick_action_type.dart
  repositories/
    dashboard_repository.dart
  services/
    dashboard_remote_service.dart
    dashboard_local_service.dart
  views/
    projects_dashboard_page.dart
  widgets/
    dashboard_header.dart
    business_selector.dart
    date_selector.dart
    offline_banner.dart
    dashboard_card.dart
    dashboard_grid.dart
    dashboard_chart.dart
    quick_action_widget.dart
    dashboard_shimmer.dart
    dashboard_error_widget.dart
    dashboard_empty_widget.dart
  routes/
    projects_routes.dart          # optional path constants only
```

Do not modify other modules for core delivery. Parent menu wiring remains outside this module.

---

## 5. Architecture & Data Flow

```
ProjectsDashboardPage
        │
        ▼
DashboardController (GetX Rx)
        │
        ▼
DashboardRepository
   ├── DashboardRemoteService  → POST GetDashboardCountv1
   └── DashboardLocalService   → Hive cache
```

### Offline-first flow

1. Page open → Binding registers dependencies  
2. `loadOffline()` → Hive (instant UI if cache exists)  
3. `sync()` → remote API when online  
4. Parse nested JSON string safely  
5. `saveLocal()` → Hive (parsed summary, not raw string)  
6. `calculatePercentages()` → build `RxList<DashboardCardModel>`  
7. UI rebuild via `Obx`

### Business change

- User selects from `businesses` or **All Business** (`businessId = null`)
- Controller updates `businessId` → `sync()` again
- Cache key includes business scope

### Connectivity

- Observe online/offline
- Offline → OfflineBanner + cache
- Online / back online → auto `sync()` once
- Pull-to-refresh always available

---

## 6. API

### Endpoint

```
POST https://kubapi.zeelearn.com/V1/commonapi/api/bp/GetDashboardCountv1
```

Base already used in app: `LocalStrings.bpms` = `https://kubapi.zeelearn.com/V1/commonapi`.

Path constant for this module (new): `api/bp/GetDashboardCountv1`  
(Do not reuse old `GetDashboardCount` unless explicitly aliased later.)

### Request

```json
{
  "user_Id": 34254,
  "Business_id": null
}
```

- `user_Id` from constructor (never hardcoded)
- `Business_id` from selected business or `null` for All Business

### Response shape

Outer envelope:

```json
{
  "success": 200,
  "data": [
    {
      "data": "[ { ...inner summary JSON... } ]"
    }
  ]
}
```

Inner summary (string that must be `jsonDecode`d):

- `TotalProject`
- `pendingtask`, `completedTask`, `InprogressTask`, `CancelledTask`
- Arrays: `CompletedProject`, `NotInterestedProject`, `RefundedProject`, `RejectedProject`, `PendingProject`, `NotStartedProject`  
  each item: `{ "status_id": n, "c": count }`

### Parsing rules

1. Decode outer map  
2. Read `data[0].data` as `String`  
3. `jsonDecode` inner string → `List` / `Map`  
4. Map to `DashboardSummary`  
5. On any parse failure → typed error; do not overwrite Hive with bad data

---

## 7. Models

All models: null-safe, `fromJson` / `toJson` / `copyWith`, Equatable.

| Model | Purpose |
|-------|---------|
| `DashboardResponse` | Outer API envelope |
| `DashboardSummary` | Parsed inner counts + status lists |
| `ProjectStatus` | `{ statusId, count }` |
| `DashboardCardModel` | UI card DTO (title, count, %, color, icon, chip, statusId, kind) |

### Card mapping

| UI Card | Source field | status_id | Color |
|---------|--------------|-----------|-------|
| Pending Projects | `PendingProject` | 6 | Blue `#1565C0` |
| Confirmed Projects | `CompletedProject` | 1 | Green `#2E7D32` |
| Refund Projects | `RefundedProject` | 4 | Teal `#00897B` |
| Rejected Projects | `RejectedProject` | 3 | Red `#D32F2F` |
| Not Interested Projects | `NotInterestedProject` | 2 | Purple `#5E35B1` |
| Pending Tasks | `pendingtask` | `101` (synthetic) | Blue `#1565C0` |
| In Progress Tasks | `InprogressTask` | `102` (synthetic) | Orange `#F9A825` |
| Completed Tasks | `completedTask` | `103` (synthetic) | Green `#2E7D32` |

**Confirmed** in UI maps to API **CompletedProject** (status_id `1`).

Task cards are not API project statuses. They still invoke `onCardTap(statusId, statusName)` using the synthetic IDs above (`101`–`103`) so the parent can branch without a second callback type.

### Percentages

- Project cards: `count / TotalProject` (guard divide-by-zero → `0`)
- Task cards: `count / (pendingtask + InprogressTask + completedTask + CancelledTask)` (guard zero)

Display: progress bar + `"X% of total"`.

---

## 8. Controller Responsibilities

`DashboardController` (GetX only):

- `loadDashboard()` — offline then sync
- `refresh()` — user pull / retry
- `sync()` — remote → local → Rx
- `saveLocal()` / `loadOffline()` via repository
- `calculateDashboard()` / `calculatePercentages()`
- `selectBusiness(int? businessId)`
- `observeConnectivity()`
- Invoke `onCardTap` / `onQuickAction` callbacks (no hard navigation)

Reactive state: `RxList`, `RxBool`, `RxInt`, `RxString`, `Rxn` as needed  
(`isLoading`, `isOffline`, `errorMessage`, `cards`, `summary`, `selectedBusinessId`).

---

## 9. Repository & Services

### `DashboardRemoteService`

- POST body with `user_Id` / `Business_id`
- Reuse app HTTP headers pattern where practical (`APIService` header helpers or equivalent)
- Map HTTP failures to typed failures (timeout, 401, 403, 500)

### `DashboardLocalService` (Hive)

- Box name e.g. `projects_dashboard_box`
- Key: `dashboard_{userId}_{businessId ?? 'all'}`
- Store JSON of `DashboardSummary`
- Read/write/clear helpers

### `DashboardRepository`

- Orchestrates remote + local
- Prefer cache-first for UI, then network
- Never called from widgets directly

---

## 10. UI & Responsive Layout

### Structure (top → bottom)

1. **Header** — `#1565C0`, title Dashboard, welcome `displayName`, search + notification
2. **Filter row** — Date selector (display-only current date in v1; no API date filter) + Business selector
3. **OfflineBanner** — when offline / serving stale cache after failed sync
4. **DashboardGrid** — 8 status cards
5. **Project Activity Overview** — chart shell + empty state (“No activity data yet”) + View All callback
6. **Quick Actions** — Project List, My Tasks, Create Project, Reports

**No bottom navigation.**

### Breakpoints

| Viewport | Cards crossAxisCount |
|----------|----------------------|
| Mobile `< 600` | 2 |
| Tablet `600–1023` | 3 |
| Desktop/Web `≥ 1024` | 4 |

Large screens: center content with max width ~1200.

### Card visuals (Figma)

- Radius ~20, soft elevation, tinted gradient background
- Icon circle, title, status chip, large count, linear progress, percent caption
- Ink ripple + staggered entrance animation
- Loading: shimmer skeletons (no `CircularProgressIndicator`)

### Chart (v1)

Keep Figma section layout using `fl_chart` shell or static empty illustration.  
No fabricated activity series. Empty state only until a real activity API exists.

---

## 11. Error & Empty States

| Case | UI |
|------|----|
| Timeout | Error + Retry; keep last cache if present |
| No internet | OfflineBanner + cache; else offline empty + Retry |
| 401 / 403 | Auth/permission message |
| 500 | Server error + Retry |
| Invalid JSON | Parse error; do not corrupt cache |
| Empty data | EmptyWidget |

---

## 12. Dependencies

**Already in project:** `get`, `hive`, `hive_flutter`, `equatable`, `fl_chart`, `http`/`dio`, `google_fonts`

**Add / uncomment as needed:**

- `shimmer` (currently commented in `pubspec.yaml`)
- `connectivity_plus` if no suitable existing connectivity observer is reusable inside the module

Minimize new packages; prefer existing Intranet patterns.

---

## 13. Performance & Standards

- Const widgets where possible
- Minimal `Obx` scope (grid/cards/banner only)
- Widget separation; no god-file
- Repository cache; lazy chart paint
- SOLID + repository pattern + DI via GetX Binding
- Lint-clean, null-safe, unit-test-ready models/parser/percentage helpers

---

## 14. Testing Targets (unit-test ready)

1. Nested JSON string parser (valid, malformed, empty)
2. Percentage calculations (zero totals, normal)
3. Card mapping from `DashboardSummary`
4. Repository: cache hit / network fail fallback (mocked services)

---

## 15. Open Decisions (resolved)

| Topic | Decision |
|-------|----------|
| Bottom nav | Removed |
| Chart data | Empty-state UI only |
| Card navigation | Callback only |
| Business list | Passed `List<BusinessApplications>`; change refetches |
| Display name | Passed constructor arg |
| Module location | `lib/modules/projects/` |
| Navigation host | Independent page via `Get.to` / `Navigator.push` |

---

## 16. Implementation Notes for Existing App

- Existing `APIService.getBpmsStats` uses older `GetDashboardCount`. New module uses **`GetDashboardCountv1`** explicitly.
- Existing `lib/pages/bpms/` remains untouched for this delivery.
- Parent (e.g. `IntranetHomePage` menu) will open this page and pass args when ready — that wiring can be a follow-up outside the core module if desired.
