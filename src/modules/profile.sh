#!/usr/bin/env bash

# STAR RUNNER - Profile Management Module
# Fully tamper-proof profile

# Profile file location
PROFILE_FILE="$HOME/.star_runner_profile"
CHECKSUM_FILE="$HOME/.star_runner_checksum"

# Initialize profile - create new or load existing
init_profile() {
    # Default values
    player_name=""
    player_title=""
    player_gender=""
    player_birth_year=2000
    high_score=0
    crystal_bank=0
    total_crystals=0
    total_asteroids=0
    current_ship=1
    current_skin=1
    owned_ships="1"
    owned_skins="1"

    # Load existing profile if present
    if [ -f "$PROFILE_FILE" ]; then
        if verify_profile_integrity; then
            load_profile
        else
            handle_tampered_profile
        fi
    else
        create_new_profile
    fi
}

# Create a new player profile
create_new_profile() {
    clear
    printf "${COLOR_CYAN}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}║${COLOR_NEUTRAL}              WELCOME TO STAR RUNNER                   ${COLOR_CYAN}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_CYAN}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"

    printf "  ${COLOR_GREEN}Creating new pilot profile...${COLOR_NEUTRAL}\n\n"

    # Get player name
    printf "  Enter your name: "
    read -r player_name

    # Get gender
    printf "\n  Select gender:\n"
    printf "  ${COLOR_CYAN}[1]${COLOR_NEUTRAL} Male\n"
    printf "  ${COLOR_CYAN}[2]${COLOR_NEUTRAL} Female\n"
    printf "  ${COLOR_CYAN}[3]${COLOR_NEUTRAL} Other\n"
    printf "\n  Choice: "
    read -r gender_choice

    case $gender_choice in
        1) 
            player_gender="Male"
            player_title="Sir" 
            ;;
        2) 
            player_gender="Female"
            player_title="Ma'am" 
            ;;
        3|*) 
            player_gender="Other"
            player_title="Mx" 
            ;;
    esac

    # Get birth year
    printf "\n  Enter birth year (e.g., 2000): "
    read -r player_birth_year
    player_birth_year=$((player_birth_year + 0))

    # Initialize default profile values
    high_score=0
    crystal_bank=0
    total_crystals=0
    total_asteroids=0
    current_ship=1
    current_skin=1
    owned_ships="1"
    owned_skins="1"

    # Save the new profile
    save_profile

    printf "\n  ${COLOR_GREEN}✓ Profile created successfully!${COLOR_NEUTRAL}\n"
    sleep 2
}

# Generate checksum for profile integrity
generate_checksum() {
    if [ -f "$PROFILE_FILE" ]; then
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum "$PROFILE_FILE" | awk '{print $1}'
        elif command -v shasum >/dev/null 2>&1; then
            shasum -a 256 "$PROFILE_FILE" | awk '{print $1}'
        else
            # fallback to md5 if SHA not available
            md5sum "$PROFILE_FILE" | awk '{print $1}'
        fi
    fi
}

# Verify profile hasn't been tampered with
verify_profile_integrity() {
    if [ ! -f "$CHECKSUM_FILE" ]; then
        return 1
    fi

    stored_checksum=$(cat "$CHECKSUM_FILE" 2>/dev/null)
    current_checksum=$(generate_checksum)

    [ "$stored_checksum" = "$current_checksum" ]
}

# Handle tampered profile (force reset)
handle_tampered_profile() {
    clear
    printf "${COLOR_RED}╔═══════════════════════════════════════════════════════╗${COLOR_NEUTRAL}\n"
    printf "${COLOR_RED}║${COLOR_NEUTRAL}                  ⚠️  SECURITY ALERT ⚠️                 ${COLOR_RED}║${COLOR_NEUTRAL}\n"
    printf "${COLOR_RED}╚═══════════════════════════════════════════════════════╝${COLOR_NEUTRAL}\n\n"

    printf "  ${COLOR_YELLOW}Profile integrity check failed!${COLOR_NEUTRAL}\n"
    printf "  ${COLOR_RED}Your profile was modified or corrupted.${COLOR_NEUTRAL}\n\n"
    printf "  ${COLOR_CYAN}The profile will now be reset to protect game integrity.${COLOR_NEUTRAL}\n"
    sleep 3

    rm -f "$PROFILE_FILE" "$CHECKSUM_FILE" 2>/dev/null
    create_new_profile
}

# Load existing profile from file
load_profile() {
    if [ -f "$PROFILE_FILE" ]; then
        # shellcheck disable=SC1090
        . "$PROFILE_FILE"

        # Ensure numeric values are numbers
        current_ship=$((current_ship + 0))
        current_skin=$((current_skin + 0))
        crystal_bank=$((crystal_bank + 0))
        high_score=$((high_score + 0))
        total_crystals=$((total_crystals + 0))
        total_asteroids=$((total_asteroids + 0))
        player_birth_year=$((player_birth_year + 0))
    fi
}

# Save current profile to file
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
current_ship=$current_ship
current_skin=$current_skin
owned_ships="$owned_ships"
owned_skins="$owned_skins"
EOF

    # Generate checksum
    checksum=$(generate_checksum)
    echo "$checksum" > "$CHECKSUM_FILE"

    # Make files read-only to prevent manual edits
    chmod 400 "$PROFILE_FILE" 2>/dev/null || true
    chmod 400 "$CHECKSUM_FILE" 2>/dev/null || true
}

# Initialize profile automatically on script load
init_profile
