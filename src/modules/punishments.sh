#!/usr/bin/env bash

# STAR RUNNER - SUPER BRUTAL Punishments Module
# Author: Dulsara Pieris (SYNAPSNEX)
# THE MOST PUNISHING SYSTEM EVER CREATED

# ============================================================================
# INTEGRATION - COPY THIS TO YOUR MAIN GAME LOOP
# ============================================================================
# 
# # At the start of game loop:
# punishment_tick
# check_long_term_punishment
#
# # For input (REPLACE YOUR INPUT HANDLING):
# read -t 0.05 -n 1 key
# handle_input_with_punishment "$key"  # This does EVERYTHING
#
# # When checking score:
# check_low_score_punishment
#
# ============================================================================

# Config
LOW_SCORE_THRESHOLD=150
SUPER_PUNISHMENT_THRESHOLD=100
EXTREME_LOSER_THRESHOLD=50

# Punishment state
PUNISHMENT_ACTIVE=0
PUNISHMENT_TIMER=0
PUNISHMENT_LEVEL=0

# Long-term punishment
punishment_level=${punishment_level:-0}
punishment_expires=${punishment_expires:-0}
punishment_prev_days=${punishment_prev_days:-0}

# Backups
punishment_backup_name="${punishment_backup_name:-}"
punishment_backup_gender="${punishment_backup_gender:-}"
punishment_backup_title="${punishment_backup_title:-}"
punishment_backup_skin="${punishment_backup_skin:-}"
punishment_backup_ship="${punishment_backup_ship:-}"
punishment_backup_ammo="${punishment_backup_ammo:-}"

# Effects
REVERSE_CONTROLS=0
DRUNK_MODE=0
RANDOM_TELEPORT=0
SHRINKING_SHIP=0
INVERTED_SCREEN=0
CHAOS_MODE=0
DIZZY_MODE=0
BLIND_MODE=0

get_ship_pos_x() { echo "${ship_column:-${ship_x:-10}}"; }
get_ship_pos_y() { echo "${ship_line:-${ship_y:-10}}"; }
set_ship_pos_x() { ship_column="$1"; ship_x="$1"; }
set_ship_pos_y() { ship_line="$1"; ship_y="$1"; }
get_max_width() { echo "${NUM_COLUMNS:-${WIDTH:-80}}"; }
get_max_height() { echo "${NUM_LINES:-${HEIGHT:-25}}"; }

sync_effects_from_level() {
    REVERSE_CONTROLS=0
    DRUNK_MODE=0
    RANDOM_TELEPORT=0
    CHAOS_MODE=0
    DIZZY_MODE=0
    BLIND_MODE=0
    SHRINKING_SHIP=0
    INVERTED_SCREEN=0

    [ "$punishment_level" -ge 1 ] && DRUNK_MODE=1
    [ "$punishment_level" -ge 2 ] && REVERSE_CONTROLS=1
    [ "$punishment_level" -ge 3 ] && RANDOM_TELEPORT=1 && CHAOS_MODE=1
    [ "$punishment_level" -ge 4 ] && DIZZY_MODE=1 && INVERTED_SCREEN=1
    [ "$punishment_level" -ge 5 ] && BLIND_MODE=1 && SHRINKING_SHIP=1
}

calculate_punishment_days() {
    case "${1:-1}" in
        1) echo 3 ;;
        2) echo 7 ;;
        3) echo 14 ;;
        4) echo 30 ;;
        5) echo 60 ;;
        *) echo 90 ;;
    esac
}

# Names and titles
LOSER_NAMES=(
    "TotalTrash" "EpicFailure" "DisasterPilot" "CrashMaster"
    "SpaceGarbage" "CosmicWaste" "StellarIdiot" "GalaxyShame"
    "AsteroidFood" "NebulaNoob" "VoidLoser" "QuasarQuitter"
    "TrashCompactor" "FailFactory" "DisasterClass" "WorthlessWreck"
)

LOSER_TITLES=(
    "the Pathetic" "the Worthless" "the Incompetent" "the Disaster"
    "the Failure" "the Embarrassment" "the Joke" "the Laughingstock"
    "the Useless" "the Hopeless" "the Terrible" "the Abysmal"
)

