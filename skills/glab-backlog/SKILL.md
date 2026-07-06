---
name: glab-backlog
description: >
  Complete reference for glab CLI commands for GitLab backlog management — issues, milestones, labels, boards, and todos. Use this skill whenever the user asks to list, create, update, close, or query issues or milestones via glab; build commands to filter backlog by sprint/milestone/label/assignee; configure a self-managed host with GITLAB_HOST/GITLAB_URI; use glab api for advanced REST or GraphQL queries; or any backlog operation with glab CLI. Aggressive trigger: any mention of glab + issue, milestone, label, sprint, backlog, board, or todo should activate this skill.
---

# glab CLI — GitLab Backlog Management

> Reference version: glab 1.95.0+  
> Scope: issues, milestones, labels, boards, todos, and direct API access. Does not cover MRs, CI/CD, releases, or snippets.

> **Configuration:** All project values come from environment variables in `.env`. The examples in this skill use literal values for illustration — always replace them with the actual env vars when executing:
> - `git179.websis.com.br` → `${GITLAB_HOST}`
> - `https://git179.websis.com.br` → `${GITLAB_URI}`
> - `sest2/itl` → `${GITLAB_REPO}`
> - `sest2%2Fitl` → URL-encoded form of `${GITLAB_REPO}` (replace `/` with `%2F`)

---

## 1. Authentication and Host Selection

### Check authentication
```bash
glab auth status
```

### Select a self-managed host

| Method | When to use |
|---|---|
| `GITLAB_HOST=... GITLAB_URI=... glab <cmd>` | **Universal** — works with any command |
| `glab api <endpoint> --hostname git179.websis.com.br` | Only in `glab api` and `glab auth login` |
| `glab issue list -R sest2/itl` | When the remote already points to the correct instance |
| Inside a git repo with a configured remote | Auto-detected |

**Standard example for self-managed instances:**
```bash
GITLAB_HOST=git179.websis.com.br GITLAB_URI=https://git179.websis.com.br \
  glab <command> -R sest2/itl
```

### Environment variables

| Variable | Purpose |
|---|---|
| `GITLAB_HOST` | Hostname (e.g. `git179.websis.com.br`) |
| `GITLAB_URI` | Full base URL |
| `GITLAB_TOKEN` / `GITLAB_ACCESS_TOKEN` | Overrides the stored token |

---

## 2. Global Flags

| Flag | Description |
|---|---|
| `-R, --repo` | Select another repository (`OWNER/REPO`, URL, or Git URL) |
| `-F, --output` | `text` (table) or `json` |
| `-p, --page` | Page number (starts at 1) |
| `-P, --per-page` | Items per page |

---

## 3. Issues

### List issues
```bash
glab issue list [--flags]
```

Main flags:

| Flag | Description |
|---|---|
| `-A, --all` | Open + closed |
| `-c, --closed` | Closed only |
| `-a, --assignee` | By assignee (`@me` for yourself) |
| `--author` | By author |
| `-l, --label` | By label (comma-separated or repeatable) |
| `--not-label` | Exclude label |
| `-m, --milestone` | By milestone title or ID |
| `-t, --issue-type` | `issue`, `incident`, `test_case` |
| `-g, --group` | Target a group instead of a project |
| `--search` | Search in title/description |
| `--order` | `created_at`, `updated_at`, `priority`, `due_date`, etc. |
| `-s, --sort` | `asc` or `desc` |
| `-F, --output-format` | `details`, `ids`, `urls` |

**Recipes:**
```bash
# All issues in a sprint (excluding tasks/work items)
GITLAB_HOST=git179.websis.com.br GITLAB_URI=https://git179.websis.com.br \
  glab issue list -R sest2/itl -m "Sprint 2026.10" -A -P 100 -t issue

# Open issues in a sprint
glab issue list -R sest2/itl -m "Sprint 2026.10" -P 100 -t issue

# By label
glab issue list -R sest2/itl -l "AWAITING APPROVAL" -A -t issue

# Text search
glab issue list -R sest2/itl --search "authentication" -A -t issue

# By author
glab issue list -R sest2/itl -m "Sprint 2026.10" --author gustavo.cintra -A -t issue

# Count by state (JSON + jq)
glab issue list -R sest2/itl -m "Sprint 2026.10" -A -P 100 -t issue -F json \
  | jq 'group_by(.state) | map({state: .[0].state, count: length})'
```

### View issue details
```bash
glab issue view <id> [-R sest2/itl] [-c]   # -c shows comments
glab issue view <id> -w                      # opens in browser
```

### Create an issue
```bash
glab issue create -R sest2/itl \
  -t "Issue title" \
  -d "Description..." \
  -l "TYPE::IMPROVEMENT,PRIORITY::QUICK WIN" \
  -m "Sprint 2026.11" \
  -y
```

