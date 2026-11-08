# Player 3C, Dodge-Graze & Tactical Arena Interactables

> **Status**: Approved
> **Author**: user + game-designer + gameplay-programmer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower)

## Summary

Defines the sacrosanct top-down 3C movement controller (`290.0 px/s` zero-inertia 8-way movement + 360° aiming), committed `Space` dodge-roll with front-loaded I-frames (`0.28s`), outer Graze absorption ring (`42.0 px` radius yielding `+10.0⚡` Overcharge per bullet grazed, up to `+20.0⚡` base per roll), and the unified data-driven **Tactical Arena Interactables** system supporting both **Proximity (`[E]`)** and **Ranged Hit-Trigger** objects with customizable combat effects.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Combat Event Bus & Data Schema`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Player 3C, Dodge-Graze & Tactical Arena Interactables** establishes the physical feel and spatial interaction language of **CHAMBER OVERDRIVE (膛室超载)**. Serving **Pillar 1 (Sacrosanct 3C Consistency)**, base movement speed, dodge-roll trajectory, and hurtbox geometry are treated as a sacred contract with the player's muscle memory—no weapon weight, terrain hazard, or item synergy is ever permitted to sluggishly degrade player movement or alter dodge recovery frames.

At the same time, this system turns spatial positioning into an active fuel source for **Pillar 2 (Action Fuels Firepower)** through two original mechanisms:
1. **Committed Dodge-Roll Grazing (`Space`)**: Rolling through enemy bullet curtains during the front-loaded `0.28s` I-frame window activates an outer electromagnetic **Graze Ring (`42.0 px`)** that siphons kinetic voltage (`+10.0⚡` Overcharge per bullet, up to 2 per roll at base or 3 with Exoskeleton Graze Matrix) directly into the player's reactor, balanced by a `0.14s` vulnerable landing recovery that rewards smart trajectory choices.
2. **Unified Customizable Tactical Arena Interactables (`ArenaInteractableData`)**: Instead of derivative single-purpose props, arena objects share a unified data-driven framework categorized into **Proximity Interactables (`[E]` key within `40.0 px`)**—such as pop-up hydraulic energy shields, overcharge tap-boxes, and kinetic launchpads—and **Ranged Hit-Trigger Interactables (shot by `LMB`/`RMB` projectiles)**—such as volatile fuel drums, cryo-coolant tanks, and bullet-splitting prism nodes.

## Detailed Design

*(Note: `game-designer` and `gameplay-programmer` consulted for 3C frame timings and `ArenaInteractableData` extensibility.)*

### Core Rules

1. **Zero-Inertia 8-Way Movement & Sacrosanct 3C Lock (`WASD` / Left Stick)**:
   - Base movement speed is locked at **`BASE_MOVE_SPEED = 290.0 px/s`**. Acceleration and deceleration are instantaneous (`1-frame` velocity snap on input press/release) so micro-dodging between dense bullet patterns feels surgical.
   - **3C Protection Rule**: No weapon, enemy debuff, or room modifier may reduce player movement speed below `290.0 px/s` or alter `DODGE_DURATION` (`0.42s`). Positive movement speed modifiers from Passive Relics (e.g., *Kinetic Boots*) are hard-capped at **`+15%` (`333.5 px/s` max)**.
2. **Concentric Dual-Circle Hitbox Architecture**:
   - **Inner Hurtbox (`PLAYER_HURTBOX_RADIUS = 14.0 px`)**: Centered at the player's torso/feet pivot, slightly smaller than the visual `32×32px` chibi sprite so near-misses feel generous and fair.
   - **Outer Graze Ring (`BASE_GRAZE_RADIUS = 42.0 px`)**: Concentric detection ring active during Dodge-Roll I-frames (`+25%` radius to `52.5 px` when *Kinetic Boots* passive is equipped).
3. **Committed Dodge-Roll & Graze Siphon (`Space` / Controller South/RB)**:
   - Pressing `Space` initiates a committed **`0.42s` (`DODGE_DURATION`)** roll along the current movement vector (or toward the aim cursor if stationary):
     - **Phase 1 — I-Frame Dash (`0.00s` to `0.28s`, `DODGE_IFRAME_END = 0.28s`)**: Moves at **`DODGE_SPEED = 640.0 px/s`**. The player's hurtbox is 100% invulnerable to enemy projectiles and contact damage, spawning 3 cyan afterimages.
     - **Graze Trigger (`+10.0⚡`)**: Any active enemy projectile entering `effective_graze_radius` during Phase 1 that has not yet been grazed (`bullet.grazed == false`) is flagged `grazed = true`, arcs cyan lightning to the player, emits `dodge_graze_triggered`, and grants **`+10.0` Overcharge** (capped at **`MAX_GRAZE_PER_ROLL = 2`** base, or `+20.0⚡` maximum per roll; expandable to `3` via Exoskeleton Forge tuning).
     - **Phase 2 — Commit Recovery (`0.28s` to `0.42s`, `0.14s` window)**: Roll velocity decelerates to **`42%` (`268.8 px/s`)**, I-frames and Graze detection end, and primary/heavy firing remains locked until `0.42s` completes.
4. **Unified Customizable Tactical Arena Interactables (`ArenaInteractableData`)**:
   - Every interactive arena object is driven by an `ArenaInteractableData` resource specifying `trigger_mode` and a customizable `effect_type` + `effect_params` dictionary:
   - **Category A: Proximity Interactables (`trigger_mode = PROXIMITY_KEY_E`, Interaction Radius `= 40.0 px`)**:
     - Activated by pressing **`[E]`** when within `40.0 px` (prioritized automatically during combat; after room clear, doors take priority if overlapping):
       1. **`DEPLOY_SHIELD_COVER` (液压防爆升盾桩)**: Snaps up a solid `96×36px` alloy-energy barrier (`60.0 HP` durability) that blocks enemy projectiles and vaporizes enemy bullets within a `28.0 px` shock-border on deployment.
       2. **`OVERCHARGE_CAPACITOR` (违章高压偷电箱)**: Rips open a corporate power junction, instantly granting **`+22.0⚡` Overcharge** to the player and emitting a `110.0 px` stun pulse that interrupts/staggers nearby enemies (1-time use per room).
       3. **`KINETIC_LAUNCHPAD` (矿坑电磁弹射板)**: Launches the player `260.0 px` toward the aim direction at `900.0 px/s` with full I-frames, triggering a `90.0 px` landing shockwave (`35.0` damage).
   - **Category B: Ranged Hit-Trigger Interactables (`trigger_mode = RANGED_HIT`, Hitbox Radius `= 22.0 px`)**:
     - Triggered when struck by any player `LMB` primary bullet, `Final Round`, or `RMB` heavy attack:
       1. **`EXPLOSIVE_BLAST` (高爆燃料罐)**: Detonates immediately (`0.035s` hitstop), dealing **`65.0` AoE damage** within `135.0 px`, clearing enemy bullets in radius, and emitting `interactable_triggered` (triggers *Tactical Saboteur Dynamo* for `+22.0⚡` if an enemy is hit).
       2. **`CRYO_SLOW_FIELD` (深冷液氮罐)**: Ruptures into a `140.0 px` sub-zero mist zone lasting **`3.5s`** (`Alpha <= 35%`), reducing enemy movement speed and enemy projectile velocity inside the zone by **`50%`**.
       3. **`PRISM_BULLET_SPLIT` (超导折射棱镜柱)**: Durable crystal node (`5 hits` capacity, `0.20s` internal cooldown); each player shot striking the prism refracts into **5 homing laser splinters** (`22.0` damage each) targeting the nearest enemies.
   - **Custom Effect Extensibility**: Designers can author new `.tres` interactables by combining any `trigger_mode` (`PROXIMITY_KEY_E` or `RANGED_HIT`) with any `effect_type` payload without modifying player controller code.

### States and Transitions

| Player 3C State | Active Conditions | Allowed Transitions | Movement & Combat Rules |
| :--- | :--- | :--- | :--- |
| **`NORMAL_SKIRMISH`** | Default state (`not is_dodging` and `not is_launching`) | $\rightarrow$ `DODGE_IFRAME` on `Space`<br>$\rightarrow$ `LAUNCH_DASH` on `[E]` Launchpad | Full 8-way movement (`290–333.5 px/s`), 360° aiming, `LMB`/`RMB`/`[R]`/`[Q]`/`[E]` all active. |
| **`DODGE_IFRAME`** | `0.00s <= dodge_timer <= 0.28s` | $\rightarrow$ `DODGE_RECOVERY` at `0.28s` | Locked movement along `dodge_dir` at `640.0 px/s`; Hurtbox disabled; Graze Ring (`42–52.5 px`) active; firing paused. |
| **`DODGE_RECOVERY`** | `0.28s < dodge_timer < 0.42s` | $\rightarrow$ `NORMAL_SKIRMISH` at `0.42s` | Velocity drops to `268.8 px/s`; Hurtbox re-enabled; Graze Ring off; firing resumes at `0.42s`. |
| **`LAUNCH_DASH`** | Triggered `KINETIC_LAUNCHPAD` (`0.00s` to `0.29s`) | $\rightarrow$ `NORMAL_SKIRMISH` on arrival | High-speed `900.0 px/s` arc with full I-frames; triggers landing shockwave on transition to `NORMAL_SKIRMISH`. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Downstream Consumer & Upstream Producer | Emits `dodge_started`, `dodge_graze_triggered`, `interactable_triggered`; reads `ArenaInteractableData` | `Combat Event Bus & Data Schema` |
| **Pooled Bullet-Hell & Damage System** | Bidirectional | Queries enemy bullet positions for Graze Ring & Hurtbox checks; Ranged Hit-Trigger interactables intercept player bullets and spawn AoE/prism effects | `Pooled Bullet-Hell & Damage System` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Downstream Consumer | Receives `+10.0⚡` from `dodge_graze_triggered` and `+22.0⚡` from `interactable_triggered`; Active Reload bar continues ticking during Dodge Roll | `Dual-Gun, Active Reload & Overcharge Engine` |
| **7-Slot Loadout & Tactical Items System** | Upstream Provider | Supplies passive stat modifiers (`fleet_step` `+12%` speed and `+25%` Graze radius) | `7-Slot Loadout & Tactical Items System` |

## Formulas

*(Note: `systems-designer` consulted for 3C velocity, graze radius, and cap formulas.)*

### 1. Effective Player Movement Velocity (`current_move_speed`)

The player's instantaneous movement speed across normal skirmishing and dodge-roll phases is defined as:

`current_move_speed = (BASE_MOVE_SPEED * min(MAX_SPEED_MULT, 1.0 + passive_speed_bonus)) * int(not is_dodging) + (DODGE_SPEED * (1.0 * int(dodge_timer <= DODGE_IFRAME_END) + DODGE_RECOVERY_FACTOR * int(dodge_timer > DODGE_IFRAME_END))) * int(is_dodging)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `BASE_MOVE_SPEED` | float | `290.0` | constant | Sacrosanct base movement speed in pixels/second |
| `passive_speed_bonus` | float | `0.0–0.15` | calculated | Sum of movement speed bonuses from equipped Passive Relics (`0.12` for *Kinetic Boots*) |
| `MAX_SPEED_MULT` | float | `1.15` | constant | Hard ceiling (`+15%`) preventing runaway speed from breaking arena bounds |
| `DODGE_SPEED` | float | `640.0` | data file | Peak dash velocity during the `0.28s` I-frame phase |
| `DODGE_IFRAME_END` | float | `0.28` | data file | Duration (seconds) of the front-loaded invulnerability and graze phase |
| `DODGE_RECOVERY_FACTOR` | float | `0.42` | data file | Velocity multiplier during the `0.14s` post-roll recovery window |

