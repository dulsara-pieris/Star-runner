#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris


# STAR RUNNER - Utility Functions Module
# Helper functions used throughout the game

# Generate random number between min and max (inclusive)
get_random_number() {
  min=$1
  max=$2
  range=$((max - min + 1))
  num=$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ')
  printf "%d" $((min + num % range))
}

# Read specified number of characters from input
read_chars() {
  eval "$1=\$(dd bs=1 count=$2 2>/dev/null)"
}

# Check if an item is owned by the player
check_ownership() {
  item_id=$1
  owned_list=$2
  
  echo "$owned_list" | grep -q ",$item_id," && return 0
  echo "$owned_list" | grep -q "^$item_id," && return 0
  echo "$owned_list" | grep -q ",$item_id$" && return 0
  [ "$owned_list" = "$item_id" ] && return 0
  return 1
}

# Add item to owned list
add_to_owned() {
  item_id=$1
  owned_list=$2
  
  if [ -z "$owned_list" ]; then
    printf "%s" "$item_id"
  else
    printf "%s,%s" "$owned_list" "$item_id"
  fi
}

# Initialize game screen and settings
on_enter() {
  hide_cursor
  show_alternate_screen
  trap 'on_exit' INT
  
  # Force initial draw of ship
  draw_border
  draw_ship
}

# Cleanup and show final statistics
on_exit() {
  if [ -n "$player_name" ]; then
    if [ "$score" -gt "$high_score" ]; then
      high_score=$score
    fi
    
    total_crystals=$((total_crystals + crystals_collected))
    total_asteroids=$((total_asteroids + asteroids_destroyed))
    crystal_bank=$((crystal_bank + crystals_collected))
    
    save_profile
  fi
  
  hide_alternate_screen
  show_cursor
  stty icanon echo
  
  printf "$COLOR_CYAN"
  clear
  check_low_score_punishment
  punishment_tick
cat << "EOF"

 ██████╗  █████╗ ███╗   ███╗███████╗     ██████╗ ██╗   ██╗███████╗██████╗ 
██╔════╝ ██╔══██╗████╗ ████║██╔════╝    ██╔═══██╗██║   ██║██╔════╝██╔══██╗
██║  ███╗███████║██╔████╔██║█████╗      ██║   ██║██║   ██║█████╗  ██████╔╝
██║   ██║██╔══██║██║╚██╔╝██║██╔══╝      ██║   ██║██║   ██║██╔══╝  ██╔══██╗
╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗    ╚██████╔╝╚██████╔╝███████╗██║  ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝     ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝

EOF

  printf "$COLOR_NEUTRAL"
  printf "\n${COLOR_MAGENTA}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}║${COLOR_NEUTRAL}              MISSION OVER - STATS                     ${COLOR_MAGENTA}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  
  printf "  ${COLOR_YELLOW}⚡ This Mission Score:${COLOR_NEUTRAL} $score\n"
  printf "  ${COLOR_CYAN}◇ Crystals Collected:${COLOR_NEUTRAL} $crystals_collected (Added to bank!)\n"
  printf "  ${COLOR_RED}◆ Asteroids Destroyed:${COLOR_NEUTRAL} $asteroids_destroyed\n\n"
  
  if [ -n "$player_name" ]; then
    current_year=2026
    player_age=$((current_year - player_birth_year))
    printf "  ${COLOR_CYAN}👤 Pilot:${COLOR_NEUTRAL} ${COLOR_GREEN}${player_title} ${player_name}${COLOR_NEUTRAL} (Age: $player_age)\n"
    printf "  ${COLOR_MAGENTA}📊 Career Stats:${COLOR_NEUTRAL}\n"
    printf "  ${COLOR_YELLOW}🏆 High Score:${COLOR_NEUTRAL} $high_score\n"
    printf "  ${COLOR_CYAN}💎 Crystal Bank:${COLOR_NEUTRAL} $crystal_bank\n"
    printf "  ${COLOR_CYAN}💎 Total Crystals:${COLOR_NEUTRAL} $total_crystals\n"
    printf "  ${COLOR_RED}💥 Total Asteroids:${COLOR_NEUTRAL} $total_asteroids\n\n"
  fi
  
  printf "  ${COLOR_GREEN}☆ Rank:${COLOR_NEUTRAL} "

  if [ "$score" -lt 10 ]; then
    printf "${COLOR_WHITE}Neural Trash${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 25 ]; then
    printf "${COLOR_WHITE}Synapse Junk${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 45 ]; then
    printf "${COLOR_WHITE}Chrome Addict${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 70 ]; then
    printf "${COLOR_WHITE}Implant Wreck${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 100 ]; then
    printf "${COLOR_WHITE}Backstreet Mind${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 135 ]; then
    printf "${COLOR_GREEN}Signal Leech${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 175 ]; then
    printf "${COLOR_GREEN}Neural Runner${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 220 ]; then
    printf "${COLOR_GREEN}Grid Initiate${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 240 ]; then
    printf "${COLOR_CYAN}Packet Runner${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 280 ]; then
    printf "${COLOR_GREEN}Net Operator${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 300 ]; then
    printf "${COLOR_CYAN}Neon Pilot${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 370 ]; then
    printf "${COLOR_CYAN}Signal Breaker${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 450 ]; then
    printf "${COLOR_BLUE}Void Skimmer${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 550 ]; then
    printf "${COLOR_BLUE}Cyber Ace${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 680 ]; then
    printf "${COLOR_BLUE}Neural Navigator${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 830 ]; then
    printf "${COLOR_MAGENTA}System Officer${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 1000 ]; then
    printf "${COLOR_MAGENTA}Protocol Commander${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 1200 ]; then
    printf "${COLOR_MAGENTA}Core Strategist${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 1450 ]; then
    printf "${COLOR_YELLOW}Quantum Captain${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 1750 ]; then
    printf "${COLOR_YELLOW}Void Admiral${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 2100 ]; then
    printf "${COLOR_YELLOW}Nexus Marshal${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 2500 ]; then
    printf "${COLOR_RED}Binary Overmind${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 3000 ]; then
    printf "${COLOR_RED}Nexus Ascendant${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 3600 ]; then
    printf "${COLOR_RED}Reality Compiler${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 4300 ]; then
    printf "${COLOR_RED}Singularity Protocol${COLOR_NEUTRAL}\n"
  else
    printf "${COLOR_RED}NEXUS-ZERO // 01101001${COLOR_NEUTRAL}\n"
  fi

  printf "\n  ${COLOR_CYAN}Created by Dulsara(SYNAPSNEX)${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_YELLOW}dulsara.synapsnex@gmail.com${COLOR_NEUTRAL}\n\n"
  exit
}