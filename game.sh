#!/bin/sh

# shellcheck disable=2059

# STAR RUNNER - Navigate through space, dodge asteroids, collect power crystals!


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
          player_gender="Male"
          if [ "$player_age" -lt 18 ]; then
            player_title="Boy"
          else
            player_title="Mr."
          fi
          break
          ;;
        [Ff]|[Ff]emale)
          player_gender="Female"
          if [ "$player_age" -lt 18 ]; then
            player_title="Girl"
          else
            player_title="Mrs."
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

    # Save initial profile
    save_profile
    printf "\n${COLOR_GREEN}Profile created successfully! Welcome, ${player_title} ${player_name} (Age: ${player_age})!${COLOR_NEUTRAL}\n\n"
    sleep 2
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
  fi
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

  case $key in
    A) # Up
      if [ "$ship_line" -gt 3 ]; then
        ship_line=$((ship_line - 1))
      fi
      ;;
    B) # Down
      if [ "$ship_line" -lt $((NUM_LINES - 2)) ]; then
        ship_line=$((ship_line + 1))
      fi
      ;;
    C) # Right
      if [ "$ship_column" -lt $((NUM_COLUMNS - 10)) ]; then
        ship_column=$((ship_column + 2))
      fi
      ;;
    D) # Left
      if [ "$ship_column" -gt 5 ]; then
        ship_column=$((ship_column - 2))
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
  
  if [ "$shield_active" = 1 ]; then
    printf "${COLOR_CYAN}⟨${COLOR_GREEN}▶${COLOR_CYAN}⟩${COLOR_NEUTRAL}"
  elif [ "$super_mode_active" = 1 ]; then
    printf "${COLOR_YELLOW}⟨◆⟩${COLOR_NEUTRAL}"
  else
    printf "${COLOR_GREEN}▶${COLOR_NEUTRAL}"
  fi
}

clear_ship() {
  move_cursor "$ship_line" $((ship_column - 3))
  printf "      "
}




spawn_asteroid() {
  i=1
  while [ $i -le 8 ]; do
    eval "active=\${asteroid_${i}_active:-0}"

    if [ "$active" = 0 ]; then
      line=$(get_random_number 3 $((NUM_LINES - 2)))
      column=$((NUM_COLUMNS - 2))
      size=$(get_random_number 1 3)

      eval "asteroid_${i}_line=$line"
      eval "asteroid_${i}_col=$column"
      eval "asteroid_${i}_size=$size"
      eval "asteroid_${i}_active=1"

      [ "$i" -gt "$asteroid_count" ] && asteroid_count=$i
      return
    fi
    i=$((i + 1))
  done
}


spawn_crystal() {
  if [ "$crystal_active" = 0 ]; then
    chance=$(get_random_number 1 5)
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
    chance=$(get_random_number 1 10)
    if [ "$chance" = 1 ]; then
      line=$(get_random_number 3 $((NUM_LINES - 2)))
      column=$((NUM_COLUMNS - 2))
      powerup_type=$(get_random_number 1 3)
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
      
      # Clear old position
      move_cursor "$line" "$col"
      case $size in
        1) printf "  " ;;
        2) printf "   " ;;
        3) printf "    " ;;
      esac
      
      # Move left
      col=$((col - 1))
      
      if [ "$col" -lt 1 ]; then
        eval "asteroid_${i}_active=0"
      else
        eval "asteroid_${i}_col=$col"
        
        # Draw at new position
        move_cursor "$line" "$col"
        printf "$COLOR_RED"
        case $size in
          1) printf "◆" ;;
          2) printf "◈◈" ;;
          3) printf "◈◆◈" ;;
        esac
        printf "$COLOR_NEUTRAL"
      fi
    fi
    i=$((i + 1))
  done
}

move_crystal() {
  if [ "$crystal_active" = 1 ]; then
    # Clear old
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
    # Clear old
    move_cursor "$powerup_line" "$powerup_col"
    printf " "
    
    powerup_col=$((powerup_col - 1))
    
    if [ "$powerup_col" -lt 1 ]; then
      powerup_active=0
    else
      move_cursor "$powerup_line" "$powerup_col"
      case $powerup_type in
        1) printf "${COLOR_YELLOW}☢${COLOR_NEUTRAL}" ;;
        2) printf "${COLOR_MAGENTA}◈${COLOR_NEUTRAL}" ;;
        3) printf "${COLOR_GREEN}⊕${COLOR_NEUTRAL}" ;;
      esac
    fi
  fi
}

fire_weapon() {
  if (( laser_active == 0 && ammo > 0 )); then
    laser_line=$ship_line
    laser_col=$((ship_column + 2))
    laser_active=1
    ((ammo--))
  fi
}

move_laser() {
  if [ "$laser_active" = 1 ]; then
    # Clear old
    move_cursor "$laser_line" "$laser_col"
    printf " "
    
    laser_col=$((laser_col + 1))
    
    if [ "$laser_col" -ge "$NUM_COLUMNS" ]; then
      laser_active=0
    else
      move_cursor "$laser_line" "$laser_col"
      printf "${COLOR_YELLOW}━${COLOR_NEUTRAL}"
    fi
  fi
}

