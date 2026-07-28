# Projects Module — Unit Testing Report

**Date:** 20 July 2026  
**Module:** Projects (`lib/modules/projects`)  
**Audience:** Product / QA / Development  

**HTML report (Material UI):** [2026-07-20-projects-unit-testing-report.html](./2026-07-20-projects-unit-testing-report.html)

---

## Verdict

| | |
|---|---|
| **Status** | Passed |
| **Result** | 60 of 60 tests passed |
| **Failed** | 0 |
| **App code changed?** | No — only test files were added |

The Projects module’s core business rules and data parsing are covered by automated unit tests, and the latest run completed successfully.

---

## What this report means

Unit tests check small pieces of logic **without opening the app** and **without calling live servers**.  
They answer questions like:

- Does the app correctly understand API data?
- Are task roots and subtasks grouped the right way?
- Are dates, amounts, and email bodies formatted correctly?
- Are create/edit task payloads built with the expected fields?

They do **not** replace manual testing of screens, login, or real API calls.

---

## Snapshot

| Metric | Value |
|--------|--------|
| Test files | 15 |
| Individual tests | 60 |
| Pass rate | 100% |
| Network required | No |
| Where tests live | `test/modules/projects/` |

---

## What was tested (in plain language)

### Dashboard
- Reading project and task counts from the dashboard API response  
- Mapping card statuses (Pending / In Progress / Completed) correctly  
- Deciding when a “missed deadline” highlight should apply  

### Project list & filters
- Understanding a project row from the API  
- Knowing when filters are active or cleared  

### Task hierarchy
- Showing only top-level tasks where parent is `0`  
- Nesting children under the correct parent  
- Parsing task fields (dates, status, creator, etc.)  

### Add / Edit task
- Detecting create vs edit mode  
- Building the correct request body for add and update APIs  
- Status and priority labels  

### Task comments & attachments
- Merging comments and files into a chat-style timeline (oldest → newest)  
- Attachment open URL (remote vs local file)  
- Upload source available for retry  

### Project details
- Franchisee details, indents, documents  
- Communication emails: HTML detection, preview text, escaped HTML  

### Helpers
- Date formatting and “missed deadline” checks  
- Amount formatting (₹)  
- Attachment file name and extension  

---

## What was not tested yet

These areas need a different style of test (mocks, UI, or device):

| Area | Why it’s out of this suite |
|------|----------------------------|
| Screen UI (buttons, layouts) | Needs widget / UI tests |
| Controllers (load, refresh, save flows) | Needs fake repositories |
| Live API / upload to cloud | Needs network or integration tests |
| Offline Hive cache | Needs local database test setup |

Recommended next phase: controller + repository tests with mocks, then UI smoke tests for critical screens.

---

## How to run the tests

From the project root:

```bash
flutter test test/modules/projects/
```

Run one file only:

```bash
flutter test test/modules/projects/task_hierarchy_test.dart
```

In Cursor / VS Code: open any file under `test/modules/projects/` and click **Run** above `main` or a single test.

---

## Test files included

| File | What it checks |
|------|----------------|
| `dashboard_parser_test.dart` | Dashboard numbers and cards |
| `dashboard_status_ids_test.dart` | Status mapping & missed deadline rules |
| `project_item_test.dart` | Project list row data |
| `project_list_filter_test.dart` | Filter on/off behaviour |
| `project_status_test.dart` | Status count objects |
| `project_detail_test.dart` | Project details API data |
| `project_email_and_utils_test.dart` | Email body, dates, amounts, file names |
| `project_date_utils_test.dart` | Date helpers |
| `task_hierarchy_test.dart` | Root/subtask tree rules |
| `task_summary_test.dart` | Task count string (`C-`, `IP-`, `P-`) |
| `task_comments_payload_test.dart` | Comments timeline order |
| `task_comment_model_test.dart` | Comment & attachment models |
| `user_task_item_test.dart` | User task list items |
| `add_task_request_test.dart` | Add/Update API payload |
| `add_task_args_test.dart` | Create vs Edit mode |

---

## Conclusion

The Projects module unit test suite is **healthy and fully passing (60/60)**.  
Production app code was **not modified** for this work.  

This gives confidence that core parsing and business rules stay correct as the module evolves. Manual and integration testing of screens and live APIs should continue as usual.

---

## Full test case list (pass flag)

`passed = true` means the test succeeded in the last full suite run (`flutter test test/modules/projects/`).