**Output Range:** `290.0 px/s` (base walk) to `333.5 px/s` (max passive walk); `640.0 px/s` during `0.00–0.28s` dodge I-frames; `268.8 px/s` during `0.28–0.42s` dodge recovery.
**Example:** With *Kinetic Boots* (`passive_speed_bonus = 0.12`), walking speed is `290.0 * min(1.15, 1.12) = 324.8 px/s`. Pressing `Space` sets `current_move_speed = 640.0 px/s` for `0.28s`, then `640.0 * 0.42 = 268.8 px/s` for the final `0.14s`.

---

### 2. Dodge-Roll Graze Overcharge Yield (`graze_overcharge_gain`)

When an enemy bullet intersects the player's Graze Ring during a Dodge Roll, the Overcharge energy awarded is defined as:

`graze_overcharge_gain = CHARGE_DODGE_GRAZE * int(is_dodging and dodge_timer <= DODGE_IFRAME_END) * int(not bullet_already_grazed) * int(roll_graze_count < MAX_GRAZE_PER_ROLL)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `CHARGE_DODGE_GRAZE` | float | `10.0` | data file | Base Tier-1 Overcharge energy awarded per grazed enemy projectile (calibrated for `72–100⚡` room budget; max `+20.0⚡` per roll) |
| `dodge_timer` | float | `0.0–0.42` | calculated | Elapsed time in the current dodge roll |
| `bullet_already_grazed` | bool | `true/false` | calculated | Per-bullet flag ensuring one projectile cannot be grazed multiple times |
| `roll_graze_count` | int | `0–3` | calculated | Number of bullets already grazed during the current `Space` roll |
| `MAX_GRAZE_PER_ROLL` | int | `2` (up to `3` via Forge) | data file | Maximum graze payouts permitted in a single dodge roll (`+20.0⚡` base cap) |

**Output Range:** `0.0` or `10.0` per bullet event, up to `20.0` (`30.0` with Forge Exoskeleton) total Overcharge per `Space` roll.
**Example:** Player rolls through a 5-bullet enemy ring at `dodge_timer = 0.12s`. Bullet #1 and Bullet #2 yield `10.0⚡` each (`roll_graze_count` reaches `2`, total `+20.0⚡`). Bullets #3–#5 evaluate `int(2 < 2) = 0`, yielding `0.0⚡` while the player still passes safely through all 5 bullets via I-frames.

## Edge Cases

- **If the player presses `Space` while an Active Reload (`[R]`) slider is moving**: Starting a Dodge Roll **does not cancel or reset** an in-progress reload; the overhead reload bar continues advancing during the roll and the player can press `[R]` mid-roll to snap a **Perfect Reload** while grazing bullets.
- **If the player presses `Space` with zero directional input (`WASD` released)**: The roll executes along the normalized vector from `player_pos` toward `get_global_mouse_position()` so `Space` never results in an in-place zero-velocity roll.
- **If a Proximity Interactable (`[E]`) deploys a solid barrier (`DEPLOY_SHIELD_COVER`) directly overlapping the player or an enemy**: The collision solver applies an immediate radial push-out vector (`(entity_pos - barrier_center).normalized() * push_margin`) so no actor is ever trapped inside deployed cover.
- **If two Proximity `[E]` targets overlap (e.g., an unactivated interactable near an unlocked exit door after `room_cleared`)**: Before `room_cleared`, exit doors are inactive so `[E]` 100% triggers the arena interactable; after `room_cleared`, `[E]` selects whichever valid target has the shorter Euclidean distance to `player_pos`.
- **If a Ranged Hit-Trigger interactable (`EXPLOSIVE_BLAST`) is struck by a piercing `Final Round` or `RMB` Railgun beam**: The interactable triggers its effect without consuming/stopping the piercing projectile, allowing the shot to both detonate the hazard and pierce enemies behind it.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Emits `dodge_started`, `dodge_graze_triggered`, `interactable_triggered`; loads `ArenaInteractableData` |
| **Pooled Bullet-Hell & Damage System** | Depended on by (Downstream) | Hard | Provides `player_pos`, `in_iframes`, `effective_graze_radius`, and deployed cover/hazard collision shapes |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depended on by (Downstream) | Hard | Consumes Graze (`+10.0⚡`) and Capacitor/Hazard Overcharge bursts (`+22.0⚡`) |
| **Tactical Micro-HUD & Screen UI System** | Depended on by (Downstream) | Hard | Renders the `42–52.5 px` cyan Graze Ring around `player_pos` and `[E]` interactable prompts |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 5, 6, and 8.)*

- **Dodge-Roll Visuals (`Z = 10` & `Z = 20`)**:
  - Launching a `Space` roll stretches the chibi sprite horizontally (`1.20x × 0.82x` squash-and-stretch) and spawns 3 additive cyan ghost afterimages (`#00F0FF`, `Alpha 35% -> 10%`) at `Z = 10`.
  - The outer Graze Ring renders at `18%` alpha during normal walking and flares to `80%` electric cyan (`2.5px` arc width) during the `0.28s` I-frame window.
