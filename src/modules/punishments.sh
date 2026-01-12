#!/usr/bin/env bash

# STAR RUNNER - Enhanced Punishments Module (SUPER FUNNY EDITION)
# Author: Dulsara Pieris (SYNAPSNEX)
# Handles long-term and short-term punishments with hilarious extras

# ------------------------------
# Config
# ------------------------------
LOW_SCORE_THRESHOLD=150
PUNISHMENT_DURATION=50
SUPER_PUNISHMENT_THRESHOLD=100  # Extra harsh below this score

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

# Expanded funny names with more variety
FUNNY_NAMES=(
    "AsteroidMagnet" "NoobSauce" "TrashPilot" "SpacePeasant" 
    "NeuralTrash" "OopsiePilot" "FailCaptain" "CrashDummy"
    "StellarLoser" "CosmicClown" "OrbitIdiot" "GalaxyGarbage"
    "StarScrub" "NebulaNincompoop" "VoidVillain" "QuasarQuitter"
    "PlanetPeon" "MeteorMoron" "CometCadet" "LunarLunatic"
)

# Expanded funny titles
FUNNY_TITLES=(
    "Lord of Fails" "Duke of Disasters" "Baron of Blunders"
    "Count of Crashes" "Prince of Poor Plays" "Knight of Nonsense"
    "Supreme Scrub" "Master of Mistakes" "Champion of Chaos"
    "Warden of Wrecks" "Admiral of Accidents" "General of Goofs"
)

PUNISHMENT_SKINS=(5 4 3)

# Super punishment effects
REVERSE_CONTROLS=0
DRUNK_MODE=0
UPSIDE_DOWN=0
RANDOM_TELEPORT=0
SHRINKING_SHIP=0

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

    # Reset super punishments
    REVERSE_CONTROLS=0
    DRUNK_MODE=0
    UPSIDE_DOWN=0
    RANDOM_TELEPORT=0
    SHRINKING_SHIP=0

    save_profile
    printf "$COLOR_GREEN ✓ Your profile has been restored to normal! $COLOR_NEUTRAL\n"
}

