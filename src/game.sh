#!/bin/sh
#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# shellcheck disable=2059

# STAR RUNNER ENHANCED - Now with ship selection, shop, and skins!

#profile file
SAVE_DIR="$HOME/.star_runner"
PROFILE_FILE="$SAVE_DIR/player_profile"
mkdir -p "$SAVE_DIR"

save_profile() {
  cat > "$PROFILE_FILE" << EOF
player_name="$player_name"
player_birth_year="$player_birth_year"
player_gender="$player_gender"
player_title="$player_title"
high_score="$high_score"
total_crystals="$total_crystals"
total_asteroids="$total_asteroids"
crystal_bank="$crystal_bank"
owned_ships="$owned_ships"
owned_skins="$owned_skins"
current_ship="$current_ship"
current_skin="$current_skin"
EOF
}

init_profile() {
  if [ ! -f "$PROFILE_FILE" ]; then
    printf "${COLOR_CYAN}Welcome, pilot! Let's create your profile.${COLOR_NEUTRAL}\n\n"
    
    # Validate name input
    while true; do
      printf "Enter your name: "
      read -r player_name
      
      if [ -n "$player_name" ]; then
        break
      else
        printf "${COLOR_RED}Name cannot be empty!${COLOR_NEUTRAL}\n"
      fi
    done
    
    # Validate birth year input
    current_year=2026
    while true; do
      printf "Enter your birth year (e.g., 2000): "
      read -r player_birth_year
      
      # Check if birth year is a valid number
      case $player_birth_year in
        ''|*[!0-9]*)
          printf "${COLOR_RED}Invalid year! Please enter a valid number.${COLOR_NEUTRAL}\n"
          ;;
        *)
          # Ensure it's treated as a number
          player_birth_year=$((player_birth_year + 0))
          if [ "$player_birth_year" -ge 1900 ] && [ "$player_birth_year" -le "$current_year" ]; then
            player_age=$((current_year - player_birth_year))
            break
          else
            printf "${COLOR_RED}Birth year must be between 1900 and ${current_year}.${COLOR_NEUTRAL}\n"
          fi
          ;;
      esac
    done
    
        # Validate gender input
    while true; do
      printf "Enter your gender (M/F): "
      read -r player_gender_input
      
      case $player_gender_input in
        [Mm]|[Mm]ale)
          if [ "$player_age" -lt 5 ]; then
            player_title="Baby"
          elif [ "$player_age" -lt 18 ]; then
            player_title="Boy"
          elif [ "$player_age" -lt 60 ]; then
            player_title="Mr."
          else
            player_title="Grand"
          fi
          break
          ;;
        [Ff]|[Ff]emale)
          player_gender="Female"
          if [ "$player_age" -lt 5 ]; then
            player_title="Baby"
          elif [ "$player_age" -lt 18 ]; then
            player_title="Girl"
          elif [ "$player_age" -lt 60 ]; then
            player_title="Mrs"
          else
            player_title="Granny"
          fi
          break
          ;;
        *)
          printf "${COLOR_RED}Invalid input! Please enter M for Male or F for Female.${COLOR_NEUTRAL}\n"
          ;;
      esac
    done


    # Default profile stats
    high_score=0
    total_crystals=0
    total_asteroids=0
    crystal_bank=100  # Starting crystals for shop
    owned_ships="1"   # Start with ship 1
    owned_skins="1"   # Start with skin 1
    current_ship=1
    current_skin=1

    # Save initial profile
    save_profile
    printf "\n${COLOR_GREEN}Profile created successfully! Welcome, ${player_title} ${player_name} (Age: ${player_age})!${COLOR_NEUTRAL}\n\n"
    printf "${COLOR_YELLOW}You've been granted 100 crystals to get started!${COLOR_NEUTRAL}\n\n"
    sleep 3
  else
    load_profile
    # Calculate current age from birth year
    current_year=2026
    player_age=$((current_year - player_birth_year))
  fi
}

load_profile() {
  if [ -f "$PROFILE_FILE" ]; then
    # shellcheck disable=SC1090
    . "$PROFILE_FILE"
    # Ensure numeric values are treated as numbers
    current_ship=$((current_ship + 0))
    current_skin=$((current_skin + 0))
    crystal_bank=$((crystal_bank + 0))
    high_score=$((high_score + 0))
    total_crystals=$((total_crystals + 0))
    total_asteroids=$((total_asteroids + 0))
    player_birth_year=$((player_birth_year + 0))
  fi
}

