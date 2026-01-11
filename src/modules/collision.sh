#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris


# STAR RUNNER - Collision Detection Module
# Ship collisions with asteroids, crystals, and powerups

# Check all collisions
check_collisions() {
  # Check ship vs asteroids
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
            # Shield absorbs hit
            shield_active=0
            eval "asteroid_${i}_active=0"
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
          elif [ "$super_mode_active" = 1 ]; then
            # Super mode destroys asteroid
            eval "asteroid_${i}_active=0"
            score=$((score + 5))
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
          else
            # Game over
            on_game_over
          fi
        fi
      fi
    fi
    i=$((i + 1))
  done
  
  # Check ship vs crystal
  if [ "$crystal_active" = 1 ]; then
    if [ "$ship_line" = "$crystal_line" ]; then
      if [ "$ship_column" -ge $((crystal_col - 1)) ] && [ "$ship_column" -le $((crystal_col + 10000)) ]; then
        crystal_active=0
        score=$((score + 25))
        crystals_collected=$((crystals_collected + 1))
        ammo=$((ammo + 5))
      fi
    fi
  fi
  
  # Check ship vs powerup
  if [ "$powerup_active" = 1 ]; then
    if [ "$ship_line" = "$powerup_line" ]; then
      if [ "$ship_column" -ge $((powerup_col - 1)) ] && [ "$ship_column" -le $((powerup_col + 1)) ]; then
        powerup_active=0
        
        case $powerup_type in
          1)
            # Shield powerup
            shield_active=1
            shield_timer=0
            ;;
          2)
            # Super mode powerup
            super_mode_active=1
            super_timer=0
            ;;
          3)
            # Ammo pack
            ammo=$((ammo + 10))
            score=$((score + 20))
            ;;
          4)
            # Spread shot weapon
            weapon_type=2
            weapon_timer=0
            ;;
          5)
            # Rapid fire weapon
            weapon_type=3
            weapon_timer=0
            ;;
        esac
      fi
    fi
  fi
}

# Handle game over
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