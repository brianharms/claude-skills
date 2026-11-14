#!/bin/bash
# Run before every push: is there anything in skills/ that belongs to the author and not to everyone?
#
#   tools/check.sh          exit 0 = clean, 1 = something to fix (each hit is printed with file:line)
#
# Looks for: the author's username, full name and home path; secret files and key names; session logs;
# real key values from ~/.secrets (names printed, never values); a skill calling another skill that is not in
# this repo; a SKILL.md without a name and description; anything gitleaks finds (if it is installed).
# Extra words to block (a domain, a project name) go one per line in tools/check.local, which is never committed.
set -uo pipefail
cd "$(dirname "$0")/.."
FLAG="$(mktemp)"; trap 'rm -f "$FLAG"' EXIT
hit() { echo "  $1"; echo x >> "$FLAG"; }   # works inside pipelines too

words=("$(id -un)" "$HOME")
full="$(id -F 2>/dev/null || true)"; [ -n "$full" ] && words+=("$full" "${full%% *}")
[ -f tools/check.local ] && while IFS= read -r w; do [ -n "$w" ] && [ "${w#\#}" = "$w" ] && words+=("$w"); done < tools/check.local

echo "▸ personal words"
for w in "${words[@]}"; do   # README and AGENTS name the GitHub account on purpose, so only the home path is checked there
  grep -rnI -i -F -- "$w" skills install.sh 2>/dev/null | while read -r l; do hit "$w: ${l:0:160}"; done
done
grep -nI -F -- "$HOME" README.md AGENTS.md 2>/dev/null | while read -r l; do hit "home path: ${l:0:160}"; done

echo "▸ secrets, key names, private paths"
grep -rnI -E '\.secrets/|api_keys\.sh|\.claude/(projects|memory)|[A-Z]+_API_KEY|FAL_KEY|BEGIN [A-Z ]*PRIVATE KEY|sk-[A-Za-z0-9]{20}' skills 2>/dev/null \
  | while read -r l; do hit "${l:0:160}"; done

echo "▸ session logs and working files"
find . -path ./.git -prune -o \( -iname 'SESSION_LOG*' -o -iname 'LOGS' \) -print | while read -r f; do
  git ls-files --error-unmatch "$f" >/dev/null 2>&1 && hit "tracked: $f"
done
git rev-list --all -- 'SESSION_LOG*' '*/SESSION_LOG*' 2>/dev/null | head -1 | while read -r c; do hit "a session log is in the history (commit $c)"; done

if [ -f "$HOME/.secrets/api_keys.sh" ]; then
  echo "▸ real key values from ~/.secrets"
  bash -c 'source "$HOME/.secrets/api_keys.sh" >/dev/null 2>&1
    for v in $(grep -o -E "^export [A-Z0-9_]+" "$HOME/.secrets/api_keys.sh" | cut -d" " -f2); do
      val="${!v}"; [ ${#val} -ge 8 ] || continue
      f=$(grep -rlF -- "$val" skills README.md AGENTS.md 2>/dev/null | head -1)
      [ -n "$f" ] && echo "  value of $v is in $f"
    done' | while read -r l; do hit "${l#  }"; done
fi

echo "▸ skills calling skills that are not here"
here=" $(ls skills | tr '\n' ' ')"
for f in skills/*/SKILL.md; do
  for n in $(grep -o -E '\.claude/skills/[a-z0-9-]+' "$f" | sed 's|.*/||' | sort -u); do   # by path, too
    case "$here" in *" $n "*) continue ;; esac
    hit "$f uses ~/.claude/skills/$n, which is not in this repo"
  done
  for c in $(grep -o -E '(^|[] `("'"'"'*>])/[a-z][a-z0-9-]{3,}' "$f" | grep -o -E '/[a-z0-9-]+' | sort -u); do
    n="${c#/}"
    case "$here" in *" $n "*) continue ;; esac
    case "$n" in tmp|dev|usr|opt|etc|var|users|private|compact|clear|help|model|config|loop|schedule) continue ;; esac
    ls "$HOME/.claude/skills/$n/SKILL.md" >/dev/null 2>&1 && hit "$f calls /$n, which is one of your skills but not in this repo"
  done
done

echo "▸ frontmatter"
for f in skills/*/SKILL.md; do
  head -1 "$f" | grep -q '^---$' && sed -n '2,8p' "$f" | grep -q '^name:' && sed -n '2,8p' "$f" | grep -q '^description:' \
    || hit "$f needs --- name: / description: --- at the top"
done

if command -v gitleaks >/dev/null 2>&1; then
  echo "▸ gitleaks"
  gitleaks dir skills --no-banner --redact >/dev/null 2>&1 || hit "gitleaks found something: gitleaks dir skills --redact"
fi

echo
if [ ! -s "$FLAG" ]; then echo "CLEAN"; exit 0; fi
echo "NOT CLEAN: fix the lines above before pushing"; exit 1
