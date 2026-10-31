#!/usr/bin/env bash
# PreToolUse hook for the code-review skill: keeps the coordinator read-only.
#
# Usage: guard-read-only.sh
#   Edit, Write, MultiEdit, NotebookEdit  allowed only for files under .scratch/
#   Bash  allowed only for read-only git and gh queries and read utilities,
#         with output redirected only into .scratch/
#   PowerShell  blocked; use Bash
#
# Reads the hook payload JSON on stdin. Exits 2 with a reason on stderr to block.

payload=$(tr -d '\n')
tool=$(printf '%s' "$payload" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

in_scratch() {
  case "/$1" in
    */../*) return 1 ;;
    */.scratch/*) return 0 ;;
  esac
  return 1
}

block() {
  echo "code-review is read-only: $1" >&2
  exit 2
}

case $tool in
  Edit|Write|MultiEdit|NotebookEdit)
    f=$(printf '%s' "$payload" | sed -n 's/.*"\(file_path\|notebook_path\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\2/p' | tr -s '\134' '/')
    in_scratch "$f" || block "it writes only its own files under .scratch/. Blocked: $f"
    exit 0
    ;;
  PowerShell) block "use Bash for git and gh queries, not PowerShell." ;;
  Bash) ;;
  *) exit 0 ;;
esac

# Extract tool_input.command and undo JSON escaping.
cmd=$(printf '%s' "$payload" \
  | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' \
  | sed 's/\\\\/\x01/g; s/\\"/"/g; s/\\n/\n/g; s/\\t/ /g; s/\x01/\\/g')

hint="Bash is limited to read-only git and gh queries and read utilities, writing only into .scratch/. Run commands one at a time."

case $cmd in
  *'$('*|*'`'*|*'<('*|*'>('*) block "no command substitution. $hint Blocked: $cmd" ;;
esac

allowed='^(cd|pwd|ls|cat|head|tail|wc|grep|sort|uniq|date|echo|printf)([[:space:]]|$)'
allowed+='|^git[[:space:]]+(diff|log|show|rev-parse|rev-list|merge-base|ls-files|status|blame|describe|for-each-ref)([[:space:]]|$)'
allowed+='|^git[[:space:]]+branch[[:space:]]+--show-current[[:space:]]*$'
allowed+='|^gh[[:space:]]+(issue|pr)[[:space:]]+(view|list|diff)([[:space:]]|$)'

# Drop harmless fd redirections, then split into simple commands.
segments=$(printf '%s\n' "$cmd" \
  | sed -E 's/[0-9]*>&[0-9]+//g; s/&?[0-9]*>>?[[:space:]]*\/dev\/null//g' \
  | sed -E 's/&&|\|\||;|\||&/\n/g')

while IFS= read -r seg; do
  seg=$(printf '%s' "$seg" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
  [ -z "$seg" ] && continue

  for target in $(printf '%s' "$seg" | grep -oE '>>?[[:space:]]*[^[:space:]]+' | sed -E "s/^>>?[[:space:]]*//; s/[\"']//g"); do
    in_scratch "$target" || block "output may only go into .scratch/. Blocked: $seg"
  done
  bare=$(printf '%s' "$seg" | sed -E 's/[0-9]*>>?[[:space:]]*[^[:space:]]+//g; s/[[:space:]]+$//')

  if printf '%s' "$bare" | grep -Eq '^mkdir[[:space:]]+-p[[:space:]]'; then
    for dir in ${bare#mkdir}; do
      [ "$dir" = "-p" ] && continue
      in_scratch "${dir//[\"\']/}/" || block "directories may only be created under .scratch/. Blocked: $seg"
    done
    continue
  fi

  printf '%s' "$bare" | grep -Eq "$allowed" || block "$hint Blocked: $seg"
  case $bare in
    git*--output*) block "write git output with a redirect into .scratch/, not --output. Blocked: $seg" ;;
  esac
done <<EOF
$segments
EOF

exit 0
