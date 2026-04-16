#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris


# STAR RUNNER - Menu Module
# Main menu, stats display, help screen, and update functionality

# Show main menu
show_main_menu() {
  clear
  printf "$COLOR_CYAN"
  cat << "EOF"
    ███████╗████████╗ █████╗ ██████╗     ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ███████╗   ██║   ███████║██████╔╝    ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ╚════██║   ██║   ██╔══██║██╔══██╗    ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ███████║   ██║   ██║  ██║██║  ██║    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
EOF
  printf "$COLOR_NEUTRAL\n"
  
  current_year=2026
  player_age=$((current_year - player_birth_year))
  
  printf "  ${COLOR_GREEN}Welcome back, ${player_title} ${player_name}!${COLOR_NEUTRAL} (Age: $player_age)\n\n"
  printf "  ${COLOR_YELLOW}💎 Crystal Bank: ${crystal_bank}${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_MAGENTA}🏆 High Score: ${high_score}${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_CYAN}Current Ship: $(get_ship_name "$current_ship")${COLOR_NEUTRAL} $(get_ship_icon "$current_ship")\n"
  printf "  ${COLOR_MAGENTA}Current Skin: $(get_skin_name "$current_skin")${COLOR_NEUTRAL}\n\n"
  printf "  ${COLOR_WHITE}Difficulty: ${difficulty_name}${COLOR_NEUTRAL}\n\n"
  
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}                      MAIN MENU                        ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "  ${COLOR_GREEN}[1]${COLOR_NEUTRAL} Start Mission\n"
  printf "  ${COLOR_YELLOW}[2]${COLOR_NEUTRAL} Hangar (Ships & Skins)\n"
  printf "  ${COLOR_MAGENTA}[3]${COLOR_NEUTRAL} View Stats\n"
  printf "  ${COLOR_CYAN}[4]${COLOR_NEUTRAL} Help\n"
  printf "  ${COLOR_NEUTRAL}[5]${COLOR_NEUTRAL} Update\n"
  printf "  ${COLOR_WHITE}[6]${COLOR_NEUTRAL} Difficulty\n"
  printf "  ${COLOR_RED}[7]${COLOR_NEUTRAL} Quit\n\n"
  printf "  Select option: "
  
  read -r menu_choice
  
  case $menu_choice in
    1)
      return 0
      ;;
    2)
      show_hangar
      show_main_menu
      ;;
    3)
      show_stats
      show_main_menu
      ;;
    4)
      show_help
      printf "\n  Press Enter to return..."
      read -r
      show_main_menu
      ;;
    5)
      update
      printf "\n  Press Enter to return..."
      read -r
      show_main_menu
      ;;
    6)
      show_difficulty_menu
      show_main_menu
      ;;
    7)
      printf "\n  ${COLOR_CYAN}Thanks for playing! Fly safe, pilot!${COLOR_NEUTRAL}\n\n"
      exit 0
      ;;
    *)
      show_main_menu
      ;;
  esac
}

# Set gameplay difficulty tuning
show_difficulty_menu() {
  clear
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}                  SELECT DIFFICULTY                    ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"

  printf "  ${COLOR_GREEN}[1] Chill${COLOR_NEUTRAL}   - 3 lives, slower spawns, score x1\n"
  printf "  ${COLOR_YELLOW}[2] Classic${COLOR_NEUTRAL} - 2 lives, balanced challenge, score x1\n"
  printf "  ${COLOR_RED}[3] Chaos${COLOR_NEUTRAL}   - 1 life, faster spawns, score x2\n\n"
  printf "  Select option: "

  read -r difficulty_choice
  case $difficulty_choice in
    1)
      difficulty_name="Chill"
      player_lives=3
      spawn_floor=3
      score_multiplier=1
      ;;
    3)
      difficulty_name="Chaos"
      player_lives=1
      spawn_floor=1
      score_multiplier=2
      ;;
    *)
      difficulty_name="Classic"
      player_lives=2
      spawn_floor=2
      score_multiplier=1
      ;;
  esac
}

