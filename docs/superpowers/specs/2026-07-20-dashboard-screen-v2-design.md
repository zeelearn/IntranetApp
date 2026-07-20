# Dashboard Screen V2 — Design Spec

**Date:** 2026-07-20  
**Status:** Approved for implementation planning  
**Scope:** New home shell under `lib/pages/home/v2/` + entry-route wiring  
**Approach:** Fresh GetX module (Approach 1)  
**Constraint:** Do **not** modify `lib/pages/home/IntranetHomePage.dart`

---

## 1. Goals

Build a production-ready **Dashboard Screen V2** that:

- Exact-matches the attached Figma for **mobile** and **website/desktop**
- Replaces `IntranetHomePage` as the post-login home entry
- Ports **all live functionality** from `IntranetHomePage` + `HomePageMenu` into a GetX-driven screen
- Uses `GetxController` as the single source of UI state and actions (IIT-standard GetX style)
- Keeps existing menu destinations and business guards working
- Leaves `IntranetHomePage` untouched as legacy

---

## 2. Non-Goals

- Editing `IntranetHomePage.dart` or `home_page_menus.dart`
- Wiring real APIs for KPI counts, project-status chart, recent activity, or reminders (placeholders only in v1)
- Showing Figma-only menu items that have no live destination today (Payments, Team, Vendors, Budget vs Actual, Documents, Advance/Settlement, etc.)
- Reworking or deleting `dashboardv2.dart` mock (leave as-is; new work lives in `dashboard_screenv2`)
- Implementing global search behavior beyond UI chrome (search is display/no-op snackbar until an API exists)
- Feature-flag dual home (v2 becomes the live entry immediately)

---

## 3. Decisions (from brainstorming)

| Topic | Decision |
|---|---|
| Scope | Full shell + home (drawer/sidebar, app bar, business switch, Firebase/notifications, password, deep links, dashboard UI) |
| Menus | Existing live menus only, restyled to Figma |
| KPI / chart / activity / reminders | UI placeholders matching Figma labels/values |
| Entry routes | Switch splash/login/magic-link (and other `IntranetHomePage` callers) to v2 now |
| Architecture | Fresh v2 module with controller + widgets; do not retrofit `dashboardv2.dart` |

---

## 4. Entry Contract

### Widget

```dart
DashboardScreenV2({
  required String userId,
  ReceivedAction? receivedAction, // optional; same deep-link/notification handoff as today
  Key? key,
})
```

### Binding / controller

```dart
Get.put(DashboardScreenV2Controller(userId: userId, receivedAction: receivedAction));
// or Binding class if preferred for consistency with projects module
```

### Entry wiring (must update)

Replace `IntranetHomePage(userId: ...)` with `DashboardScreenV2(userId: ...)` in:

- `lib/pages/intro/splash.dart`
- `lib/pages/auth/login.dart`
- `lib/pages/auth/magic_link_handler.dart`
- `lib/pages/login/components/login_form.dart`
- Other call sites that currently push `IntranetHomePage` (e.g. PJP form back-home navigations)

Pass through the same constructor args (`userId`, `receivedAction` when present).

---

## 5. Folder Structure

```
lib/pages/home/v2/
  dashboard_screenv2.dart                 # Scaffold + responsive shell
  dashboard_screen_v2_controller.dart     # GetxController
  widgets/
    dash_v2_tokens.dart                   # colors, text styles, radii, shadows
    dash_welcome_banner.dart
    dash_kpi_row.dart                     # mobile KPI strip + web KPI cards
    dash_quick_access_card.dart
    dash_quick_access_grid.dart
    dash_sidebar.dart                     # web sidebar + shared nav model for drawer
    dash_mobile_app_bar.dart
    dash_web_top_bar.dart
    dash_project_status_card.dart         # placeholder donut
    dash_recent_activity_card.dart        # placeholder list
    dash_upcoming_reminders_card.dart     # placeholder list
```

Optional: a thin `dashboard_screen_v2_binding.dart` if the team prefers explicit GetX bindings.

---

## 6. Responsive Layout

**Breakpoint:** `maxWidth >= 1000` → web layout; otherwise mobile layout.

### Mobile (Figma 1)

1. Deep-blue AppBar: menu, user name + business subtitle (tap → business picker), search, notifications (badge placeholder)
2. Welcome banner with greeting + subtitle + illustration
3. Four KPI stats in one row (placeholders): My PJP, My CVF, Pending, Approved
4. Two-column feature card grid (live menus only)
5. Footer: `Intranet_{appVersion}`

Drawer content = same nav model as web sidebar (live destinations + logout).

### Web (Figma 2)

1. Persistent left sidebar (collapsible): logo, nav items, optional Need Help / Contact Support footer card
2. Top bar: sidebar toggle, search field, notifications, profile (name + designation)
3. Greeting + date-range chip (display-only) + “+ New Project” → Projects flow
4. Four KPI cards with progress bars (placeholder %)
5. Quick Access section (live menus; Customize = snackbar/no-op)
6. Bottom row: Project Status / Recent Activity / Upcoming Reminders (placeholders)
7. Footer version string

---

## 7. Live Menu Set (source of truth)

Quick Access / feature cards come from **current live** `HomePageMenu` behavior:

