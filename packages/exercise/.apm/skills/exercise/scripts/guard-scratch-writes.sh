#!/usr/bin/env bash
# PreToolUse hook: limits file edits to .scratch/, so a skill or agent that runs
# commands can record its results without changing the code or the tests.
#
# Usage: guard-scratch-writes.sh <skill-or-agent-name>
#   Edit, Write, MultiEdit, NotebookEdit  allowed only for files under .scratch/
#
# Reads the hook payload JSON on stdin. Exits 2 with a reason on stderr to block.

name=${1:-this skill}

f=$(tr -d '\n' | sed -n 's/.*"\(file_path\|notebook_path\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\2/p' | tr -s '\134' '/')

case "/$f" in
  */../*) ;;
  */.scratch/*) exit 0 ;;
esac

echo "$name writes only its own files under .scratch/. Blocked: $f" >&2
exit 2