# Ship definitions (stats)
get_ship_name() {
  case $1 in
    1) printf "Scout" ;;
    2) printf "Interceptor" ;;
    3) printf "Frigate" ;;
    4) printf "Cruiser" ;;
    5) printf "Battleship" ;;
  esac
}

get_ship_icon() {
  case $1 in
    1) printf "▶" ;;
    2) printf "▷" ;;
    3) printf "⊳" ;;
    4) printf "⊲" ;;
    5) printf "⧐" ;;
  esac
}

get_ship_speed() {
  case $1 in
    1) printf "2" ;;  # Fast
    2) printf "2" ;;  # Fast
    3) printf "1" ;;  # Medium
    4) printf "1" ;;  # Medium
    5) printf "1" ;;  # Slow
  esac
}

get_ship_ammo() {
  case $1 in
    1) printf "20" ;;
    2) printf "25" ;;
    3) printf "30" ;;
    4) printf "40" ;;
    5) printf "50" ;;
  esac
}

get_ship_price() {
  case $1 in
    1) printf "0" ;;    # Free starter
    2) printf "150" ;;
    3) printf "300" ;;
    4) printf "500" ;;
    5) printf "800" ;;
  esac
}

# Skin definitions
get_skin_name() {
  case $1 in
    1) printf "Default" ;;
    2) printf "Crimson" ;;
    3) printf "Cyber" ;;
    4) printf "Gold" ;;
    5) printf "Rainbow" ;;
  esac
}

get_skin_color() {
  case $1 in
    1) printf "$COLOR_GREEN" ;;
    2) printf "$COLOR_RED" ;;
    3) printf "$COLOR_CYAN" ;;
    4) printf "$COLOR_YELLOW" ;;
    5) printf "$COLOR_MAGENTA" ;;
  esac
}

get_skin_price() {
  case $1 in
    1) printf "0" ;;    # Free starter
    2) printf "100" ;;
    3) printf "150" ;;
    4) printf "200" ;;
    5) printf "300" ;;
  esac
}

check_ownership() {
  item_id=$1
  owned_list=$2
  
  echo "$owned_list" | grep -q ",$item_id," && return 0
  echo "$owned_list" | grep -q "^$item_id," && return 0
  echo "$owned_list" | grep -q ",$item_id$" && return 0
  [ "$owned_list" = "$item_id" ] && return 0
  return 1
}

add_to_owned() {
  item_id=$1
  owned_list=$2
  
  if [ -z "$owned_list" ]; then
    printf "%s" "$item_id"
  else
    printf "%s,%s" "$owned_list" "$item_id"
  fi
}

