# Xinghan Canlan 1v1 Mode

`xinghan_canlan` is a FreeKill/New Moon Kill extension for a competitive 1v1 mode. It provides the mode logic, rule skills, QML selection dialogs, English translations, and a dedicated 108-card deck.

## Features

- Two-player 1v1 mode.
- Seat 1 is the lord and first player; seat 2 is the renegade and second player.
- Opens with 18 generals, then bans in this order: second player 1, first player 2, second player 1.
- Drafts generals in this order: second 1, first 2, second 2, first 2, second 2, first 2, second 2, first receives the final remaining general.
- Each player builds a 7-general pool.
- Each round deploys 1 or 2 generals according to the remaining deployable-general state.
- Winning generals are locked; losing generals return to their owner's pool.
- A player wins the match only after winning 3 rounds and having exactly 5 locked generals.
- Dedicated 108-card deck.
- Ao Zhan rules: after the second deck shuffle, Peach can answer Analeptic/Wine requests; after the third shuffle, the current turn player loses 1 HP at turn end.
- Selection dialogs use responsive QML layouts with adaptive grid columns.

## Deploy State

The number of generals a player may deploy is determined by how many deployable generals remain:

| Deployable generals left | Deploy limit |
| --- | --- |
| 7 or 5 | Single or dual general |
| 6 or 4 | Dual general only |
| 3 | Single general only |

This finite-state restriction ensures that a player who wins 3 rounds ends with exactly 5 locked generals.

## Installation

1. Copy the `xinghan_canlan` directory into the FreeKill `packages` directory.
2. Restart the client.
3. Select the "Xinghan Canlan" game mode.

Expected layout:

```text
FreeKill/
└── packages/
    └── xinghan_canlan/
        ├── init.lua
        ├── pkg/
        ├── qml/
        └── i18n/
```

## Project Layout

```text
xinghan_canlan/
├── init.lua
├── i18n/
│   └── en_US.lua
├── pkg/
│   ├── xinghan_cards/
│   │   └── init.lua
│   └── xinghan_mode/
│       ├── rule_skills/
│       │   └── xinghan_1v1.lua
│       ├── xinghan_1v1.lua
│       └── xinghan_util.lua
├── qml/
│   ├── XinghanDeploy.qml
│   └── XinghanSelect.qml
├── README.en.md
└── README.md
```

## Development Notes

- Mode setup: `pkg/xinghan_mode/xinghan_1v1.lua`
- Rule skills: `pkg/xinghan_mode/rule_skills/xinghan_1v1.lua`
- Deck definition: `pkg/xinghan_cards/init.lua`
- Ban/draft dialog: `qml/XinghanSelect.qml`
- Deploy dialog: `qml/XinghanDeploy.qml`

This repository does not include the full FreeKill runtime, so local verification is limited to static checks. Full testing should be done in the game client after installing the package.

## License

GPL-3.0-or-later
