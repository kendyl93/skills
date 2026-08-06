#!/usr/bin/env bash
#
# Symlink every skill in this repo into your Claude Code skills directory.
#
# Symlinks (not copies) so `git pull` updates your installed skills instantly,
# and your local edits stay inside this repo where they can be committed.
#
#   ./install.sh                  install all skills for the current user
#   ./install.sh --dry-run        show what would happen, change nothing
#   ./install.sh --force          replace existing symlinks
#   ./install.sh --target DIR     install somewhere else (e.g. a project's .claude/skills)
#   ./install.sh --uninstall      remove only the symlinks that point into this repo
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET_DIR="$HOME/.claude/skills"
FORCE=0
DRY_RUN=0
UNINSTALL=0

usage() { sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --force)     FORCE=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --target)    TARGET_DIR="${2:?--target needs a directory}"; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

[ -d "$SKILLS_SRC" ] || { echo "no skills/ directory found in $REPO_ROOT" >&2; exit 1; }

run() { [ "$DRY_RUN" -eq 1 ] && echo "  would run: $*" || "$@"; }

linked=0 skipped=0 removed=0

if [ "$UNINSTALL" -eq 1 ]; then
  echo "Removing skill symlinks pointing into $REPO_ROOT"
  for link in "$TARGET_DIR"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$REPO_ROOT"/*) echo "- $(basename "$link")"; run rm "$link"; removed=$((removed + 1)) ;;
    esac
  done
  echo "Removed $removed."
  exit 0
fi

echo "Installing skills from $SKILLS_SRC into $TARGET_DIR"
run mkdir -p "$TARGET_DIR"

while IFS= read -r skill_file; do
  src_dir="$(cd "$(dirname "$skill_file")" && pwd)"
  name="$(basename "$src_dir")"
  link="$TARGET_DIR/$name"

  if [ -L "$link" ]; then
    if [ "$(readlink "$link")" = "$src_dir" ]; then
      echo "= $name (already installed)"; skipped=$((skipped + 1)); continue
    fi
    if [ "$FORCE" -eq 1 ]; then
      echo "~ $name (replacing symlink to $(readlink "$link"))"
      run rm "$link"
    else
      echo "! $name — a different symlink exists; re-run with --force to replace" >&2
      skipped=$((skipped + 1)); continue
    fi
  elif [ -e "$link" ]; then
    # A real file or directory. Never delete it, even with --force.
    echo "! $name — a real directory already exists at $link; move it aside first" >&2
    skipped=$((skipped + 1)); continue
  fi

  echo "+ $name"
  run ln -s "$src_dir" "$link"
  linked=$((linked + 1))
done < <(find "$SKILLS_SRC" -name SKILL.md -type f | sort)

echo
echo "Installed $linked, skipped $skipped."
echo "Start a new Claude Code session to pick them up."