show_hangar() {
  clear
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}                    HANGAR - SHIP SELECTION            ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "  ${COLOR_YELLOW}Crystal Bank: ${crystal_bank}💎${COLOR_NEUTRAL}\n\n"
  
  i=1
  while [ $i -le 5 ]; do
    ship_name=$(get_ship_name $i)
    ship_icon=$(get_ship_icon $i)
    ship_speed=$(get_ship_speed $i)
    ship_ammo=$(get_ship_ammo $i)
    ship_price=$(get_ship_price $i)
    
    if check_ownership "$i" "$owned_ships"; then
      status="${COLOR_GREEN}[OWNED]${COLOR_NEUTRAL}"
      if [ "$current_ship" = "$i" ]; then
        status="${COLOR_YELLOW}[EQUIPPED]${COLOR_NEUTRAL}"
      fi
    else
      status="${COLOR_RED}[LOCKED - ${ship_price}💎]${COLOR_NEUTRAL}"
    fi
    
    printf "  ${COLOR_CYAN}[$i]${COLOR_NEUTRAL} $ship_icon $ship_name - Speed:$ship_speed Ammo:$ship_ammo $status\n"
    i=$((i + 1))
  done
  
  printf "\n  ${COLOR_GREEN}[E]${COLOR_NEUTRAL} Equip Ship | ${COLOR_YELLOW}[B]${COLOR_NEUTRAL} Buy Ship | ${COLOR_MAGENTA}[S]${COLOR_NEUTRAL} Skins | ${COLOR_WHITE}[R]${COLOR_NEUTRAL} Return\n"
  printf "\n  Select option: "
  
  read -r hangar_choice
  
  case $hangar_choice in
    [1-5])
      if check_ownership "$hangar_choice" "$owned_ships"; then
        current_ship=$hangar_choice
        save_profile
        printf "\n  ${COLOR_GREEN}✓ Ship equipped!${COLOR_NEUTRAL}\n"
        sleep 1
        show_hangar
      else
        printf "\n  ${COLOR_RED}✗ You don't own this ship!${COLOR_NEUTRAL}\n"
        sleep 2
        show_hangar
      fi
      ;;
    [Bb])
      printf "\n  Enter ship number to buy (1-5): "
      read -r buy_ship
      case $buy_ship in
        [1-5])
          if check_ownership "$buy_ship" "$owned_ships"; then
            printf "\n  ${COLOR_YELLOW}You already own this ship!${COLOR_NEUTRAL}\n"
            sleep 2
          else
            ship_price=$(get_ship_price "$buy_ship")
            ship_name=$(get_ship_name "$buy_ship")
            if [ "$crystal_bank" -ge "$ship_price" ]; then
              crystal_bank=$((crystal_bank - ship_price))
              owned_ships=$(add_to_owned "$buy_ship" "$owned_ships")
              current_ship=$buy_ship
              save_profile
              printf "\n  ${COLOR_GREEN}✓ Purchased and equipped $ship_name!${COLOR_NEUTRAL}\n"
              sleep 2
            else
              printf "\n  ${COLOR_RED}✗ Not enough crystals! Need: $ship_price, Have: $crystal_bank${COLOR_NEUTRAL}\n"
              sleep 2
            fi
          fi
          ;;
      esac
      show_hangar
      ;;
    [Ss])
      show_skin_shop
      ;;
    [Ee])
      printf "\n  Enter ship number to equip (1-5): "
      read -r equip_ship
      case $equip_ship in
        [1-5])
          if check_ownership "$equip_ship" "$owned_ships"; then
            current_ship=$equip_ship
            save_profile
            printf "\n  ${COLOR_GREEN}✓ Ship equipped!${COLOR_NEUTRAL}\n"
            sleep 1
          else
            printf "\n  ${COLOR_RED}✗ You don't own this ship!${COLOR_NEUTRAL}\n"
            sleep 2
          fi
          ;;
      esac
      show_hangar
      ;;
    [Rr])
      return
      ;;
    *)
      show_hangar
      ;;
  esac
}

