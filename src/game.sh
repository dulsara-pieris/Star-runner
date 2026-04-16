#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# STAR RUNNER ENHANCED - Main Game Entry Point

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
source "$SCRIPT_DIR/modules/render.sh"
source "$SCRIPT_DIR/modules/entities.sh"
source "$SCRIPT_DIR/modules/weapons.sh"
source "$SCRIPT_DIR/modules/collision.sh"
source "$SCRIPT_DIR/modules/input.sh"
source "$SCRIPT_DIR/modules/effects.sh"
source "$SCRIPT_DIR/modules/punishments.sh"
source "$SCRIPT_DIR/modules/inventory.sh"   # Optional: career stats module

# Init tamper-proof achievements
#init_achievements

# Parse CLI arguments
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
# Game State
# ------------------------------
ship_line=$((NUM_LINES / 2))
ship_column=5
paused=0
asteroid_count=0
crystal_active=0
powerup_active=0
laser_active=0
laser2_active=0
laser3_active=0
shield_active=0
shield_timer=0
grace_timer=0
super_mode_active=0
super_timer=0
weapon_type=1
weapon_timer=0
frame=0
score=0
level=1
speed_multiplier=0
crystals_collected=0
asteroids_destroyed=0
combo_streak=0
combo_timer=0
last_points=0

# Accessibility + challenge tuning
difficulty_name="Classic"
score_multiplier=1
spawn_floor=2
player_lives=2

# Load profile (high score, crystals, stats)
init_profile

# Show main menu
show_main_menu

# Set ammo based on selected ship
current_ship=$((current_ship + 0))
ammo=$(get_ship_ammo "$current_ship")
ammo=$((ammo + 0))

# Configure terminal input
stty -icanon -echo time $TURN_DURATION min 0

# Initialize screen
on_enter
draw_border
draw_ship

# Show launch sequence
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
    # Player input
    # --------------------------
    handle_input

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
    # Background and spawning
    # --------------------------
    [ $((frame % 10)) -eq 0 ] && draw_stars

    spawn_frequency=$((4 - speed_multiplier))
    [ "$spawn_frequency" -lt "$spawn_floor" ] && spawn_frequency=$spawn_floor
    [ $((frame % spawn_frequency)) -eq 0 ] && spawn_asteroid

    [ $((frame % 20)) -eq 0 ] && { spawn_crystal; spawn_powerup; }

    # --------------------------
    # Update entities
    # --------------------------
    check_long_term_punishment
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

    # Combo timeout
    if [ "$combo_streak" -gt 0 ]; then
      combo_timer=$((combo_timer + 1))
      if [ "$combo_timer" -ge 18 ]; then
        reset_combo
      fi
    fi

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
  else
    # Paused: only handle input & draw ship
    handle_input
    draw_ship
  fi
done
