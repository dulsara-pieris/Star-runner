#!/usr/bin/env bash
#SYNAPSNEX OSS-Protection License (SOPL) v1.0
#Copyright (c) 2026 Dulsara Pieris

# STAR RUNNER - Profile Management Module
# Fully tamper-proof, fancy UI, full stats

PROFILE_FILE="$HOME/.star_runner_profile"
CHECKSUM_FILE="$HOME/.star_runner_checksum"

# Default values
DEFAULT_PROFILE=$(cat << EOF
player_name=""
player_title=""
player_gender=""
player_birth_year=2000
high_score=0
crystal_bank=0
total_crystals=0
total_asteroids=0
games_played=0
last_level=1
current_ship=1
current_skin=1
owned_ships="1"
owned_skins="1"
EOF
)

# --------------------------------------
# Colors for fancy UI
# --------------------------------------
COLOR_NEUTRAL="\e[0m"
COLOR_CYAN="\e[36m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_RED="\e[31m"

# --------------------------------------
# Helpers
# --------------------------------------
generate_checksum() {
    if [[ -f "$PROFILE_FILE" ]]; then
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum "$PROFILE_FILE" | awk '{print $1}'
        elif command -v shasum >/dev/null 2>&1; then
            shasum -a 256 "$PROFILE_FILE" | awk '{print $1}'
        else
            md5sum "$PROFILE_FILE" | awk '{print $1}'
        fi
    fi
}

verify_profile_integrity() {
    [[ ! -f "$CHECKSUM_FILE" || ! -f "$PROFILE_FILE" ]] && return 1
    [[ "$(generate_checksum)" == "$(cat "$CHECKSUM_FILE")" ]]
}

reset_profile() {
    echo "$DEFAULT_PROFILE" > "$PROFILE_FILE"
    echo "$(generate_checksum)" > "$CHECKSUM_FILE"
}

handle_tampered_profile() {
    clear
    printf "${COLOR_RED}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_RED}║${COLOR_NEUTRAL}                  ⚠️  SECURITY ALERT ⚠️                ${COLOR_RED}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_RED}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"
    printf "  ${COLOR_YELLOW}Profile integrity failed or edited!${COLOR_NEUTRAL}\n"
    printf "  ${COLOR_CYAN}Resetting profile to protect game integrity...${COLOR_NEUTRAL}\n"
    sleep 4
    reset_profile
    create_new_profile
}

# --------------------------------------
# Profile functions
# --------------------------------------
init_profile() {
    # Create files if missing
    [[ ! -f "$PROFILE_FILE" ]] && echo "$DEFAULT_PROFILE" > "$PROFILE_FILE"
    [[ ! -f "$CHECKSUM_FILE" ]] && echo "$(generate_checksum)" > "$CHECKSUM_FILE"

    # Reset if tampered
    verify_profile_integrity || handle_tampered_profile

    # Load into shell
    load_profile
}

create_new_profile() {
    clear
    printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}║${COLOR_NEUTRAL}              WELCOME TO STAR RUNNER                   ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"

    printf "  ${COLOR_GREEN}Creating new pilot profile...${COLOR_NEUTRAL}\n\n"

    # Get name
    printf "  Enter your name: "
    read -r player_name

    # Get gender
    printf "\n  Select gender:\n"
    printf "  ${COLOR_CYAN}[1]${COLOR_NEUTRAL} Male\n"
    printf "  ${COLOR_CYAN}[2]${COLOR_NEUTRAL} Female\n"
    printf "  ${COLOR_CYAN}[3]${COLOR_NEUTRAL} Other\n"
    printf "  Choice: "
    read -r gender_choice

    case $gender_choice in
        1) player_gender="Male"; player_title="Sir" ;;
        2) player_gender="Female"; player_title="Ma'am" ;;
        3|*) player_gender="Other"; player_title="Mx" ;;
    esac

    # Birth year
    printf "\n  Enter birth year (e.g., 2000): "
    read -r player_birth_year
    player_birth_year=$((player_birth_year + 0))

    # Initialize default stats
    high_score=0
    crystal_bank=0
    total_crystals=0
    total_asteroids=0
    games_played=0
    last_level=1
    current_ship=1
    current_skin=1
    owned_ships="1"
    owned_skins="1"

    # Save profile
    save_profile

    printf "\n  ${COLOR_GREEN}✓ Profile created successfully!${COLOR_NEUTRAL}\n"
    sleep 2
}

load_profile() {
    [[ -f "$PROFILE_FILE" ]] && . "$PROFILE_FILE"

    # Ensure numeric values
    high_score=$((high_score + 0))
    crystal_bank=$((crystal_bank + 0))
    total_crystals=$((total_crystals + 0))
    total_asteroids=$((total_asteroids + 0))
    games_played=$((games_played + 0))
    last_level=$((last_level + 0))
    current_ship=$((current_ship + 0))
    current_skin=$((current_skin + 0))
    player_birth_year=$((player_birth_year + 0))
}

save_profile() {
    cat > "$PROFILE_FILE" << EOF
player_name="$player_name"
player_title="$player_title"
player_gender="$player_gender"
player_birth_year=$player_birth_year
high_score=$high_score
crystal_bank=$crystal_bank
total_crystals=$total_crystals
total_asteroids=$total_asteroids
games_played=$games_played
last_level=$last_level
current_ship=$current_ship
current_skin=$current_skin
owned_ships="$owned_ships"
owned_skins="$owned_skins"
EOF

    # Update checksum
    echo "$(generate_checksum)" > "$CHECKSUM_FILE"
}

# --------------------------------------
# Initialize automatically
# --------------------------------------
init_profile