PUNISHMENT_SKINS=(5 4 3)

INSULTS=(
    "PATHETIC! Even space debris flies better!"
    "Your ancestors are ASHAMED!"
    "DISGRACEFUL PERFORMANCE!"
    "Are you TRYING to fail?!"
    "A TRAINED MONKEY could do better!"
    "WORTHLESS PILOT DETECTED!"
    "GARBAGE! ABSOLUTE GARBAGE!"
    "The galaxy MOCKS you!"
    "Your flight school wants a REFUND!"
    "WORST. PILOT. EVER."
    "Git gud, SCRUB!"
    "You're making EVERYONE look bad!"
)

# ============================================================================
# BACKUP AND RESTORE
# ============================================================================

backup_profile() {
    if [ -z "$punishment_backup_name" ]; then
        punishment_backup_name="${player_name:-Unknown}"
        punishment_backup_gender="${player_gender:-Male}"
        punishment_backup_title="${player_title:-Sir}"
        punishment_backup_skin="${current_skin:-1}"
        punishment_backup_ship="${current_ship:-1}"
        punishment_backup_ammo="${ammo:-10}"
    fi
}

restore_profile() {
    player_name="$punishment_backup_name"
    player_gender="$punishment_backup_gender"
    player_title="$punishment_backup_title"
    current_skin="$punishment_backup_skin"
    current_ship="$punishment_backup_ship"
    ammo="$punishment_backup_ammo"
    
    punishment_level=0
    punishment_expires=0
    punishment_backup_name=""
    punishment_backup_gender=""
    punishment_backup_title=""
    punishment_backup_skin=""
    punishment_backup_ship=""
    punishment_backup_ammo=""
    
    REVERSE_CONTROLS=0
    DRUNK_MODE=0
    RANDOM_TELEPORT=0
    SHRINKING_SHIP=0
    INVERTED_SCREEN=0
    CHAOS_MODE=0
    DIZZY_MODE=0
    BLIND_MODE=0
    
    [ "$(type -t save_profile)" = "function" ] && save_profile
    echo -e "\033[32m ✓ Punishment expired! Profile restored. \033[0m"
}

# ============================================================================
# LONG-TERM PUNISHMENT (PERSISTENT)
# ============================================================================

