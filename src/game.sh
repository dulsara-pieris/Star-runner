#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# STAR RUNNER ENHANCED - Main Game Entry Point

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
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
source "$SCRIPT_DIR/modules/achievements.sh"

init_achievements

# Parse command-line arguments
while :; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -u|--update)
      update
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -?*)
      printf 'ERROR: Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Initialize game state variables
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

# Initialize or load player profile
init_profile

# Show main menu and wait for user to start
show_main_menu

# Set ammo based on selected ship
current_ship=$((current_ship + 0))
ammo=$(get_ship_ammo "$current_ship")
ammo=$((ammo + 0))

# Configure terminal for game input
stty -icanon -echo time $TURN_DURATION min 0

# Initialize game screen
on_enter

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

# Clear screen and draw initial state
draw_border
draw_ship

# ============================================================================
# MAIN GAME LOOP
# ============================================================================
while true; do
  if [ "$paused" = 0 ]; then
    # Handle player input
    handle_input
    
    # Check for level progression
    new_level=$((score / 200 + 1))
    if [ "$new_level" -ne "$level" ]; then
      level=$new_level
      speed_multiplier=$((level - 1))
      
      # Show level up notification
      printf "$COLOR_GREEN"
      center_col=$((NUM_COLUMNS / 2 - 10))
      center_line=$((NUM_LINES / 2))
      move_cursor $center_line $center_col
      printf " ★ LEVEL $level ★ "
      printf "$COLOR_NEUTRAL"
    fi
    
    # Draw background stars periodically
    frame_mod_10=$((frame % 10))
    if [ "$frame_mod_10" -eq 0 ]; then
      draw_stars
    fi
    
    # Spawn asteroids based on difficulty
    spawn_frequency=$((4 - speed_multiplier))
    [ "$spawn_frequency" -lt 2 ] && spawn_frequency=2
    
    frame_mod_spawn=$((frame % spawn_frequency))
    if [ "$frame_mod_spawn" -eq 0 ]; then
      spawn_asteroid
    fi
    
    # Spawn collectibles periodically
    frame_mod_20=$((frame % 20))
    if [ "$frame_mod_20" -eq 0 ]; then
      spawn_crystal
      spawn_powerup
    fi
    
    # Update all entity positions
    move_asteroids
    move_crystal
    move_powerup
    move_laser
    
    # Check for collisions and interactions
    check_laser_hits
    check_collisions
    update_timers
    
    # Render current frame
    draw_ship
    draw_hud
    
    # Increment frame counter
    frame=$((frame + 1))
  else
    # When paused, only handle input
    handle_input
    draw_ship
  fi
done