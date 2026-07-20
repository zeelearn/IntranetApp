# Task Hierarchy Module — Design Spec

**Date:** 2026-07-14  
**Status:** Approved for implementation  
**Scope:** `lib/modules/projects/`

## Decisions

| Topic | Choice |
|-------|--------|
| UX | Figma in-place expand/collapse tree |
| Mutations | UI + menus/callbacks only (APIs later) |
| Entry | Project Details → TaskHierarchyScreen |
| Hierarchy | One `Gettaskdata` call; `Map<parentId, children>` |

## API

`POST .../api/bp/Gettaskdata`  
`{ projectID, UserId }`

## Offline

Hive: `tasks_{userId}_{projectId}`
