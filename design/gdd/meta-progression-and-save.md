# Save/Load, Ship Hub & Meta-Progression

> **Status**: Approved
> **Author**: user + systems-designer + gameplay-programmer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 4 (Zero-Filler High-Stakes Routing)

## Summary

Governs the **Base Hub ("The Debt-Collector" Ship Hub)** with 5 functional stations (Playable Character Roster, Specialist NPC Meta-Unlocks, Lore & Armory Codex, Firing Range Target Dummies, and Overdrive Pact Difficulty Modifiers), **Horizontal Pool-Expansion Meta-Progression** (zero mandatory stat-grind), **Room-Boundary Auto-Save Checkpoints (`user://active_run_checkpoint.sav`)**, and a strict **Mechanics-to-Lore Skin Decoupling Contract** so all world names, flavor text, and visual themes can be swapped or overhauled via external tables before formal Stage 4 art production without touching a single line of gameplay code.

> **Quick reference** — Layer: `Polish` · Priority: `Alpha` · Key deps: `7-Slot Loadout & Tactical Items System`, `3-Door Routing, Overdrive Bet & Floor Generator`, `Pit-Stop, Bounty Chip Economy & Rival Cast System`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Save/Load, Ship Hub & Meta-Progression** connects individual 30–45 minute runs into a 100+ hour roguelite experience while enforcing two foundational architectural guarantees:
1. **Horizontal Variety Over Stat-Grind (反数值逼肝的横向解锁体系)**: In strict compliance with our Anti-Pillars, meta-currency (**`🔥 Overdrive Sparks / 超载星核火种`**) is **never** spent on "+50% permanent HP/Damage" stat sticks. Instead, meta-progression unlocks new **Playable Characters**, expands the **Common/Rare/Epic/Legendary Weapon, Dynamo Core & Relic pools**, unlocks **Black-Market & Forge facility features** (Mystery Contraband Box, Reroll Machine, Axis 3/4 Tuning), and opens **Overdrive Pact Difficulty Modifiers** for veteran replayability.
2. **100% Mechanics-to-Lore Skin Decoupling (底层机制与世界观皮肤完全解耦)**: Because world-building, character names, and narrative tone may be refined or completely re-themed prior to full visual asset production, every hub station, currency, NPC slot, character archetype, and item in the codebase is addressed strictly by **theme-agnostic functional IDs** (`currency_in_run`, `currency_meta`, `hub_station_shop_unlock`, `playable_archetype_sniper`, `boss_stratum_03`). All display names, dialogues, codex entries, and sprite paths are loaded from external localization/skin tables (`res://data/localization/skin_table_zh.csv` / `.tres`), allowing an instant world-theme overhaul in minutes before locking final art specs.

## Detailed Design

*(Note: `systems-designer` and `gameplay-programmer` consulted for save serialization, anti-save-scum checkpoints, and skin decoupling.)*

### Core Rules

1. **Mechanics-to-Lore Skin Decoupling Contract (底层逻辑与世界观皮肤解耦铁律)**:
   - **Rule**: No GDScript logic file, formula, state machine, or save-file key may hardcode lore-specific nouns (such as *"Gunboy"*, *"Sample Y"*, *"Old Rex"*, or *"Bounty Chips"*).
   - **Two-Layer Indirection**:
     - **Layer 1 — Immutable Functional IDs (`StringName`)**: Code and save files exclusively reference functional role IDs (`currency_in_run`, `currency_meta`, `npc_specialist_merchant`, `npc_specialist_smith`, `npc_quest_01`, `rival_slot_sniper`, `stratum_01..10`).
     - **Layer 2 — Hot-Swappable Skin & Text Table (`ThemeSkinCatalog`)**: Maps each functional ID to its current `display_name_zh`, `flavor_desc_zh`, `dialogue_bank_id`, and `visual_asset_path`. Re-theming the entire world setting before formal asset production requires editing only `ThemeSkinCatalog` with **zero code or save-schema refactoring**.
