# Projects Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver an offline-first GetX Projects Dashboard under `lib/modules/projects/` matching the approved Figma/spec, opened via constructor args + callbacks.

**Architecture:** Remote + Hive local services behind a repository; GetX controller drives Rx UI; responsive Material 3 widgets; no bottom nav; chart empty state; card taps fire callbacks.

**Tech Stack:** Flutter, GetX, Hive, http, equatable, fl_chart, shimmer, connectivity_plus

**Spec:** `docs/superpowers/specs/2026-07-13-projects-dashboard-design.md`

---

## File Map

| File | Responsibility |
|------|----------------|
| `lib/modules/projects/models/*` | DTOs + JSON parse |
| `lib/modules/projects/services/*` | HTTP + Hive |
| `lib/modules/projects/repositories/dashboard_repository.dart` | Offline-first orchestration |
| `lib/modules/projects/controllers/dashboard_controller.dart` | Rx state + actions |
| `lib/modules/projects/bindings/dashboard_binding.dart` | DI |
| `lib/modules/projects/widgets/*` | Reusable UI |
| `lib/modules/projects/views/projects_dashboard_page.dart` | Screen |
| `lib/modules/projects/routes/projects_routes.dart` | Optional constants |
| `test/modules/projects/*` | Parser + percentage tests |
| `pubspec.yaml` | Enable shimmer + connectivity_plus |

---

### Task 1: Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1:** Uncomment/add `shimmer: ^3.0.0` and add `connectivity_plus: ^6.1.0`
- [ ] **Step 2:** Run `flutter pub get`
- [ ] **Step 3:** Commit deps if requested later (batch with feature)

### Task 2: Models + Parser

**Files:**
- Create: `lib/modules/projects/models/project_status.dart`
- Create: `lib/modules/projects/models/dashboard_summary.dart`
- Create: `lib/modules/projects/models/dashboard_response.dart`
- Create: `lib/modules/projects/models/dashboard_card_model.dart`
- Create: `lib/modules/projects/models/quick_action_type.dart`
- Create: `lib/modules/projects/models/dashboard_colors.dart`
- Create: `lib/modules/projects/models/dashboard_failure.dart`
- Test: `test/modules/projects/dashboard_parser_test.dart`

- [ ] Implement Equatable models with fromJson/toJson/copyWith
- [ ] Nested string parse in `DashboardResponse.parseInnerSummary`
- [ ] Unit tests for valid/invalid JSON and percentages
- [ ] Run: `flutter test test/modules/projects/dashboard_parser_test.dart`

### Task 3: Services + Repository

**Files:**
- Create: `lib/modules/projects/services/dashboard_remote_service.dart`
- Create: `lib/modules/projects/services/dashboard_local_service.dart`
- Create: `lib/modules/projects/repositories/dashboard_repository.dart`

- [ ] Remote POST to `LocalStrings.bpms + '/api/bp/GetDashboardCountv1'`
- [ ] Hive box `projects_dashboard_box`, key `dashboard_{userId}_{businessId??all}`
- [ ] Repository: loadCache, sync, refresh with failure types

### Task 4: Controller + Binding

**Files:**
- Create: `lib/modules/projects/controllers/dashboard_controller.dart`
- Create: `lib/modules/projects/bindings/dashboard_binding.dart`
- Create: `lib/modules/projects/routes/projects_routes.dart`

- [ ] Controller: loadDashboard, refresh, sync, selectBusiness, connectivity, card builders, callbacks
- [ ] Binding injects args + services

### Task 5: Widgets + Page

**Files:**
- Create all widgets under `lib/modules/projects/widgets/`
- Create: `lib/modules/projects/views/projects_dashboard_page.dart`

- [ ] Header, filters, offline banner, grid (2/3/4 cols), chart empty, quick actions, shimmer, error, empty
- [ ] No setState; Obx only
- [ ] Match Figma colors from spec

### Task 6: Verify

- [ ] `flutter analyze lib/modules/projects`
- [ ] `flutter test test/modules/projects/`

---

## Execution Notes

- Reuse `BusinessApplications` from `package:Intranet/api/response/login_response.dart`
- Reuse header style from `APIService.getHeader`
- Do not modify other modules
- Synthetic task status IDs: 101, 102, 103
