#!/usr/bin/env bash
# STAR RUNNER – Achievements (Tamper‑Proof)

ACH_FILE="$HOME/.star_runner_achievements.json"
SIG_FILE="$HOME/.star_runner_achievements.sig"

DEFAULT_ACHIEVEMENTS='[
  {"id":"First Flight","desc":"Play your first game","unlocked":false},
  {"id":"Survivor","desc":"Survive 60 seconds","unlocked":false},
  {"id":"Collector","desc":"Collect 100 crystals","unlocked":false},
  {"id":"Speed Runner","desc":"Reach max speed","unlocked":false},
  {"id":"Asteroid Destroyer","desc":"Destroy 50 asteroids","unlocked":false},
  {"id":"Level Up","desc":"Reach level 5","unlocked":false}
]'

# -----------------------------
# Internal security
# -----------------------------

hash_file() {
    sha256sum "$ACH_FILE" | awk '{print $1}'
}

lock_files() {
    chmod 400 "$ACH_FILE" "$SIG_FILE" 2>/dev/null
}

unlock_files() {
    chmod 600 "$ACH_FILE" "$SIG_FILE" 2>/dev/null
}

reset_achievements() {
    unlock_files
    echo "$DEFAULT_ACHIEVEMENTS" > "$ACH_FILE"
    hash_file > "$SIG_FILE"
    lock_files
}

verify_integrity() {
    [[ ! -f "$ACH_FILE" || ! -f "$SIG_FILE" ]] && return 1
    [[ "$(hash_file)" == "$(cat "$SIG_FILE")" ]]
}

# -----------------------------
# Public API
# -----------------------------

init_achievements() {
    if ! verify_integrity; then
        reset_achievements
    fi
}

unlock_achievement() {
    local id="$1"

    if jq -e --arg id "$id" '.[] | select(.id==$id and .unlocked==true)' "$ACH_FILE" >/dev/null; then
        return
    fi

    unlock_files
    jq --arg id "$id" '
      map(if .id==$id then .unlocked=true else . end)
    ' "$ACH_FILE" > "$ACH_FILE.tmp" && mv "$ACH_FILE.tmp" "$ACH_FILE"

    echo "🏆 ACHIEVEMENT UNLOCKED: $id"
    hash_file > "$SIG_FILE"
    lock_files
}

list_achievements() {
    echo "⭐ Achievements"
    echo "-----------------"
    jq -r '.[] | "\(.unlocked | if . then "✅" else "❌" end) \(.id) — \(.desc)"' "$ACH_FILE"
}

# -----------------------------
# First‑time setup
# -----------------------------

if [[ ! -f "$ACH_FILE" ]]; then
    reset_achievements
fi