| Key | Label | Destination | Guard |
|---|---|---|---|
| `projects` | Projects | `ProjectsDashboardPage` via `ProjectsEntryArgs` | — |
| `my_pjp` | My PJP | `MyPjpListScreen` | business mapped |
| `my_cvf` | My CVF | `MyCVFListScreenV2` | business mapped |
| `my_report` | My Report | `MyReportsScreen` | — |
| `pjp_cvf_approval_exp` | PJP-CVF Approval (Exp) | `PJPManagerExceptionalScreen` | business mapped; BPMS users also see this |
| `bpms` | BPMS | `BPMSDashboard` | franchisee id in Hive; shown when `isBpms` |
| `zll_saathi` | ZllSaathi | `ZllSaathi(...)` | business mapped |
| `expenses` | Expenses / Expense | expense tracker embed | — |
| `contracts` | Contracts | `AllLegalStatusPage` | — |
| `pjp_dashboard` | PJP Dashboard | `SummaryDashboard` | business mapped |
| `notiflow` | Notiflow | `MyWebsiteView` | emp code allow-list |

Sidebar / drawer also includes active drawer items from today:

| Key | Label | Behavior |
|---|---|---|
| `dashboard` | Dashboard / Home | Stay on dashboard (selected) |
| `pjp` | PJP | Same as My PJP |
| `cvf` | CVF | Same as My CVF |
| `projects_nav` | Projects (drawer title currently uses username in legacy; v2 uses “Projects”) | Same as Projects |
| `approvals_pjp` | Approvals → PJP | `PJPManagerScreen` |
| `logout` | Log Out | Clear session → login |

Commented-out legacy attendance/leave/outdoor drawer items are **not** revived unless they become live again.

Figma-only extras without live screens are **omitted**.

---

## 8. Controller Responsibilities

`DashboardScreenV2Controller extends GetxController`

### Init sequence

1. Load Hive user profile (employee id/code, name, designation, email, gender defaults, avatar, business id/name, password-expired flag, franchisee/BPMS)
2. Decode `KEY_LOGIN_RESPONSE` → `businessApplications`
3. Ensure `DashboardPageController` / `DashboardBinding` registered (expenses advance limit)
4. Init Firebase messaging + deep-link / URI handlers (parity with current home)
5. Load package version; Android in-app update check
6. Seed placeholder KPI / chart / activity / reminder models
7. If password expired → show update-password dialog

### Reactive fields

- Identity: `userFullName`, `firstName`, `userName`, `employeeId`, `employeeCode`, `designation`, `email`
- Business: `businessId`, `businessName`, `businessApplications`, `isBpms`
- Profile: `profileImageUrl`, `profileAvatarBytes`
- Shell: `appVersion`, `sidebarExpanded`, `selectedNav`, `notificationCount` (placeholder), `isLoading`
- Placeholders: `kpiStats`, `projectStatusSegments`, `recentActivities`, `upcomingReminders`

### Actions (parity list)

- `selectBusiness` / show business picker dialog
- `openProjects`, `openMyPjp`, `openMyCvf`, `openMyReport`, `openPjpCvfApprovalExp`, `openBpms`, `openZllSaathi`, `openExpenses`, `openContracts`, `openPjpDashboard`, `openNotiflow`, `openPjpApprovals`
- `openNewProject` (same as Projects)
- `validateBusiness(menuKey)` → message if `businessId == 0` for guarded menus
- `uploadProfilePicture` / profile view / Firebase upload callbacks
- `updatePassword` flow (same API path as current dialog)
- `signOut`
- `onBackPressed` / `PopScope` handling
- Deep-link / notification open handlers

UI widgets call controller methods only; no business logic in widgets.

---

## 9. Placeholder Data (v1)

Use Figma-like static values so the UI looks complete:

- KPIs: My PJP `24`, My CVF `12`, Pending `05`, Approved `18` (with matching progress % on web)
- Project Status: Confirmed / Pending / Rejected / Refund / Not Interested segments as in Figma
- Recent Activity: 4–5 sample rows with relative times
- Upcoming Reminders: 3–4 sample events
- Notification badge: `3`

Document clearly in code that these are temporary until APIs exist. Do not invent fake repository calls.

---

## 10. Visual Tokens

Extract from Figma / attached screenshots:

- Scaffold background: light gray/off-white (~`#F4F6FB`)
- Cards: white, radius ~12–16, soft shadow
- Primary blue for AppBar / active nav / primary buttons
- Accent set for icons: blue, green, orange, purple, pink, teal, yellow
- Typography: Poppins / existing Google Fonts used in app (consistent with nearby v2 screens)

Preserve Material feel; do not introduce a new unrelated theme system beyond local tokens.

---

## 11. Error Handling & Lifecycle

- Business not mapped → existing `Utility.showMessage` text
- Loaders for password update / avatar upload / login refresh (same UX)
- Snackbars for recoverable failures
- `PopScope(canPop: false)` with back-to-home / exit confirm parity
- Dispose observers / stream subscriptions in `onClose`
- Keep `IntranetHomePage` available in codebase but unused by default entry paths

---

## 12. Testing / Verification

Manual checklist:

1. Cold start → splash → `DashboardScreenV2` (logged in)
2. Login → lands on v2
3. Mobile width: AppBar, banner, KPI row, 2-col cards, drawer, footer
4. Desktop width: sidebar, top bar, KPI cards, quick access, bottom placeholder panels
5. Each live menu card / sidebar item opens the correct screen
6. Business switch updates subtitle and Hive; guarded menus still validate
7. Logout returns to login
8. Password-expired user sees update dialog
9. Notification / deep-link handoff does not crash (parity paths)
10. `IntranetHomePage.dart` git diff is empty (unchanged)

---

## 13. Out of Scope Follow-ups

- Real KPI / activity / reminder / chart APIs
- Search implementation
- Customize Quick Access persistence
- Contact Support destination if no existing screen (optional mailto stub only)
- Removing or archiving `IntranetHomePage` / `dashboardv2.dart`
