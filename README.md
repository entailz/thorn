# Thorn

My personal Quickshell config, optimized for productivity and focus.


https://github.com/user-attachments/assets/118c47d4-c6ca-41b3-8fe9-6aac501a1c41


Still working on a decent enough install script, __probably best not to use
this until then.__

If you would like to try this shell out, and have deps installed:

1. Pywal: Add the colors-qs.json file in scripts to your pywal templates,
run `wal -e -i image.jpg --saturate 0.2 --backend haishoku` to generate
colors from templates and check if deps are properly installed
(image.jpg can be any image). Make a symlink for ~/.cache/wal/colors-qs.json in
Thorn's `"root:/"`, replacing the static colors-qs.json that is currently
in there.
2. Fonts & Wallpaper Folder: See Globals.qml, replace font and secondaryFont
with preferred fonts. Replace imageFolder `/paper` with the name of your
wallpaper directory, where homeDir is `$HOME`.
3. Hyprland Integration: See scripts/thorn.conf for layerrules and binds.
4. Wallpaper Shaders: If the compiled shaders (end in qsb) aren't working
you will need to go into shaders/src and compile the shaders yourself
with QSB. Firstly, remove all baked shaders that end in .qsb in ./shaders,
then enter the shaders/src directory. Compile the shaders:
   - Bash & Zsh: `for shader in *.frag; do qsb --qt6 "$shader" -o "../$shader.qsb"; done`
   - Fish: `for shader in *.frag; qsb --qt6 "$shader" -o "../$shader.qsb"; end`
5. Vesktop/Vencord: Make sure wal-vesktop is cloned somewhere (just a bash script).
Add the path of script to Globals.qml's walVesktop property. Run
`./wal-discord -u` for setup, scroll down to Themes in Vencord/Vesktop, enable
thorn_discord.theme. Changing wallpaper should modify the color palette of
discord theme.

## Features

- Working calendar and planner
- Pomodoro Timer (WIP)
- Mini Markdown Editor and Previewer
- Configurable Visualizer - Waves and Bars
- Hyprpicker Cache
- Audio OSD
- Custom Region Select (For use with wf-recorder for instance)
- Wallpaper Manager - Shader Mediated Transitions and Coord Selector
(kinda like SWWW)
- Runner w/ Multiple Views and Sort Modes - Frequency, Categories, Web Search
and Grid View
- Dock w/ Draggable Toplevels (WIP)
- Wallpaper Lutgen Picker
- Colorgen Compatible With Simple Pywal JSON Configuration
- Toplevel Overview Focus Selector


## Roadmap

- Finish vertical bar.
- Control panel to control the props in Globals.qml
- Significantly simplify the dock and fix some of the weird race
conditions created by focus grab timers.
- Reminder notifications from calendar module
- Fix random crashes which I think caused by FileView, but unsure really
- Build out Pomodoro timer to load study presets
- Move the markdown editor to a pull tab on the side or bottom
and load previous notes for editing
- Re-implement lutgen
- Wait for Outfoxxed to make BT module
- Dedupe reusable code

## Deps

- Quickshell
- Pywal + Haishoku backend
- Material Symbols
- Cava
- Wf-Recorder

__Optional:__
- [Wal-Vesktop](https://github.com/entailz/wal-vesktop) (see installation directions)