| # | File | Test case | Passed |
|---|------|-----------|--------|
| 1 | `add_task_args_test.dart` | AddTaskArgs: isEditMode false for create | true |
| 2 | `add_task_args_test.dart` | AddTaskArgs: isEditMode true when taskId > 0 | true |
| 3 | `add_task_args_test.dart` | AddTaskArgs: isEditMode true when seedTask present | true |
| 4 | `add_task_args_test.dart` | TaskFormStatusOption: labelForId covers known statuses | true |
| 5 | `add_task_args_test.dart` | TaskFormPriority: exposes standard priorities | true |
| 6 | `add_task_request_test.dart` | AddTaskRequest: serializes API payload keys | true |
| 7 | `add_task_request_test.dart` | UpdateTaskStatusRequest: serializes UpdateTaskStatus payload | true |
| 8 | `add_task_request_test.dart` | TaskFormStatusOption: maps id to UpdateTaskStatus label | true |
| 9 | `add_task_request_test.dart` | ProjectDateUtils.formatApi: formats yyyy-MM-dd | true |
| 10 | `dashboard_parser_test.dart` | DashboardResponse.parseInnerSummary: parses nested JSON string list | true |
| 11 | `dashboard_parser_test.dart` | DashboardResponse.parseInnerSummary: throws invalidJson on malformed inner string | true |
| 12 | `dashboard_parser_test.dart` | DashboardResponse.parseInnerSummary: throws empty when data list is empty | true |
| 13 | `dashboard_parser_test.dart` | DashboardCardModel.fromSummary: calculates percentages with zero-safe totals | true |
| 14 | `dashboard_parser_test.dart` | DashboardCardModel.fromSummary: maps pending and confirmed counts | true |
| 15 | `dashboard_status_ids_test.dart` | DashboardStatusIds: maps task card ids to GettaskbyUser Status | true |
| 16 | `dashboard_status_ids_test.dart` | DashboardStatusIds: showsMissedDeadline only for pending project/task | true |
| 17 | `dashboard_status_ids_test.dart` | DashboardStatusIds: isTaskCard detects task status ids | true |
| 18 | `dashboard_status_ids_test.dart` | DashboardFailure: toString includes type and message | true |
| 19 | `project_date_utils_test.dart` | ProjectDateUtils: formats dd-MM-yyyy | true |
| 20 | `project_date_utils_test.dart` | ProjectDateUtils: detects missed deadline | true |
| 21 | `project_detail_test.dart` | ProjectDetailData: parses GetFranchiseeDetailInfoV1 envelope | true |
| 22 | `project_detail_test.dart` | ProjectDetailData: isStaleForToday when synced yesterday | true |
| 23 | `project_email_and_utils_test.dart` | ProjectCommunicationItem email parsing: detects HTML body | true |
| 24 | `project_email_and_utils_test.dart` | ProjectCommunicationItem email parsing: unescapes entity-encoded HTML | true |
| 25 | `project_email_and_utils_test.dart` | ProjectCommunicationItem email parsing: bodyPreview truncates long plain text | true |
| 26 | `project_email_and_utils_test.dart` | ProjectCommunicationItem email parsing: plain text body is not treated as HTML | true |
| 27 | `project_email_and_utils_test.dart` | ProjectDateUtils extended: formatApi uses yyyy-MM-dd | true |
| 28 | `project_email_and_utils_test.dart` | ProjectDateUtils extended: formatAmount uses Indian grouping | true |
| 29 | `project_email_and_utils_test.dart` | ProjectDateUtils extended: tryParse supports ISO and dd-MM-yyyy | true |
| 30 | `project_email_and_utils_test.dart` | ProjectDateUtils extended: formatReadableDateTime appends time hint | true |
| 31 | `project_email_and_utils_test.dart` | TaskAttachmentList helpers: fileName extracts last path segment | true |
| 32 | `project_email_and_utils_test.dart` | TaskAttachmentList helpers: extensionOf is lowercase without dot | true |
| 33 | `project_item_test.dart` | ProjectItem: fromJson maps GetAllProjectList_new fields | true |
| 34 | `project_item_test.dart` | ProjectItem: fromJson falls back project_id when CRM_id missing | true |
| 35 | `project_item_test.dart` | ProjectItem: toJson / copyWith round-trip key fields | true |
| 36 | `project_list_filter_test.dart` | ProjectListFilter: empty has no active filters | true |
| 37 | `project_list_filter_test.dart` | ProjectListFilter: hasActiveFilters when any field set | true |
| 38 | `project_list_filter_test.dart` | ProjectListFilter: copyWith updates and clear flags | true |
| 39 | `project_list_filter_test.dart` | ProjectListFilter: equality via Equatable | true |
| 40 | `project_status_test.dart` | ProjectStatus: fromJson maps status_id and c | true |
| 41 | `project_status_test.dart` | ProjectStatus: fromJson coerces string numbers | true |
| 42 | `project_status_test.dart` | ProjectStatus: toJson / copyWith | true |
| 43 | `task_comment_model_test.dart` | TaskCommentAttachment: openUrl prefers remote url over localPath | true |
| 44 | `task_comment_model_test.dart` | TaskCommentAttachment: openUrl falls back to localPath | true |
| 45 | `task_comment_model_test.dart` | TaskCommentAttachment: hasUploadSource for bytes or localPath | true |
| 46 | `task_comment_model_test.dart` | TaskComment: initials from senderName | true |
| 47 | `task_comment_model_test.dart` | TaskComment: copyWith updates deliveryStatus | true |
| 48 | `task_comment_model_test.dart` | TaskCommentsArgs: props include task id and userId | true |
| 49 | `task_comments_payload_test.dart` | TaskCommentsPayload: merges comments and files oldest first; isMine by CreatedBy | true |
| 50 | `task_hierarchy_test.dart` | TaskRepository.buildChildrenMap: maps roots and children | true |
| 51 | `task_hierarchy_test.dart` | TaskRepository.buildChildrenMap: only exact parent_task_id 0 is root; children stay nested | true |
| 52 | `task_hierarchy_test.dart` | HierarchyTaskResponse: flattens nested data lists | true |
| 53 | `task_hierarchy_test.dart` | HierarchyTask parent dates: parses parant_date and parant_plandate pairs | true |
| 54 | `task_hierarchy_test.dart` | Create/Update API response parsing: maps AddNewTask data item into HierarchyTask | true |
| 55 | `task_summary_test.dart` | TaskSummary.parse: parses C-IP-P format | true |
| 56 | `task_summary_test.dart` | TaskSummary.parse: parses BPC | true |
| 57 | `task_summary_test.dart` | TaskSummary.parse: handles empty and invalid | true |
| 58 | `user_task_item_test.dart` | UserTaskItem: fromJson maps GettaskbyUser fields | true |
| 59 | `user_task_item_test.dart` | UserTaskItem: toProjectItem uses franchisee / project ids | true |
| 60 | `user_task_item_test.dart` | UserTaskItem: toJson round-trips core keys | true |

**Totals:** 60 tests · passed=`true` for all · failed=`false` count = 0
