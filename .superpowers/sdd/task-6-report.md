# Task 6 Report: Compose DashboardScreenV2 + shell lifecycle parity

## Status: Complete

## What was built

- `lib/pages/home/v2/dashboard_screenv2.dart`: `DashboardScreenV2` `StatefulWidget`.
  `Get.put`s `DashboardScreenV2Controller` in `initState`, calls
  `controller.bootstrapShell(context)`, `Get.delete`s in `dispose`. `build` uses
  `PopScope(canPop: false, onPopInvokedWithResult: ... controller.onBackPressed())`
  + `LayoutBuilder` switching on `kWideBreakpoint` (1000).
  - Mobile: `DashMobileAppBar`, `Drawer(DashSidebar(isDrawer: true))`,
    scrollable body (`DashWelcomeBanner` → `DashKpiRow` → Quick Access
    heading → `DashQuickAccessGrid`), `bottomNavigationBar: Utility.footer(appVersion)`.
  - Web: collapsible `DashSidebar` in a `Row`, `DashWebTopBar`
    (embeds `DashWebHeaderActions`), `DashKpiRow(variant: web)`, Quick Access
    section with Customize button (`onCustomizeTap`), bottom insight row
    (`DashProjectStatusCard` / `DashRecentActivityCard` / `DashUpcomingRemindersCard`),
    centered gray `Intranet_${version}` footer text.

- `lib/pages/home/v2/dashboard_screen_v2_controller.dart`: added
  `WidgetsBindingObserver` mixin + `bootstrapShell(BuildContext)` (idempotent)
  porting from `IntranetHomePage` (read-only reference, unmodified):
  - `initFirebase` (Crashlytics enable, `setAutoInitEnabled`, permission request)
  - Received-notification-action handoff (`td`/`Video_path`/`url` payload
    branches from the widget ctor)
  - `NotificationController.initializeLocalNotifications()` +
    `FirebaseMessaging.onMessageOpenedApp` listeners (`_handleMessage` +
    navigate-to-`UserNotification`, mirroring both listeners registered by
    `initState`)
  - `checkForUpdate()` (Android, `in_app_update`) / `_verifyVersion()` (iOS,
    `app_version_update`), also re-run on `didChangeAppLifecycleState` resume
  - `_incomingLinkHandler()` / `deepLinkCommonFunction()` (`app_links`,
    `ZllTicket` route parity)
  - `onBackPressed()` (exit-confirm `AlertDialog`, Android `SystemNavigator.pop`
    / iOS `exit(0)`)
  - `getProfileImage()` / `uploadProfilePicture()` using `FirebaseStorageUtil`
    with new `_ProfileAvatarFetchResponse` / `_AvatarUploadResponse`
    (`onUploadResponse`) callback classes (cleaner 1:1 split vs. legacy's
    single type-switching callback)
  - `_showUpdatePasswordDialog()` / `_performPasswordUpdate()` — new
    `_UpdatePasswordDialog` `StatefulWidget` (same fields/validation/styling)
    + `_PasswordUpdateResponse` (`onResponse`) calling
    `IntranetServiceHandler.changePassword`
  - `onClose()` removes the observer and cancels all stream subscriptions
  - `loadAppVersion()` (PackageInfo) and password-expired check wired into
    `_initialize()`/`loadUserFromHive()`
  - Expenses: `_initialize()` now calls
    `DashboardPageController.getMaxAdvanceLimit(employeeCode)` once
    `DashboardPageController` is registered and `employeeCode` is loaded

## Decisions (no blocking ambiguity found)

- `setupInteractedMessage` and `_initURIHandler` are dead code in
  `IntranetHomePage` today (defined but never invoked — the only call site is
  commented out). I ported the actually-live behavior (`onMessageOpenedApp`
  listeners called directly from `initState`) and omitted re-creating the two
  unused legacy methods verbatim, to avoid dead code / analyzer noise while
  preserving live functional parity.
- Skipped porting `_getId`/`FCM().setNotifications` (device-id/token
  registration for push). It's not in the brief's explicit port list and adds
  device_info_plus/token-registration complexity; flagging as a gap below.

## Verification

- `dart analyze lib/pages/home/v2/` → **0 errors** (4 pre-existing-style infos:
  `depend_on_referenced_packages` for `firebase_messaging`, 3×
  `use_build_context_synchronously` — all pre-existing patterns elsewhere in
  the codebase, e.g. `IntranetHomePage.dart`).
- `flutter analyze` (whole repo) → 0 errors in `lib/`/`test/`; only pre-existing
  vendored-package errors under `android/build/ios/SourcePackages/...`
  (unrelated to this change).
- `flutter test test/pages/home/v2/` → **14/14 passed**.
- `git diff` on `IntranetHomePage.dart` and `home_page_menus.dart` → empty
  (untouched, confirmed).

## Concerns / follow-ups for reviewer

1. **No FCM device-token registration** in the V2 flow (see decision above) —
   push notifications will still arrive, but the device isn't (re-)registered
   from the V2 shell the way `IntranetHomePage._getId` did. Follow-up task if
   needed.
2. `bootstrapShell` uses `Get.context` for dialogs launched from Firebase
   callbacks; this matches the brief's guidance but inherits the same
   `use_build_context_synchronously` info-level pattern already present in
   `IntranetHomePage.dart`.
3. Entry routes are intentionally **not** switched (Task 7).

## Commit

`Compose DashboardScreenV2 with mobile/web layouts and shell lifecycle`
(`lib/pages/home/v2/dashboard_screenv2.dart`,
`lib/pages/home/v2/dashboard_screen_v2_controller.dart`)

## Important review fixes (2026-07-20)

- Ported foreground FCM/device registration into
  `DashboardScreenV2Controller`: device id and user agent are built with
  `DeviceInfoPlugin`, `FCM().setNotifications` runs after the employee and app
  version load, and `FirebaseMessaging.onMessage` forwards messages to
  `NotificationService().parseNotification`.
- The foreground message subscription now replaces any prior subscription and
  is cancelled in `onClose`.
- Added `getProfileImage({bool force = false})`; avatar upload completion now
  forces a Firebase fetch so cached bytes cannot leave the UI stale.
- Added regression tests for forced avatar fetching and foreground subscription
  replacement/disposal.
- `dart analyze lib/pages/home/v2/` → 0 errors (4 existing info-level findings).
- `flutter test test/pages/home/v2/` → 16/16 passed.
- `IntranetHomePage.dart` and entry routes were not modified.