show_skin_shop() {
  clear
  printf "${COLOR_MAGENTA}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}║${COLOR_NEUTRAL}                    SKIN CUSTOMIZATION                 ${COLOR_MAGENTA}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_MAGENTA}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "  ${COLOR_YELLOW}Crystal Bank: ${crystal_bank}💎${COLOR_NEUTRAL}\n\n"
  
  i=1
  while [ $i -le 5 ]; do
    skin_name=$(get_skin_name $i)
    skin_color=$(get_skin_color $i)
    skin_price=$(get_skin_price $i)
    ship_icon=$(get_ship_icon "$current_ship")
    
    if check_ownership "$i" "$owned_skins"; then
      status="${COLOR_GREEN}[OWNED]${COLOR_NEUTRAL}"
      if [ "$current_skin" = "$i" ]; then
        status="${COLOR_YELLOW}[ACTIVE]${COLOR_NEUTRAL}"
      fi
    else
      status="${COLOR_RED}[LOCKED - ${skin_price}💎]${COLOR_NEUTRAL}"
    fi
    
    printf "  ${COLOR_CYAN}[$i]${COLOR_NEUTRAL} ${skin_color}${ship_icon}${COLOR_NEUTRAL} $skin_name $status\n"
    i=$((i + 1))
  done
  
  printf "\n  ${COLOR_GREEN}[A]${COLOR_NEUTRAL} Apply Skin | ${COLOR_YELLOW}[B]${COLOR_NEUTRAL} Buy Skin | ${COLOR_WHITE}[R]${COLOR_NEUTRAL} Return\n"
  printf "\n  Select option: "
  
  read -r skin_choice
  
  case $skin_choice in
    [1-5])
      if check_ownership "$skin_choice" "$owned_skins"; then
        current_skin=$skin_choice
        save_profile
        printf "\n  ${COLOR_GREEN}✓ Skin applied!${COLOR_NEUTRAL}\n"
        sleep 1
        show_skin_shop
      else
        printf "\n  ${COLOR_RED}✗ You don't own this skin!${COLOR_NEUTRAL}\n"
        sleep 2
        show_skin_shop
      fi
      ;;
    [Bb])
      printf "\n  Enter skin number to buy (1-5): "
      read -r buy_skin
      case $buy_skin in
        [1-5])
          if check_ownership "$buy_skin" "$owned_skins"; then
            printf "\n  ${COLOR_YELLOW}You already own this skin!${COLOR_NEUTRAL}\n"
            sleep 2
          else
            skin_price=$(get_skin_price "$buy_skin")
            skin_name=$(get_skin_name "$buy_skin")
            if [ "$crystal_bank" -ge "$skin_price" ]; then
              crystal_bank=$((crystal_bank - skin_price))
              owned_skins=$(add_to_owned "$buy_skin" "$owned_skins")
              current_skin=$buy_skin
              save_profile
              printf "\n  ${COLOR_GREEN}✓ Purchased and applied $skin_name skin!${COLOR_NEUTRAL}\n"
              sleep 2
            else
              printf "\n  ${COLOR_RED}✗ Not enough crystals! Need: $skin_price, Have: $crystal_bank${COLOR_NEUTRAL}\n"
              sleep 2
            fi
          fi
          ;;
      esac
      show_skin_shop
      ;;
    [Aa])
      printf "\n  Enter skin number to apply (1-5): "
      read -r apply_skin
      case $apply_skin in
        [1-5])
          if check_ownership "$apply_skin" "$owned_skins"; then
            current_skin=$apply_skin
            save_profile
            printf "\n  ${COLOR_GREEN}✓ Skin applied!${COLOR_NEUTRAL}\n"
            sleep 1
          else
            printf "\n  ${COLOR_RED}✗ You don't own this skin!${COLOR_NEUTRAL}\n"
            sleep 2
          fi
          ;;
      esac
      show_skin_shop
      ;;
    [Rr])
      show_hangar
      ;;
    *)
      show_skin_shop
      ;;
  esac
}

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
  
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}                      MAIN MENU                        ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "  ${COLOR_GREEN}[1]${COLOR_NEUTRAL} Start Mission\n"
  printf "  ${COLOR_YELLOW}[2]${COLOR_NEUTRAL} Hangar (Ships & Skins)\n"
  printf "  ${COLOR_MAGENTA}[3]${COLOR_NEUTRAL} View Stats\n"
  printf "  ${COLOR_CYAN}[4]${COLOR_NEUTRAL} Help\n"
  printf "  ${COLOR_RED}[5]${COLOR_NEUTRAL} Quit\n\n"
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
      printf "\n  ${COLOR_CYAN}Thanks for playing! Fly safe, pilot!${COLOR_NEUTRAL}\n\n"
      exit 0
      ;;
    *)
      show_main_menu
      ;;
  esac
}

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

# Constants
COLOR_BLUE='\e[1;34m'
COLOR_GREEN='\e[1;32m'
COLOR_MAGENTA='\e[1;35m'
COLOR_NEUTRAL='\e[0m'
COLOR_RED='\e[1;31m'
COLOR_YELLOW='\e[1;33m'
COLOR_CYAN='\e[1;36m'
COLOR_WHITE='\e[1;37m'
ESCAPE_CHAR=$(printf '\033')
MIN_NUM_COLUMNS=40
MIN_NUM_LINES=20
TURN_DURATION=2
TERMINAL_SIZE=$(stty size)
NUM_COLUMNS="${TERMINAL_SIZE##* }"
NUM_LINES="${TERMINAL_SIZE%% *}"

if [ "$NUM_LINES" -lt "$MIN_NUM_LINES" ] || [ "$NUM_COLUMNS" -lt "$MIN_NUM_COLUMNS" ]; then
  printf 'Error: Your terminal size is too small. Need at least 40x20.\n' >&2
  exit 1
fi

if ! type stty > /dev/null 2>&1; then
  printf 'Error: stty is required\n' >&2
  exit 1
fi

