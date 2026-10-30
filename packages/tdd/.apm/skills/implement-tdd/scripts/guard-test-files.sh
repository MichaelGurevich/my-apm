#!/usr/bin/env bash
# PreToolUse hook for the tdd-* agents: restricts which files an agent may edit.
#
# Usage: guard-test-files.sh <tests-only|no-tests> <agent-name>
#   tests-only  block edits to anything that is not a test file (tdd-red)
#   no-tests    block edits to test files (tdd-green, tdd-refactor)
#
# Reads the hook payload JSON on stdin. Exits 2 with a reason on stderr to block.

mode=$1
agent=${2:-this agent}

f=$(tr -d '\n' | sed -n 's/.*"\(file_path\|notebook_path\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\2/p' | tr -s '\134' '/')

is_test_file() {
  printf '%s' "$1" | grep -Eq '(^|/)(tests?|__tests__|spec)/|[._-](test|spec)\.[^/]+$|(^|/)test_[^/]+$|Tests?\.[^/]+$'
}

case $mode in
  tests-only)
    if ! is_test_file "$f"; then
      echo "$agent may only edit test files. Blocked: $f" >&2
      exit 2
    fi
    ;;
  no-tests)
    if is_test_file "$f"; then
      echo "$agent must not edit test files; edit production code only. Blocked: $f" >&2
      exit 2
    fi
    ;;
  *)
    echo "guard-test-files.sh: unknown mode '$mode' (expected tests-only or no-tests)" >&2
    exit 2
    ;;
esac
