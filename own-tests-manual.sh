#!/usr/bin/env bash
# The project's own test command (bin/rails test) on the base commit, with the Ruby the harness found.
set -u
repo="$PWD/repo"; d="$PWD/baseline-tree"
git -C "$repo" worktree remove --force "$d" 2>/dev/null; rm -rf "$d"
git -C "$repo" worktree add -q --detach "$d" 60e3910f01facf1732b8df4195a77623bf2c6ffa
cp "$repo/Gemfile.lock" "$repo/config/database.yml" "$d/" ; mv "$d/database.yml" "$d/config/"
cp "$repo"/db/*.sqlite3* "$d/db/"; [ -n "${DIFF:-}" ] && git -C "$d" apply "$DIFF" && echo "applied $DIFF"
export PATH="/opt/homebrew/opt/ruby/bin:$(/opt/homebrew/opt/ruby/bin/ruby -e 'print Gem.bindir'):$PATH" CI=1
cd "$d"; ruby -v; start=$(date +%s)
bin/rails test 2>&1 | tail -15
echo "exit ${PIPESTATUS[0]} seconds $(( $(date +%s) - start ))"
cd ..; git -C "$repo" worktree remove --force "$d"
