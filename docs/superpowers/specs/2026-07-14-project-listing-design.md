# Project Listing Module — Design Spec

**Date:** 2026-07-14  
**Status:** Approved for implementation  
**Scope:** `lib/modules/projects/` (extend existing module)

## Decisions

| Topic | Choice |
|-------|--------|
| Architecture | Same GetX + Remote/Local/Repository as Dashboard |
| Project tap | Lightweight `ProjectDetailScreen` placeholder |
| Card actions | Figma swipe: Details / Notes / Edit |
| Entry | Dashboard project cards (status 1–6) → list with `projectTeam_status` |
| Task cards (101–103) | Not opened via this list API |

## API

`POST .../api/bp/GetAllProjectList_new`  
Body: `{ userID, projectTeam_status, Business_id }`

## Offline

Hive cache key: `projects_{userId}_{status}_{businessId|all}`

## UI

Figma: AppBar (back, title+count, business, search), search bar, filter sheet, status chips, swipeable cards, shimmer/empty/error, pull-to-refresh, responsive 1/2/grid columns.