apply_long_term_punishment() {
    local current_time=$(date +%s)
    punishment_level=${punishment_level:-0}
    
    backup_profile
    
    # Escalate if already punished
    if [ "$punishment_expires" -gt "$current_time" ]; then
        punishment_level=$((punishment_level + 1))
        local days
        days=$(calculate_punishment_days "$punishment_level")
        punishment_prev_days=$days
        punishment_expires=$((current_time + days*24*60*60))
    else
        # First punishment
        punishment_level=1
        local days=3
        punishment_prev_days=$days
        punishment_expires=$((current_time + days*24*60*60))
    fi
    
    # INVERT GENDER FROM ORIGINAL
    case "$punishment_backup_gender" in
        "Male")
            player_gender="Female"
            player_title="Lady ${LOSER_TITLES[$RANDOM % ${#LOSER_TITLES[@]}]}"
            ;;
        "Female")
            player_gender="Male"
            player_title="Lord ${LOSER_TITLES[$RANDOM % ${#LOSER_TITLES[@]}]}"
            ;;
        *)
            player_gender="Alien"
            player_title="Entity ${LOSER_TITLES[$RANDOM % ${#LOSER_TITLES[@]}]}"
            ;;
    esac
    
    # ESCALATING NAMES
    local base="${LOSER_NAMES[$RANDOM % ${#LOSER_NAMES[@]}]}"
    case $punishment_level in
        1) player_name="$base" ;;
        2) player_name="${base}9000" ;;
        3) player_name="xXx_${base}_xXx" ;;
        4) player_name="${base}_FAIL" ;;
        *) player_name="ULTIMATE_${base}_666" ;;
    esac
    
    # Downgrades
    current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
    current_ship=1
    ammo=$((ammo / 3))
    [ "$ammo" -lt 1 ] && ammo=1
    
    # Make name permanent at level 3+
    if [ "$punishment_level" -ge 3 ]; then
        punishment_backup_name="$player_name"
        echo -e "\033[31m ☠ YOUR SHAMEFUL NAME IS NOW PERMANENT! ☠ \033[0m"
    fi
    
    # Activate progressive effects
    sync_effects_from_level
    
    [ "$(type -t save_profile)" = "function" ] && save_profile
    
    echo -e "\033[31m"
    echo "╔═══════════════════════════════════════════╗"
    echo "║   ⚠ PUNISHMENT LEVEL $punishment_level ACTIVATED ⚠       ║"
    echo "╠═══════════════════════════════════════════╣"
    printf "║ Name: %-37s ║\n" "$player_name"
    printf "║ Title: %-36s ║\n" "$player_title"
    printf "║ Gender: %-35s ║\n" "$player_gender"
    printf "║ Duration: %-32s ║\n" "${days} day(s)"
    echo "╠═══════════════════════════════════════════╣"
    [ "$REVERSE_CONTROLS" -eq 1 ] && echo "║ 🔄 REVERSE CONTROLS                       ║"
    [ "$DRUNK_MODE" -eq 1 ] && echo "║ 🍺 DRUNK MODE                             ║"
    [ "$RANDOM_TELEPORT" -eq 1 ] && echo "║ 🌀 RANDOM TELEPORTS                       ║"
    [ "$CHAOS_MODE" -eq 1 ] && echo "║ 💥 CHAOS MODE                             ║"
    [ "$DIZZY_MODE" -eq 1 ] && echo "║ 😵 DIZZY MODE                             ║"
    [ "$BLIND_MODE" -eq 1 ] && echo "║ 🕶️ BLIND MODE                             ║"
    [ "$SHRINKING_SHIP" -eq 1 ] && echo "║ 📉 SHRINKING SHIP                         ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "\033[0m"
}

check_long_term_punishment() {
    local current_time=$(date +%s)
    if [ "$punishment_expires" -gt 0 ] && [ "$punishment_expires" -le "$current_time" ] && [ -n "$punishment_backup_name" ]; then
        restore_profile
    elif [ "$punishment_expires" -gt "$current_time" ] && [ "$punishment_level" -gt 0 ]; then
        sync_effects_from_level
    fi
}

# ============================================================================
# SHORT-TERM PUNISHMENT (IMMEDIATE CHAOS)
# ============================================================================

apply_short_punishment() {
    [ "$PUNISHMENT_ACTIVE" -eq 1 ] && return
    
    PUNISHMENT_ACTIVE=1
    PUNISHMENT_TIMER=100
    
    echo -e "\n\033[31m ${INSULTS[$RANDOM % ${#INSULTS[@]}]} \033[0m"
    
    # Spawn asteroids based on score
    local asteroid_count=10
    [ "${score:-0}" -lt "$SUPER_PUNISHMENT_THRESHOLD" ] && asteroid_count=20
    [ "${score:-0}" -lt "$EXTREME_LOSER_THRESHOLD" ] && asteroid_count=30
    
    if [ "${score:-0}" -lt "$EXTREME_LOSER_THRESHOLD" ]; then
        echo -e "\033[31m"
        echo "╔═══════════════════════════════════════════╗"
        echo "║ ☠☠☠ EXTREME LOSER DETECTED! ☠☠☠          ║"
        echo "║ YOU ARE A DISGRACE TO ALL PILOTS!        ║"
        echo "╚═══════════════════════════════════════════╝"
        echo -e "\033[0m"
    fi
    
    for i in $(seq 1 $asteroid_count); do
        [ "$(type -t spawn_asteroid)" = "function" ] && spawn_asteroid
    done
    
    # Reduce ammo brutally
    ammo=$((ammo / 4))
    [ "$ammo" -lt 1 ] && ammo=1
    
    # Activate random effect
    case $((RANDOM % 8)) in
        0) REVERSE_CONTROLS=1; echo -e "\033[33m ⬅➡ CONTROLS REVERSED! \033[0m" ;;
        1) DRUNK_MODE=1; echo -e "\033[33m 🍺 DRUNK MODE! \033[0m" ;;
        2) RANDOM_TELEPORT=1; echo -e "\033[33m 🌀 RANDOM TELEPORTS! \033[0m" ;;
        3) CHAOS_MODE=1; echo -e "\033[33m 💥 CHAOS MODE! \033[0m" ;;
        4) DIZZY_MODE=1; echo -e "\033[33m 😵 DIZZY MODE! \033[0m" ;;
        5) BLIND_MODE=1; echo -e "\033[33m 🕶️ BLIND MODE! \033[0m" ;;
        6) SHRINKING_SHIP=1; echo -e "\033[33m 📉 SHRINKING SHIP! \033[0m" ;;
        7) INVERTED_SCREEN=1; echo -e "\033[33m 🙃 SCREEN INVERTED! \033[0m" ;;
    esac
    
    flash_screen
}

