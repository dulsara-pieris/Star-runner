#!/usr/bin/env bash

#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# =============================
# STAR RUNNER - Inventory / Shop Module
# Combines Ships, Skins, and Crystal Management
# =============================

# -----------------------------
# Ships Definition
# -----------------------------
declare -A ships

ships[1_name]="Scout"
ships[1_icon]="▶"
ships[1_speed]=2
ships[1_ammo]=20
ships[1_health]=50
ships[1_price]=0
ships[1_unlock_level]=0
ships[1_ability]="Speed Boost"
ships[1_max_speed]=3

ships[2_name]="Interceptor"
ships[2_icon]="▷"
ships[2_speed]=2
ships[2_ammo]=25
ships[2_health]=60
ships[2_price]=150
ships[2_unlock_level]=5
ships[2_ability]="Double Shot"
ships[2_max_speed]=3

ships[3_name]="Frigate"
ships[3_icon]="⊳"
ships[3_speed]=1
ships[3_ammo]=30
ships[3_health]=80
ships[3_price]=300
ships[3_unlock_level]=10
ships[3_ability]="Shield"
ships[3_max_speed]=2

ships[4_name]="Cruiser"
ships[4_icon]="⊲"
ships[4_speed]=1
ships[4_ammo]=40
ships[4_health]=100
ships[4_price]=500
ships[4_unlock_level]=15
ships[4_ability]="Mega Bomb"
ships[4_max_speed]=2

ships[5_name]="Battleship"
ships[5_icon]="⧐"
ships[5_speed]=1
ships[5_ammo]=50
ships[5_health]=150
ships[5_price]=800
ships[5_unlock_level]=20
ships[5_ability]="Invincible Burst"
ships[5_max_speed]=1

# -----------------------------
# Skins Definition
# -----------------------------
declare -A skins

skins[1_name]="Red Blaze"
skins[1_color]="${COLOR_RED}"
skins[1_price]=50

skins[2_name]="Blue Comet"
skins[2_color]="${COLOR_BLUE}"
skins[2_price]=50

skins[3_name]="Green Flash"
skins[3_color]="${COLOR_GREEN}"
skins[3_price]=75

skins[4_name]="Yellow Star"
skins[4_color]="${COLOR_YELLOW}"
skins[4_price]=100

skins[5_name]="Purple Nova"
skins[5_color]="${COLOR_MAGENTA}"
skins[5_price]=150

# -----------------------------
# Getter Functions
# -----------------------------
get_ship_name() { echo "${ships[$1_name]}"; }
get_ship_icon() { echo "${ships[$1_icon]}"; }
get_ship_speed() { echo "${ships[$1_speed]}"; }
get_ship_ammo() { echo "${ships[$1_ammo]}"; }
get_ship_health() { echo "${ships[$1_health]}"; }
get_ship_price() { echo "${ships[$1_price]}"; }
get_ship_unlock_level() { echo "${ships[$1_unlock_level]}"; }
get_ship_ability() { echo "${ships[$1_ability]}"; }
get_ship_max_speed() { echo "${ships[$1_max_speed]}"; }

get_skin_name() { echo "${skins[$1_name]}"; }
get_skin_color() { echo "${skins[$1_color]}"; }
get_skin_price() { echo "${skins[$1_price]}"; }

# -----------------------------
# Utility: Ownership & Profile
# -----------------------------
check_ownership() {
  local id=$1
  local list=$2
  [[ ",$list," == *",$id,"* ]] && return 0 || return 1
}

add_to_owned() {
  local id=$1
  local list=$2
  if [ -z "$list" ]; then
    echo "$id"
  else
    echo "$list,$id"
  fi
}

# -----------------------------
# Equip / Buy Ship
# -----------------------------
equip_ship() {
  local id=$1
  if check_ownership "$id" "$owned_ships"; then
    current_ship=$id
    save_profile
    printf "\n  ${COLOR_GREEN}✓ Ship equipped: $(get_ship_name $id)${COLOR_NEUTRAL}\n"
    sleep 1
  else
    printf "\n  ${COLOR_RED}✗ You don't own this ship!${COLOR_NEUTRAL}\n"
    sleep 2
  fi
}

buy_ship() {
  local id=$1
  if check_ownership "$id" "$owned_ships"; then
    printf "\n  ${COLOR_YELLOW}You already own this ship!${COLOR_NEUTRAL}\n"
    sleep 2
    return
  fi

  local price=$(get_ship_price "$id")
  local name=$(get_ship_name "$id")
  if [ "$crystal_bank" -ge "$price" ]; then
    crystal_bank=$((crystal_bank - price))
    owned_ships=$(add_to_owned "$id" "$owned_ships")
    current_ship=$id
    save_profile
    printf "\n  ${COLOR_GREEN}✓ Purchased and equipped $name!${COLOR_NEUTRAL}\n"
    sleep 2
  else
    printf "\n  ${COLOR_RED}✗ Not enough crystals! Need: $price, Have: $crystal_bank${COLOR_NEUTRAL}\n"
    sleep 2
  fi
}

# -----------------------------
# Equip / Buy Skin
# -----------------------------
apply_skin() {
  local id=$1
  if check_ownership "$id" "$owned_skins"; then
    current_skin=$id
    save_profile
    printf "\n  ${COLOR_GREEN}✓ Skin applied: $(get_skin_name $id)${COLOR_NEUTRAL}\n"
    sleep 1
  else
    printf "\n  ${COLOR_RED}✗ You don't own this skin!${COLOR_NEUTRAL}\n"
    sleep 2
  fi
}

