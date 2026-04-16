#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris


# STAR RUNNER - Weapons Module
# Laser firing and movement systems

# Fire weapon based on current weapon type
fire_weapon() {
  if [ "$weapon_type" = 1 ]; then
    # Standard single laser
    if [ "$laser_active" = 0 ] && [ "$ammo" -gt 0 ]; then
      laser_line=$ship_line
      laser_col=$((ship_column + 2))
      laser_active=1
      ammo=$((ammo - 1))
    fi
  elif [ "$weapon_type" = 2 ]; then
    # Spread shot - 3 lasers at once
    if [ "$laser_active" = 0 ] && [ "$laser2_active" = 0 ] && [ "$laser3_active" = 0 ] && [ "$ammo" -ge 3 ]; then
      # Center laser
      laser_line=$ship_line
      laser_col=$((ship_column + 2))
      laser_active=1
      
      # Top laser
      laser2_line=$((ship_line - 1))
      laser2_col=$((ship_column + 2))
      laser2_active=1
      
      # Bottom laser
      laser3_line=$((ship_line + 1))
      laser3_col=$((ship_column + 2))
      laser3_active=1
      
      ammo=$((ammo - 3))
    fi
  elif [ "$weapon_type" = 3 ]; then
    # Rapid fire - can fire continuously
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

# Move all active lasers
move_laser() {
  # Move laser 1
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
  
  # Move laser 2 (spread shot top)
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
  
  # Move laser 3 (spread shot bottom)
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

# Check if any laser hits an asteroid
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
        
        # Check collision
        if [ "$current_laser_line" = "$line" ]; then
          if [ "$current_laser_col" -ge "$col" ] && [ "$current_laser_col" -le $((col + size)) ]; then
            # Deactivate asteroid
            eval "asteroid_${i}_active=0"
            
            # Deactivate laser
            if [ "$laser_num" = 1 ]; then
              laser_active=0
            elif [ "$laser_num" = 2 ]; then
              laser2_active=0
            else
              laser3_active=0
            fi
            
            # Award points with combo support
            register_asteroid_destroy "$type"
            
            # Clear asteroid
            move_cursor "$line" "$col"
            case $size in
              1) printf "   " ;;
              2) printf "    " ;;
              3) printf "     " ;;
            esac
            
            # Show explosion effect
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