# Display career statistics
show_stats() {
  clear
  printf "${COLOR_MAGENTA}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}║${COLOR_NEUTRAL}                    CAREER STATISTICS                  ${COLOR_MAGENTA}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  
  current_year=2026
  player_age=$((current_year - player_birth_year))
  
  printf "  ${COLOR_CYAN}👤 Pilot Profile${COLOR_NEUTRAL}\n"
  printf "     Name: ${COLOR_GREEN}${player_title} ${player_name}${COLOR_NEUTRAL}\n"
  printf "     Age: $player_age\n"
  printf "     Gender: $player_gender\n\n"
  
  printf "  ${COLOR_YELLOW}📊 Career Stats${COLOR_NEUTRAL}\n"
  printf "     High Score: ${COLOR_YELLOW}${high_score}${COLOR_NEUTRAL}\n"
  printf "     Total Crystals Collected: ${COLOR_CYAN}${total_crystals}💎${COLOR_NEUTRAL}\n"
  printf "     Total Asteroids Destroyed: ${COLOR_RED}${total_asteroids}${COLOR_NEUTRAL}\n"
  printf "     Crystal Bank: ${COLOR_YELLOW}${crystal_bank}💎${COLOR_NEUTRAL}\n\n"
  
  printf "  ${COLOR_MAGENTA}🚀 Hangar${COLOR_NEUTRAL}\n"
  printf "     Ships Owned: "
  ship_count=0
  i=1
  while [ $i -le 5 ]; do
    if check_ownership "$i" "$owned_ships"; then
      ship_count=$((ship_count + 1))
    fi
    i=$((i + 1))
  done
  printf "${ship_count}/5\n"
  
  printf "     Skins Owned: "
  skin_count=0
  i=1
  while [ $i -le 5 ]; do
    if check_ownership "$i" "$owned_skins"; then
      skin_count=$((skin_count + 1))
    fi
    i=$((i + 1))
  done
  printf "${skin_count}/5\n\n"
  
  printf "  Press Enter to return..."
  read -r
}

# Display help/instructions
show_help() {
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}         STAR RUNNER - MISSION BRIEFING            ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "${COLOR_YELLOW}CONTROLS:${COLOR_NEUTRAL}\n"
  printf "  Arrow Keys - Navigate your ship\n"
  printf "  [SPACE]    - Fire laser (uses ammo)\n"
  printf "  [P]        - Pause/Resume\n"
  printf "  [Q]        - Quit mission\n\n"
  printf "${COLOR_GREEN}OBJECTIVE:${COLOR_NEUTRAL}\n"
  printf "  Navigate through space, dodge asteroids, collect crystals!\n"
  printf "  Destroy asteroids with your laser for bonus points.\n"
  printf "  Game gets harder as you level up!\n"
  printf "  Destroy asteroids back-to-back to build combo bonus points.\n\n"
  printf "${COLOR_CYAN}COLLECTIBLES:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_CYAN}◇${COLOR_NEUTRAL}  Power Crystal - +25 points, +5 ammo, adds to bank!\n\n"
  printf "${COLOR_MAGENTA}POWER-UPS:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_YELLOW}☢${COLOR_NEUTRAL}  Shield - Absorb one hit\n"
  printf "  ${COLOR_MAGENTA}◈${COLOR_NEUTRAL}  Super Mode - Invincibility + destroy asteroids on contact\n"
  printf "  ${COLOR_GREEN}⊕${COLOR_NEUTRAL}  Ammo Pack - +10 laser shots, +20 points\n"
  printf "  ${COLOR_CYAN}⚡${COLOR_NEUTRAL}  Spread Shot - Fire 3 lasers at once (temporary)\n"
  printf "  ${COLOR_WHITE}◇${COLOR_NEUTRAL}  Rapid Fire - Shoot continuously (temporary)\n\n"
  printf "${COLOR_RED}HAZARDS:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_RED}◆ ◈◈ ◈◆◈${COLOR_NEUTRAL}  Asteroids (10 pts each)\n"
  printf "  ${COLOR_MAGENTA}⊕ ◉◉ ◉⊕◉${COLOR_NEUTRAL}  UFOs - Track your position! (20 pts each)\n\n"
  printf "${COLOR_YELLOW}HANGAR & SHOP:${COLOR_NEUTRAL}\n"
  printf "  Collect crystals to buy new ships and skins!\n"
  printf "  Different ships have different speeds and ammo\n"
  printf "  Customize your ship with color skins\n\n"
  printf "${COLOR_YELLOW}DIFFICULTY:${COLOR_NEUTRAL}\n"
  printf "  Every 200 points = New Level\n"
  printf "  Higher levels = Faster asteroids + UFO enemies\n\n"
  printf "${COLOR_WHITE}ACCESSIBILITY:${COLOR_NEUTRAL}\n"
  printf "  Choose Chill / Classic / Chaos from the main menu\n"
  printf "  More lives on Chill mode makes the game friendlier for new players.\n\n"
  printf "${COLOR_GREEN}Good luck, pilot! 🚀${COLOR_NEUTRAL}\n\n"
}

