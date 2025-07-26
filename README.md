# Thorn

My personal Quickshell config, optimized for productivity and focus.

https://github.com/user-attachments/assets/118c47d4-c6ca-41b3-8fe9-6aac501a1c41

**⚠️ Note:** Still working on a decent enough install script, **probably best not to use this until then.**

## Installation

If you would like to try this shell out, and have dependencies installed:

### 1. Walrus Setup
[Walrus](https://github.com/entailz/walrus) is a minimal Pywal replacement that has replaced Pywal to eliminate Python dependencies.

- **For Arch users:** Install walrus-git from AUR
- **Setup process:**
  1. Build Walrus and add it to your path
  2. Change wallpaper once
  3. Remove current colors-qs.json in root:/ and create a symbolic link to new Walrus palette:
     ```bash
     ln -s ~/.cache/walrus/colors.json ~/.config/quickshell/thorn/colors-qs.json
     ```

### 2. Fonts & Wallpaper Configuration
- **Fonts:** Edit `Globals.qml` and replace `font` and `secondaryFont` with your preferred fonts
- **Wallpaper:** Replace `imageFolder` `/paper` with your wallpaper directory name (relative to `$HOME`)

### 3. Hyprland Integration
See `scripts/thorn.conf` for required layer rules and key bindings.

### 4. Wallpaper Shaders
If the compiled shaders (files ending in `.qsb`) aren't working, you'll need to compile them manually:

1. Remove all existing `.qsb` files from `./shaders`
2. Navigate to `shaders/src` directory
3. Compile shaders using QSB:

   **Bash & Zsh:**
   ```bash
   for shader in *.frag; do qsb --qt6 "$shader" -o "../$shader.qsb"; done
   ```

   **Fish:**
   ```fish
   for shader in *.frag; qsb --qt6 "$shader" -o "../$shader.qsb"; end
   ```

### 5. Vesktop/Vencord Integration
For Discord theming support:

1. Clone `wal-vesktop` repository
2. Add the script path to `Globals.qml`'s `walVesktop` property
3. Run `./wal-discord -u` for initial setup
4. In Vencord/Vesktop settings:
   - Navigate to Themes and enable `thorn_discord.theme`
   - Go to Vencord settings and enable "window transparency"
5. Wallpaper changes will automatically update Discord's color palette

**⚠️ Note:** Flatpak users, please use -f flag with Wal-Vesktop to target Flatpak installation directory.

## Features

- **Productivity Tools**
  - Working calendar and planner
  - Pomodoro Timer (work in progress)
  - Mini Markdown Editor and Previewer

- **Visual & Audio**
  - Configurable Visualizer (waves and bars)
  - Audio OSD
  - Hyprpicker Cache

- **System Integration**
  - Custom Region Select (compatible with wf-recorder)
  - Wallpaper Manager with shader-mediated transitions and coordinate selector (similar to SWWW)
  - Runner with multiple views and sort modes (frequency, categories, web search, grid view)
  - Dock with draggable toplevels (work in progress)

## Roadmap

**Immediate Goals:**
- Finish vertical bar implementation
- Create control panel for `Globals.qml` properties
- Simplify dock and resolve focus grab timer race conditions

**Planned Features:**
- Reminder notifications from calendar module
- Fix random crashes (possibly caused by FileView)
- Enhanced Pomodoro timer with study presets
- Relocate markdown editor to pull tab (side or bottom) with note history
- Re-implement lutgen functionality

## Dependencies

**Required:**
- Quickshell
- [Walrus](https://github.com/entailz/walrus)
- Material Symbols
- Cava
- Wf-Recorder

**Optional:**
- [Wal-Vesktop](https://github.com/entailz/wal-vesktop) (see installation directions above)
