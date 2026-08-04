# Employee Search Autocomplete — Design

**Date:** 2026-08-03  
**Status:** Approved  
**Entry:** Dashboard V2 `onSearchTap`

## Summary

Replace `_showComingSoon` on dashboard search with a Flutter `SearchDelegate` that loads employees via `APIService.getEmployeeList()`, filters as the user types, and opens a detail screen on tap.

## Behavior

1. Tap search → `showSearch` with `EmployeeSearchDelegate`.
2. Load employee list once (cache in delegate for the session).
3. Filter by name, code, email, designation, department, contact (case-insensitive).
4. Suggestion row: avatar, name, designation, employee code.
5. Tap → `EmployeeDetailScreen` with labeled fields (Name, Email, Designation, Code, Department, Role, Grade, Location, Zone, Manager, DOB, Contact, etc.).
6. Contact row supports `tel:` when number present.

## Data

Extend `EmployeeInfo` to parse optional API fields when present; display `—` when empty. Existing list screen continues to work.

## Out of scope

Offline Hive cache, edit employee, web top-bar wiring (commented out).
