{{- renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" -}}

## How It Works

Two che profiles: `ontoRepo` (autoDiscover) renders this repo's own docs;
`gitlabGroup` (autoDiscover, eligible only when `GITLAB_GROUP` is set, via
`execIf`) runs the `ci/zsh/scripts/bootstrap/*.zsh` scripts.
`10-clone.zsh` clones/syncs every project of a gitlab group (`$GITLAB_GROUP`,
required) into that group's host dir `$WORKSPACE_DIR/$HOST_DIR_GITLAB_GROUP`
(required; `$WORKSPACE_DIR` defaults to `~/projects/gitlab`), then `20-index.zsh`
walks that host dir writing each subgroup's `assets/data/repo-index.md` plus
rendered `AGENTS.md`/`CLAUDE.md`.

The index is bottom-up: a leaf subgroup lists its repos with each repo's purpose
inlined; a parent subgroup lists its own direct repos and links child subgroup
indexes by reference (no flattening).

## Usage

- `make render-templates` — regenerate this repo's own docs.
- Set `GITLAB_GROUP`, `HOST_DIR_GITLAB_GROUP`, and `GITLAB_TOKEN` (and optionally
  `WORKSPACE_DIR`), then `che run-scripts` (setting `GITLAB_GROUP` makes the
  profile eligible; `che run-scripts --profile=gitlabGroup` forces it without) to
  clone + index.