read_chars() {
  eval "$1=\$(dd bs=1 count=$2 2>/dev/null)"
}

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
    A) # Up - always move 1 line at a time vertically
      if [ "$ship_line" -gt 3 ]; then
        clear_ship
        ship_line=$((ship_line - 1))
      fi
      ;;
    B) # Down - always move 1 line at a time vertically
      if [ "$ship_line" -lt $((NUM_LINES - 2)) ]; then
        clear_ship
        ship_line=$((ship_line + 1))
      fi
      ;;
    C) # Right - use ship speed for horizontal movement
      if [ "$ship_column" -lt $((NUM_COLUMNS - 10)) ]; then
        clear_ship
        ship_column=$((ship_column + ship_speed))
      fi
      ;;
    D) # Left - use ship speed for horizontal movement
      if [ "$ship_column" -gt 5 ]; then
        clear_ship
        ship_column=$((ship_column - ship_speed))
      fi
      ;;
    q) on_exit ;;
    p) toggle_pause ;;
    ' ') fire_weapon ;;
  esac
}

get_random_number() {
  min=$1
  max=$2
  range=$((max - min + 1))
  num=$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ')
  printf "%d" $((min + num % range))
}

show_alternate_screen() {
  printf '\033[?1049h\033[2J\033[H'
}

hide_alternate_screen() {
  printf '\033[2J\033[H\033[?1049l'
}

move_cursor() {
  printf "\033[$1;$2H"
}

hide_cursor() {
  printf "\033[?25l"
}

show_cursor() {
  printf "\033[?25h"
}

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

clear_ship() {
  move_cursor "$ship_line" "$ship_column"
  if [ "$shield_active" = 1 ] || [ "$super_mode_active" = 1 ]; then
    printf "    "
  else
    printf "  "
  fi
}

spawn_asteroid() {
  asteroid_count=$((asteroid_count + 1))
  i=$asteroid_count

  line=$(get_random_number 10 $((NUM_LINES - 10)))
  column=$((NUM_COLUMNS - 1))
  size=$(get_random_number 1 3)
  
  if [ "$level" -ge 3 ]; then
    type_chance=$(get_random_number 1 10)
    if [ "$type_chance" -le 3 ]; then
      asteroid_type=2
    else
      asteroid_type=1
    fi
  else
    asteroid_type=1
  fi

  eval "asteroid_${i}_line=$line"
  eval "asteroid_${i}_col=$column"
  eval "asteroid_${i}_size=$size"
  eval "asteroid_${i}_type=$asteroid_type"
  eval "asteroid_${i}_active=1"
}

spawn_crystal() {
  if [ "$crystal_active" = 0 ]; then
    chance=$(get_random_number 1 1)
    if [ "$chance" = 1 ]; then
      line=$(get_random_number 3 $((NUM_LINES - 2)))
      column=$((NUM_COLUMNS - 2))
      crystal_line=$line
      crystal_col=$column
      crystal_active=1
    fi
  fi
}

spawn_powerup() {
  if [ "$powerup_active" = 0 ]; then
    chance=$(get_random_number 1 8)
    if [ "$chance" = 1 ]; then
      line=$(get_random_number 3 $((NUM_LINES - 2)))
      column=$((NUM_COLUMNS - 2))
      if [ "$level" -ge 4 ]; then
        powerup_type=$(get_random_number 1 5)
      else
        powerup_type=$(get_random_number 1 3)
      fi
      powerup_line=$line
      powerup_col=$column
      powerup_active=1
    fi
  fi
}

move_asteroids() {
  i=1
  while [ $i -le "$asteroid_count" ]; do
    eval "active=\$asteroid_${i}_active"
    
    if [ "$active" = 1 ]; then
      eval "line=\$asteroid_${i}_line"
      eval "col=\$asteroid_${i}_col"
      eval "size=\$asteroid_${i}_size"
      eval "type=\$asteroid_${i}_type"
      
      move_cursor "$line" "$col"
      case $size in
        1) printf "   " ;;
        2) printf "    " ;;
        3) printf "     " ;;
      esac
      
      if [ "$type" = 2 ]; then
        col=$((col - 1))
        if [ "$line" -lt "$ship_line" ]; then
          line=$((line + 1))
        elif [ "$line" -gt "$ship_line" ]; then
          line=$((line - 1))
        fi
      else
        move_speed=$((1 + speed_multiplier / 2))
        col=$((col - move_speed))
      fi
      
      if [ "$col" -lt 1 ]; then
        eval "asteroid_${i}_active=0"
      else
        eval "asteroid_${i}_col=$col"
        eval "asteroid_${i}_line=$line"
        
        move_cursor "$line" "$col"
        
        if [ "$type" = 2 ]; then
          printf "$COLOR_MAGENTA"
          case $size in
            1) printf "⊕" ;;
            2) printf "◉◉" ;;
            3) printf "◉⊕◉" ;;
          esac
        else
          printf "$COLOR_RED"
          case $size in
            1) printf "◆" ;;
            2) printf "◈◈" ;;
            3) printf "◈◆◈" ;;
          esac
        fi
        printf "$COLOR_NEUTRAL"
      fi
    fi
    i=$((i + 1))
  done
}

