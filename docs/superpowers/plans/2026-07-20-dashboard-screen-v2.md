# Dashboard Screen V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Figma-matched mobile + web home dashboard with GetX that replaces `IntranetHomePage` as the app entry, porting all live menu/shell behavior without modifying `IntranetHomePage.dart`.

**Architecture:** Fresh module under `lib/pages/home/v2/`. `DashboardScreenV2Controller` owns Hive user/business state, placeholder KPIs, and navigation actions. `DashboardScreenV2` is a responsive shell (`LayoutBuilder`, breakpoint 1000) switching mobile vs web layouts. Widgets are dumb; they call controller methods. Entry routes (splash/login/magic-link/etc.) navigate to `DashboardScreenV2`.

**Tech Stack:** Flutter, GetX (`get: ^4.6.5`), Hive, Google Fonts, fl_chart, existing Intranet APIs/screens (`ProjectsDashboardPage`, `MyPjpListScreen`, `MyCVFListScreenV2`, expenses, Saathi, etc.)

**Spec:** `docs/superpowers/specs/2026-07-20-dashboard-screen-v2-design.md`

## Global Constraints

- Do **not** modify `lib/pages/home/IntranetHomePage.dart` or `lib/pages/home/home_page_menus.dart`
- Live menus only (no Figma-only Payments/Team/Vendors/Documents/etc.)
- KPI / chart / activity / reminders = static placeholders (no fake API repositories)
- Responsive breakpoint: `maxWidth >= 1000` → web; else mobile
- GetX only for new screen state (no `setState` in v2 widgets/controller UI updates)
- Port shell parity from `IntranetHomePage`: business switch, profile avatar, password-expired dialog, Firebase messaging/deep links, logout, in-app update, footer version
- Leave `dashboardv2.dart` untouched

## File Map

| File | Responsibility |
|---|---|
| `lib/pages/home/v2/models/dash_v2_models.dart` | KPI, activity, reminder, nav, quick-access models |
| `lib/pages/home/v2/widgets/dash_v2_tokens.dart` | Colors, text styles, radii |
| `lib/pages/home/v2/dashboard_screen_v2_controller.dart` | GetxController — all state + actions |
| `lib/pages/home/v2/widgets/dash_welcome_banner.dart` | Mobile/web greeting banner |
| `lib/pages/home/v2/widgets/dash_kpi_row.dart` | Mobile strip + web KPI cards |
| `lib/pages/home/v2/widgets/dash_quick_access_card.dart` | Single feature card |
| `lib/pages/home/v2/widgets/dash_quick_access_grid.dart` | Responsive grid of live menus |
| `lib/pages/home/v2/widgets/dash_sidebar.dart` | Web sidebar + drawer body |
| `lib/pages/home/v2/widgets/dash_mobile_app_bar.dart` | Mobile AppBar |
| `lib/pages/home/v2/widgets/dash_web_top_bar.dart` | Web top header |
| `lib/pages/home/v2/widgets/dash_project_status_card.dart` | Placeholder donut |
| `lib/pages/home/v2/widgets/dash_recent_activity_card.dart` | Placeholder activity |
| `lib/pages/home/v2/widgets/dash_upcoming_reminders_card.dart` | Placeholder reminders |
| `lib/pages/home/v2/dashboard_screenv2.dart` | Entry scaffold + responsive compose |
| `test/pages/home/v2/dash_v2_menu_visibility_test.dart` | Menu visibility unit tests |
| `test/pages/home/v2/dash_v2_greeting_test.dart` | Greeting helper unit test |
| Entry route files listed in Task 7 | Point to `DashboardScreenV2` |

---

### Task 1: Models, tokens, menu catalog + unit tests

**Files:**
- Create: `lib/pages/home/v2/models/dash_v2_models.dart`
- Create: `lib/pages/home/v2/widgets/dash_v2_tokens.dart`
- Create: `lib/pages/home/v2/dash_v2_menu_catalog.dart`
- Create: `test/pages/home/v2/dash_v2_menu_visibility_test.dart`
- Create: `test/pages/home/v2/dash_v2_greeting_test.dart`

