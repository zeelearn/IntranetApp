# Project Details — Design Spec

**Date:** 2026-07-16  
**Status:** Approved

## Summary

Figma-aligned Project Details screen opened from project list footer buttons (Communication, Indent Details, Documents). One page with four tabs; `initialTab` matches the tapped button. Data from `GetFranchiseeDetailInfoV1`, offline-first Hive cache, refresh + auto-refresh when cache is from a previous calendar day.

## Navigation

- `ProjectDetailScreen.open(project, userId, currentUserName, statusName, statusColor, initialTab, businessId)`
- Tabs: `communication` | `indent` | `tasks` | `documents`
- List wiring:
  - Communication → `initialTab: communication`
  - Indent Details → `initialTab: indent`
  - Documents → `initialTab: documents`

## API

- `POST {bpms}/api/bp/GetFranchiseeDetailInfoV1`
- Body: `{"Franchisee_ID": <int>, "crm_id": "<crmId>"}`
- Response `data[0]`: `franDetails`, `communication[]`, `indentDetails[]`, `documents[]`

## Offline

- Hive box `projects_detail_box`, key `detail_{franchiseeId}_{crmId}`
- Payload includes `syncedAt` (ISO date)
- On open: load cache → paint → sync if online
- If `syncedAt` date ≠ today → auto refresh
- Overflow **Refresh** forces network sync

## UI

- App bar: back, “Project Details”, overflow (Refresh)
- Header card: Project ID + name, status badge, collapsible Franchisee Details
- Tab card: Communication / Indent Details / Tasks / Documents
- Communication: email rows with date, preview, Read More
- Indent: summary + indent cards (status colors)
- Tasks: embed project task hierarchy (reuse TaskHierarchyController / list widgets)
- Documents: reuse attachment UI with Name + DocURL

## Out of scope

- Communication compose/send
- Indent detail drill-down page
- Filter sheets beyond stub UI