# ============================================================================
# INPUT HANDLING WITH PUNISHMENT EFFECTS
# ============================================================================

handle_input_with_punishment() {
    local key="$1"
    
    # Empty input
    [ -z "$key" ] && return
    
    # Store original for comparison
    local original_key="$key"
    
    # REVERSE CONTROLS
    if [ "$REVERSE_CONTROLS" -eq 1 ]; then
        case "$key" in
            A) key="B" ;;
            B) key="A" ;;
            C) key="D" ;;
            D) key="C" ;;
        esac
    fi
    
    # DIZZY MODE - randomly swap directions
    if [ "$DIZZY_MODE" -eq 1 ] && [ $((RANDOM % 3)) -eq 0 ]; then
        case "$key" in
            A|B|C|D) key="$(echo -e "A\nB\nC\nD" | shuf -n1)" ;;
        esac
    fi

    printf "%s" "$key"
}

get_punishment_time_left() {
    local now=$(date +%s)
    local left=$((punishment_expires - now))
    [ "$left" -lt 0 ] && left=0
    echo "$left"
}

get_punishment_status_text() {
    local left
    left=$(get_punishment_time_left)
    [ "$left" -le 0 ] && { echo "CLEAR"; return; }
    local days=$((left / 86400))
    local hours=$(((left % 86400) / 3600))
    echo "P$punishment_level ${days}d ${hours}h"
}

# ============================================================================
# PUNISHMENT TICK - CALL EVERY FRAME
# ============================================================================

punishment_tick() {
    [ "$PUNISHMENT_ACTIVE" -eq 0 ] && [ "$punishment_level" -eq 0 ] && return
    
    # DRUNK MODE - random drift
    if [ "$DRUNK_MODE" -eq 1 ] && [ $((RANDOM % 3)) -eq 0 ]; then
        local max_w max_h ship_x ship_y
        max_w=$(get_max_width)
        max_h=$(get_max_height)
        ship_x=$(get_ship_pos_x)
        ship_y=$(get_ship_pos_y)

        ship_x=$((ship_x + (RANDOM % 3 - 1)))
        ship_y=$((ship_y + (RANDOM % 3 - 1)))
        [ "$ship_y" -lt 3 ] && ship_y=3
        [ "$ship_y" -gt $((max_h - 2)) ] && ship_y=$((max_h - 2))
        [ "$ship_x" -lt 5 ] && ship_x=5
        [ "$ship_x" -gt $((max_w - 10)) ] && ship_x=$((max_w - 10))
        set_ship_pos_x "$ship_x"
        set_ship_pos_y "$ship_y"
    fi
    
    # RANDOM TELEPORT
    if [ "$RANDOM_TELEPORT" -eq 1 ] && [ $((RANDOM % 25)) -eq 0 ]; then
        local max_w max_h
        max_w=$(get_max_width)
        max_h=$(get_max_height)
        set_ship_pos_x $((RANDOM % (max_w - 15) + 5))
        set_ship_pos_y $((RANDOM % (max_h - 8) + 4))
        echo -e "\033[33m ⚡ TELEPORTED! \033[0m"
        flash_screen
    fi
    
    # CHAOS MODE - spawn random asteroids
    if [ "$CHAOS_MODE" -eq 1 ] && [ $((RANDOM % 15)) -eq 0 ]; then
        [ "$(type -t spawn_asteroid)" = "function" ] && spawn_asteroid
    fi
    
    # BLIND MODE - clear parts of screen
    if [ "$BLIND_MODE" -eq 1 ] && [ $((RANDOM % 5)) -eq 0 ]; then
        for i in {1..5}; do
            local max_w max_h blind_y blind_x
            max_w=$(get_max_width)
            max_h=$(get_max_height)
            blind_y=$((RANDOM % max_h))
            blind_x=$((RANDOM % max_w))
            tput cup "$blind_y" "$blind_x" 2>/dev/null && printf "   "
        done
    fi
    
    # Countdown short-term punishment
    if [ "$PUNISHMENT_ACTIVE" -eq 1 ]; then
        PUNISHMENT_TIMER=$((PUNISHMENT_TIMER - 1))
        
        if [ "$PUNISHMENT_TIMER" -le 0 ]; then
            PUNISHMENT_ACTIVE=0
            REVERSE_CONTROLS=0
            DRUNK_MODE=0
            RANDOM_TELEPORT=0
            CHAOS_MODE=0
            DIZZY_MODE=0
            BLIND_MODE=0
            SHRINKING_SHIP=0
            INVERTED_SCREEN=0
            echo -e "\033[32m ✓ Short punishment ended! \033[0m"
        fi
    fi
}