- **Tactical Arena Interactable Visuals (`Z = 20` & `Z = 10`)**:
  - **Proximity `[E]` Objects**: Carry a crisp `2px` `#0B0D12` outline and display a high-contrast `[E]` floating action badge when the player enters `40.0 px`. Deployed shields (`DEPLOY_SHIELD_COVER`) display visible damage states at `100%`, `50%`, and `25%` durability.
  - **Ranged Hit-Trigger Objects**: Highlighted by bold hazard chevrons (Crimson `#FF2A3C` for `EXPLOSIVE_BLAST`, Sub-Zero Cyan `#00F0FF` for `CRYO_SLOW_FIELD`, Violet-Gold for `PRISM_BULLET_SPLIT`). Ground mist/shockwaves strictly obey **Player/Arena Ground VFX Alpha `<= 45%`** at `Z = 10` so enemy bullets at `Z = 40` remain 100% visible.
- **Audio Cues**:
  - `sfx_combat_graze.wav` (`44.1kHz` high-frequency electric zip, pitch-scaled `1.0x` on 1st graze, `1.15x` on 2nd graze in the same roll).
  - Distinct mechanical deployment clunk (`DEPLOY_SHIELD_COVER`), electric surge (`OVERCHARGE_CAPACITOR`), cryo hiss (`CRYO_SLOW_FIELD`), and prism chime (`PRISM_BULLET_SPLIT`).

