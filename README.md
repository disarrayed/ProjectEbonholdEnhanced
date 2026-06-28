<div align="center">

# Project Ebonhold Enhanced

UI enhancements for Project Ebonhold. Install this addon alongside the server
client and disable it any time you want the server UI to take over.

[![Downloads](https://img.shields.io/github/downloads/disarrayed/ProjectEbonholdEnhanced/total?style=for-the-badge&label=Downloads&color=3FC7EB)](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases)
![Project Ebonhold Enhanced 0.1.62](https://img.shields.io/badge/Project%20Ebonhold%20Enhanced-0.1.62-3FC7EB.svg?style=for-the-badge)
![Project Ebonhold 3.3.5a](https://img.shields.io/badge/Project%20Ebonhold-3.3.5a-3FC7EB.svg?style=for-the-badge)

[**Download**](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases/latest) | [**Source**](https://github.com/disarrayed/ProjectEbonholdEnhanced)

</div>

---

## What it does

Project Ebonhold Enhanced is an overlay addon. It improves the live-realm UI
without editing the server addon files.

- Dark transparent Project Ebonhold themed windows
- Echo Picker and Echo Browser cleanup
- Enhanced Enchanted Anvil and Affix Book UI
- Owned Soul Ashe Tree UI with smoother movement, zoom, search, and themed bars
- Player run frame and compact mode cleanup
- Hardcore reminder and update notice styling
- Interface Options controls for Enhanced settings

PTR belongs to the server version. On PTR, Project Ebonhold Enhanced disables
itself so the server UI stays in control.

---

## Install

1. Download the latest zip from [Releases](https://github.com/disarrayed/ProjectEbonholdEnhanced/releases).
2. Extract to `WoW\Interface\AddOns`.
3. Folder must be named `ProjectEbonholdEnhanced`.
4. Restart WoW. A `/reload` is not enough on first install.

You do not need a `ProjectEbonhold` addon folder. The server addon comes from
the Project Ebonhold client files.

To go back to the server UI, disable or delete the `ProjectEbonholdEnhanced`
folder and restart WoW.

---

## Slash commands

```text
/pee              Open the Project Ebonhold Enhanced panel
/pee version      Show the loaded Enhanced version
/pee notice       Reopen the Enhanced update notice when available
/pee ashe start   Run the Soul Ashe Progression visual test
/pee ashe stop    Stop the Soul Ashe Progression visual test
/affix            Open the Affix Book
/anvil            Open the Enchanted Anvil
```

Theme and behavior settings live in the normal Interface Options panel.

---

## Notes

- Built for Project Ebonhold on WoW 3.3.5a.
- Project Ebonhold Enhanced stores its own settings and positions.
- Server-owned talents, action bars, PTR behavior, and gameplay systems stay
  with the server addon.
- Server visual theme controls are ignored while Enhanced is enabled. Existing
  server theme settings are normalized at startup, and turning off the server
  Transparent design option prompts you to disable Enhanced.
- Soul Ashe Tree search supports `missing` for unlearned nodes and `perm` or
  `permanent` for permanent nodes.
- Release zips contain only the addon folder and player-facing release files.

---

<div align="center">
<sub>Made for the Project Ebonhold community.</sub>
</div>