2. **The 5 Functional Stations of the Base Hub (`HubScene`)**:
   - Between runs, the player spawns in the central Hub (currently themed as the *"Debt-Collector" Bounty Ship Bar*) containing 5 interactive stations (`[E]`):
     1. **`hub_station_roster` (Playable Character Select Bar)**: Switch between unlocked Playable Archetypes (`playable_default_allrounder` [Colt], `playable_sniper_piercer` [Vesper], `playable_explosion_specialist` [Bucky], `playable_shield_mimic` [Specimen Y-Jr.]). Each archetype defines a starting `Primary + Heavy + Dynamo + Innate Passive Trait`.
     2. **`hub_station_quartermaster` (Meta-Pool & Facility Unlocks)**: Spend **`🔥 Overdrive Sparks (`currency_meta`)`** to unlock new weapons, Dynamo Cores, and Relics into the run drop pool, or unlock permanent Pit-Stop facilities (Mystery Contraband Box, Shop Reroll Machine, Forge Axis 3 & Axis 4).
     3. **`hub_station_firing_range` (Target Dummy Range)**: Contains 3 immortal mechanical target dummies (1 Standard Fodder, 1 Shielded Elite that periodically flashes a `0.85s` Weak-Point Interrupt window, and 1 DPS Meter dummy) so players can test weapon recoil, Final Rounds, Active Reload sweet spots, and `RMB` Heavy Spenders before launching a run.
     4. **`hub_station_codex` (Armory, Enemy & Lore Codex)**: Tracks discovery/kill counts and displays humorous flavor text for all weapons, items, enemies, bosses, and NPC side-quests.
     5. **`hub_station_launch_pod` (Run Launch & Overdrive Pact Modifiers)**: Starts the next run; once Stratum 3 is cleared once, unlocks the **Overdrive Pact Board (霸王契约高难词缀板)** where players can toggle optional challenge pacts (`+15%` enemy bullet speed, `+1` Elite per room, stricter reload windows, guaranteed Rival Boss ambushes) in exchange for **`+15%` to `+100%` bonus `🔥 Overdrive Sparks`**.
3. **Anti-Grind Meta-Progression Categories**:
   - **Allowed Meta-Unlocks**:
     - Expanding the item/weapon/core drop pool (`35+` unlockable blueprints across `RARE / EPIC / LEGENDARY`).
     - Unlocking Pit-Stop features (Shop Reroll Machine, Contraband Blind Box, Forge Axis 3/4, Starting Weapon 2-Choice Rack, Carry-Over `25 🪙` Pocket Change).
     - Unlocking new Playable Character Archetypes via in-run Rival Boss defeats / quests.
   - **Forbidden Meta-Unlocks**:
     - Never sell repeatable flat "+X% Base Damage" or "+X Max HP" stat grinds that invalidate Run #1 skill balance.
4. **Two-File Save Architecture (`meta_profile.sav` & `active_run_checkpoint.sav`)**:
   - **`user://meta_profile.sav` (Persistent Meta Save + `.bak` Atomic Backup)**:
     - Stores `currency_meta` (`🔥 Overdrive Sparks`), unlocked blueprint IDs, NPC quest states (`Category A/B/C` progression), Codex counters, Pact clear records, and audio/accessibility settings.
     - Written atomically (write to `.tmp` $\rightarrow$ verify SHA-256 checksum $\rightarrow$ rename `.sav` to `.bak` $\rightarrow$ move `.tmp` to `.sav`).
   - **`user://active_run_checkpoint.sav` (Mid-Run Room Checkpoint)**:
     - Automatically saved at the exact moment a room transitions to `ROOM_CLEARED_ROUTING` or upon entering a new door (`< 5ms` non-blocking write).
     - Stores `run_rng_seed`, `stratum_index`, `node_index`, `endless_loop_count`, current HP / Aegis Shield / Aegis Pips, `currency_in_run` (`🪙`), 7-Slot Loadout IDs + Forge modifiers, and active Side-Quest state.
     - **Anti-Save-Scum Rule**: Deleted immediately upon player death (`Defeat`) or campaign extraction (`Victory`) after committing earned `🔥 Overdrive Sparks` to `meta_profile.sav`.