move_crystal() {
  if [ "$crystal_active" = 1 ]; then
    move_cursor "$crystal_line" "$crystal_col"
    printf " "
    
    crystal_col=$((crystal_col - 1))
    
    if [ "$crystal_col" -lt 1 ]; then
      crystal_active=0
    else
      move_cursor "$crystal_line" "$crystal_col"
      printf "${COLOR_CYAN}◇${COLOR_NEUTRAL}"
    fi
  fi
}

move_powerup() {
  if [ "$powerup_active" = 1 ]; then
    move_cursor "$powerup_line" "$powerup_col"
    printf "  "
    
    powerup_col=$((powerup_col - 1))
    
    if [ "$powerup_col" -lt 1 ]; then
      powerup_active=0
    else
      move_cursor "$powerup_line" "$powerup_col"
      case $powerup_type in
        1) printf "${COLOR_YELLOW}☢${COLOR_NEUTRAL}" ;;
        2) printf "${COLOR_MAGENTA}◈${COLOR_NEUTRAL}" ;;
        3) printf "${COLOR_GREEN}⊕${COLOR_NEUTRAL}" ;;
        4) printf "${COLOR_CYAN}⚡${COLOR_NEUTRAL}" ;;
        5) printf "${COLOR_WHITE}◇${COLOR_NEUTRAL}" ;;
      esac
    fi
  fi
}

fire_weapon() {
  if [ "$weapon_type" = 1 ]; then
    if [ "$laser_active" = 0 ] && [ "$ammo" -gt 0 ]; then
      laser_line=$ship_line
      laser_col=$((ship_column + 2))
      laser_active=1
      ammo=$((ammo - 1))
    fi
  elif [ "$weapon_type" = 2 ]; then
    if [ "$laser_active" = 0 ] && [ "$laser2_active" = 0 ] && [ "$laser3_active" = 0 ] && [ "$ammo" -ge 3 ]; then
      laser_line=$ship_line
      laser_col=$((ship_column + 2))
      laser_active=1
      
      laser2_line=$((ship_line - 1))
      laser2_col=$((ship_column + 2))
      laser2_active=1
      
      laser3_line=$((ship_line + 1))
      laser3_col=$((ship_column + 2))
      laser3_active=1
      
      ammo=$((ammo - 3))
    fi
  elif [ "$weapon_type" = 3 ]; then
    if [ "$ammo" -gt 0 ]; then
      if [ "$laser_active" = 0 ]; then
        laser_line=$ship_line
        laser_col=$((ship_column + 2))
        laser_active=1
        ammo=$((ammo - 1))
      fi
    fi
  fi
}

move_laser() {
  if [ "$laser_active" = 1 ]; then
    move_cursor "$laser_line" "$laser_col"
    printf " "
    
    laser_col=$((laser_col + 2))
    
    if [ "$laser_col" -ge "$NUM_COLUMNS" ]; then
      laser_active=0
    else
      move_cursor "$laser_line" "$laser_col"
      printf "${COLOR_YELLOW}━${COLOR_NEUTRAL}"
    fi
  fi
  
  if [ "$laser2_active" = 1 ]; then
    move_cursor "$laser2_line" "$laser2_col"
    printf " "
    
    laser2_col=$((laser2_col + 2))
    
    if [ "$laser2_col" -ge "$NUM_COLUMNS" ]; then
      laser2_active=0
    else
      move_cursor "$laser2_line" "$laser2_col"
      printf "${COLOR_YELLOW}━${COLOR_NEUTRAL}"
    fi
  fi
  
  if [ "$laser3_active" = 1 ]; then
    move_cursor "$laser3_line" "$laser3_col"
    printf " "
    
    laser3_col=$((laser3_col + 2))
    
    if [ "$laser3_col" -ge "$NUM_COLUMNS" ]; then
      laser3_active=0
    else
      move_cursor "$laser3_line" "$laser3_col"
      printf "${COLOR_YELLOW}━${COLOR_NEUTRAL}"
    fi
  fi
}

