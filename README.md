# Shell Odyssey 🚀

```
    ____  _   _ _____ _     _       ___  ______   _____ _____ _____ _____ _____   __
   / ___|| | | | ____| |   | |     / _ \|  _ \ \ / / ___/ ____| ____| ____| ____| \ \
   \___ \| |_| |  _| | |   | |    | | | | | | \ V /\___ \  _| |  _| |  _| |  _|    \ \
    ___) |  _  | |___| |___| |___ | |_| | |_| || |  ___) | |___| |___| |___| |       ) )
   |____/|_| |_|_____|_____|_____| \___/|____/ |_| |____/|_____|_____|_____|_|      /_/

              A Terminal Learning Adventure
```

## The Mission

You are the emergency systems operator aboard the research vessel **Odyssey**.

The ship has suffered a catastrophic system failure during a deep space mission. With most of the crew in cryosleep and the main AI offline, you must navigate through the ship's computer systems using only your terminal skills.

Your mission: restore critical systems, decode distress signals, and save the crew.

## What You'll Learn

Shell Odyssey teaches intermediate-to-advanced terminal commands through hands-on puzzles:

| Sector | Location | Skills |
|--------|----------|--------|
| Tutorial | Airlock | Review basics, game mechanics |
| Sector 1 | Engineering | `find`, `grep`, `tree`, `wc` |
| Sector 2 | Comms | Pipes, `head`/`tail`, `sort`, `cut`, `awk` |
| Sector 3 | Reactor | `xargs`, `sed`, shell scripting |
| Sector 4 | Bridge | Process management, `curl`, `ssh` |

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/shell-odyssey.git ~/shell-odyssey

# Or if you already have it, just cd into it
cd ~/shell-odyssey

# Run the installer
./install.sh
```

### Begin Your Mission

```bash
# Start the game
cd ~/shell-odyssey/odyssey/airlock

# Read the welcome message
cat .scroll

# Check your current mission
cat .mission
```

## How to Play

1. **Navigate** using `cd` to move between ship compartments
2. **Read** `.mission` files to understand your objective
3. **Explore** files and directories to find clues
4. **Solve** puzzles using the commands you learn
5. **Progress** is tracked automatically when you complete missions

### Helpful Commands

```bash
# Check your overall progress
~/shell-odyssey/scripts/check-progress.sh

# Get a hint for the current room
~/shell-odyssey/scripts/hint.sh

# Reset the game if something breaks
~/shell-odyssey/scripts/reset.sh
```

## Game Mechanics

- **`.mission`** - Your current objective
- **`.scroll`** - Narrative text and lore
- **`.complete`** - Created when you solve a puzzle (don't create manually!)
- **`.hidden/`** - Secret areas unlocked by solving puzzles

## Tips for New Operators

1. Read everything carefully - clues are hidden in the narrative
2. Use `ls -la` to see hidden files
3. Don't be afraid to experiment - `reset.sh` can fix mistakes
4. The `hint.sh` script provides graduated hints (try not to overuse it!)

## Requirements

- macOS or Linux with Bash 4.0+
- Basic familiarity with `cd`, `ls`, `cat`, `pwd`
- A sense of adventure

## Credits

Created as a learning tool inspired by [Bashcrawl](https://gitlab.com/slackermedia/bashcrawl).

---

*"In space, no one can hear you grep... but they can see your command history."*
