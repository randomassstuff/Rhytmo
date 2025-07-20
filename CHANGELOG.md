# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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