### States and Transitions

| Hub & Persistence State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`BOOT_LOADING`** | Game launch | $\rightarrow$ `RESUME_PROMPT` if valid `active_run_checkpoint.sav` exists<br>$\rightarrow$ `HUB_EXPLORATION` otherwise | Validates `meta_profile.sav` (falling back to `.bak` if corrupted) and loads active `ThemeSkinCatalog`. |
| **`RESUME_PROMPT`** | Unfinished run checkpoint detected on launch | $\rightarrow$ `IN_RUN_RESTORED` on choosing *[继续当前行动]*<br>$\rightarrow$ `HUB_EXPLORATION` on choosing *[放弃并返回基地]* | Restores exact room-clear state and RNG seed state in `< 1.0s`. |
| **`HUB_EXPLORATION`** | Player inside Base Hub | $\rightarrow$ `IN_RUN_ACTIVE` when stepping into `hub_station_launch_pod` (`[E]`) | Player can freely test weapons on firing range dummies, spend `🔥 Overdrive Sparks`, swap characters, and configure Overdrive Pacts. |
| **`IN_RUN_ACTIVE`** | Active cavern run | $\rightarrow$ Writes `active_run_checkpoint.sav` on every `room_cleared`<br>$\rightarrow$ `RUN_SUMMARY_SETTLEMENT` on Death or Extraction | Tracks run stats and writes room-boundary checkpoints. |
| **`RUN_SUMMARY_SETTLEMENT`** | Run ended (Defeat, Stratum 3/10 Extraction, or Endless end) | $\rightarrow$ `HUB_EXPLORATION` (`< 1.0s` Quick-Restart option also available) | Deletes `active_run_checkpoint.sav`, awards `run_sparks_earned` to `meta_profile.sav`, and displays damage breakdown by trigger source. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **7-Slot Loadout & Tactical Items System** | Bidirectional | Serializes/deserializes the 7 equipped slots and filters drop pools by unlocked blueprint IDs | `Save/Load, Ship Hub & Meta-Progression` |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Bidirectional | Triggers mid-run checkpoint save on `room_cleared`; receives `run_rng_seed` and active Overdrive Pact modifiers | `Save/Load, Ship Hub & Meta-Progression` |
| **Pit-Stop, Bounty Chip Economy & Rival Cast System** | Bidirectional | Persists Category A/B/C NPC quest states, facility unlocks (Blind Box, Reroll, Forge Axes), and unlocked Playable Archetypes | `Save/Load, Ship Hub & Meta-Progression` |

## Formulas

*(Note: `systems-designer` consulted for meta-currency payout and blueprint unlock curve math.)*

### 1. Run Settlement Meta-Currency Payout (`run_sparks_earned`)

At the end of any run (whether ending in Defeat, Extraction, or Endless Loop), the amount of **`🔥 Overdrive Sparks (`currency_meta`)`** awarded is defined as:

`run_sparks_earned = round(( float(rooms_cleared) * SPARKS_PER_ROOM + float(bosses_defeated) * SPARKS_PER_BOSS + float(overdrive_bets_won) * SPARKS_PER_BET + float(endless_loops_completed) * SPARKS_PER_LOOP ) * (1.0 + PACT_BONUS_STEP * float(active_pact_rank)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `rooms_cleared` | int | `0–99` | calculated | Total combat rooms cleared during the run (`SPARKS_PER_ROOM = 2.0`) |
| `bosses_defeated` | int | `0–20` | calculated | Total Stratum Bosses and Rival Hidden Bosses defeated (`SPARKS_PER_BOSS = 20.0`) |
| `overdrive_bets_won` | int | `0–30` | calculated | Number of Overdrive Bet (`-25⚡`) rooms successfully cleared (`SPARKS_PER_BET = 6.0`) |
| `endless_loops_completed` | int | `0–99` | calculated | Completed Sample Y Endless Loops (`SPARKS_PER_LOOP = 35.0`) |
| `PACT_BONUS_STEP` | float | `0.15` | data file | `+15%` bonus Sparks per active Overdrive Pact difficulty rank |
| `active_pact_rank` | int | `0–6` | calculated | Selected Overdrive Pact challenge level (`0` = standard difficulty) |

**Output Range:** `4 🔥` (early Floor 1 wipe) to `90–140 🔥` (full 3-Floor clear with 2 Bets) up to `400+ 🔥` (Stratum 10 + Endless Loop with Pacts).
**Example:** Player clears 3 Strata (`15` combat rooms = `30 🔥`), defeats 3 Bosses (`60 🔥`), wins 2 Overdrive Bets (`12 🔥`) at Pact Rank `2` (`+30%` bonus):
`run_sparks_earned = round((30.0 + 60.0 + 12.0 + 0.0) * (1.0 + 0.15 * 2)) = round(102.0 * 1.30) = 133 🔥 Overdrive Sparks`.

---

### 2. Blueprint Meta-Unlock Cost Curve (`blueprint_unlock_cost`)

To ensure new players unlock their first several weapons and relics after just 1–2 short runs while Legendary centerpiece blueprints remain exciting mid-term goals, the `🔥 Overdrive Sparks` cost to unlock a blueprint of rarity `R` is defined as:

`blueprint_unlock_cost = round(BASE_UNLOCK_COST_BY_RARITY * (1.0 + TIER_PROGRESSION_SLOPE * float(unlock_tier_depth)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `BASE_UNLOCK_COST_BY_RARITY` | float | `25.0–120.0` | data file | Base Spark cost (`25` Common, `45` Rare, `75` Epic, `120` Legendary) |
| `TIER_PROGRESSION_SLOPE` | float | `0.12` | data file | `+12%` cost step per deeper unlock tree row (`0..4`) |
| `unlock_tier_depth` | int | `0–4` | data file | Row depth in the Quartermaster unlock catalog |

**Output Range:** `25 🔥` (Tier-0 Common weapon/relic, affordable after a single Floor 1 run) to `178 🔥` (Tier-4 Legendary centerpiece).
**Example:** Unlocking a Tier-1 `RARE` Passive Relic (`BASE_UNLOCK_COST_BY_RARITY = 45.0`, `unlock_tier_depth = 1`) costs `round(45.0 * 1.12) = 50 🔥 Overdrive Sparks`.

## Edge Cases

- **If the game crashes or power is lost mid-write while saving `meta_profile.sav`**: On next boot, if `meta_profile.sav` fails its SHA-256 checksum verification, the loader automatically restores `meta_profile.sav.bak` and notifies the player with zero loss of permanent unlocks.
- **If the player Force-Quits (`Alt+F4`) in the middle of a combat room before dying**: Because `active_run_checkpoint.sav` is written strictly on `room_cleared` / door entry, resuming the game places the player back at the **start of that room (door entry state)** with the exact deterministic `run_rng_seed`—preventing players from rerolling room drops, Mystery Boxes, or Bucky's Forge cards by force-quitting.
- **If the developer swaps the entire `ThemeSkinCatalog` (e.g., changing world lore, character names, and currency names before Stage 4 art production)**: Because `meta_profile.sav` and `active_run_checkpoint.sav` store only immutable functional IDs (`playable_sniper_piercer`, `currency_meta`, `relic_tesla_mag_well`), existing save files load 100% seamlessly under the new world theme.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **7-Slot Loadout & Tactical Items System** | Depends on (Upstream) | Hard | Serializes 7-Slot loadout state and unlocks new `.tres` item IDs into the drop pool |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Depends on (Upstream) | Hard | Saves mid-run room checkpoints and applies Overdrive Pact modifiers to floor generation |
| **Pit-Stop, Bounty Chip Economy & Rival Cast System** | Depends on (Upstream) | Hard | Persists NPC quest unlocks (*Category A/B/C*) and unlocked Playable Character Archetypes |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 2, 5, 6, and 8.)*

- **Warm Hub Sanctuary Atmosphere (`3800K` Tungsten + Neon Accents)**:
  - Contrasts with the cold/hostile cavern floors by framing the 5 Hub stations in warm work-lamp pools (`Value 30%–45%`).
- **Skin-Table Driven UI & Sprites**:
  - All Hub station signage, character portraits, and currency icons resolve their paths through `ThemeSkinCatalog`.

📌 **Asset Spec** — Hub station layouts, target dummy states, and skin-table indirection rules are defined.

## Game Feel

- **Instant `< 1.0s` "One More Run" Loop**: Whether dying in a tough Boss fight or extracting with a pile of `🔥 Overdrive Sparks`, the player can either press `[R] Quick Restart` to drop straight into Stratum 1 Node 1 in under 1 second, or warp to the Hub to unlock a shiny new weapon and test it immediately on the Firing Range Dummies.

## UI Requirements

- **Run Summary Telemetry Screen**: Displays Run Duration, Stratum/Loop Reached, Damage Breakdown by Trigger Source (`Primary` vs. `Final Round` vs. `RMB Heavy` vs. `Perfect Reload / Relics`), `🔥 Overdrive Sparks` earned, and newly unlocked Blueprints.
- **Quartermaster Unlock Grid & Codex Overlay**: Clean 4-Tier Rarity colored grid showing locked/unlocked blueprints and their `🔥` costs.

> **📌 UX Flag — Save/Load, Ship Hub & Meta-Progression**: The Run Summary screen, Quartermaster Unlock Grid, and Hub station prompts will be included in `design/ux/`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | 7-Slot `Resource` IDs, `room_cleared` signal | Yes — checkpoint serializer binds directly to `room_cleared` |
| `design/gdd/pit-stop-and-rival-system.md` | 4-Tier Rarity (`COMMON..LEGENDARY`), 3-Category NPC unlocks, Playable Gunboy roster | Yes — Quartermaster and Roster station persist all NPC/Rival states |
| `design/narrative/world-lore.md` | Space Gunboy / Planet X / Sample Y theme | Yes — encapsulated via `ThemeSkinCatalog` so lore/names can be modified anytime prior to art production |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** all display names, currency labels, and NPC titles are stored in `ThemeSkinCatalog` mapped by functional IDs (`currency_in_run`, `npc_specialist_merchant`, etc.), **WHEN** `ThemeSkinCatalog` is replaced with a new world-theme table, **THEN** all HUD labels, Hub stations, Codex entries, and existing `.sav` files function with `0` code changes or broken references.
- **GIVEN** the player clears Stratum 1 Node 3 (`room_cleared == true`) and closes the game, **WHEN** the game relaunches and the player selects *Resume Run*, **THEN** `active_run_checkpoint.sav` restores the exact Stratum/Node, `run_rng_seed`, HP, Aegis Shield/Pips, `🪙` wallet, and 7-Slot Loadout in `< 1.0s`.
- **GIVEN** `meta_profile.sav` is intentionally corrupted by invalid bytes while `meta_profile.sav.bak` is intact, **WHEN** the game boots, **THEN** the checksum validator detects the corruption and automatically restores `meta_profile.sav.bak` without losing `🔥 Overdrive Sparks` or unlocks.
- **GIVEN** the Quartermaster unlock catalog, **WHEN** all meta-upgrades are inspected, **THEN** `100%` of upgrades are horizontal pool additions, facility unlocks, or starting choice options, and `0` upgrades grant repeatable permanent flat "+% Base Damage" or "+Max HP" stat inflation.

## Open Questions

- *None — all 11/11 system GDDs are now complete, verified, and locked.*
