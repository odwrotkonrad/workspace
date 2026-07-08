##[>] 🤖🤖
#[what] Project's Makefile
SHELL := zsh
.SHELLFLAGS := -c

WRAPPERS :=
COMMANDS := render-templates run-repo-ci-prepare-hooks run-repo-ci-precommit-all

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] root of the local gitlab workspace the bootstrap scripts clone into + index
#[vals] path, default ~/projects/gitlab
export WORKSPACE_DIR
#[what] gitlab group to clone (with subgroups); gates the gitlabGroup che profile (onlyIf), unset -> clone/index skip
#[vals] gitlab group path
export GITLAB_GROUP
#[what] host dir under $WORKSPACE_DIR for that group's repos (replaces the remote group path segment), unset -> clone skips
#[vals] dir name
export HOST_DIR_GITLAB_GROUP
#[what] gitlab token for https clone (CI), unset -> clone skips
#[vals] gitlab api token
export GITLAB_TOKEN
##[<] Environment Variables

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md, repo-structure.md, CLAUDE.md, AGENTS.md, README.md)
render-templates:
	@che render-templates --profile=ontoRepo
##[<] Docs

##[>] CI [genai-include]
#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
run-repo-ci-precommit-all: run-repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force
##[<] CI
##[<] 🤖🤖
