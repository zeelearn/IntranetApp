# Projects Configuration — Mass Reassignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a BH-only **Configuration** sidebar item that opens a mock-first dual-panel **Mass Project Reassignment** page in `lib/modules/projects`.

**Architecture:** Extend `ProjectsSidebarRoles` + dashboard sidebar wiring → mock reassignment repository → GetX controller/binding/screen with reusable widgets. UI uses existing `EmployeeInfo` shape and Projects visual tokens (`DashboardColors`).

**Tech Stack:** Flutter, GetX, existing `EmployeeInfo`, unit tests via `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-09-08-projects-configuration-reassignment-design.md`

## Global Constraints

- Configuration menu and screen: **BH only** (case-insensitive `KEY_EMP_TYPE`).
- Dual-panel layout (stacked on narrow); 3-step indicator is visual-only.
- Mock repository for employees/projects/submit; no real reassignment API in this plan.
- Reuse `EmployeeInfo`; do not fork a parallel employee model.
- Follow Visual Charts patterns for `open` / `Binding.makeTag` / exports in `projects.dart`.

---

## File map

| File | Responsibility |
|------|----------------|
| `utils/projects_sidebar_roles.dart` | `canShowConfiguration` |
| `models/reassignable_project.dart` | Project row for table |
| `models/reassignment_pair.dart` | Queued source→target+projects |
| `repositories/project_reassignment_repository.dart` | Abstract API |
| `services/mock_project_reassignment_service.dart` | In-memory mock data |
| `controllers/project_configuration_controller.dart` | Wizard state |
| `bindings/project_configuration_binding.dart` | DI |
| `views/project_configuration_screen.dart` | Dual-panel page |
| `widgets/reassignment_employee_picker.dart` | Searchable employee field + card |
| `widgets/reassignment_projects_table.dart` | Select-all + checkboxes |
| `widgets/reassignment_preview_panel.dart` | Target side preview |
| `widgets/projects_sidebar.dart` | Configuration menu item |
| `controllers/dashboard_controller.dart` | `showConfigurationMenu` |
| `views/projects_dashboard_page.dart` | Open Configuration |
| `projects.dart` | Exports |
| Tests under `test/modules/projects/` | Roles + controller + mock |

---

### Task 1: BH-only sidebar role gate

**Files:**
- Modify: `lib/modules/projects/utils/projects_sidebar_roles.dart`
- Modify: `test/modules/projects/projects_sidebar_roles_test.dart`

**Interfaces:**
- Produces: `ProjectsSidebarRoles.canShowConfiguration(String? employeeType) → bool` (true only for `BH`)

- [ ] **Step 1: Write the failing test**

```dart
test('allows Configuration for BH only', () {
  expect(ProjectsSidebarRoles.canShowConfiguration('BH'), isTrue);
  expect(ProjectsSidebarRoles.canShowConfiguration('bh'), isTrue);
  expect(ProjectsSidebarRoles.canShowConfiguration('MAN'), isFalse);
  expect(ProjectsSidebarRoles.canShowConfiguration('ZM'), isFalse);
  expect(ProjectsSidebarRoles.canShowConfiguration('EMP'), isFalse);
  expect(ProjectsSidebarRoles.canShowConfiguration(''), isFalse);
  expect(ProjectsSidebarRoles.canShowConfiguration(null), isFalse);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/modules/projects/projects_sidebar_roles_test.dart`

Expected: FAIL — `canShowConfiguration` not defined

- [ ] **Step 3: Implement**

```dart
static const configurationRoles = {'BH'};

static bool canShowConfiguration(String? employeeType) {
  return configurationRoles.contains(normalize(employeeType));
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/modules/projects/projects_sidebar_roles_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/modules/projects/utils/projects_sidebar_roles.dart test/modules/projects/projects_sidebar_roles_test.dart
git commit -m "feat(projects): gate Configuration sidebar to BH role"
```

---

### Task 2: Models + mock repository

**Files:**
- Create: `lib/modules/projects/models/reassignable_project.dart`
- Create: `lib/modules/projects/models/reassignment_pair.dart`
- Create: `lib/modules/projects/repositories/project_reassignment_repository.dart`
- Create: `lib/modules/projects/services/mock_project_reassignment_service.dart`
- Test: `test/modules/projects/project_reassignment_mock_test.dart`

**Interfaces:**
- Produces:
  - `class ReassignableProject { id, name, status, teamLabels, ownerId, ownerName }`
  - `class ReassignmentPair { source, target, projects }`
  - `abstract class ProjectReassignmentRepository { Future<List<EmployeeInfo>> listEmployees(); Future<List<ReassignableProject>> listProjectsForEmployee(String employeeKey); Future<void> submitMassReassignment(List<ReassignmentPair> pairs); }`
  - `class MockProjectReassignmentRepository implements ProjectReassignmentRepository`

- [ ] **Step 1: Write failing mock test**

