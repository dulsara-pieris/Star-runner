"""
Star Runner — Skins Module
Handles cosmetic skins for ships
"""

# ------------------------------
# Skin Definitions
# ------------------------------

SKINS = [
    {
        "name": "Classic",
        "color": "Cyan",
        "unlocked": True
    },
    {
        "name": "Red Comet",
        "color": "Red",
        "unlocked": False
    },
    {
        "name": "Golden Star",
        "color": "Yellow",
        "unlocked": False
    },
    {
        "name": "Shadow",
        "color": "Magenta",
        "unlocked": False
    }
]

# ------------------------------
# Skin Functions
# ------------------------------

def get_skin(index: int) -> dict:
    """Return skin data for a given index."""
    if 0 <= index < len(SKINS):
        return SKINS[index]
    return SKINS[0]  # default skin

def unlock_skin(profile: dict, skin_index: int):
    """Unlock a skin for the player."""
    if 0 <= skin_index < len(SKINS):
        unlocked = profile.setdefault("unlocked_skins", [])
        if skin_index not in unlocked:
            unlocked.append(skin_index)
            print(f"🎉 Skin '{SKINS[skin_index]['name']}' unlocked!")

def is_skin_unlocked(profile: dict, skin_index: int) -> bool:
    """Check if a skin is unlocked in the player's profile."""
    return skin_index in profile.get("unlocked_skins", [])

def load_skins(profile: dict) -> list[dict]:
    """
    Load all skins and mark unlocked ones based on the profile.
    Returns a list of skin dicts with an added 'unlocked' key.
    """
    unlocked = profile.get("unlocked_skins", [])
    skins_list = []
    for i, skin in enumerate(SKINS):
        skin_copy = skin.copy()
        skin_copy["unlocked"] = i in unlocked or skin_copy["unlocked"]
        skins_list.append(skin_copy)
    return skins_list
