# 🚀 Star Runner

**Star Runner** is a fast-paced, terminal-based arcade game written entirely in **Shell script**. Navigate your starship through a dangerous asteroid field, collect power crystals, and utilize special abilities to achieve the highest score in the galaxy.

Developed by **Dulsara Pieris (SYNAPSNEX)**.

---

## 🕹️ Game Features

* **Dynamic Gameplay:** Dodge asteroids of various sizes that move across your terminal in real-time.
* **Career Profile System:** Automatically creates a persistent local profile (`~/.star_runner`) to track your name, age, high scores, total crystals, and career stats.
* **Combat Mechanics:** Use your onboard laser system to blast obstacles (requires ammo).
* **Power-ups:**
    * **☢ Shield:** Absorb a single hit without destroying your ship.
    * **◈ Super Mode:** Become invincible and destroy asteroids on contact.
    * **⊕ Ammo Pack:** Refill your laser reserves.
* **Ranking System:** Progress from a **Street Spectator** to a legendary **NEXUS-ZERO // 01101001** based on your mission performance.

---

## 🛠️ System Requirements & Setup

To run this game, you need:
* A Unix-like environment: **Linux**, **macOS**, or **WSL (Windows Subsystem for Linux)**.
* Standard utilities: `sh`, `stty`, `dd`, `od`.
* A terminal window sized at least **40 columns x 20 lines**.

### 📝 Installation

<pre align="center" style="font-family: 'Courier New', Courier, monospace;"> 
curl -sSL https://raw.githubusercontent.com/dulsara-pieris/Bash-game/main/install.sh | sudo bash 
<pre>

### Key,Action
**Arrow Keys** "Navigate Ship (Up, Down, Left, Right)"
**Spacebar** Fire Laser (Uses 1 Ammo)
**Q** Quit & Save Stats