# ============================================================================
# VISUAL EFFECTS
# ============================================================================

flash_screen() {
    for i in {1..3}; do
        tput cup 0 0 2>/dev/null
        sleep 0.05
    done
}

# ============================================================================
# PUNISHMENT TRIGGERS
# ============================================================================

check_low_score_punishment() {
    if [ "${score:-0}" -lt "$LOW_SCORE_THRESHOLD" ]; then
        apply_short_punishment
        apply_long_term_punishment
        
        [ "${score:-0}" -lt "$SUPER_PUNISHMENT_THRESHOLD" ] && echo -e "\033[31m ${INSULTS[$RANDOM % ${#INSULTS[@]}]} \033[0m"
        [ "${score:-0}" -lt "$EXTREME_LOSER_THRESHOLD" ] && echo -e "\033[31m ${INSULTS[$RANDOM % ${#INSULTS[@]}]} \033[0m"
    fi
}

# ============================================================================
# HALL OF SHAME
# ============================================================================

SHAME_FILE="${GAME_DIR:-.}/.hall_of_shame"

add_to_hall_of_shame() {
    echo "${1:-0}|${2:-Unknown}|$(date '+%Y-%m-%d %H:%M')" >> "$SHAME_FILE"
    echo -e "\033[31m"
    echo "╔═══════════════════════════════════════════╗"
    echo "║  📜 ADDED TO HALL OF SHAME! 📜            ║"
    echo "║  Your failure is now PERMANENT!          ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "\033[0m"
}

show_hall_of_shame() {
    [ ! -f "$SHAME_FILE" ] && return
    
    echo -e "\n\033[31m"
    echo "╔═══════════════════════════════════════════╗"
    echo "║         HALL OF SHAME (Top 10)           ║"
    echo "╠═══════════════════════════════════════════╣"
    sort -t'|' -k1 -n "$SHAME_FILE" 2>/dev/null | head -10 | while IFS='|' read -r sc nm dt; do
        printf "║ %-5s | %-20s | %-10s ║\n" "$sc" "${nm:0:20}" "${dt:0:10}"
    done
    echo "╚═══════════════════════════════════════════╝"
    echo -e "\033[0m"
}

check_and_add_to_shame() {
    [ "${score:-0}" -lt "$EXTREME_LOSER_THRESHOLD" ] && add_to_hall_of_shame "${score:-0}" "${player_name:-Unknown}"
}

# ============================================================================
# EXPORT FUNCTIONS FOR GAME LOOP
# ============================================================================
export -f handle_input_with_punishment
export -f punishment_tick
export -f get_punishment_status_text
export -f check_low_score_punishment
export -f check_long_term_punishment
export -f check_and_add_to_shame
export -f show_hall_of_shame