📌 **Asset Spec** — Visual/Audio requirements are defined. After GDDs are approved, `/asset-spec` can produce per-asset visual descriptions and generation prompts from this section.

## Game Feel

- **Instant Input Snappiness**: `0ms` input inertia on `WASD` direction changes; `Space` dodge roll responds on the exact frame pressed.
- **Graze Dopamine**: Grazing an enemy bullet triggers a crisp micro-flash on the outer ring, an ascending electric zip sound, and a floating `+10⚡` callout, making close-quarters bullet weaving feel exhilarating rather than terrifying.
- **Tactical Arena Mastery**: Shooting a `PRISM_BULLET_SPLIT` node to split a Final Round into 5 homing beams or tapping `[E]` on a `DEPLOY_SHIELD_COVER` pylon to block a sniper shot gives players creative spatial outplays in every room.

## UI Requirements

- **Graze Ring Indicator**: Drawn directly around `player_pos` (`42.0 px` base radius) as part of the `64px` Player-Proximate Micro-HUD.
- **Proximity `[E]` Context Prompt**: Clean `12px` bold Chinese tag above any `PROXIMITY_KEY_E` interactable within `40.0 px` (e.g., `[E] 升起防爆盾`, `[E] 汲取超载电箱 (+30⚡)`, `[E] 启动弹射板`).

