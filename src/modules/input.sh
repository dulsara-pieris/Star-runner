#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# STAR RUNNER - Input Handling Module
# Keyboard input processing

# Handle player input
handle_input() {
  read_chars key 1

  if [ "$key" = "$ESCAPE_CHAR" ]; then
    read_chars key 2
    key="${key##*[}"
  fi

  # Get ship speed for movement - ensure it's a number
  current_ship=$((current_ship + 0))
  ship_speed=$(get_ship_speed "$current_ship")
  ship_speed=$((ship_speed + 0))

  case $key in
    A) # Up arrow - always move 1 line at a time vertically
      if [ "$ship_line" -gt 3 ]; then
        clear_ship
        ship_line=$((ship_line - 1))
      fi
      ;;
    B) # Down arrow - always move 1 line at a time vertically
      if [ "$ship_line" -lt $((NUM_LINES - 2)) ]; then
        clear_ship
        ship_line=$((ship_line + 1))
      fi
      ;;
    C) # Right arrow - use ship speed for horizontal movement
      if [ "$ship_column" -lt $((NUM_COLUMNS - 10)) ]; then
        clear_ship
        ship_column=$((ship_column + ship_speed))
      fi
      ;;
    D) # Left arrow - use ship speed for horizontal movement
      if [ "$ship_column" -gt 5 ]; then
        clear_ship
        ship_column=$((ship_column - ship_speed))
      fi
      ;;
    q|Q) # Quit
      on_exit
      ;;
    p|P) # Pause
      toggle_pause
      ;;
    ' ') # Spacebar - fire weapon
      fire_weapon
      ;;
  esac
}

# Toggle pause state
toggle_pause() {
  if [ "$paused" = 0 ]; then
    paused=1
    printf "$COLOR_CYAN"
    center_col=$((NUM_COLUMNS / 2 - 8))
    center_line=$((NUM_LINES / 2))
    move_cursor $center_line $center_col
    printf " ║║ PAUSED ║║ "
    printf "$COLOR_NEUTRAL"
  else
    paused=0
    center_col=$((NUM_COLUMNS / 2 - 8))
    center_line=$((NUM_LINES / 2))
    move_cursor $center_line $center_col
    printf "               "
  fi
}