check_laser_hits() {
  if [ "$laser_active" = 0 ]; then
    return
  fi
  
  i=1
  while [ $i -le "$asteroid_count" ]; do
    eval "active=\$asteroid_${i}_active"
    
    if [ "$active" = 1 ]; then
      eval "line=\$asteroid_${i}_line"
      eval "col=\$asteroid_${i}_col"
      eval "size=\$asteroid_${i}_size"
      
      if [ "$laser_line" = "$line" ]; then
        if [ "$laser_col" -ge "$col" ] && [ "$laser_col" -le $((col + size)) ]; then
          # Hit!
          eval "asteroid_${i}_active=0"
          laser_active=0
          score=$((score + 10))
          asteroids_destroyed=$((asteroids_destroyed + 1))
          
          # Clear asteroid
          move_cursor "$line" "$col"
          case $size in
            1) printf "  " ;;
            2) printf "   " ;;
            3) printf "    " ;;
          esac
          
          # Explosion effect
          move_cursor "$line" "$col"
          printf "${COLOR_YELLOW}✶${COLOR_NEUTRAL}"
          
          return
        fi
      fi
    fi
    i=$((i + 1))
  done
}

check_collisions() {
  # Check asteroids
  i=1
  while [ $i -le "$asteroid_count" ]; do
    eval "active=\$asteroid_${i}_active"
    
    if [ "$active" = 1 ]; then
      eval "line=\$asteroid_${i}_line"
      eval "col=\$asteroid_${i}_col"
      eval "size=\$asteroid_${i}_size"
      
      if [ "$ship_line" = "$line" ]; then
        if [ "$ship_column" -ge "$col" ] && [ "$ship_column" -le $((col + size)) ]; then
          if [ "$shield_active" = 1 ]; then
            shield_active=0
            eval "asteroid_${i}_active=0"
            move_cursor "$line" "$col"
            case $size in
              1) printf "  " ;;
              2) printf "   " ;;
              3) printf "    " ;;
            esac
          elif [ "$super_mode_active" = 1 ]; then
            eval "asteroid_${i}_active=0"
            score=$((score + 5))
            move_cursor "$line" "$col"
            case $size in
              1) printf "  " ;;
              2) printf "   " ;;
              3) printf "    " ;;
            esac
          else
            on_game_over
          fi
        fi
      fi
    fi
    i=$((i + 1))
  done
  
  # Check crystal
  if [ "$crystal_active" = 1 ]; then
    if [ "$ship_line" = "$crystal_line" ]; then
      if [ "$ship_column" -ge $((crystal_col - 1)) ] && [ "$ship_column" -le $((crystal_col + 1)) ]; then
        crystal_active=0
        score=$((score + 50))
        crystals_collected=$((crystals_collected + 1))
        ammo=$((ammo + 5))
      fi
    fi
  fi
  
  # Check powerup
  if [ "$powerup_active" = 1 ]; then
    if [ "$ship_line" = "$powerup_line" ]; then
      if [ "$ship_column" -ge $((powerup_col - 1)) ] && [ "$ship_column" -le $((powerup_col + 1)) ]; then
        powerup_active=0
        
        case $powerup_type in
          1) # Shield
            shield_active=1
            shield_timer=0
            ;;
          2) # Super mode
            super_mode_active=1
            super_timer=0
            ;;
          3) # Ammo
            ammo=$((ammo + 10))
            score=$((score + 20))
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
}

draw_hud() {
  printf "$COLOR_YELLOW"
  move_cursor 2 5
  printf "SCORE: $score"
  
  move_cursor 2 20
  printf "AMMO: $ammo"
  
  move_cursor 2 35
  printf "CRYSTALS: $crystals_collected"
  
  if [ "$shield_active" = 1 ]; then
    printf "$COLOR_CYAN"
    move_cursor 2 50
    printf "⟨SHIELD⟩"
  fi
  
  if [ "$super_mode_active" = 1 ]; then
    printf "$COLOR_YELLOW"
    move_cursor 2 65
    printf "⟨SUPER⟩"
  fi
  
  printf "$COLOR_NEUTRAL"
}