**Interfaces:**
- Produces:
  - `DashKpiStat({required String label, required String value, required IconData icon, required Color color, double progress = 0})`
  - `DashActivityItem({required String title, required String subtitle, required String timeAgo, required IconData icon, required Color color})`
  - `DashReminderItem({required String month, required String day, required String title, required String when})`
  - `DashChartSegment({required String label, required double value, required Color color})`
  - `DashNavItem({required String key, required String label, required IconData icon, String? section})`
  - `DashQuickAccessItem({required String key, required String title, required String subtitle, required IconData icon, required Color color, required bool requiresBusiness, bool bpmsOnly = false, bool hideWhenBpms = false, bool notiflowOnly = false})`
  - `DashV2MenuCatalog.visibleQuickAccess({required bool isBpms, required String employeeCode}) → List<DashQuickAccessItem>`
  - `DashV2MenuCatalog.sidebarItems({required bool isBpms}) → List<DashNavItem>`
  - `DashV2Greeting.forDateTime(DateTime now, String firstName) → String` (e.g. `Good Morning, Sudhir 👋`)
  - `DashV2Colors`, `DashV2Text` token classes

- [ ] **Step 1: Write failing menu visibility tests**

```dart
// test/pages/home/v2/dash_v2_menu_visibility_test.dart
import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-BPMS user sees PJP-CVF Approval and not BPMS', () {
    final items = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: false,
      employeeCode: '99999999',
    );
    final keys = items.map((e) => e.key).toList();
    expect(keys, contains('pjp_cvf_approval_exp'));
    expect(keys, isNot(contains('bpms')));
    expect(keys, contains('projects'));
    expect(keys, contains('my_pjp'));
    expect(keys, contains('expenses'));
    expect(keys, isNot(contains('notiflow')));
  });

  test('BPMS user sees BPMS and still sees PJP-CVF Approval', () {
    final keys = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: true,
      employeeCode: '99999999',
    ).map((e) => e.key).toList();
    expect(keys, contains('bpms'));
    expect(keys, contains('pjp_cvf_approval_exp'));
  });

  test('notiflow allow-list emp code includes Notiflow', () {
    final keys = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: false,
      employeeCode: '14002156',
    ).map((e) => e.key).toList();
    expect(keys, contains('notiflow'));
  });

  test('sidebar always includes dashboard, pjp, cvf, projects, approvals_pjp, logout', () {
    final keys = DashV2MenuCatalog.sidebarItems(isBpms: false)
        .map((e) => e.key)
        .toList();
    expect(keys, containsAll(['dashboard', 'pjp', 'cvf', 'projects_nav', 'approvals_pjp', 'logout']));
  });
}
```

- [ ] **Step 2: Write failing greeting test**

```dart
// test/pages/home/v2/dash_v2_greeting_test.dart
import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('morning greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 9), 'Sudhir'),
      'Good Morning, Sudhir 👋',
    );
  });
  test('afternoon greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 14), 'Sudhir'),
      'Good Afternoon, Sudhir 👋',
    );
  });
  test('evening greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 19), 'Sudhir'),
      'Good Evening, Sudhir 👋',
    );
  });
}
```

- [ ] **Step 3: Run tests — expect FAIL (library missing)**

Run: `flutter test test/pages/home/v2/dash_v2_menu_visibility_test.dart test/pages/home/v2/dash_v2_greeting_test.dart`

Expected: FAIL — target URI does not exist / undefined class

- [ ] **Step 4: Implement models**

Create `lib/pages/home/v2/models/dash_v2_models.dart` with the classes listed in Interfaces (immutable `const` constructors where possible).

- [ ] **Step 5: Implement tokens**

Create `lib/pages/home/v2/widgets/dash_v2_tokens.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashV2Colors {
  DashV2Colors._();
  static const Color scaffold = Color(0xFFF4F6FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFEDF1F7);
  static const Color textDark = Color(0xFF1F2A44);
  static const Color textMuted = Color(0xFF8A94A6);
  static const Color primary = Color(0xFF1565C0); // deep blue AppBar
  static const Color blue = Color(0xFF4C6FFF);
  static const Color green = Color(0xFF2BB673);
  static const Color amber = Color(0xFFFFA63D);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC5990);
  static const Color teal = Color(0xFF14B8A6);
  static const Color red = Color(0xFFEF4E6B);
  static Color tint(Color c) => c.withValues(alpha: 0.12);
}

class DashV2Text {
  DashV2Text._();
  static TextStyle title = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: DashV2Colors.textDark);
  static TextStyle subtitle = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle sectionTitle = GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: DashV2Colors.textDark);
  static TextStyle cardTitle = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: DashV2Colors.textDark);
  static TextStyle cardSubtitle = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle kpiValue = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: DashV2Colors.textDark);
  static TextStyle caption = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle appBarTitle = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle appBarSubtitle = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70);
}
```

