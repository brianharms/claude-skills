#!/bin/bash
# Install these Claude Code skills into ~/.claude/skills.
#
#   ./install.sh                     install all of them
#   ./install.sh explain grade       install only these (anything they need comes along)
#   ./install.sh --list              what is here, and what is already installed
#   ./install.sh --update            replace the copies this installer put in before, with the versions here
#   ./install.sh --dry-run ...       print what would happen, change nothing
#
# Never overwrites a skill of the same name that you already have from somewhere else. No sudo.
set -euo pipefail
cd "$(dirname "$0")"

DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MARK=".installed-from-claude-skills"     # left inside each skill this installer copied, so --update knows it is ours
DRY=0; UPDATE=0; LIST=0; WANT=()

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --update) UPDATE=1 ;;
    --list) LIST=1 ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $a (try --help)" >&2; exit 1 ;;
    *) WANT+=("$a") ;;
  esac
done

ALL=(); for d in skills/*/; do ALL+=("$(basename "$d")"); done

needs() {   # skills a skill calls, so they come along
  case "$1" in
    grade-and-fix) echo "grade hypothesize" ;;
    walkthrough) echo "grade" ;;
  esac
}
describe() { awk '/^description:/{sub(/^description: *"?/,""); sub(/"$/,""); print; exit}' "skills/$1/SKILL.md" | cut -c1-90; }

if [ "$LIST" = 1 ]; then
  for s in "${ALL[@]}"; do
    if [ -f "$DEST/$s/$MARK" ]; then st="installed"; elif [ -e "$DEST/$s" ]; then st="you have a different '$s'"; else st="-"; fi
    printf "%-14s %-26s %s\n" "$s" "$st" "$(describe "$s")"
  done
  exit 0
fi

[ ${#WANT[@]} -gt 0 ] || WANT=("${ALL[@]}")
PICK=()
add() {
  local s="$1" p
  [ -d "skills/$s" ] || { echo "no skill called '$s' here. Try: ./install.sh --list" >&2; exit 1; }
  for p in ${PICK[@]+"${PICK[@]}"}; do [ "$p" = "$s" ] && return 0; done
  PICK+=("$s")
  for p in $(needs "$s"); do add "$p"; done
}
for s in "${WANT[@]}"; do add "$s"; done

run() { if [ "$DRY" = 1 ]; then echo "  would run: $*"; else "$@"; fi; }
[ "$DRY" = 1 ] || mkdir -p "$DEST"
SRC_HEAD="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
done_list=(); skipped=()
for s in "${PICK[@]}"; do
  if [ -e "$DEST/$s" ]; then
    if [ -f "$DEST/$s/$MARK" ] && [ "$UPDATE" = 1 ]; then
      run rm -rf "$DEST/$s"
    elif [ -f "$DEST/$s/$MARK" ]; then
      skipped+=("$s (already installed; --update replaces it)"); continue
    else
      skipped+=("$s (you already have a skill called '$s'; left alone)"); continue
    fi
  fi
  run cp -R "skills/$s" "$DEST/$s"
  [ "$DRY" = 1 ] || echo "$SRC_HEAD" > "$DEST/$s/$MARK"
  done_list+=("$s")
done

echo
if [ ${#done_list[@]} -gt 0 ]; then
  echo "RESULT: installed into $DEST: ${done_list[*]}"
  echo "NEXT: type / in Claude Code and look for them (e.g. /${done_list[0]}). If they are not listed, start a new session."
else
  echo "RESULT: nothing new installed."
fi
for s in ${skipped[@]+"${skipped[@]}"}; do echo "SKIPPED: $s"; done
[ "$DRY" = 0 ] || echo "(dry run: nothing changed)"
