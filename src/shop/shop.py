"""
Star Runner — Shop Module
Handles buying ships, skins, and power-ups
"""

from player.ships import SHIPS
from player.skins import SKINS, unlock_skin
from core.utils import center_text
from core.config import NUM_LINES
import sys

# ------------------------------
# Shop Interface
# ------------------------------

def show_shop(profile):
    """Display shop menu and handle purchases."""
    while True:
        print("\n--- STAR RUNNER SHOP ---")
        print(f"Crystals: {profile.get('crystals_bank', 0)}\n")
        print("1. Unlock Ship")
        print("2. Unlock Skin")
        print("3. Exit Shop")
        choice = input("Select option (1-3): ").strip()

        if choice == "1":
            unlock_ship(profile)
        elif choice == "2":
            unlock_skin_item(profile)
        elif choice == "3":
            break
        else:
            print("Invalid option.")


# ------------------------------
# Unlock Ship
# ------------------------------

def unlock_ship(profile):
    """Allow purchasing locked ships."""
    print("\nAvailable Ships:")
    for idx, ship in enumerate(SHIPS):
        unlocked = idx in profile.get("unlocked_ships", [])
        status = "(Unlocked)" if unlocked else "(Locked, 50 crystals)"
        print(f"{idx}. {ship['name']} {status}")
    
    choice = input("Select ship index to unlock: ").strip()
    if choice.isdigit():
        idx = int(choice)
        if idx in profile.get("unlocked_ships", []):
            print("Ship already unlocked.")
            return
        if profile.get("crystals_bank", 0) >= 50:
            profile["crystals_bank"] -= 50
            profile.setdefault("unlocked_ships", []).append(idx)
            print(f"✅ Ship '{SHIPS[idx]['name']}' unlocked!")
        else:
            print("❌ Not enough crystals.")
    else:
        print("Invalid input.")


# ------------------------------
# Unlock Skin
# ------------------------------

def unlock_skin_item(profile):
    """Allow purchasing locked skins."""
    print("\nAvailable Skins:")
    for idx, skin in enumerate(SKINS):
        unlocked = idx in profile.get("unlocked_skins", [])
        status = "(Unlocked)" if unlocked else "(Locked, 20 crystals)"
        print(f"{idx}. {skin['name']} {status}")
    
    choice = input("Select skin index to unlock: ").strip()
    if choice.isdigit():
        idx = int(choice)
        if idx in profile.get("unlocked_skins", []):
            print("Skin already unlocked.")
            return
        if profile.get("crystals_bank", 0) >= 20:
            profile["crystals_bank"] -= 20
            unlock_skin(profile, idx)
        else:
            print("❌ Not enough crystals.")
    else:
        print("Invalid input.")

def open_shop(profile):
    """
    Open the shop interface.
    Currently a stub — prints available items.
    """
    items = [
        {"name": "Extra Ammo", "price": 50},
        {"name": "Shield Upgrade", "price": 100},
        {"name": "Speed Boost", "price": 75}
    ]
    print("🛒 Welcome to the Star Runner Shop!")
    for i, item in enumerate(items):
        print(f"{i + 1}. {item['name']} — {item['price']} crystals")
    
    print("Shop is currently a stub. No purchases implemented yet.")