- [ ] **Step 6: Implement menu catalog + greeting**

Create `lib/pages/home/v2/dash_v2_menu_catalog.dart`:

- Hardcode the full quick-access list matching `HomePageMenu` (Projects, My PJP, My CVF, My Report, PJP-CVF Approval / BPMS branching, ZllSaathi, Expenses, Contracts, PJP Dashboard, Notiflow).
- `notiflowAccessList = ['14002156','14002172','14002035','14001828','14001782']` (same as `home_page_menus.dart`).
- `visibleQuickAccess`: if `isBpms` include `bpms` **and** `pjp_cvf_approval_exp`; if not `isBpms` include `pjp_cvf_approval_exp` only (not `bpms`); include `notiflow` only when allow-list matches.
- `sidebarItems`: dashboard, pjp, cvf, projects_nav, section Approvals → approvals_pjp, logout.
- `DashV2Greeting.forDateTime`: hour `<12` Morning, `<17` Afternoon, else Evening.

Mark guarded items with `requiresBusiness: true` for: my_pjp, my_cvf, pjp_cvf_approval_exp, zll_saathi, pjp_dashboard.

- [ ] **Step 7: Run tests — expect PASS**

Run: `flutter test test/pages/home/v2/dash_v2_menu_visibility_test.dart test/pages/home/v2/dash_v2_greeting_test.dart`

Expected: All PASS

- [ ] **Step 8: Commit**

```bash
git add lib/pages/home/v2/models/dash_v2_models.dart \
  lib/pages/home/v2/widgets/dash_v2_tokens.dart \
  lib/pages/home/v2/dash_v2_menu_catalog.dart \
  test/pages/home/v2/
git commit -m "Add Dashboard V2 models, tokens, and menu catalog tests"
```

---

### Task 2: Controller — user load, placeholders, business switch

**Files:**
- Create: `lib/pages/home/v2/dashboard_screen_v2_controller.dart`
- Create: `test/pages/home/v2/dash_v2_controller_placeholders_test.dart`
- Modify later tasks will extend this file

**Interfaces:**
- Produces: `class DashboardScreenV2Controller extends GetxController`
  - ctor: `DashboardScreenV2Controller({required this.userId, this.receivedAction})`
  - `final String userId;`
  - `final dynamic receivedAction;` (keep type compatible with AwesomeNotifications `ReceivedAction?` — import the same type `IntranetHomePage` uses)
  - Reactive fields per spec §8
  - `Future<void> loadUserFromHive()`
  - `Future<void> loadBusinessApplications()`
  - `void seedPlaceholders()`
  - `Future<void> updateCurrentBusiness(int bid, String name, int uid)`
  - `bool get isBusinessMapped => businessId.value != 0`
  - `bool validateBusiness(String menuKey)` — returns false + snackbar/message when guarded and not mapped
  - `List<DashQuickAccessItem> get quickAccessItems` (uses catalog + `isBpms` + `employeeCode`)
  - `static const double kWideBreakpoint = 1000`

**Reference (copy logic, do not edit):**
- `IntranetHomePage.getUserInfo` (~716–760)
- `IntranetHomePage.getLoginResponse` (~267–301)
- `IntranetHomePage.updateCurrentBusiness` (~154–165)
- Placeholder values from spec §9

- [ ] **Step 1: Write failing placeholder test**

```dart
import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  test('seedPlaceholders fills KPI and lists', () {
    final c = DashboardScreenV2Controller(userId: '1');
    c.seedPlaceholders();
    expect(c.kpiStats.length, 4);
    expect(c.kpiStats[0].label, 'My PJP');
    expect(c.kpiStats[0].value, '24');
    expect(c.projectStatusSegments.isNotEmpty, true);
    expect(c.recentActivities.length, greaterThanOrEqualTo(3));
    expect(c.upcomingReminders.length, greaterThanOrEqualTo(3));
    expect(c.notificationCount.value, 3);
  });
}
```

