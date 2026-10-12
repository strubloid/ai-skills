#!/usr/bin/env bash
# uninstall.sh - Remove the skills-sync setup and (optionally) its outputs.
#
# Usage:
#   ./uninstall.sh                 interactive: command + state; asks before
#                                  removing installed skills from each target.
#   ./uninstall.sh --purge         also remove skills from every configured
#                                  target without asking.
#   ./uninstall.sh --keep-skills   remove command + state, leave skills alone.
#   ./uninstall.sh --dry-run       show what would happen, do nothing.
#   ./uninstall.sh --help          this help.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${SKILLS_SYNC_STATE_DIR:-$HOME/.config/skills-sync}"
STATE_FILE="$STATE_DIR/state.conf"
UPDATE_CMD_PATH="$HOME/.local/bin/update-skills"

log()  { printf '\033[1;34m[skills]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[skills]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m[skills]\033[0m %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

# Parse state.
SKILLS_TARGETS=()
SKILLS_INSTALLED=()

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
}

# Remove a skill from a target directory only if it exists.
purge_skill() {
  local target_path="$1" name="$2" dry_run="$3"
  if [[ -d "$target_path/$name" ]]; then
    if (( dry_run )); then
      log "  - would remove $target_path/$name"
    else
      rm -rf "$target_path/$name"
      log "  - removed  $target_path/$name"
    fi
    return 0
  fi
  return 1
}

purge_target() {
  local tool="$1" path="$2" enabled="$3" dry_run="$4"
  (( enabled == 1 )) || { log "skip  $tool ($path) — disabled in state"; return 0; }
  [[ -d "$path" ]] || { warn "$tool target missing: $path"; return 0; }

  local removed=0 kept=0 name
  for name in "${SKILLS_INSTALLED[@]:-}"; do
    [[ -z "$name" ]] && continue
    if purge_skill "$path" "$name" "$dry_run"; then
      removed=$((removed+1))
    else
      kept=$((kept+1))
    fi
  done
  printf '%d\t%d\n' "$removed" "$kept"
}

usage() {
  cat <<EOF
uninstall.sh — remove the skills-sync setup installed by install.sh.

By default: removes the \`update-skills\` command and the state file,
then asks before removing synced skills from each configured target.

  ./uninstall.sh                 interactive (default)
  ./uninstall.sh --keep-skills   keep skills in target dirs
  ./uninstall.sh --purge         remove skills without asking
  ./uninstall.sh --dry-run       show what would happen
  ./uninstall.sh --help          this help
EOF
}

main() {
  local mode="" dry_run=0
  for arg in "$@"; do
    case "$arg" in
      --purge)        mode="purge" ;;
      --keep-skills)  mode="keep" ;;
      --dry-run|-n)   dry_run=1; mode="dry" ;;
      --help|-h)      usage; exit 0 ;;
      *)              usage >&2; exit 1 ;;
    esac
  done
  [[ -z "$mode" ]] && mode="interactive"

  load_state

  echo
  log "== uninstall =="
  echo "state file: $STATE_FILE $( [[ -f "$STATE_FILE" ]] && echo "(present)" || echo "(missing)" )"
  echo "command:    $UPDATE_CMD_PATH $( [[ -x "$UPDATE_CMD_PATH" ]] && echo "(installed)" || echo "(missing)" )"
  echo "targets:    ${#SKILLS_TARGETS[@]}"
  echo "managed:    ${#SKILLS_INSTALLED[@]} skill(s)"
  echo

  if (( ${#SKILLS_TARGETS[@]} == 0 )) && [[ ! -f "$STATE_FILE" ]] && [[ ! -x "$UPDATE_CMD_PATH" ]]; then
    warn "nothing to uninstall."
    exit 0
  fi

  # Decide skill-removal behavior.
  local remove_skills="no"
  case "$mode" in
    purge)    remove_skills="yes" ;;
    keep)     remove_skills="no" ;;
    dry)      remove_skills="preview" ;;
    interactive)
      if [[ ${#SKILLS_INSTALLED[@]} -gt 0 ]]; then
        read -r -p "Remove synced skills from each target? [y/N] " ans
        [[ "$ans" =~ ^[Yy]([Ee][Ss])?$ ]] && remove_skills="yes" || remove_skills="no"
      fi
      ;;
  esac

  # Purge per target.
  if [[ "$remove_skills" != "no" ]]; then
    local e tool path en grand_removed=0 grand_kept=0 removed kept
    for e in "${SKILLS_TARGETS[@]:-}"; do
      [[ -z "$e" ]] && continue
      IFS='|' read -r tool path en <<<"$e"
      log "purge $tool -> $path"
      stats="$(purge_target "$tool" "$path" "$en" "$dry_run")"
      IFS=$'\t' read -r removed kept <<<"$stats"
      grand_removed=$((grand_removed+removed))
      grand_kept=$((grand_kept+kept))
      printf '       %d removed\n' "$removed"
    done
    echo
    if (( dry_run )); then
      log "would remove $grand_removed skill(s) total."
    else
      log "removed  $grand_removed skill(s) total."
    fi
  else
    log "keeping skills in target dirs."
  fi

  # Remove the command wrapper.
  if [[ -e "$UPDATE_CMD_PATH" ]]; then
    if (( dry_run )); then
      log "would remove $UPDATE_CMD_PATH"
    else
      rm -f "$UPDATE_CMD_PATH"
      log "removed $UPDATE_CMD_PATH"
    fi
  else
    log "$UPDATE_CMD_PATH not present."
  fi

  # Remove the state file (and dir if empty).
  if [[ -f "$STATE_FILE" ]]; then
    if (( dry_run )); then
      log "would remove $STATE_FILE"
    else
      rm -f "$STATE_FILE"
      log "removed $STATE_FILE"
      rmdir "$STATE_DIR" 2>/dev/null || true
    fi
  else
    log "$STATE_FILE not present."
  fi

  echo
  if (( dry_run )); then
    log "dry-run complete. nothing was changed."
  else
    log "uninstall complete."
    if [[ -d "$SCRIPT_DIR" ]]; then
      log "the install script itself was left in place at: $SCRIPT_DIR"
      log "delete it manually if you no longer need it."
    fi
  fi
}

main "$@"