# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [V1.1.0-pre] - 2025-07-05
The new content update we've been working on is here! <br>
Well, at least the pre-release is. <br>
Keep that in mind, as there may be some placeholder assets!

### Additions
* New Mode: Campaign Mode!
  * Enter in the songs you want to play, and see what score you get!
* New Achievement: Speed Demon!
  * Use the maximum note speed on any song!
* Lua Scripting Support
* Discord Rich Presence
* More Languages (PR by [NeoDev](https://github.com/JoaTH-Team/Rhythmo-SC/pull/15))
  * Italiano (IT)
  * Bahasa Indonesia (ID)
  * Русский (RU)
  * 中文 (ZH)
  * 日本語 (JP)
  * 한국어 (KO)
  * العربية (AR)
    * With this, also comes custom font support for languages!
* Custom Noteskins/Note Splashes Support
* Sustain Notes
* Auto Updater (Made by [maybekoi](https://github.com/maybekoi))
* Global Mods Folder
* Animated Mod Icon Support

### Changes
* HScript Improvements
* Improved Chart Editor
* Finished Chart for Hexes and Frostbite
* Reorganized Assets
* Optimized Code

### Fixes
* Fixed Scripted State and Substate Switching

## [V1.0.0] - 2025-03-01
Initial release build!

### Additions
* Achievements
* Ranks + Accuracy
  * Also comes with a Results Screen
* Customizable Main Menu
* Scripted States / Substates
* RGB Note Coloring
* New Scripting Functions
* New Language: Tiếng Việt (VN)
* Support for `.hx`, `.hxc`, and `.hscript` script files

### Changes from Pre-Release
* Reorganized the Source Code
* Improved Input System
* Improved Song Charting
* Made camera scrolling smoother on most menus
* Better Pause Menu
* Options Menu Overhaul
* Made some variables public in `PlayState.hx` for easier scripting
* Made countdown sounds separate sound files for more customizability
* A whole lot more silly messages in `tipText.txt`
* New function to load spritesheets
    * Example: `Paths.spritesheet('animation', SPARROW);`
* ALMOST All songs charted
* Changed language files layout
* Better scripting template
* Improved Documentation
* Updated Modding API to `1.0.5`
    * Added `coreAssetRedirect` to `frameworkParams`
    * Any mod with any `api_version` can be loaded
    * New function: `getModIDs()`
        * Returns all currently loaded mod's IDs 
* Code Refactoring

### Fixes
* Fixed Crash Handler
* Fixed "`errorSparrow`" graphic

## [V1.0.0-pre] - 2024-10-14
Initial pre-release build!