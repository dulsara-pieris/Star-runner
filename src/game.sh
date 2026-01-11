#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# =============================
# STAR RUNNER ENHANCED - Main Game Entry
# =============================

# ------------------------------
# Setup
# ------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modules
source "$SCRIPT_DIR/modules/config.sh"
source "$SCRIPT_DIR/modules/utils.sh"
source "$SCRIPT_DIR/modules/profile.sh"
source "$SCRIPT_DIR/modules/ships.sh"
source "$SCRIPT_DIR/modules/skins.sh"
source "$SCRIPT_DIR/modules/menu.sh"
source "$SCRIPT_DIR/modules/shop.sh"
source "$SCRIPT_DIR/modules/inventory.sh"  # <- Inventory module
source "$SCRIPT_DIR/modules/render.sh"
source "$SCRIPT_DIR/modules/entities.sh"
source "$SCRIPT_DIR/modules/weapons.sh"
source "$SCRIPT_DIR/modules/collision.sh"
source "$SCRIPT_DIR/modules/input.sh"
source "$SCRIPT_DIR/modules/effects.sh"
#source "$SCRIPT_DIR/modules/achievements.sh"
source "$SCRIPT_DIR/modules/stats.sh"

# ------------------------------
# Init profile and achievements
# ------------------------------
init_profile
#init_achievements

# ------------------------------
# Parse CLI arguments
# ------------------------------
while :; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    -u|--update) update; exit 0 ;;
    --) shift; break ;;
    -?*) printf 'ERROR: Unknown option: %s\n' "$1" >&2; exit 1 ;;
    *) break ;;
  esac
  shift
done

# ------------------------------
# Show main menu (including hangar/skins)
# ------------------------------
show_main_menu

# ------------------------------
# Ensure selected ship is valid
# ------------------------------
if ! check_ownership "$current_ship" "$owned_ships"; then
  # Equip default ship if current_ship invalid
  current_ship=1
fi

# Update ammo based on current ship
ammo=$(get_ship_ammo "$current_ship")
health=$(get_ship_health "$current_ship")

# ------------------------------
# Configure terminal input
# ------------------------------
stty -icanon -echo time $TURN_DURATION min 0

# ------------------------------
# Initialize screen
# ------------------------------
on_enter
draw_border
draw_ship

# Launch sequence
printf "$COLOR_CYAN"
center_col=$((NUM_COLUMNS / 2 - 12))
center_line=$((NUM_LINES / 2))
move_cursor $center_line $center_col
printf " ▶ LAUNCHING STAR RUNNER ◀ "
printf "$COLOR_NEUTRAL"
sleep 2
move_cursor $center_line $center_col
printf "                           "

# ------------------------------
# MAIN GAME LOOP
# ------------------------------
while true; do
  if [ "$paused" -eq 0 ]; then
    # --------------------------
    # Handle player input
    # --------------------------
    handle_input

    # Check if inventory/hangar invoked
    if [ "$inventory_open" -eq 1 ]; then
      show_hangar       # Player can buy/equip ships
      inventory_open=0  # Close after exit
      # Update ammo/health after equipping new ship
      ammo=$(get_ship_ammo "$current_ship")
      health=$(get_ship_health "$current_ship")
    fi

    if [ "$skins_open" -eq 1 ]; then
      show_skin_shop    # Player can buy/apply skins
      skins_open=0
    fi

    # --------------------------
    # Level progression
    # --------------------------
    new_level=$((score / 200 + 1))
    if [ "$new_level" -ne "$level" ]; then
      level=$new_level
      speed_multiplier=$((level - 1))

      # Level-up notification
      printf "$COLOR_GREEN"
      center_col=$((NUM_COLUMNS / 2 - 10))
      center_line=$((NUM_LINES / 2))
      move_cursor $center_line $center_col
      printf " ★ LEVEL $level ★ "
      printf "$COLOR_NEUTRAL"
      sleep 1
      move_cursor $center_line $center_col
      printf "                      "
    fi

    # --------------------------
    # Background & spawning
    # --------------------------
    [ $((frame % 10)) -eq 0 ] && draw_stars

    spawn_frequency=$((4 - speed_multiplier))
    [ "$spawn_frequency" -lt 2 ] && spawn_frequency=2
    [ $((frame % spawn_frequency)) -eq 0 ] && spawn_asteroid

    [ $((frame % 20)) -eq 0 ] && { spawn_crystal; spawn_powerup; }

    # --------------------------
    # Update entities
    # --------------------------
    move_asteroids
    move_crystal
    move_powerup
    move_laser

    # --------------------------
    # Collisions & timers
    # --------------------------
    check_laser_hits
    check_collisions
    update_timers

    # --------------------------
    # Render frame
    # --------------------------
    draw_ship
    draw_hud

    # --------------------------
    # Increment frame
    # --------------------------
    frame=$((frame + 1))

    # --------------------------
    # Update career stats
    # --------------------------
    if [ "$score" -gt "$high_score" ]; then
      high_score=$score
    fi
    total_crystals=$((total_crystals + crystals_collected))
    total_asteroids=$((total_asteroids + asteroids_destroyed))
    crystals_bank=$((crystals_bank + crystals_collected))

    # Rank calculation
    if [ "$high_score" -ge 1000 ]; then
      rank="Star Pilot"
    elif [ "$high_score" -ge 500 ]; then
      rank="Space Cadet"
    else
      rank="Neural Trash"
    fi

    # Save stats periodically
    save_profile

  else
    # Paused: only handle input & draw ship
    handle_input
    draw_ship
  fi
done
