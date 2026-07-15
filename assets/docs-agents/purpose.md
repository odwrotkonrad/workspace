# Purpose

## What It Is

Owns the local gitlab workspace at `$WORKSPACE_DIR` (default `~/projects/gitlab`): clones/syncs every project of one or more gitlab groups (`$GITLAB_GROUPS`, `<group>:<host_dir>` pairs; single-group `$GITLAB_GROUP`/`$HOST_DIR_GITLAB_GROUP` fallback) into each group's host dir under `$WORKSPACE_DIR`, then generates a recursive **repo index** for every subgroup dir from the workspace root down so agents and humans opening any subgroup see its directory structure, each repo's purpose inlined, child subgroups inlined recursively.

## Why It Exists

Cloning many nested gitlab repos leaves no signal about what each subgroup holds. This repo makes each subgroup self-describing: a self-contained index (repos with purposes inlined, child subgroups inlined recursively) written as generated `AGENTS.md`/`CLAUDE.md`. The clone responsibility moved here out of `configs`.

## Goals

- One place owns clone + index generation for the whole workspace.
- Each subgroup dir carries a fresh generated index of its direct children.
- Recursive: each index is self-contained, child subgroups inlined below their parent.
- Runs both locally (ssh) and in CI (https + `GITLAB_TOKEN`).

