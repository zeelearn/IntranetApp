# Projects Configuration — Mass Project Reassignment Design

**Date:** 2026-09-08  
**Status:** Approved (pending user review of this file)  
**Module:** `lib/modules/projects`  
**Entry:** Projects sidebar → **Configuration** (Business Head only)

## Summary

Add a **Configuration** sidebar item visible only to **Business Head (`BH`)** users. Opening it shows a **Mass Project Reassignment** dual-panel page (mock-first) that lets a BH pick a source employee, select that employee’s projects, pick a target employee, preview assignments, and perform a mock mass reassignment.

## Goals

- Gate Configuration to `employeeType == BH` (Hive `KEY_EMP_TYPE`), same pattern as Visual Charts.
- Dual-panel UI matching the approved mock (source/projects | target/preview).
- Reuse `EmployeeInfo` and existing Projects module patterns (sidebar roles, GetX screen + binding + controller, dashboard colors).
- Mock data layer first; keep a clear seam for real APIs later.

## Non-goals

- Real reassignment / project-by-owner backend APIs (stub repository only).
- Linear multi-route 3-step wizard screens.
- Configuration settings beyond mass reassignment in this release.
- Non-BH roles seeing or deep-linking into the page (guard + hide menu).

## Access control

| Surface | Rule |
|--------|------|
| Sidebar **Configuration** | `ProjectsSidebarRoles.canShowConfiguration(employeeType)` → `true` only for `BH` |
| Screen open | If not BH, show message and pop / do not open |
| Dashboard controller | `showConfigurationMenu` reactive flag from `employeeType` |

Role check is case-insensitive (`bh` / `BH`).

## UX — dual panel

### Shell

- Title: **Mass Project Reassignment** (or **Project Reassignment**).
- Subtle 3-step indicator (visual only for v1): Select Source & Projects (active) · Select Destination & Confirm · Review & Submit.
- Responsive: side-by-side on wide; stacked on narrow.

### Left — Source & Projects

1. Searchable source employee field (typeahead over mock / optional `GetEmployees` list shaped as `EmployeeInfo`).
2. Source profile card (name, designation, department when available).
3. Mapped projects table:
   - Columns: checkbox, Project Name, Status, Team, Owner
   - Select All (N)
   - Multi-select rows
4. Loading / empty / error states consistent with other project lists.

### Right — Destination & Confirm

1. Searchable target employee field (`EmployeeInfo`).
2. Target profile card + availability badge (mock: Available).
3. Validation banner when source == target: *Source and target employee cannot be the same.*
4. **Assignments to create** list (selected projects → target).
5. Summary: *N projects selected • Will be reassigned from A → B.*

### Footer

- Queued assignment pairs count (support **Add Another Assignment Pair** — queues current pair and resets selection for another source→target batch in the same session).
- Primary: **Perform Mass Reassignment** (enabled when ≥1 valid queued or current selection with different source/target and ≥1 project).
- On success (mock): snackbar / dialog; clear selection and queue.

## Data model (mock-first)

### Reuse

- `EmployeeInfo` (`lib/api/response/employee_list_response.dart`) for employees.
- Existing `DashboardColors` / sidebar / list state widgets where practical.

### New (Projects module)

- `ReassignableProject` — id, name, status, teamMemberLabels/avatars (mock), ownerId, ownerName.
- `ReassignmentPair` — source `EmployeeInfo`, target `EmployeeInfo`, selected project ids/names.
- `ProjectReassignmentRepository` (interface) + `MockProjectReassignmentRepository`:
  - `listEmployees()`
  - `listProjectsForEmployee(employeeId|code)`
  - `submitMassReassignment(List<ReassignmentPair>)` → success result

Optional later: remote implementation calling real BPMS endpoints without changing UI.

## Architecture (files)

```
lib/modules/projects/
  utils/projects_sidebar_roles.dart          # + canShowConfiguration (BH)
  models/reassignable_project.dart
  models/reassignment_pair.dart
  repositories/project_reassignment_repository.dart
  services/mock_project_reassignment_service.dart
  controllers/project_configuration_controller.dart
  bindings/project_configuration_binding.dart
  views/project_configuration_screen.dart
  widgets/reassignment_*.dart                # employee picker, project table, preview
  widgets/projects_sidebar.dart              # Configuration item
  controllers/dashboard_controller.dart      # showConfigurationMenu
  views/projects_dashboard_page.dart         # wire tap → open screen
  projects.dart                              # exports
```

Tests:

- `projects_sidebar_roles_test.dart` — BH only for Configuration.
- Controller unit tests — same employee validation, select-all, queue pair, submit enabled rules.
- Mock repository smoke test.

## Validation rules

1. Source and target must both be selected.
2. Source employee code/id ≠ target.
3. At least one project selected for the current pair (or queue non-empty for submit).
4. Perform Mass Reassignment disabled until rules pass.

## Open points (accepted for v1)

- Stepper steps 2–3 are indicator-only; all work happens on the dual panel.
- Team avatars may be initials chips from mock names.
- Employee list may be fully mock; wiring `APIService.getEmployeeList()` is a fast follow if needed without changing UI contracts.

## Success criteria

- Non-BH users do not see **Configuration**.
- BH users open dual-panel reassignment UI from sidebar.
- Can select source, multi-select projects, select different target, preview, queue pairs, and mock-submit successfully.
- No production API dependency for reassignment submit in this release.
