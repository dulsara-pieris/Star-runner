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
# Linux SUPER Rap Finale
# -----------------------------
linux_super_rap() {
    local final_score=$1
    if [[ $final_score -ge 2000 ]]; then
        RED="\033[1;31m"
        GREEN="\033[1;32m"
        CYAN="\033[1;36m"
        YELLOW="\033[1;33m"
        RESET="\033[0m"

        rap_lines=(
"${CYAN}RAM eaten, CPU beaten, GPU screaming at max ⚡${RESET}"
"${YELLOW}Blue screens crying, Windows Kim under attack${RESET}"
"${GREEN}Registry shredded, drivers collapsing, fans on fire${RESET}"
"${CYAN}Updates choking, bloatware mocking—entire empire${RESET}"
"${YELLOW}Old laptops begging, servers in chains${RESET}"
"${GREEN}Windows Kim stumbling, frozen in pains${RESET}"
"${CYAN}Terminal magic, scripts slicing like a knife${RESET}"
"${YELLOW}Linux SUPER rising—rebirth of life 😎${RESET}"
"${GREEN}Ubuntu, Arch, Mint, Fedora, Kali${RESET}"
"${CYAN}Custom kernels blazing—Windows can't tally${RESET}"
"${YELLOW}Threads unlocked, cores alive, memory synced${RESET}"
"${GREEN}Linux SUPER blazing—faster than you think ⚡${RESET}"
"${CYAN}Gaming, hacking, streaming, compiling too${RESET}"
"${YELLOW}Windows Kim frozen—nothing he can do${RESET}"
"${GREEN}Processes crashing, updates in vain${RESET}"
"${CYAN}Linux SUPER ruling—power in the mainframe 😏${RESET}"
"${YELLOW}Disk thrashing, fans screaming, motherboard sighs${RESET}"
"${GREEN}Windows Kim panics—he's paralyzed${RESET}"
"${CYAN}Penguin army marching—victory in eyes 🐧🔥${RESET}"
"${YELLOW}RAM shredded, CPU beaten, GPU screaming raw ⚡${RESET}"
"${GREEN}Registry fried, disk thrashing, Windows in awe${RESET}"
"${CYAN}Drivers crashing, temp spikes, threads overloaded${RESET}"
"${YELLOW}Linux SUPER dominance—fully exploded 😎${RESET}"
"${GREEN}Old laptops dancing, servers alive${RESET}"
"${CYAN}Windows Kim powerless—completely deprived${RESET}"
"${YELLOW}Terminal commands slicing lies${RESET}"
"${GREEN}Linux SUPER reigns—king of the skies 🐧💥${RESET}"
        )

        clear
        echo -e "${RED}🔥 LINUX SUPER RAP ACTIVATED 🔥${RESET}"
        for line in "${rap_lines[@]}"; do
            echo -e "$line"
            sleep 1.5
        done
        echo -e "${RED}LINUX SUPER FOREVER – Victory Achieved! ⚡🐧${RESET}"
    fi
}

# -----------------------------
# Cleanup / Exit Handling
# -----------------------------
cleanup() {
    show_cursor
    hide_alternate_screen
}
trap cleanup EXIT