> **📌 UX Flag — Player 3C, Dodge-Graze & Tactical Arena Interactables**: This system has UI requirements (Graze Ring & Proximity `[E]` prompts), which are consolidated into `design/gdd/tactical-micro-hud.md` and `design/ux/hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `dodge_started`, `dodge_graze_triggered`, `interactable_triggered`, `ArenaInteractableData` | Yes — exact signal signatures and `trigger_mode` / `effect_type` enums match |
| `design/art/art-bible.md` | Section 1 & Section 8 (`Z=10` VFX Alpha `<= 45%`, `Z=20` Actors & Cover, `2px` outlines) | Yes — cryo fields and afterimages capped at `<= 45%` alpha |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** the player is in `NORMAL_SKIRMISH` with no speed passives, **WHEN** directional input is applied or stacks with any Passive Relic, **THEN** movement speed equals `290.0 px/s` at base and never exceeds `333.5 px/s` (`+15%` cap) or drops below `290.0 px/s`.
- **GIVEN** the player presses `Space` to dodge roll through 4 active enemy bullets, **WHEN** `0.00s <= dodge_timer <= 0.28s`, **THEN** the player takes `0` damage, `dodge_graze_triggered` fires for the first `2` bullets granting `+20.0⚡` total Overcharge (`+10.0⚡` each), and bullets #3–#4 grant `0.0⚡` (`MAX_GRAZE_PER_ROLL == 2`).
- **GIVEN** the player is in `DODGE_RECOVERY` (`0.28s < dodge_timer < 0.42s`), **WHEN** an enemy projectile intersects `PLAYER_HURTBOX_RADIUS` (`14.0 px`), **THEN** the player is vulnerable and takes normal hit damage.
- **GIVEN** an `ArenaInteractableData` configured with `trigger_mode = PROXIMITY_KEY_E` and `effect_type = DEPLOY_SHIELD_COVER`, **WHEN** the player presses `[E]` within `40.0 px`, **THEN** the shield barrier activates (`60.0 HP`), clears enemy bullets within `28.0 px`, and blocks subsequent enemy projectiles until its durability reaches `0.0`.
- **GIVEN** an `ArenaInteractableData` configured with `trigger_mode = RANGED_HIT` and `effect_type = CRYO_SLOW_FIELD`, **WHEN** struck by a player projectile, **THEN** it spawns a `140.0 px` zone for `3.5s` (`Alpha <= 0.35`) that reduces enemy and enemy-bullet speed inside it by `50%`.

## Open Questions

- *None — 3C constants, Dodge-Graze caps, and the unified Proximity/Ranged `ArenaInteractableData` schema are locked.*
