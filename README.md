# Luanti mod packs: `more_killing`

Mod which add more possibilites to kill monsters..

## Source code:

Copyright (c) 2025 SFENCE
MIT - check LICENSE file

## License of media (textures, sounds and models):
CC BY-SA 4.0 - check LICENSE file

Copyright (c) 2025 SFENCE (CC BY-SA 4.0):
All textures not mentioned bellow.

Copyright (c) 2025 SFENCE (CC BY-SA 3.0):
  * `trapworks_spikes_spike__*` - delivered from `default_tool_*.png` textures by BlockMen from Minetest game, default mod.
  * `throwable_tnt_tnt_stick_*` - delivered from `tnt_tnt_stick.png` texture by paramat from Minetest game, tnt mod.


## How to use (player guide)

This short player-focused guide explains the in-game steps you need to arm and use the traps. Crafting recipes are available in-game; below are the special actions (punch, hammer, right-click, drop) required to build or arm traps.

### `throwable_tnt`
- What you get: A burning TNT stick shown in your inventory as "TNT Burning Stick"; it can be thrown and will explode after a short timer.
 - How to light: While holding a normal TNT stick (from the TNT mod), use the game's use action while pointing at a fire source (torch or any node with the fire group) to light it. The stick in your wield slot becomes the burning stick and stores the fuse start time.
 - How to use: With the burning stick in hand you can:
  - Use the item (use button) to throw it — it flies forward and explodes when the timer runs out.
  - Drop the burning stick to spawn a slower flying entity (also explodes after its fuse).

### `trapworks_spears`
  1. Create a `Trap Spear Support` piece by using a knife on suitable small branches/twigs lying on the ground; the knife converts a twig into a ready-to-use spear support.
  2. Place the support node where you want the trap.
  3. Face the support and punch it while holding the spear item you want to use (e.g. a wooden, steel or other spear). The spear will be embedded and the support becomes an armed spear trap.
  - Note: Placing the spear will consume the spear item (unless you're in creative).

### `trapworks_spikes`

- What you get: Pole nodes (skeleton of the trap) and full spike traps for different materials. There is also a wooden spike variant that is created differently.
- How to place poles: Use the hammer action while pointing at the ground where you want the base. The hammer action requires 9 Trap Wooden Pole parts and will consume them to place a single "Spikes trap poles" node.
  - Tip: The mod checks the hotbar line adjacent to your wielded slot — keep the pole parts on that line so the hammer action can find them.
- How to set a trap after poles are placed:
  1. Wooden spikes: use a knife (cutting action) on placed poles to convert them directly into the wooden spike trap. Wooden spikes are created this way and are not built by attaching spike items.
  2. Metal/stone/etc. spikes: place the required spike items in the adjacent hotbar line (you need 9 of the same spike item for one trap) and use the hammer action while pointing at the poles; the hammer will consume 9 spike items and convert the poles into the full spike trap.

### `trapworks_strings`

- What you get: String traps at three heights: ground, angled and knee, plus matching pole nodes.
- How to place poles: Use the hammer action while pointing at the ground where you want string poles. The hammer action requires 4 Trap Wooden Pole parts and will consume them to place a single poles node.
  - Tip: Keep the pole parts on the hotbar line adjacent to your wielded slot so the hammer action can find them.
- How to set a string trap:
  1. After poles are placed, hold at least 3 pieces of String and right-click the poles to install the string trap. Three pieces of String will be taken from your hand (unless in creative), and the poles will become the armed string node.
  - Breaking a string trap drops a small amount of String.
  - Note: a single poles node uses 4 Trap Wooden Pole parts. If you have active trapworks_spikes also, make sure to have up to 8 poles in inventory below hammer, othervise spikes poles can be placed.

### `trapworks_parts`
- What you get: Trap Wooden Pole parts (inventory: "Trap Wooden Pole") — wooden pole parts used when building or dismantling pole-based traps.
- How to craft parts: Use a knife (cutting action) on a stick to convert one stick into one Trap Wooden Pole. Keep sticks on the hotbar line adjacent to your wielded slot so the knife action can find them.

## Found bug? Want improvements?
If you foun bug, have improvment idea etc, use https://github.com/sfence/more_killing/issues . Author is opened to help via PR, but strongly recommend to consult improvment idea first via issue or different comunication platform.

