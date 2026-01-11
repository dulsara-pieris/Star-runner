#!/usr/bin/env bash

# STAR RUNNER - Punishments Module (FULL FIXED)
# Author: Dulsara Pieris (SYNAPSNEX)
# Handles long-term and short-term punishments, fully reversible

# ------------------------------
# Config
# ------------------------------
LOW_SCORE_THRESHOLD=50        # Minimum score before punishment triggers
PUNISHMENT_DURATION=50        # Short-term punishment frames

# Short-term punishment
PUNISHMENT_ACTIVE=0
PUNISHMENT_TIMER=0

# Long-term punishment (persisted)
punishment_level=${punishment_level:-0}
punishment_expires=${punishment_expires:-0}

# Original profile backup (persisted)
punishment_backup_name="${punishment_backup_name:-}"
punishment_backup_gender="${punishment_backup_gender:-}"
punishment_backup_title="${punishment_backup_title:-}"
punishment_backup_skin="${punishment_backup_skin:-}"
punishment_backup_ship="${punishment_backup_ship:-}"
punishment_backup_ammo="${punishment_backup_ammo:-}"

FUNNY_NAMES=("AsteroidMagnet" "NoobSauce" "TrashPilot" "SpacePeasant" "NeuralTrash" "OopsiePilot")
PUNISHMENT_SKINS=(5 4 3)

# ------------------------------
# Backup original profile before long-term punishment
# ------------------------------
backup_profile_for_punishment() {
    if [ -z "$punishment_backup_name" ]; then
        punishment_backup_name="$player_name"
        punishment_backup_gender="$player_gender"
        punishment_backup_title="$player_title"
        punishment_backup_skin="$current_skin"
        punishment_backup_ship="$current_ship"
        punishment_backup_ammo="$ammo"
    fi
}

# ------------------------------
# Restore profile after long-term punishment expires
# ------------------------------
restore_profile_after_punishment() {
    player_name="$punishment_backup_name"
    player_gender="$punishment_backup_gender"
    player_title="$punishment_backup_title"
    current_skin="$punishment_backup_skin"
    current_ship="$punishment_backup_ship"
    ammo="$punishment_backup_ammo"

    # Clear punishment state
    punishment_level=0
    punishment_expires=0
    punishment_backup_name=""
    punishment_backup_gender=""
    punishment_backup_title=""
    punishment_backup_skin=""
    punishment_backup_ship=""
    punishment_backup_ammo=""

    save_profile
    printf "$COLOR_GREEN ✓ Your profile has been restored to normal! $COLOR_NEUTRAL\n"
}

