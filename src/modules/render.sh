#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# STAR RUNNER - Rendering Module
# All drawing and display functions

# -----------------------------
# Screen & Cursor Control
# -----------------------------

# Show alternate screen buffer
show_alternate_screen() {
  printf '\033[?1049h\033[2J\033[H'
}

# Hide alternate screen buffer
hide_alternate_screen() {
  printf '\033[2J\033[H\033[?1049l'
}

# Move cursor to specific position
move_cursor() {
  printf "\033[$1;$2H"
}

# Hide cursor
hide_cursor() {
  printf "\033[?25l"
}

# Show cursor
show_cursor() {
  printf "\033[?25h"
}

# -----------------------------
# Drawing Functions
# -----------------------------

# Draw game border
draw_border() {
  printf "$COLOR_CYAN"
  
  # Top border
  move_cursor 1 1
  i=1
  while [ $i -le "$NUM_COLUMNS" ]; do
    printf '─'
    i=$((i + 1))
  done
  
  # Bottom border
  move_cursor "$NUM_LINES" 1
  i=1
  while [ $i -le "$NUM_COLUMNS" ]; do
    printf '─'
    i=$((i + 1))
  done
  
  printf "$COLOR_NEUTRAL"
}

# Draw player ship with current skin color
draw_ship() {
  move_cursor "$ship_line" "$ship_column"
  
  # Ensure current_ship and current_skin are numbers
  current_ship=$((current_ship + 0))
  current_skin=$((current_skin + 0))
  
  ship_icon=$(get_ship_icon "$current_ship")
  ship_color=$(get_skin_color "$current_skin")
  
  if [ "$shield_active" = 1 ]; then
    printf "${COLOR_CYAN}⟨${ship_color}${ship_icon}${COLOR_CYAN}⟩${COLOR_NEUTRAL}"
  elif [ "$super_mode_active" = 1 ]; then
    printf "${COLOR_YELLOW}⟨${ship_icon}⟩${COLOR_NEUTRAL}"
  elif [ "$grace_timer" -gt 0 ] && [ $((grace_timer % 2)) -eq 0 ]; then
    printf "${COLOR_RED}${ship_icon}${COLOR_NEUTRAL}"
  else
    printf "${ship_color}${ship_icon}${COLOR_NEUTRAL}"
  fi
}

# Clear ship from previous position
clear_ship() {
  move_cursor "$ship_line" "$ship_column"
  if [ "$shield_active" = 1 ] || [ "$super_mode_active" = 1 ]; then
    printf "    "
  else
    printf "  "
  fi
}

# Draw HUD (score, ammo, level, powerups)
draw_hud() {
  printf "$COLOR_YELLOW"
  move_cursor 2 5
  printf "SCORE: $score | LVL: $level"
  
  move_cursor 2 30
  printf "AMMO: $ammo"
  
  move_cursor 2 45
  printf "CRYSTALS: $crystals_collected"

  move_cursor 2 64
  printf "LIVES: $player_lives"

  move_cursor 3 5
  printf "MODE: $difficulty_name | COMBO: x$combo_streak"
  
  col_offset=60
  
  if [ "$shield_active" = 1 ]; then
    printf "$COLOR_CYAN"
    move_cursor 2 $col_offset
    printf "⟨SHIELD⟩"
    col_offset=$((col_offset + 10))
  fi
  
  if [ "$super_mode_active" = 1 ]; then
    printf "$COLOR_YELLOW"
    move_cursor 2 $col_offset
    printf "⟨SUPER⟩"
    col_offset=$((col_offset + 9))
  fi
  
  if [ "$weapon_type" = 2 ]; then
    printf "$COLOR_CYAN"
    move_cursor 2 $col_offset
    printf "⟨SPREAD⟩"
  elif [ "$weapon_type" = 3 ]; then
    printf "$COLOR_WHITE"
    move_cursor 2 $col_offset
    printf "⟨RAPID⟩"
  fi
  
  printf "$COLOR_NEUTRAL"
}

# Draw background stars
draw_stars() {
  star_count=0
  while [ $star_count -lt 15 ]; do
    line=$(get_random_number 3 $((NUM_LINES - 1)))
    col=$(get_random_number 2 $((NUM_COLUMNS - 1)))
    move_cursor "$line" "$col"
    printf "${COLOR_WHITE}.${COLOR_NEUTRAL}"
    star_count=$((star_count + 1))
  done
}

# -----------------------------
# Cleanup / Exit Handling
# -----------------------------
cleanup() {
    show_cursor
    hide_alternate_screen
}
trap cleanup EXIT