- [ ] **Step 2: Run test — expect FAIL**

Run: `flutter test test/pages/home/v2/dash_v2_controller_placeholders_test.dart`

Expected: FAIL — missing controller

- [ ] **Step 3: Implement controller skeleton**

Create `dashboard_screen_v2_controller.dart` with:

1. All `Rx` fields from spec
2. `seedPlaceholders()` assigning Figma-like static data (comment: `// PLACEHOLDER until KPI APIs exist`)
3. `onInit` → `seedPlaceholders()` then async `loadUserFromHive()` / `loadBusinessApplications()` (guard Hive calls so unit tests that only call `seedPlaceholders` do not require Hive)
4. `updateCurrentBusiness` writing `KEY_BUSINESS_ID`, `KEY_BUSINESS_NAME`, `KEY_BUSINESS_USERID`
5. `validateBusiness`: guarded keys = `{'my_pjp','my_cvf','pjp_cvf_approval_exp','zll_saathi','pjp_dashboard'}`; if `businessId == 0`, call `Utility.showMessage(Get.context!, 'Business not mapped. Please connect with your manager.')` and return false
6. Register expenses binding if missing:

```dart
if (!Get.isRegistered<DashboardPageController>()) {
  DashboardBinding().dependencies();
}
```

(same imports as `IntranetHomePage` / `home_page_menus.dart`)

- [ ] **Step 4: Run placeholder test — expect PASS**

Run: `flutter test test/pages/home/v2/dash_v2_controller_placeholders_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/pages/home/v2/dashboard_screen_v2_controller.dart \
  test/pages/home/v2/dash_v2_controller_placeholders_test.dart
git commit -m "Add Dashboard V2 controller with Hive load and placeholders"
```

---

### Task 3: Controller — navigation actions + logout

**Files:**
- Modify: `lib/pages/home/v2/dashboard_screen_v2_controller.dart`
- Reference: `lib/pages/home/home_page_menus.dart` (open methods), `IntranetHomePage.getMenu` / `signOut`

**Interfaces:**
- Produces methods (all `Future<void>` or `void`, using `Get.context!` / `Navigator.of(Get.context!)`):
  - `openProjects()`
  - `openMyPjp()`
  - `openMyCvf()`
  - `openMyReport()`
  - `openPjpCvfApprovalExp()`
  - `openBpms()`
  - `openZllSaathi()`
  - `openExpenses()`
  - `openContracts()`
  - `openPjpDashboard()`
  - `openNotiflow()`
  - `openPjpApprovals()` // `PJPManagerScreen`
  - `openNewProject()` // alias → `openProjects`
  - `onQuickAccessTap(String key)` // switch → above
  - `onSidebarTap(String key)` // dashboard/pjp/cvf/projects_nav/approvals_pjp/logout
  - `signOut()` // parity with `IntranetHomePage.signOut` → `IntroPage`
  - `showBusinessPicker({required bool fromDrawer})`
  - `onSearchTap()` / `onCustomizeTap()` / `onNotificationsTap()` → snackbar “Coming soon” or no-op snackbar
  - `onContactSupportTap()` → snackbar or `mailto:` launch if trivial

- [ ] **Step 1: Implement `onQuickAccessTap` switch**

Map keys exactly to catalog keys. Each open method must mirror `HomePageMenu` navigation (`Navigator.push` + same screen constructors). For business-guarded items call `if (!validateBusiness(key)) return;` first.

Copy `openExpense` / `openSaarthi` bodies from `home_page_menus.dart` (~530–578) into controller methods (adapt `widget.*` → controller fields / `profileAvatarBytes`).

- [ ] **Step 2: Implement sidebar + logout**

- `dashboard` → set `selectedNav = 'dashboard'` only
- `pjp` / `cvf` / `projects_nav` → corresponding open methods (pop drawer if open via `Navigator.of(Get.context!).maybePop()` when mobile)
- `approvals_pjp` → `PJPManagerScreen(employeeId: employeeId.value)` with business guard
- `logout` → `signOut()` clearing Hive + `HiveDatabase.clear()` + expense controllers + `Navigator.pushAndRemoveUntil` to `IntroPage` (same as `IntranetHomePage.signOut` ~2016–2033)