# ------------------------------
# Apply long-term punishment with escalating hilarity
# ------------------------------
apply_long_term_punishment() {
    current_time=$(date +%s)
    punishment_level=${punishment_level:-0}

    # Backup original profile if first punishment
    if [ -z "$punishment_backup_name" ]; then
        backup_profile_for_punishment
        last_flip_gender="$player_gender"
    fi

    # Check if punishment is active (escalate)
    if [ "$punishment_expires" -gt "$current_time" ]; then
        punishment_level=$((punishment_level + 1))

        # Duration doubles each time
        prev_days=${punishment_prev_days:-3}
        days=$(( prev_days * 2 ))
        punishment_prev_days=$days
        punishment_expires=$((current_time + days*24*60*60))

        # Flip gender based on last applied flip
        case "$last_flip_gender" in
            "Male")
                player_gender="Female"
                player_title="Madam ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
                last_flip_gender="Female"
                ;;
            "Female")
                player_gender="Male"
                player_title="Sir ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
                last_flip_gender="Male"
                ;;
            *)
                player_gender="Alien"
                player_title="Mx ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
                last_flip_gender="Alien"
                ;;
        esac

        # Get increasingly ridiculous name
        player_name="${FUNNY_NAMES[$RANDOM % ${#FUNNY_NAMES[@]}]}"
        
        # Add numbers for extra humiliation at high levels
        if [ "$punishment_level" -ge 2 ]; then
            player_name="${player_name}$RANDOM"
        fi
        
        if [ "$punishment_level" -ge 4 ]; then
            player_name="${player_name}_THE_WORST"
        fi

        # Apply ugly skin, weakest ship, low ammo
        current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
        current_ship=1
        ammo=$((ammo / 2))
        [ "$ammo" -lt 1 ] && ammo=1

        # Make name permanent if level >= 3
        if [ "$punishment_level" -ge 3 ]; then
            punishment_backup_name="$player_name"
        fi

        # Activate super punishments at higher levels
        if [ "$punishment_level" -ge 2 ]; then
            REVERSE_CONTROLS=1
        fi
        if [ "$punishment_level" -ge 3 ]; then
            DRUNK_MODE=1
        fi
        if [ "$punishment_level" -ge 4 ]; then
            RANDOM_TELEPORT=1
        fi
        if [ "$punishment_level" -ge 5 ]; then
            SHRINKING_SHIP=1
            printf "$COLOR_RED ☠ MAXIMUM PUNISHMENT! You are the shame of the galaxy! ☠ $COLOR_NEUTRAL\n"
        fi

        save_profile
        printf "$COLOR_RED ⚠ Punishment ESCALATED! Level: $punishment_level\n"
        printf "   Name: $player_name | Title: $player_title\n"
        printf "   Gender: $player_gender | Duration: $days day(s)\n"
        [ "$REVERSE_CONTROLS" -eq 1 ] && printf "   💀 REVERSE CONTROLS ACTIVE!\n"
        [ "$DRUNK_MODE" -eq 1 ] && printf "   🍺 DRUNK MODE ACTIVE!\n"
        [ "$RANDOM_TELEPORT" -eq 1 ] && printf "   🌀 RANDOM TELEPORTS ACTIVE!\n"
        [ "$SHRINKING_SHIP" -eq 1 ] && printf "   📉 SHRINKING SHIP ACTIVE!\n"
        printf "$COLOR_NEUTRAL"
        return
    fi

    # First-time punishment
    punishment_level=1
    days=3
    punishment_prev_days=$days
    punishment_expires=$((current_time + days*24*60*60))

    # Flip gender (opposite of current)
    case "$player_gender" in
        "Male") 
            player_gender="Female"
            player_title="Madam ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
            last_flip_gender="Female"
            ;;
        "Female")
            player_gender="Male"
            player_title="Sir ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
            last_flip_gender="Male"
            ;;
        *)
            player_gender="Alien"
            player_title="Mx ${FUNNY_TITLES[$RANDOM % ${#FUNNY_TITLES[@]}]}"
            last_flip_gender="Alien"
            ;;
    esac

    # Ugly skin, weak ship, low ammo
    player_name=${FUNNY_NAMES[$RANDOM % ${#FUNNY_NAMES[@]}]}
    current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}
    current_ship=1
    ammo=$((ammo / 2))
    [ "$ammo" -lt 1 ] && ammo=1

    save_profile
    printf "$COLOR_RED ⚠ PUNISHMENT APPLIED!\n"
    printf "   Duration: $days day(s) | Level: $punishment_level\n"
    printf "   Name: $player_name | Title: $player_title\n"
    printf "   Gender: $player_gender\n"
    printf "   May this teach you to play better! $COLOR_NEUTRAL\n"
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
# Short-term chaos punishment with variety
# ------------------------------
apply_short_punishment() {
    if [ "$PUNISHMENT_ACTIVE" -eq 1 ]; then return; fi
    PUNISHMENT_ACTIVE=1
    PUNISHMENT_TIMER=$PUNISHMENT_DURATION

    # Random punishment message
    local messages=(
        "✗ Git gud scrub!"
        "✗ Even asteroids are embarrassed for you!"
        "✗ Your ancestors weep!"
        "✗ The galaxy laughs at your failure!"
        "✗ Have you tried NOT crashing?"
        "✗ My grandma flies better than this!"
        "✗ Achievement Unlocked: Total Disaster!"
    )
    printf "\n$COLOR_RED ${messages[$RANDOM % ${#messages[@]}]} $COLOR_NEUTRAL\n"

    # Reduce ship speed
    local original_speed
    original_speed=$(get_ship_speed "$current_ship")
    local new_speed=$((original_speed - 2))  # Harsher now
    [ "$new_speed" -lt 1 ] && new_speed=1
    set_ship_speed "$current_ship" "$new_speed"

    # Reduce ammo more severely
    ammo=$((ammo / 3))
    [ "$ammo" -lt 1 ] && ammo=1

    # Multiple visual effects
    blink_ship_effect
    shake_screen_effect

    # Spawn extra asteroids (more if score is really bad)
    local asteroid_count=5
    if [ "$score" -lt "$SUPER_PUNISHMENT_THRESHOLD" ]; then
        asteroid_count=10
        printf "$COLOR_RED ☠ SUPER PUNISHMENT! ☠ $COLOR_NEUTRAL\n"
    fi
    for i in $(seq 1 $asteroid_count); do spawn_asteroid; done

    # Force ugly skin temporarily
    old_skin="$current_skin"
    current_skin=${PUNISHMENT_SKINS[$RANDOM % ${#PUNISHMENT_SKINS[@]}]}

    # Random extra punishments
    case $((RANDOM % 4)) in
        0) UPSIDE_DOWN=1; printf "$COLOR_YELLOW 🙃 Ship is upside down! $COLOR_NEUTRAL\n" ;;
        1) REVERSE_CONTROLS=1; printf "$COLOR_YELLOW ⬅➡ Controls reversed! $COLOR_NEUTRAL\n" ;;
        2) DRUNK_MODE=1; printf "$COLOR_YELLOW 🍺 Drunk mode activated! $COLOR_NEUTRAL\n" ;;
        3) SHRINKING_SHIP=1; printf "$COLOR_YELLOW 📉 Ship is shrinking! $COLOR_NEUTRAL\n" ;;
    esac
}

# ------------------------------
# Punishment tick (call per frame)
# ------------------------------
punishment_tick() {
    if [ "$PUNISHMENT_ACTIVE" -eq 1 ]; then
        # Blink effect
        [ $((frame % 5)) -eq 0 ] && draw_ship

        # Drunk mode - random position shifts
        if [ "$DRUNK_MODE" -eq 1 ] && [ $((frame % 3)) -eq 0 ]; then
            ship_y=$((ship_y + (RANDOM % 3 - 1)))
            ship_x=$((ship_x + (RANDOM % 3 - 1)))
        fi

        # Random teleport
        if [ "$RANDOM_TELEPORT" -eq 1 ] && [ $((RANDOM % 20)) -eq 0 ]; then
            ship_x=$((RANDOM % (WIDTH - 10) + 5))
            ship_y=$((RANDOM % (HEIGHT - 5) + 3))
            printf "$COLOR_YELLOW ⚡ TELEPORTED! $COLOR_NEUTRAL\n"
        fi

        PUNISHMENT_TIMER=$((PUNISHMENT_TIMER - 1))
        if [ "$PUNISHMENT_TIMER" -le 0 ]; then
            PUNISHMENT_ACTIVE=0
            ammo=$(get_ship_ammo "$current_ship")
            set_ship_speed "$current_ship" "$(get_ship_speed "$current_ship")"
            current_skin="$old_skin"
            
            # Clear temporary effects
            REVERSE_CONTROLS=0
            DRUNK_MODE=0
            UPSIDE_DOWN=0
            RANDOM_TELEPORT=0
            SHRINKING_SHIP=0
            
            printf "$COLOR_GREEN ✓ Chaos punishment ended! Try to do better! $COLOR_NEUTRAL\n"
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
# Shake screen effect (new!)
# ------------------------------
shake_screen_effect() {
    for i in {1..5}; do
        tput cup $((RANDOM % 3)) $((RANDOM % 3))
        sleep 0.05
    done
    tput cup 0 0
}

# ------------------------------
# Insult generator for extra humiliation
# ------------------------------
generate_insult() {
    local insults=(
        "You fly like a concussed space slug!"
        "My coffee maker has better reflexes!"
        "Are you TRYING to hit every asteroid?"
        "I've seen better piloting from a potato!"
        "Your ship's AI is considering resignation!"
        "The asteroids are AVOIDING you out of pity!"
        "Your flight recorder just filed for therapy!"
        "Houston, we have a competence problem!"
        "Space janitors fly better than this!"
        "Your mother was a hamster and your father smelt of elderberries!"
    )
    printf "$COLOR_RED ${insults[$RANDOM % ${#insults[@]}]} $COLOR_NEUTRAL\n"
}

# ------------------------------
# Trigger punishments if score is low
# ------------------------------
check_low_score_punishment() {
    if [ "$score" -lt "$LOW_SCORE_THRESHOLD" ]; then
        apply_short_punishment
        apply_long_term_punishment
        
        # Extra insult if really bad
        if [ "$score" -lt "$SUPER_PUNISHMENT_THRESHOLD" ]; then
            generate_insult
        fi
    fi
}

# ------------------------------
# Hall of Shame (track worst performances)
# ------------------------------
declare -A HALL_OF_SHAME
SHAME_FILE="${GAME_DIR}/.hall_of_shame"

add_to_hall_of_shame() {
    local shame_score=$1
    local shame_name=$2
    echo "$shame_score|$shame_name|$(date +%Y-%m-%d)" >> "$SHAME_FILE"
    printf "$COLOR_RED 📜 You've been added to the Hall of Shame! $COLOR_NEUTRAL\n"
}

show_hall_of_shame() {
    if [ -f "$SHAME_FILE" ]; then
        printf "\n$COLOR_RED === HALL OF SHAME === $COLOR_NEUTRAL\n"
        sort -t'|' -k1 -n "$SHAME_FILE" | head -10 | while IFS='|' read -r score name date; do
            printf "$COLOR_YELLOW Score: $score | $name | $date $COLOR_NEUTRAL\n"
        done
    fi
}

# Add to shame if score is really terrible
if [ "$score" -lt 50 ] && [ "$game_over" -eq 1 ]; then
    add_to_hall_of_shame "$score" "$player_name"
fi