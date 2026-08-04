# Employee Search Autocomplete Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Dashboard search opens employee autocomplete (`SearchDelegate`) using `getEmployeeList()`, with a detail screen on tap.

**Architecture:** Expand `EmployeeInfo` parsing → `EmployeeSearchDelegate` + `EmployeeDetailScreen` under `lib/pages/userinfo/` → wire `DashboardScreenV2Controller.onSearchTap`.

**Tech Stack:** Flutter, SearchDelegate, existing `APIService.getEmployeeList()`.

---

### Task 1: Expand EmployeeInfo + filter helper

**Files:**
- Modify: `lib/api/response/employee_list_response.dart`
- Create: `lib/pages/userinfo/employee_search_utils.dart`
- Test: `test/pages/userinfo/employee_search_utils_test.dart`

**Steps:** Parse optional fields (department, role, grade, location, zone, manager, DOB, etc.). Add `matchesQuery` / filter helper. Unit-test filter.

### Task 2: Detail screen

**Files:**
- Create: `lib/pages/userinfo/employee_detail_screen.dart`

**Steps:** Read-only labeled rows using DashV2 tokens; call action for phone.

### Task 3: SearchDelegate + wire dashboard

**Files:**
- Create: `lib/pages/userinfo/employee_search_delegate.dart`
- Modify: `lib/pages/home/v2/dashboard_screen_v2_controller.dart`

**Steps:** Load API once, show suggestions, navigate to detail. Replace `onSearchTap` coming-soon.