- [ ] **Step 3: Implement business picker dialog**

Port `showBusinessListDialog` (~303–352) using `Get.dialog` / `showDialog(context: Get.context!)`. On select call `updateCurrentBusiness`.

- [ ] **Step 4: Manual smoke (no automated UI test required)**

In comments or checklist: verify analyze clean:

Run: `dart analyze lib/pages/home/v2/dashboard_screen_v2_controller.dart`

Expected: No errors (warnings OK if pre-existing style)

- [ ] **Step 5: Commit**

```bash
git add lib/pages/home/v2/dashboard_screen_v2_controller.dart
git commit -m "Add Dashboard V2 navigation actions and logout"
```

---

### Task 4: Mobile UI widgets

**Files:**
- Create: `lib/pages/home/v2/widgets/dash_welcome_banner.dart`
- Create: `lib/pages/home/v2/widgets/dash_kpi_row.dart`
- Create: `lib/pages/home/v2/widgets/dash_quick_access_card.dart`
- Create: `lib/pages/home/v2/widgets/dash_quick_access_grid.dart`
- Create: `lib/pages/home/v2/widgets/dash_mobile_app_bar.dart`
- Create: `lib/pages/home/v2/widgets/dash_sidebar.dart` (drawer body used by mobile too)

**Interfaces:**
- Consumes: `DashboardScreenV2Controller` via `GetView` or `Get.find`
- Produces widgets matching mobile Figma (spec §6 Mobile)

- [ ] **Step 1: Build `DashMobileAppBar`**

PreferredAppBar-style `AppBar`:
- `backgroundColor: DashV2Colors.primary`
- leading: `Icons.menu` → `Scaffold.of(context).openDrawer()`
- title: `Obx` Column — `userFullName`, tappable `businessName` → `controller.showBusinessPicker(fromDrawer: false)`
- actions: search icon → `onSearchTap`, notification with red badge from `notificationCount`

- [ ] **Step 2: Build welcome banner**

Light-blue gradient rounded card; left: `Obx` greeting via `DashV2Greeting.forDateTime(DateTime.now(), firstName)` + subtitle “Stay updated with your tasks”; right: illustration — use a simple `Icon`/`Image.asset` if an asset exists, else a decorative chart/clipboard icon stack (do not block on missing Figma export).

- [ ] **Step 3: Build KPI row (mobile mode)**

Horizontal `Row` of 4 equal `Expanded` children: circular tinted icon, value, label, colored underline. Data from `controller.kpiStats`.

Also support `variant: DashKpiVariant.web` in same file for Task 5 (cards with progress bars) — implement both variants now to avoid rework.

- [ ] **Step 4: Build quick access card + grid**

Card: white, radius 12–16, soft shadow, left tinted icon box, title+subtitle, trailing chevron.  
Grid: `LayoutBuilder` — mobile 2 cols; tablet 3; web 4. Items from `controller.quickAccessItems`; `onTap: () => controller.onQuickAccessTap(item.key)`.

- [ ] **Step 5: Build sidebar/drawer list**

`ListView` of `DashNavItem`s with section headers; active `dashboard` highlighted light blue; logout at bottom; optional Need Help card at bottom for web (can hide on mobile). Calls `controller.onSidebarTap`.

- [ ] **Step 6: Analyze widgets**

