#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# =============================
# STAR RUNNER - Ships Module
# Defines all ships, stats, abilities, and utility functions
# =============================

# -----------------------------
# Ships Definition
# -----------------------------
declare -A ships

# Format: [<id>_<property>]=value

ships[1_name]="Scout"
ships[1_icon]="▶"
ships[1_speed]=2       # movement per tick
ships[1_ammo]=20       # starting ammo
ships[1_health]=50     # starting health
ships[1_ability]="Speed Boost"
ships[1_max_speed]=3

ships[2_name]="Interceptor"
ships[2_icon]="▷"
ships[2_speed]=2
ships[2_ammo]=25
ships[2_health]=60
ships[2_ability]="Double Shot"
ships[2_max_speed]=3

ships[3_name]="Frigate"
ships[3_icon]="⊳"
ships[3_speed]=1
ships[3_ammo]=30
ships[3_health]=80
ships[3_ability]="Shield"
ships[3_max_speed]=2

ships[4_name]="Cruiser"
ships[4_icon]="⊲"
ships[4_speed]=1
ships[4_ammo]=40
ships[4_health]=100
ships[4_ability]="Mega Bomb"
ships[4_max_speed]=2

ships[5_name]="Battleship"
ships[5_icon]="⧐"
ships[5_speed]=1
ships[5_ammo]=50
ships[5_health]=150
ships[5_ability]="Invincible Burst"
ships[5_max_speed]=1

# -----------------------------
# Getter Functions
# -----------------------------
get_ship_name() { echo "${ships[$1_name]}"; }
get_ship_icon() { echo "${ships[$1_icon]}"; }
get_ship_speed() { echo "${ships[$1_speed]}"; }
get_ship_ammo() { echo "${ships[$1_ammo]}"; }
get_ship_health() { echo "${ships[$1_health]}"; }
get_ship_ability() { echo "${ships[$1_ability]}"; }
get_ship_max_speed() { echo "${ships[$1_max_speed]}"; }

# -----------------------------
# Animated Ship Icon Frames
# Optional: allows simple terminal animation
# -----------------------------
# frame: 1..3 (can expand)
get_ship_icon_frame() {
  local ship=$1
  local frame=$2
  case $ship in
    1) # Scout
      case $frame in
        1) echo "▶" ;;
        2) echo "➤" ;;
        3) echo "▷" ;;
      esac ;;
    2) # Interceptor
      case $frame in
        1) echo "▷" ;;
        2) echo "▹" ;;
        3) echo "➤" ;;
      esac ;;
    3) # Frigate
      case $frame in
        1) echo "⊳" ;;
        2) echo "⊵" ;;
        3) echo "⊶" ;;
      esac ;;
    4) # Cruiser
      case $frame in
        1) echo "⊲" ;;
        2) echo "⊳" ;;
        3) echo "⊴" ;;
      esac ;;
    5) # Battleship
      case $frame in
        1) echo "⧐" ;;
        2) echo "⯈" ;;
        3) echo "⯆" ;;
      esac ;;
    *) echo "?" ;;
  esac
}

# -----------------------------
# Utility: Display full ship info (for debug or HUD)
# -----------------------------
show_ship_info() {
  local id=$1
  echo "Ship: $(get_ship_name $id)"
  echo "Icon: $(get_ship_icon $id)"
  echo "Speed: $(get_ship_speed $id)"
  echo "Ammo: $(get_ship_ammo $id)"
  echo "Health: $(get_ship_health $id)"
  echo "Ability: $(get_ship_ability $id)"
}

# -----------------------------
# Example usage in game.sh:
# current_ship=1
# ship_name=$(get_ship_name "$current_ship")
# ship_icon=$(get_ship_icon "$current_ship")
# ship_speed=$(get_ship_speed "$current_ship")
# ship_ammo=$(get_ship_ammo "$current_ship")
# ship_health=$(get_ship_health "$current_ship")
# ship_ability=$(get_ship_ability "$current_ship")
# show_ship_info "$current_ship"
# -----------------------------