check_laser_hits() {
  for laser_num in 1 2 3; do
    eval "laser_is_active=\$laser${laser_num}_active"
    [ "$laser_num" = 1 ] && laser_is_active=$laser_active
    
    if [ "$laser_is_active" = 0 ]; then
      continue
    fi
    
    eval "current_laser_line=\$laser${laser_num}_line"
    eval "current_laser_col=\$laser${laser_num}_col"
    [ "$laser_num" = 1 ] && current_laser_line=$laser_line && current_laser_col=$laser_col
    
    i=1
    while [ $i -le "$asteroid_count" ]; do
      eval "active=\$asteroid_${i}_active"
      
      if [ "$active" = 1 ]; then
        eval "line=\$asteroid_${i}_line"
        eval "col=\$asteroid_${i}_col"
        eval "size=\$asteroid_${i}_size"
        eval "type=\$asteroid_${i}_type"
        
        if [ "$current_laser_line" = "$line" ]; then
          if [ "$current_laser_col" -ge "$col" ] && [ "$current_laser_col" -le $((col + size)) ]; then
            eval "asteroid_${i}_active=0"
            
            if [ "$laser_num" = 1 ]; then
              laser_active=0
            elif [ "$laser_num" = 2 ]; then
              laser2_active=0
            else
              laser3_active=0
            fi
            
            if [ "$type" = 2 ]; then
              score=$((score + 20))
            else
              score=$((score + 10))
            fi
            asteroids_destroyed=$((asteroids_destroyed + 1))
            
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
            
            move_cursor "$line" "$col"
            printf "${COLOR_YELLOW}✶${COLOR_NEUTRAL}"
            
            break
          fi
        fi
      fi
      i=$((i + 1))
    done
  done
}

check_collisions() {
  i=1
  while [ $i -le "$asteroid_count" ]; do
    eval "active=\$asteroid_${i}_active"
    
    if [ "$active" = 1 ]; then
      eval "line=\$asteroid_${i}_line"
      eval "col=\$asteroid_${i}_col"
      eval "size=\$asteroid_${i}_size"
      eval "type=\$asteroid_${i}_type"
      
      if [ "$ship_line" = "$line" ]; then
        if [ "$ship_column" -ge "$col" ] && [ "$ship_column" -le $((col + size)) ]; then
          if [ "$shield_active" = 1 ]; then
            shield_active=0
            eval "asteroid_${i}_active=0"
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
          elif [ "$super_mode_active" = 1 ]; then
            eval "asteroid_${i}_active=0"
            score=$((score + 5))
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
          else
            on_game_over
          fi
        fi
      fi
    fi
    i=$((i + 1))
  done
  
  if [ "$crystal_active" = 1 ]; then
    if [ "$ship_line" = "$crystal_line" ]; then
      if [ "$ship_column" -ge $((crystal_col - 1)) ] && [ "$ship_column" -le $((crystal_col + 1)) ]; then
        crystal_active=0
        score=$((score + 25))
        crystals_collected=$((crystals_collected + 1))
        ammo=$((ammo + 5))
      fi
    fi
  fi
  
  if [ "$powerup_active" = 1 ]; then
    if [ "$ship_line" = "$powerup_line" ]; then
      if [ "$ship_column" -ge $((powerup_col - 1)) ] && [ "$ship_column" -le $((powerup_col + 1)) ]; then
        powerup_active=0
        
        case $powerup_type in
          1)
            shield_active=1
            shield_timer=0
            ;;
          2)
            super_mode_active=1
            super_timer=0
            ;;
          3)
            ammo=$((ammo + 10))
            score=$((score + 20))
            ;;
          4)
            weapon_type=2
            weapon_timer=0
            ;;
          5)
            weapon_type=3
            weapon_timer=0
            ;;
        esac
      fi
    fi
  fi
}

update_timers() {
  if [ "$shield_active" = 1 ]; then
    shield_timer=$((shield_timer + 1))
    if [ "$shield_timer" -ge 30 ]; then
      shield_active=0
      shield_timer=0
    fi
  fi
  
  if [ "$super_mode_active" = 1 ]; then
    super_timer=$((super_timer + 1))
    if [ "$super_timer" -ge 25 ]; then
      super_mode_active=0
      super_timer=0
    fi
  fi
  
  if [ "$weapon_type" -ne 1 ]; then
    weapon_timer=$((weapon_timer + 1))
    if [ "$weapon_timer" -ge 40 ]; then
      weapon_type=1
      weapon_timer=0
    fi
  fi
}

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