Run: `dart analyze lib/pages/home/v2/widgets/`

Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/pages/home/v2/widgets/
git commit -m "Add Dashboard V2 mobile UI widgets"
```

---

### Task 5: Web UI widgets (top bar + insight panels)

**Files:**
- Create: `lib/pages/home/v2/widgets/dash_web_top_bar.dart`
- Create: `lib/pages/home/v2/widgets/dash_project_status_card.dart`
- Create: `lib/pages/home/v2/widgets/dash_recent_activity_card.dart`
- Create: `lib/pages/home/v2/widgets/dash_upcoming_reminders_card.dart`

**Interfaces:**
- Consumes: controller placeholder lists + `fl_chart` `PieChart`
- Produces web-only chrome + three bottom cards (spec §6 Web)

- [ ] **Step 1: Web top bar**

Row: menu/collapse → `controller.toggleSidebar()`, expanded search `TextField` (“Search here…”), notification badge, profile avatar + name + designation (`Obx`).

- [ ] **Step 2: Web header actions row**

Greeting (reuse banner text without illustration or compact), date-range chip (static string from controller `dateRangeLabel = 'May 20 – May 26, 2024'.obs` placeholder), blue `+ New Project` → `openNewProject()`.

- [ ] **Step 3: Project status card**

White card titled “Project Status Overview”; `PieChart` from `fl_chart` using `projectStatusSegments`; legend list; “View All Projects” → `openProjects()`.

- [ ] **Step 4: Recent activity + reminders**

List tiles from placeholders; “View All” → snackbar for now.

- [ ] **Step 5: Analyze + commit**

```bash
dart analyze lib/pages/home/v2/widgets/
git add lib/pages/home/v2/widgets/
git commit -m "Add Dashboard V2 web chrome and placeholder insight cards"
```

---

### Task 6: Compose `DashboardScreenV2` + shell lifecycle parity

**Files:**
- Modify: `lib/pages/home/v2/dashboard_screenv2.dart` (currently empty/1 line)
- Modify: `lib/pages/home/v2/dashboard_screen_v2_controller.dart` (Firebase, password, deep links, profile upload, in-app update)

**Interfaces:**
- Produces: `class DashboardScreenV2 extends StatefulWidget` **or** `GetView` + Stateful host for `WidgetsBindingObserver` / Firebase
  - Prefer: `DashboardScreenV2` as `StatefulWidget` that `Get.put`s controller in `initState` and deletes in `dispose`, implementing lifecycle observers by delegating to controller methods — **or** put observer on controller via `WidgetsBinding.instance.addObserver` in `onInit`/`onClose` (match whatever is cleaner; Firebase callbacks that need `BuildContext` use `Get.context`).

**Reference methods to port (read-only from IntranetHomePage):**
- `initFirebase`, `setupInteractedMessage`, `_handleMessage`, `_initURIHandler`, `_incomingLinkHandler`, `deepLinkCommonFunction`
- `_showUpdatePasswordDialog`, `_performPasswordUpdate`
- `getProfileImage`, `uploadProfilePicture`, upload success callbacks
- `checkForUpdate`, `onBackClickListener`
- `PackageInfo` version → footer

- [ ] **Step 1: Implement screen scaffold**

```dart
class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({super.key, required this.userId, this.receivedAction});
  final String userId;
  final dynamic receivedAction;
  ...
}
```

In `initState`:
```dart
controller = Get.put(DashboardScreenV2Controller(
  userId: widget.userId,
  receivedAction: widget.receivedAction,
));
controller.bootstrapShell(context); // firebase, deeplink, password, update check
```

`build`:
```dart
return Obx(() {
  // optional loading gate
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) controller.onBackPressed();
    },
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= DashboardScreenV2Controller.kWideBreakpoint;
        if (isWide) return _buildWeb(context);
        return _buildMobile(context);
      },
    ),
  );
});
```

Mobile: `Scaffold(appBar: DashMobileAppBar(), drawer: Drawer(child: DashSidebar(...)), body: SingleChildScrollView(... banner, kpi mobile, quick grid ...), bottomNavigationBar: version footer)`.

Web: `Scaffold(body: Row(children:[DashSidebar(collapsible), Expanded(child: Column(topBar, Expanded(scroll: greeting/actions, kpi web, quick access, bottom 3 cards)))]))`.

Footer text: `Intranet_${controller.appVersion.value}` (match `Utility.footer` style if possible).

- [ ] **Step 2: Port shell lifecycle into controller**

Implement `bootstrapShell(BuildContext context)` that sequentially calls ported helpers. Keep behavior identical; adapt `setState` → `.value =` / `.refresh()`. Password dialog uses `Get.dialog` or `showDialog`. Profile upload uses existing `FirebaseStorageUtil` + callback interface (controller can implement `onUploadResponse` same as home page, or use anonymous callback classes in the same file).

- [ ] **Step 3: Ensure expenses max advance still called**

In screen `build` or controller after employeeCode loaded:
```dart
if (Get.isRegistered<DashboardPageController>()) {
  Get.find<DashboardPageController>().getMaxAdvanceLimit(employeeCode.toString());
}
```

- [ ] **Step 4: Analyze screen**

Run: `dart analyze lib/pages/home/v2/`

Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/pages/home/v2/
git commit -m "Compose DashboardScreenV2 with mobile/web layouts and shell lifecycle"
```