# Update game from git repository
 printf "${COLOR_GREEN}Update game from git repository"
update() {
  INSTALL_DIR="/usr/local/share/Star-runner"
  VERSION_FILE="$INSTALL_DIR/VERSION"
  
  # Check if installed
  if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "❌ Star-runner is not installed in $INSTALL_DIR"
    return 1
  fi
  
  # Check if we need sudo for git operations
  if [ ! -w "$INSTALL_DIR/.git" ] && [ "$EUID" -ne 0 ]; then
    echo "🔐 Update requires elevated permissions..."
    echo "🔄 Re-running with sudo..."
    
    # Re-run this script with sudo and --update flag
    if command -v star-runner >/dev/null 2>&1; then
      sudo star-runner --update
    else
      # If not installed globally, find the script
      SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
      sudo bash "$SCRIPT_PATH" --update
    fi
    return $?
  fi
  
  set -e
  cd "$INSTALL_DIR"
  
  # Allow git as root
  git config --global --add safe.directory "$INSTALL_DIR" 2>/dev/null || true
  
  # Read current version
  if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null | head -n1 | xargs)
    [[ -z "$CURRENT_VERSION" ]] && CURRENT_VERSION="unknown"
  else
    CURRENT_VERSION="unknown"
  fi
  
  echo "🔄 Updating Star-runner…"
  echo "📌 Current version: $CURRENT_VERSION"
  
  # Save rollback point
  OLD_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
  
  echo "📥 Fetching updates…"
  if ! git fetch origin 2>/dev/null; then
    echo "❌ Failed to fetch updates. Check your internet connection."
    return 1
  fi
  
  # Fast-forward merge
  if git merge --ff-only origin/main 2>/dev/null; then
    # Read new version after update
    if [[ -f "$VERSION_FILE" ]]; then
      NEW_VERSION=$(cat "$VERSION_FILE" 2>/dev/null | head -n1 | xargs)
      [[ -z "$NEW_VERSION" ]] && NEW_VERSION="unknown"
    else
      NEW_VERSION="unknown"
    fi
    
    echo "✅ Update successful!"
    echo "🆕 New version: $NEW_VERSION"
    
    # If we're root but was called by a user, show completion message
    if [ "$EUID" -eq 0 ]; then
      echo "✨ You can now run star-runner to play!"
    fi
  else
    echo "❌ Update failed! Rolling back…"
    git reset --hard "$OLD_COMMIT" 2>/dev/null || true
    echo "↩️ Rolled back to $CURRENT_VERSION"
    return 1
  fi
}
