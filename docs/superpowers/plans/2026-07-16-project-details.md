# Project Details Implementation Plan

> **For Claude:** Required codebase patterns live under `lib/modules/projects/`. Follow offline-first GetX pattern.

**Goal:** Figma Project Details page with V1 franchisee API, tabs, offline cache, list button wiring.

**Architecture:** Remote → Local Hive → Repository → Controller → Screen + tab widgets.

## Tasks

1. Models + parse tests — DONE (`project_detail.dart`, `project_detail_test.dart`)
2. Remote/Local/Repo — DONE
3. Controller + Binding — DONE
4. UI (header, tabs, communication/indent/docs/tasks) — DONE
5. Wire project list footer buttons — DONE
6. Spec — `docs/superpowers/specs/2026-07-16-project-details-design.md`
