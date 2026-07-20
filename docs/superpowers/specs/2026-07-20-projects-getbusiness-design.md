# Projects GetBusiness — Design Spec

**Date:** 20 July 2026  
**Module:** Projects (`ProjectsDashboardPage` only)  
**Status:** Approved

---

## Problem

Intranet session businesses use `business_ID` from login (`BusinessApplications`).  
Projects BPMS APIs expect a **different** id space from `GetBusiness` (`Business_Id`).

Using intranet ids in ProjectsDashboard filters incorrectly. Mapping must be **Projects-only**; other modules keep intranet ids.

## Decision

| Concern | Choice |
|--------|--------|
| List source for Projects selector | `GET/POST …/api/bp//GetBusiness` |
| Match intranet → Projects | By **normalized business name** |
| Where load runs | Inside `DashboardController` (Approach A) |
| Offline | Hive cache of GetBusiness list |
| Intranet / other modules | Unchanged |

## Name normalization

1. Trim  
2. Lower-case  
3. Remove non-alphanumeric characters  
4. If result starts with `e` and length > 1, strip that leading `e`  

Examples: `eKidzee` ↔ `Kidzee` → `kidzee`; `eMountLitera` ↔ `Mount Litera` → `mountlitera`.

## Flow

```
Open ProjectsDashboard
  → read intranet KEY_BUSINESS_NAME (entry args)
  → fetch GetBusiness (or Hive cache if offline/fail)
  → replace selector list with Projects businesses
  → match intranet name → set selectedBusinessId = Projects Business_Id
  → if no match → All Business (null)
  → load dashboard counts with Projects Business_id
```

## API

- **URL:** `{LocalStrings.bpms}/api/bp//GetBusiness`  
  (`https://kubapi.zeelearn.com/V1/commonapi/api/bp//GetBusiness`)
- **Method:** POST (same family as other `/api/bp` Gets), body `{}`
- **Success:** `{ "success": 200, "data": [ { "Business_Id": 1, "Business_Name": "eKidzee" }, … ] }`

## Offline

- Box: `projects_business_box`  
- Key: `get_business_list`  
- On network failure: load cache; show offline banner  
- If no cache: empty list + All Business; dashboard may still use count cache

## Scope / non-goals

- Do **not** change intranet business dialog or Hive `KEY_BUSINESS_ID`  
- Do **not** remap ids for PJP / CVF / other modules  
- Host can still pass login `businesses`; controller treats them as fallback only until GetBusiness/cache loads

## UI impact

- Selector shows GetBusiness names/ids  
- Navigation to Project List passes **Projects** `businessId` + Projects business list  
- `userId` (BP user) unchanged from existing entry args rule
