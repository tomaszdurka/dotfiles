#!/bin/sh
# Claude Code status line.
# Shows: model | ctx: N% used | dev: <url> (if a project dev server is up)

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  out=$(printf "%s | ctx: %.0f%% used" "$model" "$used")
else
  out="$model"
fi

# --- Dev server detection -------------------------------------------------
# Projects based on app-template / saas-template log their Next.js admin
# dev server output to data/dev-admin.log inside the project. The server is
# started on an OS-assigned port, so we re-read the log each time and
# verify the port actually answers before showing it (a stale log can
# remain after the server dies or is restarted on a new port).

project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // empty')
log_file="$project_dir/data/dev-admin.log"

if [ -n "$project_dir" ] && [ -f "$log_file" ]; then
  dev_url=$(grep -m1 -o 'http://localhost:[0-9]*' "$log_file" 2>/dev/null)
  if [ -n "$dev_url" ]; then
    code=$(curl -s -o /dev/null -m 1 -w '%{http_code}' "$dev_url/" 2>/dev/null)
    if [ -n "$code" ] && [ "$code" != "000" ]; then
      out="$out | dev: $dev_url"
    fi
  fi
fi

printf "%s" "$out"
