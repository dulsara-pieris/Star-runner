"""
Star Runner — Rendering Module
Handles ship, stars, HUD, borders, and terminal setup
"""

import os
import sys
import random
from core.config import NUM_LINES, NUM_COLUMNS, COLOR_CYAN, COLOR_GREEN, COLOR_RED, COLOR_YELLOW, COLOR_NEUTRAL, COLOR_WHITE

# ------------------------------
# Terminal Setup
# ------------------------------

def on_enter():
    """Prepare the terminal for the game."""
    os.system('clear')           # Clear screen
    print("\033[?25l", end="")   # Hide cursor
    sys.stdout.flush()

def on_exit():
    """Reset terminal when exiting game."""
    print("\033[?25h", end="")   # Show cursor
    sys.stdout.flush()

# ------------------------------
# Cursor Utilities
# ------------------------------

def move_cursor(line: int, col: int):
    """Move cursor to a specific position."""
    print(f"\033[{line};{col}H", end="")

def center_text(text: str, line: int = None):
    """Print text centered on screen."""
    if line is None:
        line = NUM_LINES // 2
    col = max((NUM_COLUMNS - len(text)) // 2, 0)
    move_cursor(line, col)
    print(text, end="")

def colored(text: str, color: str):
    """Wrap text in ANSI color codes."""
    return f"{color}{text}{COLOR_NEUTRAL}"

# ------------------------------
# Ship Rendering
# ------------------------------

SHIP_ART = [
    "  ^  ",
    " /|\\ ",
    "/_|_\\"
]

def draw_ship(state):
    """Draw the player's ship at current position."""
    line = state["ship_line"]
    col = state["ship_column"]

    for i, row in enumerate(SHIP_ART):
        move_cursor(line + i, col)
        print(colored(row, COLOR_CYAN), end="")

    # Clear trailing line below ship
    move_cursor(line + len(SHIP_ART), 1)
    print(" " * NUM_COLUMNS, end="")

# ------------------------------
# Border
# ------------------------------

def draw_border():
    """Draw top and bottom borders."""
    top_bottom = "+" + "-" * (NUM_COLUMNS - 2) + "+"
    move_cursor(1, 1)
    print(top_bottom)
    move_cursor(NUM_LINES, 1)
    print(top_bottom)

# ------------------------------
# Stars / Background
# ------------------------------

def draw_stars(density=0.05):
    """Randomly draw stars in the background."""
    for line in range(2, NUM_LINES - 1):
        for col in range(1, NUM_COLUMNS - 1):
            if random.random() < density:
                move_cursor(line, col)
                print(colored("*", COLOR_WHITE), end="")

# ------------------------------
# HUD
# ------------------------------

def draw_hud(state, profile):
    """Draw score, level, ammo, shields, etc."""
    move_cursor(NUM_LINES, 2)
    hud = f"Score: {state['score']}  Level: {state['level']}  Crystals: {profile.get('crystals_bank', 0)}  Ammo: {state.get('ammo',0)}"
    if state.get("shield_active"):
        hud += "  [SHIELD]"
    if state.get("super_mode_active"):
        hud += "  [SUPER]"
    print(hud[:NUM_COLUMNS-2], end="")

# ------------------------------
# Launch Sequence
# ------------------------------

def launch_sequence():
    """Show launch banner in center of screen."""
    text = "▶ LAUNCHING STAR RUNNER ◀"
    center_text(text)
