# Projects GetBusiness Implementation Plan

> **For agentic workers:** Implement task-by-task. Steps use checkbox syntax.

**Goal:** Load Projects businesses from GetBusiness, map intranet selected name → Projects Business_Id, with Hive offline support — ProjectsDashboard only.

**Architecture:** Remote + local + repository for GetBusiness; name matcher util; DashboardController loads list before dashboard sync; selector uses Projects ids.

**Tech Stack:** Flutter, GetX, Hive, http, LocalStrings.bpms

## Global Constraints

- Name match: trim → lower → strip non-alphanumeric → strip leading `e` if length > 1
- Projects-only; do not change intranet KEY_BUSINESS_* for other modules
- Path: `/api/bp//GetBusiness` on LocalStrings.bpms

---

### Task 1: Model + name matcher + unit tests

- [x] Add `lib/modules/projects/models/project_business.dart`
- [x] Add `lib/modules/projects/utils/business_name_matcher.dart`
- [x] Add `test/modules/projects/business_name_matcher_test.dart` + model parse test
- [x] Run tests

### Task 2: Remote / local / repository

- [x] `project_business_remote_service.dart`
- [x] `project_business_local_service.dart`
- [x] `project_business_repository.dart` (sync + offline)

### Task 3: Wire DashboardController + binding + UI

- [x] Inject repository; load businesses onInit; map selection; RxList businesses
- [x] Header/page use controller.businesses for selector + project list open
- [x] Binding registers new services

### Task 4: Verify

- [x] `flutter test test/modules/projects/business_name_matcher_test.dart` (+ related)
- [x] Analyze changed files