# ------------------------------
# Apply long-term punishment
# ------------------------------
apply_long_term_punishment() {
    current_time=$(date +%s)

    # Initialize level if not set
    punishment_level=${punishment_level:-0}

    # Backup original profile if first punishment
    if [ "${#punishment_backup[@]}" -eq 0 ]; then
        punishment_backup=("$player_name" "$player_gender" "$player_title" "$current_skin" "$current_ship" "$ammo")
    fi

    # Check if punishment is active
    if [ "$punishment_expires" -gt "$current_time" ]; then
        # Escalate
        punishment_level=$((punishment_level + 1))

        # Duration doubles each time
        prev_days=${punishment_prev_days:-3}
        days=$(( prev_days * 2 ))
        punishment_prev_days=$days
        punishment_expires=$((current_time + days*24*60*60))

        # Flip gender/title every time
        orig_gender="${punishment_backup[1]}"
        case "$orig_gender" in
            "Male") player_gender="Female"; player_title="Madam" ;;
            "Female") player_gender="Male"; player_title="Sir" ;;
            *) player_gender="Alien"; player_title="Mx" ;;
        esac

        # Apply ugly skin, weakest ship, low ammo
        player_name=${FUNNY_NAMES[$RANDOM % ${#FUNNY_NAMES[@]}]}
        current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
        current_ship=1
        ammo=$((ammo / 2))
        [ "$ammo" -lt 1 ] && ammo=1

        # Make name permanent if level >= 3
        if [ "$punishment_level" -ge 3 ]; then
            punishment_backup[0]="$player_name"
        fi

        save_profile
        printf "$COLOR_RED ⚠ Punishment escalated! Level: $punishment_level, Name: $player_name, Gender: $player_gender, Duration: $days day(s) $COLOR_NEUTRAL\n"
        return
    fi

    # First-time punishment
    punishment_level=1
    days=3
    punishment_prev_days=$days
    punishment_expires=$((current_time + days*24*60*60))

    # Flip gender/title
    case "$player_gender" in
        "Male") player_gender="Female"; player_title="Madam" ;;
        "Female") player_gender="Male"; player_title="Sir" ;;
        *) player_gender="Alien"; player_title="Mx" ;;
    esac

    # Ugly skin, weak ship, low ammo
    player_name=${FUNNY_NAMES[$RANDOM % ${#FUNNY_NAMES[@]}]}
    current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
    current_ship=1
    ammo=$((ammo / 2))
    [ "$ammo" -lt 1 ] && ammo=1

    save_profile
    printf "$COLOR_RED ⚠ Punishment applied for $days day(s)! Level: $punishment_level, Name: $player_name, Gender: $player_gender $COLOR_NEUTRAL\n"
}


# ------------------------------
# Check if long-term punishment expired
# ------------------------------
check_long_term_punishment() {
    local current_time
    current_time=$(date +%s)
    if [ "$punishment_expires" -le "$current_time" ] && [ -n "$punishment_backup_name" ]; then
        restore_profile_after_punishment
    fi
}

# ------------------------------
# Short-term chaos punishment
# ------------------------------
apply_short_punishment() {
    if [ "$PUNISHMENT_ACTIVE" -eq 1 ]; then return; fi
    PUNISHMENT_ACTIVE=1
    PUNISHMENT_TIMER=$PUNISHMENT_DURATION

    printf "\n$COLOR_RED ✗ Chaos punishment activated! $COLOR_NEUTRAL\n"

    # Reduce ship speed
    local original_speed
    original_speed=$(get_ship_speed "$current_ship")
    local new_speed=$((original_speed - 1))
    [ "$new_speed" -lt 1 ] && new_speed=1
    set_ship_speed "$current_ship" "$new_speed"

    # Halve ammo
    ammo=$((ammo / 2))
    [ "$ammo" -lt 1 ] && ammo=1

    # Blink ship effect
    blink_ship_effect

    # Spawn extra asteroids
    for i in {1..5}; do spawn_asteroid; done

    # Force ugly skin temporarily
    old_skin="$current_skin"
    current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
}

# ------------------------------
# Punishment tick (call per frame)
# ------------------------------
punishment_tick() {
    if [ "$PUNISHMENT_ACTIVE" -eq 1 ]; then
        [ $((frame % 5)) -eq 0 ] && draw_ship
        PUNISHMENT_TIMER=$((PUNISHMENT_TIMER - 1))
        if [ "$PUNISHMENT_TIMER" -le 0 ]; then
            PUNISHMENT_ACTIVE=0
            ammo=$(get_ship_ammo "$current_ship")
            set_ship_speed "$current_ship" "$(get_ship_speed "$current_ship")"
            current_skin="$old_skin"
            printf "$COLOR_GREEN ✓ Chaos punishment ended! $COLOR_NEUTRAL\n"
        fi
    fi
}

# ------------------------------
# Blink ship effect
# ------------------------------
blink_ship_effect() {
    for i in {1..3}; do
        clear
        draw_border
        sleep 0.1
        draw_ship
        sleep 0.1
    done
}

# ------------------------------
# Trigger punishments if score is low
# ------------------------------
check_low_score_punishment() {
    if [ "$score" -lt "$LOW_SCORE_THRESHOLD" ]; then
        apply_short_punishment
        apply_long_term_punishment
    fi
}