buy_skin() {
  local id=$1
  if check_ownership "$id" "$owned_skins"; then
    printf "\n  ${COLOR_YELLOW}You already own this skin!${COLOR_NEUTRAL}\n"
    sleep 2
    return
  fi

  local price=$(get_skin_price "$id")
  local name=$(get_skin_name "$id")
  if [ "$crystal_bank" -ge "$price" ]; then
    crystal_bank=$((crystal_bank - price))
    owned_skins=$(add_to_owned "$id" "$owned_skins")
    current_skin=$id
    save_profile
    printf "\n  ${COLOR_GREEN}✓ Purchased and applied $name skin!${COLOR_NEUTRAL}\n"
    sleep 2
  else
    printf "\n  ${COLOR_RED}✗ Not enough crystals! Need: $price, Have: $crystal_bank${COLOR_NEUTRAL}\n"
    sleep 2
  fi
}

# -----------------------------
# Show Hangar
# -----------------------------
show_hangar() {
  while true; do
    clear
    printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}║${COLOR_NEUTRAL}                    HANGAR - SHIP SELECTION            ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
    printf "  ${COLOR_YELLOW}Crystal Bank: ${crystal_bank}💎${COLOR_NEUTRAL}\n\n"

    for id in {1..5}; do
      local ship_name=$(get_ship_name $id)
      local ship_icon=$(get_ship_icon $id)
      local ship_speed=$(get_ship_speed $id)
      local ship_ammo=$(get_ship_ammo $id)
      local ship_price=$(get_ship_price $id)

      if check_ownership "$id" "$owned_ships"; then
        if [ "$current_ship" = "$id" ]; then
          status="${COLOR_YELLOW}[EQUIPPED]${COLOR_NEUTRAL}"
        else
          status="${COLOR_GREEN}[OWNED]${COLOR_NEUTRAL}"
        fi
      else
        status="${COLOR_RED}[LOCKED - ${ship_price}💎]${COLOR_NEUTRAL}"
      fi

      printf "  ${COLOR_CYAN}[$id]${COLOR_NEUTRAL} $ship_icon $ship_name - Speed:$ship_speed Ammo:$ship_ammo $status\n"
    done

    printf "\n  ${COLOR_GREEN}[E]${COLOR_NEUTRAL} Equip | ${COLOR_YELLOW}[B]${COLOR_NEUTRAL} Buy | ${COLOR_MAGENTA}[S]${COLOR_NEUTRAL} Skins | ${COLOR_WHITE}[R]${COLOR_NEUTRAL} Return\n"
    printf "\n  Select option: "
    read -r choice

    case $choice in
      [1-5]) equip_ship "$choice" ;;
      [Ee])
        printf "\n  Enter ship number to equip (1-5): "
        read -r ship_to_equip
        equip_ship "$ship_to_equip"
        ;;
      [Bb])
        printf "\n  Enter ship number to buy (1-5): "
        read -r ship_to_buy
        buy_ship "$ship_to_buy"
        ;;
      [Ss])
        show_skin_shop
        ;;
      [Rr]) return ;;
      *) continue ;;
    esac
  done
}

# -----------------------------
# Show Skin Shop
# -----------------------------
show_skin_shop() {
  while true; do
    clear
    printf "${COLOR_MAGENTA}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_MAGENTA}║${COLOR_NEUTRAL}                    SKIN CUSTOMIZATION                 ${COLOR_MAGENTA}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_MAGENTA}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
    printf "  ${COLOR_YELLOW}Crystal Bank: ${crystal_bank}💎${COLOR_NEUTRAL}\n\n"

    for id in {1..5}; do
      local skin_name=$(get_skin_name $id)
      local skin_color=$(get_skin_color $id)
      local skin_price=$(get_skin_price $id)
      local ship_icon=$(get_ship_icon "$current_ship")

      if check_ownership "$id" "$owned_skins"; then
        if [ "$current_skin" = "$id" ]; then
          status="${COLOR_YELLOW}[ACTIVE]${COLOR_NEUTRAL}"
        else
          status="${COLOR_GREEN}[OWNED]${COLOR_NEUTRAL}"
        fi
      else
        status="${COLOR_RED}[LOCKED - ${skin_price}💎]${COLOR_NEUTRAL}"
      fi

      printf "  ${COLOR_CYAN}[$id]${COLOR_NEUTRAL} ${skin_color}${ship_icon}${COLOR_NEUTRAL} $skin_name $status\n"
    done

    printf "\n  ${COLOR_GREEN}[A]${COLOR_NEUTRAL} Apply | ${COLOR_YELLOW}[B]${COLOR_NEUTRAL} Buy | ${COLOR_WHITE}[R]${COLOR_NEUTRAL} Return\n"
    printf "\n  Select option: "
    read -r choice

    case $choice in
      [1-5]) apply_skin "$choice" ;;
      [Aa])
        printf "\n  Enter skin number to apply (1-5): "
        read -r skin_to_apply
        apply_skin "$skin_to_apply"
        ;;
      [Bb])
        printf "\n  Enter skin number to buy (1-5): "
        read -r skin_to_buy
        buy_skin "$skin_to_buy"
        ;;
      [Rr]) return ;;
      *) continue ;;
    esac
  done
}

# =============================
# Example usage:
# show_hangar
# show_skin_shop
# =============================