---

### Task 7: Switch entry routes to DashboardScreenV2

**Files:**
- Modify: `lib/pages/intro/splash.dart` (~66)
- Modify: `lib/pages/auth/login.dart` (~551)
- Modify: `lib/pages/auth/magic_link_handler.dart` (~80)
- Modify: `lib/pages/login/components/login_form.dart` (~258)
- Modify: `lib/pages/pjp/PJPForm.dart` (~388)
- Modify: `lib/pages/pjp/new_pjp.dart` (~699)
- Modify: `lib/pages/pjp/cvf/add_cvf.dart` (~1566)

**Constraint:** Do not modify `IntranetHomePage.dart`

- [ ] **Step 1: Replace navigations**

For each call site:

```dart
// before
IntranetHomePage(userId: ..., receivedAction: ...)

// after
DashboardScreenV2(userId: ..., receivedAction: ...)
```

Add import:
```dart
import 'package:Intranet/pages/home/v2/dashboard_screenv2.dart';
```

Remove unused `IntranetHomePage` imports only if no longer referenced in that file.

- [ ] **Step 2: Verify no unintended IntranetHomePage edits**

Run: `git diff -- lib/pages/home/IntranetHomePage.dart`

Expected: empty

- [ ] **Step 3: Analyze touched entry files**

Run: `dart analyze lib/pages/intro/splash.dart lib/pages/auth/login.dart lib/pages/auth/magic_link_handler.dart lib/pages/login/components/login_form.dart`

Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/pages/intro/splash.dart \
  lib/pages/auth/login.dart \
  lib/pages/auth/magic_link_handler.dart \
  lib/pages/login/components/login_form.dart \
  lib/pages/pjp/PJPForm.dart \
  lib/pages/pjp/new_pjp.dart \
  lib/pages/pjp/cvf/add_cvf.dart
git commit -m "Route app entry and home returns to DashboardScreenV2"
```

---

### Task 8: Verification

**Files:** none new

- [ ] **Step 1: Run unit tests**

Run: `flutter test test/pages/home/v2/`

Expected: All PASS

- [ ] **Step 2: Full analyze on v2**

Run: `dart analyze lib/pages/home/v2/`

Expected: No errors

- [ ] **Step 3: Manual checklist (from spec §12)**

1. Cold start logged-in → splash → `DashboardScreenV2`
2. Login → v2
3. Narrow window: mobile Figma structure
4. Wide window: web Figma structure
5. Each live quick-access item opens correct screen
6. Business switch works; guarded menus block when `businessId == 0`
7. Logout → Intro/login
8. Password-expired path shows dialog (if testable)
9. Confirm `IntranetHomePage.dart` still unchanged

- [ ] **Step 4: Final commit if any fixups**

```bash
git add -u lib/pages/home/v2/ test/pages/home/v2/
git commit -m "Fix Dashboard V2 verification findings"
```

(Only if there are fixups; skip empty commit.)

---

## Spec Coverage Self-Review

| Spec section | Task(s) |
|---|---|
| §1 Goals / GetX home | 2–7 |
| §2 Non-goals | respected throughout |
| §3 Decisions | all tasks |
| §4 Entry contract | 6–7 |
| §5 Folder structure | 1–6 |
| §6 Responsive layouts | 4–6 |
| §7 Live menu set | 1, 3, 4 |
| §8 Controller responsibilities | 2, 3, 6 |
| §9 Placeholders | 2, 5 |
| §10 Visual tokens | 1, 4 |
| §11 Error/lifecycle | 3, 6 |
| §12 Testing | 1, 2, 8 |
| §13 Follow-ups | out of scope (not implemented) |

## Placeholder / Consistency Scan

- No TBD steps remaining
- Menu keys consistent: `projects`, `my_pjp`, `my_cvf`, `my_report`, `pjp_cvf_approval_exp`, `bpms`, `zll_saathi`, `expenses`, `contracts`, `pjp_dashboard`, `notiflow`, `dashboard`, `pjp`, `cvf`, `projects_nav`, `approvals_pjp`, `logout`
- Breakpoint constant: `DashboardScreenV2Controller.kWideBreakpoint = 1000`
- Class name: `DashboardScreenV2` / `DashboardScreenV2Controller`