```dart
test('mock lists employees and projects for a source', () async {
  final repo = MockProjectReassignmentRepository();
  final employees = await repo.listEmployees();
  expect(employees.length, greaterThanOrEqualTo(2));
  final projects = await repo.listProjectsForEmployee(employees.first.employeeCode);
  expect(projects, isNotEmpty);
  await repo.submitMassReassignment([]);
});
```

- [ ] **Step 2: Run test — expect FAIL (types missing)**

Run: `flutter test test/modules/projects/project_reassignment_mock_test.dart`

- [ ] **Step 3: Implement models + mock**

`ReassignableProject`:

```dart
class ReassignableProject {
  const ReassignableProject({
    required this.id,
    required this.name,
    required this.status,
    required this.teamLabels,
    required this.ownerId,
    required this.ownerName,
  });
  final String id;
  final String name;
  final String status; // Active | In Progress | Pending
  final List<String> teamLabels;
  final String ownerId;
  final String ownerName;
}
```

`ReassignmentPair`:

```dart
class ReassignmentPair {
  const ReassignmentPair({
    required this.source,
    required this.target,
    required this.projects,
  });
  final EmployeeInfo source;
  final EmployeeInfo target;
  final List<ReassignableProject> projects;
}
```

Mock: seed ≥3 employees (e.g. Amit Verma, Neha Kapoor, Rohit Sharma) as `EmployeeInfo`, and ≥6 projects mapped to Amit’s code. `listProjectsForEmployee` filters by `ownerId`/`employeeCode`. `submitMassReassignment` completes after a short delay (no throw).

- [ ] **Step 4: Run test — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add lib/modules/projects/models/reassignable_project.dart \
  lib/modules/projects/models/reassignment_pair.dart \
  lib/modules/projects/repositories/project_reassignment_repository.dart \
  lib/modules/projects/services/mock_project_reassignment_service.dart \
  test/modules/projects/project_reassignment_mock_test.dart
git commit -m "feat(projects): add mock mass-reassignment models and repository"
```

---

### Task 3: Configuration controller (validation + queue)

**Files:**
- Create: `lib/modules/projects/controllers/project_configuration_controller.dart`
- Create: `lib/modules/projects/bindings/project_configuration_binding.dart`
- Test: `test/modules/projects/project_configuration_controller_test.dart`

**Interfaces:**
- Consumes: `ProjectReassignmentRepository`
- Produces controller API:
  - `employees`, `sourceProjects`, `selectedProjectIds`
  - `sourceEmployee`, `targetEmployee`
  - `queuedPairs`
  - `sourceQuery` / `targetQuery` filter helpers
  - `bool get canQueueCurrentPair`
  - `bool get canSubmit`
  - `String? get sameEmployeeError` → non-null when source==target
  - `selectSource`, `selectTarget`, `toggleProject`, `selectAllProjects`
  - `queueCurrentPair()`, `submit()`, `load()`

- [ ] **Step 1: Write failing controller tests**

```dart
test('blocks queue when source equals target', () async {
  final c = ProjectConfigurationController(repository: MockProjectReassignmentRepository());
  await c.load();
  final a = c.employees.first;
  c.selectSource(a);
  c.selectTarget(a);
  expect(c.sameEmployeeError, isNotNull);
  expect(c.canQueueCurrentPair, isFalse);
});

test('queues pair and enables submit', () async {
  final c = ProjectConfigurationController(repository: MockProjectReassignmentRepository());
  await c.load();
  final source = c.employees[0];
  final target = c.employees[1];
  c.selectSource(source);
  await c.loadProjectsForSource();
  c.selectAllProjects();
  c.selectTarget(target);
  expect(c.canQueueCurrentPair, isTrue);
  c.queueCurrentPair();
  expect(c.queuedPairs.length, 1);
  expect(c.canSubmit, isTrue);
});
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `flutter test test/modules/projects/project_configuration_controller_test.dart`

- [ ] **Step 3: Implement controller + binding**

Binding mirrors Visual Charts (`makeTag(userId)`, put repository + controller).

Controller rules:
- Same employee → `sameEmployeeError = 'Source and target employee cannot be the same.'`
- `canQueueCurrentPair` requires source, target, different keys, ≥1 selected project
- `queueCurrentPair` appends `ReassignmentPair`, clears current selection
- `submit` calls repository with `queuedPairs` (or current pair if queue empty but valid), then clears

Employee key: prefer `employeeCode`, fallback `employeeId`.

- [ ] **Step 4: Run tests — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add lib/modules/projects/controllers/project_configuration_controller.dart \
  lib/modules/projects/bindings/project_configuration_binding.dart \
  test/modules/projects/project_configuration_controller_test.dart
