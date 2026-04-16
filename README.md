# 🚀 Star Runner
## // WARNING: fully vibe coded(VIBE = VERY INPRODUCTIVE BUT EXCITING)

**Star Runner** is a **fast-paced, terminal-based arcade game** written entirely in **Bash**. Navigate your starship through a dangerous asteroid field, collect power crystals, and unleash special abilities to achieve the **highest score in the galaxy**.

Developed by **Dulsara Pieris (SYNAPSNEX)**.

---

## 🕹️ Features

* **Dynamic Gameplay:** Dodge asteroids of various sizes in real-time.
* **Career Profile System:** Persistent local profile (`~/.star_runner`) tracks your stats, high scores, crystals, and progress.
* **Combat Mechanics:** Fire lasers to destroy obstacles (requires ammo management).
* **Difficulty Modes:** Pick **Chill**, **Classic**, or **Chaos** to match your skill level.
* **Combo Scoring:** Destroy asteroids in streaks to earn bonus points.
* **Power-ups:**

  * **☢ Shield:** Absorb a single hit.
  * **◈ Super Mode:** Become invincible and destroy asteroids on contact.
  * **⊕ Ammo Pack:** Refill your laser reserves.
* **Ranking System:** Advance from **Neural Trash** to **NEXUS-ZERO // 01101001** based on your performance.

---

## 🛠️ System Requirements

* **OS:** Linux, macOS, or WSL (Windows Subsystem for Linux)
* **Terminal Utilities:** `sh`, `stty`, `dd`, `od`
* **Recommended Terminal Size:** At least **40 columns x 20 lines**

---

## ⚡ Installation

Install **Star Runner** with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/dulsara-pieris/Bash-game/main/install.sh | sudo bash
```

This will:

* Copy `game.sh` to `/usr/local/bin/star-runner`
* Set executable permissions
* Optionally create a config/profile folder at `~/.star_runner`

---

## 🎮 Controls

| Key        | Action                                     |
| ---------- | -------------------------------------------|
| Arrow Keys | Move your ship (Up, Down, Left, Right)     |
| Spacebar   | Fire Laser (consumes 1 ammo)               |
| P          | Pause and unpause                          |
| Q          | Quit & Save Stats can recive punishments   |

Pick a difficulty from the main menu before launching:
- **Chill:** 3 lives, slower pace
- **Classic:** 2 lives, balanced pace
- **Chaos:** 1 life, fast pace, 2x score multiplier

---

## 🏁 Quick Start

1. Open your terminal.
2. Run:

```bash
star-runner
```

3. Dodge asteroids, collect crystals, and climb the ranks!
4. Press `Q` to quit and save your progress.

> ⚠ **Tip:** Resize your terminal to **at least 40x20** for the best experience.

---

## 🗑️ Uninstallation

Remove the game and your profile:

```bash
sudo ./uninstall.sh
rm -rf ~/.star_runner
```

---

## 📂 File Structure

```
├──  AUTHORS.md
├──  CODE_OF_CONDUCT.md
├──  install.sh
├──  LICENSE
├──  modules
├──  NOTICE.md
├──  README.md
├──  Release
│   ├──  0.1.0.md
│   ├──  0.1.1.md
│   └──  0.2.0.md
├──  src
│   ├──  game.sh
│   └──  modules
│       ├──  collision.sh
│       ├──  config.sh
│       ├──  effects.sh
│       ├──  entities.sh
│       ├──  input.sh
│       ├──  inventory.sh
│       ├──  menu.sh
│       ├──  profile.sh
│       ├──  punishments.sh
│       ├──  render.sh
│       ├──  ships.sh
│       ├──  shop.sh
│       ├──  skins.sh
│       ├──  utils.sh
│       └──  weapons.sh
├──  uninstall.sh
└──  VERSION
```

---

## 👥 Credits

* **Developer & Owner:** Dulsara Pieris (SYNAPSNEX)
* **Contributors:** See `AUTHORS.md`

---

## ⚖️ License

Star Runner is licensed under the **SYNAPSNEX OSS-Protection License (SOPL) v1.0**.
See [`LICENSE`](./LICENSE) and [`NOTICE.md`](./NOTICE.md) for details.

---

## 🔗 Links

* [Project Repository](https://github.com/dulsara-pieris/Bash-game)
* [Issues & Feedback](https://github.com/dulsara-pieris/Bash-game/issues)
