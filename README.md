<div align="center">

# Project Ebonhold Enhanced

Overlay addon for Project Ebonhold. Keeps the server addon in place and adds a cleaner UI layer for Echoes, Affixes, Soul Ashe, and related windows.

[![Downloads](https://img.shields.io/github/downloads/disarrayed/ProjectEbonholdEnhanced/total?style=for-the-badge&label=Downloads&color=69ccf0)](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases)
![Project Ebonhold Enhanced 0.1.60](https://img.shields.io/badge/Project%20Ebonhold%20Enhanced-0.1.60-69ccf0.svg?style=for-the-badge)
![Project Ebonhold 3.3.5a](https://img.shields.io/badge/Project%20Ebonhold-3.3.5a-69ccf0.svg?style=for-the-badge)

[**Download**](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases/latest) | [**Source**](https://github.com/disarrayed/ProjectEbonholdEnhanced)

</div>

---

## What it does

- Skins Project Ebonhold UI with the Enhanced dark transparent theme
- Improves Echo Picker, Echo Browser, Affix Book, Enchanted Anvil, and Soul Ashe Tree screens
- Adds Enhanced settings without changing the server addon settings
- Can be disabled at any time so the server Project Ebonhold addon takes over again

---

## Install

1. Download the latest zip from [Releases](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases)
2. Extract to `WoW\Interface\AddOns`
3. The extracted folder should be named `ProjectEbonholdEnhanced`
4. Fully restart WoW.

The server `ProjectEbonhold` addon comes from the MPQ. You do not need a `ProjectEbonhold` folder for this overlay.

---

## Slash commands

| Command | What it does |
| --- | --- |
| `/pee` | Open the Project Ebonhold Enhanced panel |
| `/pe` | Short alias for `/pee` |
| `/pee show` | Show the Enhanced panel |
| `/pee hide` | Hide the Enhanced panel |
| `/pee version` | Print the installed Enhanced version |
| `/pee theme` | Print the current theme settings |
| `/pee opacity 70-100` | Set transparent window opacity |
| `/pee font 50-150` | Set Enhanced UI font scale |
| `/pee fontscale 50-150` | Same as `/pee font` |
| `/pee perkscale 50-300` | Set Echo and Soul Ashe UI scale |
| `/pee perkuiscale 50-300` | Same as `/pee perkscale` |
| `/pee transparent on` | Turn the transparent theme on |
| `/pee transparent off` | Turn the transparent theme off |
| `/pee anvil` | Open the Enchanted Anvil |
| `/pee extraction` | Same as `/pee anvil` |
| `/anvil` | Open the Enchanted Anvil directly |
| `/extraction` | Same as `/anvil` |
| `/pee affix` | Open the Affix Book |
| `/pee affixes` | Same as `/pee affix` |
| `/affix` | Open the Affix Book directly |
| `/affixes` | Same as `/affix` |
| `/pee notice` | Show the Project Ebonhold update notice when available |
| `/pee button` | Toggle the legacy launcher button if it exists |
| `/pee launcher` | Same as `/pee button` |
| `/pee objective` | Print current objective tracker debug details |
| `/pee streedump` | Print Soul Ashe Tree debug details |
| `/petal` | Show talent profile commands |
| `/petalent` | Same as `/petal` |
| `/petal save <name>` | Save your current talent setup |
| `/petal apply [name]` | Apply the active profile or a named profile |
| `/petal delete <name>` | Delete a saved talent profile |
| `/petal list` | List saved talent profiles |

---

## How to use

- Start with `/pee` for the main Enhanced panel.
- Use direct commands like `/pee opacity 80` when you want a quick theme change.
- Use `/anvil` when you want the Enchanted Anvil, and `/affix` when you only want the Affix Book.
- Some visual changes ask for a reload. Use `/reload` when the addon tells you to.
- On PTR, Enhanced disables itself so the server `ProjectEbonhold` addon stays in control.
- Debug commands are only for troubleshooting when someone asks for that output.

---

## Notes

Project Ebonhold Enhanced is an overlay addon. It requires the server `ProjectEbonhold` addon and is not meant to replace it.

If something breaks, disable `ProjectEbonholdEnhanced` and the server addon will continue to work by itself.