draw_stars() {
  # Background stars
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
  # 1. Update and Save Data
  if [ -n "$player_name" ]; then
    # Update high score if mission score is higher
    if [ "$score" -gt "$high_score" ]; then
      high_score=$score
    fi
    
    # Add mission stats to career totals
    total_crystals=$((total_crystals + crystals_collected))
    total_asteroids=$((total_asteroids + asteroids_destroyed))
    
    # Save to local profile file
    save_profile
    
    # --- CLOUD SYNC SECTION ---
    safe_name=$(echo "$player_name" | tr -d '[:space:][:punct:]')
    
    # Send only the score to your KVdb bucket
    # -m 5: timeout after 5 seconds
    # -s: silent mode
    # -o /dev/null: hide technical output
    # --data-raw: ensure the number is sent exactly
    curl -s -m 5 -o /dev/null -X POST \
         --data-raw "$score" \
         "https://kvdb.io/HKnPR6HRekZq7J327tEQfa/player_$safe_name"
    # --- END CLOUD SYNC ---
  fi
  
  # 2. Restore Terminal State
  hide_alternate_screen
  show_cursor
  stty icanon echo
  
  # 3. Display Final Results UI
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
  printf "  ${COLOR_CYAN}◇ Crystals Collected:${COLOR_NEUTRAL} $crystals_collected\n"
  printf "  ${COLOR_RED}◆ Asteroids Destroyed:${COLOR_NEUTRAL} $asteroids_destroyed\n\n"
  
  if [ -n "$player_name" ]; then
    current_year=2026
    player_age=$((current_year - player_birth_year))
    printf "  ${COLOR_CYAN}👤 Pilot:${COLOR_NEUTRAL} ${COLOR_GREEN}${player_title} ${player_name}${COLOR_NEUTRAL} (Age: $player_age)\n"
    printf "  ${COLOR_MAGENTA}📊 Career Stats:${COLOR_NEUTRAL}\n"
    printf "  ${COLOR_YELLOW}🏆 High Score:${COLOR_NEUTRAL} $high_score\n"
    printf "  ${COLOR_CYAN}💎 Total Crystals:${COLOR_NEUTRAL} $total_crystals\n"
    printf "  ${COLOR_RED}💥 Total Asteroids:${COLOR_NEUTRAL} $total_asteroids\n\n"
  fi
  
  printf "  ${COLOR_GREEN}☆ Rank:${COLOR_NEUTRAL} "
  
  if [ "$score" -lt 100 ]; then
    printf "${COLOR_WHITE}Cadet${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 300 ]; then
    printf "${COLOR_GREEN}Pilot${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 500 ]; then
    printf "${COLOR_CYAN}Commander${COLOR_NEUTRAL}\n"
  elif [ "$score" -lt 1000 ]; then
    printf "${COLOR_MAGENTA}Captain${COLOR_NEUTRAL}\n"
  else
    printf "${COLOR_YELLOW}Admiral${COLOR_NEUTRAL}\n"
  fi
  
  printf "\n  ${COLOR_CYAN}Created by Dulsara(SYNAPSNEX)${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_YELLOW}dulsara.synapsnex@gmail.com${COLOR_NEUTRAL}\n\n"
  
  exit
}
show_help() {
  printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}║${COLOR_NEUTRAL}         STAR RUNNER - MISSION BRIEFING               ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
  printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
  printf "${COLOR_YELLOW}CONTROLS:${COLOR_NEUTRAL}\n"
  printf "  Arrow Keys - Navigate your ship\n"
  printf "  [SPACE]    - Fire laser (uses ammo)\n"
  printf "  [P]        - Pause/Resume\n"
  printf "  [Q]        - Quit mission\n\n"
  printf "${COLOR_GREEN}OBJECTIVE:${COLOR_NEUTRAL}\n"
  printf "  Navigate through space, dodge asteroids, collect crystals!\n"
  printf "  Destroy asteroids with your laser for bonus points.\n\n"
  printf "${COLOR_CYAN}COLLECTIBLES:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_CYAN}◇${COLOR_NEUTRAL}  Power Crystal - +50 points, +5 ammo\n\n"
  printf "${COLOR_MAGENTA}POWER-UPS:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_YELLOW}☢${COLOR_NEUTRAL}  Shield - Absorb one hit\n"
  printf "  ${COLOR_MAGENTA}◈${COLOR_NEUTRAL}  Super Mode - Invincibility + destroy asteroids on contact\n"
  printf "  ${COLOR_GREEN}⊕${COLOR_NEUTRAL}  Ammo Pack - +10 laser shots, +20 points\n\n"
  printf "${COLOR_RED}HAZARDS:${COLOR_NEUTRAL}\n"
  printf "  ${COLOR_RED}◆ ◈◈ ◈◆◈${COLOR_NEUTRAL}  Asteroids of various sizes\n\n"
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
shield_active=0
shield_timer=0
super_mode_active=0
super_timer=0
frame=0
score=0
crystals_collected=0
asteroids_destroyed=0
ammo=20

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

# Initialize or load profile BEFORE changing terminal settings
init_profile

stty -icanon -echo time $TURN_DURATION min 0

on_enter
draw_border

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

# Game loop
while true; do
  if [ "$paused" = 0 ]; then
    sleep 0.03

    clear_ship
    handle_input

    # Background
    frame_mod_10=$((frame % 10))
    if [ "$frame_mod_10" -eq 0 ]; then
      draw_stars
    fi

    # Spawning
    frame_mod_3=$((frame % 3))
    if [ "$frame_mod_3" -eq 0 ]; then
      spawn_asteroid
    fi

    frame_mod_20=$((frame % 20))
    if [ "$frame_mod_20" -eq 0 ]; then
      spawn_crystal
      spawn_powerup
    fi

    # Movement
    move_asteroids
    move_crystal
    move_powerup
    move_laser

    # Logic
    check_laser_hits
    check_collisions
    update_timers

    # Draw
    draw_ship
    draw_hud

    frame=$((frame + 1))
  fi
done