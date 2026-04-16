#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris


# STAR RUNNER - Effects Module
# Powerup timers and temporary effects management

# Update all active timers
update_timers() {
  # Shield timer
  if [ "$shield_active" = 1 ]; then
    shield_timer=$((shield_timer + 1))
    if [ "$shield_timer" -ge 30 ]; then
      shield_active=0
      shield_timer=0
    fi
  fi
  
  # Super mode timer
  if [ "$super_mode_active" = 1 ]; then
    super_timer=$((super_timer + 1))
    if [ "$super_timer" -ge 25 ]; then
      super_mode_active=0
      super_timer=0
    fi
  fi
  
  # Weapon timer (for spread shot and rapid fire)
  if [ "$weapon_type" -ne 1 ]; then
    weapon_timer=$((weapon_timer + 1))
    if [ "$weapon_timer" -ge 40 ]; then
      weapon_type=1
      weapon_timer=0
    fi
  fi

  # Post-hit grace window
  if [ "$grace_timer" -gt 0 ]; then
    grace_timer=$((grace_timer - 1))
  fi
}