on_game_over() {
  printf "$COLOR_RED"
  center_col=$((NUM_COLUMNS / 2 - 10))
  center_line=$((NUM_LINES / 2))
  move_cursor $center_line $center_col
  printf " ⚠ SHIP DESTROYED ⚠ "
  printf "$COLOR_NEUTRAL"
  
  sleep 3
  on_exit
}

on_enter() {
  hide_cursor
  show_alternate_screen
  trap 'on_exit' INT
  
  # Force initial draw of ship
  draw_border
  draw_ship
}

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
  cat << "EOF"

    ███████╗████████╗ █████╗ ██████╗     ██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
    ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗    ██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ███████╗   ██║   ███████║██████╔╝    ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ╚════██║   ██║   ██╔══██║██╔══██╗    ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ███████║   ██║   ██║  ██║██║  ██║    ██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
                                                                                                
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
if [ "$score" -lt 20 ]; then
  printf "${COLOR_WHITE}Street Spectator${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 40 ]; then
  printf "${COLOR_WHITE}Neon Bystander${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 65 ]; then
  printf "${COLOR_WHITE}Signal Listener${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 90 ]; then
  printf "${COLOR_WHITE}Binary Initiate${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 120 ]; then
  printf "${COLOR_GREEN}Cadet${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 155 ]; then
  printf "${COLOR_GREEN}Data Trainee${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 195 ]; then
  printf "${COLOR_GREEN}Grid Operator${COLOR_NEUTRAL}\n"

elif [ "$score" -lt 240 ]; then
  printf "${COLOR_CYAN}Packet Runner${COLOR_NEUTRAL}\n"

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
  printf "  Game gets harder as you level up!\n\n"
  printf "${COLOR_CYAN}COLLECTIBLES:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_CYAN}◇${COLOR_NEUTRAL}  Power Crystal - +50 points, +5 ammo, adds to bank!\n\n"
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
  printf "${COLOR_GREEN}Good luck, pilot! 🚀${COLOR_NEUTRAL}\n\n"
}

# Game variables
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

while :; do
  case $1 in
    -h | --help)
      show_help
      exit
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
      break ;;
  esac
  shift
done

# Initialize or load profile
init_profile

# Show main menu
show_main_menu

# Set ammo based on selected ship
current_ship=$((current_ship + 0))
ammo=$(get_ship_ammo "$current_ship")
ammo=$((ammo + 0))

stty -icanon -echo time $TURN_DURATION min 0

on_enter

# Intro
printf "$COLOR_CYAN"
center_col=$((NUM_COLUMNS / 2 - 12))
center_line=$((NUM_LINES / 2))
move_cursor $center_line $center_col
printf " ▶ LAUNCHING STAR RUNNER ◀ "
printf "$COLOR_NEUTRAL"
sleep 2
move_cursor $center_line $center_col
printf "                           "

# Clear screen and redraw everything
draw_border
draw_ship

# Game loop
while true; do
  if [ "$paused" = 0 ]; then
    handle_input

    new_level=$((score / 200 + 1))
    if [ "$new_level" -ne "$level" ]; then
      level=$new_level
      speed_multiplier=$((level - 1))
      
      printf "$COLOR_GREEN"
      center_col=$((NUM_COLUMNS / 2 - 10))
      center_line=$((NUM_LINES / 2))
      move_cursor $center_line $center_col
      printf " ★ LEVEL $level ★ "
      printf "$COLOR_NEUTRAL"
    fi

    frame_mod_10=$((frame % 10))
    if [ "$frame_mod_10" -eq 0 ]; then
      draw_stars
    fi

    spawn_frequency=$((4 - speed_multiplier))
    [ "$spawn_frequency" -lt 2 ] && spawn_frequency=2
    
    frame_mod_spawn=$((frame % spawn_frequency))
    if [ "$frame_mod_spawn" -eq 0 ]; then
      spawn_asteroid
    fi

    frame_mod_20=$((frame % 20))
    if [ "$frame_mod_20" -eq 0 ]; then
      spawn_crystal
      spawn_powerup
    fi

    move_asteroids
    move_crystal
    move_powerup
    move_laser

    check_laser_hits
    check_collisions
    update_timers

    draw_ship
    draw_hud

    frame=$((frame + 1))
  else
    # When paused, still handle input and redraw ship
    handle_input
    draw_ship
  fi
done