git commit -m "feat(projects): add configuration reassignment controller"
```

---

### Task 4: Dual-panel UI screen + widgets

**Files:**
- Create: `lib/modules/projects/views/project_configuration_screen.dart`
- Create: `lib/modules/projects/widgets/reassignment_employee_picker.dart`
- Create: `lib/modules/projects/widgets/reassignment_projects_table.dart`
- Create: `lib/modules/projects/widgets/reassignment_preview_panel.dart`

**Interfaces:**
- Consumes: `ProjectConfigurationController`
- Produces: `ProjectConfigurationScreen.open({required int userId})` and `openFromHive()` (reject non-BH)

- [ ] **Step 1: Implement employee picker widget**

Search field filters `employees` by name/code/designation. On select, show profile card (avatar initials, name, designation • department).

- [ ] **Step 2: Implement projects table**

Header with Select All (N). Rows: checkbox, name, status chip (Active green / In Progress blue / Pending yellow), team chips, owner name. Bind to `selectedProjectIds`.

- [ ] **Step 3: Implement preview panel**

Target picker + card, red banner when `sameEmployeeError != null`, list of assignments to create, summary text.

- [ ] **Step 4: Implement screen shell**

`Scaffold` + AppBar title **Mass Project Reassignment**. Visual stepper (3 circles). Body: `LayoutBuilder` — if width ≥ 900, `Row` of two Expanded cards; else `Column` scroll. Footer bar: queued count, outlined **Add Another Assignment Pair**, filled **Perform Mass Reassignment**.

Use `DashboardColors` / Google Fonts consistent with Visual Charts.

`openFromHive`: read `KEY_EMP_TYPE` / `KEY_EMPLOYEE_ID`; if not BH, `Get.snackbar` and return null.

- [ ] **Step 5: Manual smoke (or widget test optional)**

Run app as BH → open Configuration → select source/target/projects → queue → submit mock success.

- [ ] **Step 6: Commit**

```bash
git add lib/modules/projects/views/project_configuration_screen.dart \
  lib/modules/projects/widgets/reassignment_employee_picker.dart \
  lib/modules/projects/widgets/reassignment_projects_table.dart \
  lib/modules/projects/widgets/reassignment_preview_panel.dart
git commit -m "feat(projects): add mass reassignment configuration UI"
```

---

### Task 5: Sidebar + dashboard wiring + exports

**Files:**
- Modify: `lib/modules/projects/widgets/projects_sidebar.dart`
- Modify: `lib/modules/projects/controllers/dashboard_controller.dart`
- Modify: `lib/modules/projects/views/projects_dashboard_page.dart`
- Modify: `lib/modules/projects/projects.dart`

**Interfaces:**
- Consumes: `canShowConfiguration`, `ProjectConfigurationScreen.openFromHive`
- Produces: sidebar **Configuration** under section **Admin** (or **Configuration**), visible when `showConfigurationMenu`

- [ ] **Step 1: Extend `ProjectsSidebar`**

Add params:

```dart
final bool showConfiguration;
final VoidCallback onConfigurationTap;
```

Default `showConfiguration = false`. When true, render section:

```dart
_SectionHeader(icon: Icons.settings_outlined, title: 'Configuration'),
_SubMenuItem(label: 'Project Reassignment', onTap: onConfigurationTap),
```

(Label in sidebar can be **Configuration** or **Project Reassignment** — use **Configuration** as the section/item per product request.)

Use item label: **Configuration**.

- [ ] **Step 2: Dashboard controller**

```dart
final RxBool showConfigurationMenu = false.obs;

void _applySidebarMenuVisibility(String role) {
  // existing...
  showConfigurationMenu.value =
      ProjectsSidebarRoles.canShowConfiguration(role);
}
```

- [ ] **Step 3: Dashboard page**

Pass `showConfiguration: controller.showConfigurationMenu.value` in both sidebar instances. `onConfigurationTap: _openConfiguration`.

```dart
Future<void> _openConfiguration() async {
  if (!controller.showConfigurationMenu.value) return;
  await ProjectConfigurationScreen.openFromHive();
}
```

- [ ] **Step 4: Export new public types from `projects.dart`**

- [ ] **Step 5: Run role + controller tests**

Run:

```bash
flutter test test/modules/projects/projects_sidebar_roles_test.dart \
  test/modules/projects/project_reassignment_mock_test.dart \
  test/modules/projects/project_configuration_controller_test.dart
```

Expected: all PASS

- [ ] **Step 6: Commit**

```bash
git add lib/modules/projects/widgets/projects_sidebar.dart \
  lib/modules/projects/controllers/dashboard_controller.dart \
  lib/modules/projects/views/projects_dashboard_page.dart \
  lib/modules/projects/projects.dart
git commit -m "feat(projects): wire BH Configuration menu to reassignment screen"
```

---

## Spec coverage check

| Spec requirement | Task |
|------------------|------|
| BH-only sidebar | 1, 5 |
| Dual-panel mock UI | 4 |
| EmployeeInfo reuse | 2, 3, 4 |
| Mock repo + submit | 2, 3 |
| Queue pairs / validation | 3 |
| Dashboard wiring | 5 |
| Visual-only stepper | 4 |
| Tests | 1–3, 5 |

## Placeholder scan

None intentionally left; mock submit is explicit, not a TODO stub without behavior.

---

**Plan complete and saved to `docs/superpowers/plans/2026-09-08-projects-configuration-reassignment.md`.**

Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  
2. **Inline Execution** — implement tasks in this session with checkpoints  

Which approach?