Additional flags: `--assignee`, `--weight`, `--due-date`, `--confidential`, `--epic`, `--template`

### Update an issue
```bash
glab issue update <id> -R sest2/itl [--flags]
```

Flags: `-t` (title), `-d` (description), `-a` (assignee: `!user` removes, `+user` adds), `-l` (add label), `-u` (remove label), `-m` (milestone; `""` disassociates), `-w` (weight)

### Close / Reopen
```bash
glab issue close <id>   # or URL
glab issue reopen <id>
```

### Comment
```bash
glab issue note <id> -m "Comment text"
```

### Delete
```bash
glab issue delete <id>
```

---

## 4. Milestones

> ⚠️ `milestone list` requires `--project` or `--group` — it does not auto-detect the current repo.

### List milestones
```bash
GITLAB_HOST=git179.websis.com.br GITLAB_URI=https://git179.websis.com.br \
  glab milestone list --project sest2/itl --state active
```

Flags: `--state` (`active`/`closed`), `--search`, `--title`, `--include-ancestors`, `--show-id`

### Create a milestone
```bash
glab milestone create \
  --title="Sprint 2026.13" \
  --project sest2/itl \
  --due-date="2026-06-15T08:00:00Z" \
  --start-date="2026-06-01T08:00:00Z" \
  --description="Sprint goal"
```

### Edit a milestone
```bash
glab milestone edit <id> --title="New Title" --project sest2/itl
# --state: 'activate' or 'close'
# --due-date, --start-date, --description also available
```

### Delete
```bash
glab milestone delete <id> --project sest2/itl
```

---

## 5. Labels

```bash
# List
glab label list -R sest2/itl

# Create
glab label create -n "label-name" -c "#FF0000" -d "Description" -R sest2/itl

# Edit
glab label edit -l <label-id> -n "new-name" -c "#00FF00" -R sest2/itl

# Delete
glab label delete "label-name" -R sest2/itl
```

---

## 6. To-Do

```bash
# List pending todos
glab todo list                          # pending (default)
glab todo list -s all                   # all states
glab todo list -t Issue                 # issues only

# Mark as done
glab todo done <id>
glab todo done --all                    # mark all as done
```

---

## 7. `glab api` — Direct API Access

```bash
glab api <endpoint> [--flags]
```

| Flag | Description |
|---|---|
| `-X` | HTTP method (`GET`, `POST`, etc.) |
| `-F, --field` | Parameter with type inference |
| `-f, --raw-field` | Parameter as a raw string |
| `--hostname` | Override host (only here and in `auth login`) |
| `--paginate` | Fetch all pages automatically |
| `--output` | `json` or `ndjson` (ideal for piping with `jq`) |

**Examples:**
```bash
# Active milestones (REST)
glab api projects/sest2%2Fitl/milestones?state=active --hostname git179.websis.com.br

# Issues for a milestone with full pagination
glab api "projects/sest2%2Fitl/issues?milestone=Sprint+2026.10&issue_type=issue&per_page=100" \
  --hostname git179.websis.com.br --paginate --output ndjson

# Issue detail
glab api projects/sest2%2Fitl/issues/632 --hostname git179.websis.com.br

# GraphQL — aggregated data
glab api graphql --hostname git179.websis.com.br -f query='
query {
  project(fullPath: "sest2/itl") {
    name
    issues(state: opened) { count }
    milestones(state: active) {
      nodes { title dueDate startDate }
    }
  }
}'
```

**Pipeline with jq:**
```bash
# Via issue list
glab issue list -m "Sprint 2026.10" -A -F json -t issue \
  | jq '.[] | {iid: .iid, title: .title, state: .state, labels: .labels}'

# Via glab api (streaming)
glab api issues --paginate --output ndjson | jq 'select(.state == "opened") | .title'
```

---

## 8. Troubleshooting

| Symptom | Solution |
|---|---|
| Command hits gitlab.com instead of your instance | Set `GITLAB_HOST` and `GITLAB_URI` |
| "Unknown flag: --project" in `glab issue` | `--project` only exists for `milestone`. Use `-R` for issues. |
| `--hostname` doesn't work in top-level commands | Only works in `glab api` and `glab auth login`. Use `GITLAB_HOST`. |
| `-m` doesn't find the milestone | Accepts title as a string: `-m "Sprint 2026.10"` |
| `-t` does the wrong thing | In `issue list` it's `--issue-type`; in `issue create` it's `--title`. Check `--help`. |

---

## 9. Discover More

```bash
glab --help
glab issue --help
glab issue list --help
glab milestone --help
glab auth status
glab config edit
```

Online docs: https://docs.gitlab.com/ee/editor_extensions/gitlab_cli/