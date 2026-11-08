# Pooled Bullet-Hell & Damage System

> **Status**: Approved
> **Author**: user + systems-designer + engine-programmer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Pre-allocated 800-slot object-pooled projectile engine (`BulletPool`), discrete player Armor/HP survival & Armor-Break Blank system, and the **3-Tier Ballistic Impact & Recoil Matrix** that differentiates snappy standard primary shots, high-impact **Final Round** knockback/stagger/hitstop, and **Heavy Weapon (`RMB`)** physical shooter recoil slides and directional corpse blasting while maintaining 60+ FPS with 500+ concurrent bullets.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Combat Event Bus & Data Schema`, `Player 3C, Dodge-Graze & Tactical Arena Interactables`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Pooled Bullet-Hell & Damage System** is the combat physics and visceral impact engine of **CHAMBER OVERDRIVE (膛室超载)**. It solves two core challenges simultaneously:
1. **Uncompromising 60+ FPS Bullet-Hell Readability & Performance**: By pre-allocating an 800-slot `BulletPool` (`500+` enemy bullets + `300` player projectiles) with zero runtime node instantiation or garbage-collection spikes, and strictly locking enemy projectiles to the highest gameplay render plane (`Z = 40`, `#FFFFFF` core + saturated warm rim) above translucent player VFX (`Z = 10`, `Alpha <= 45%`), the screen remains 100% readable even during chaotic Overdrive Bet rooms.
2. **3-Tier Ballistic Impact & Recoil Matrix (三级枪械打击感与物理后坐力阶梯)**: Every shot tier has unmistakable physical weight:
   - **Tier A — Standard Primary Shots (`LMB`)**: Crisp `6px` gun-sprite kick, `5°` muzzle rise, spinning brass shell ejection, and zero player movement displacement so dodging stays surgical.
   - **Tier B — Primary Final Round (`LMB` Mag = 1)**: Audible chambering click + amber muzzle glow before firing; on impact, triggers a **`0.03s` meaty hitstop**, **`28.0 px` enemy knockback**, **`0.25s` enemy attack-timer stagger**, and an enlarged golden critical popup.
   - **Tier C — Heavy Spender Weapons (`RMB` `45 / 65 / 90⚡`)**: Unleashing a heavy weapon physically pushes the **player character backward in a safe `0.08s` recoil slide (`8.0 px` Light / `16.0 px` Medium Railgun / `22.0 px` Ultimate Black Hole)** with dust puffs and `0.80x -> 1.15x` squash-and-stretch, paired with `0.045s–0.06s` heavy hitstop, `45.0 px` enemy knockback, and directional high-velocity debris scattering on kill.

## Detailed Design

*(Note: `systems-designer` and `engine-programmer` consulted for object pooling, damage math, and recoil physics.)*

### Core Rules

1. **Zero-Allocation 800-Slot Projectile Pool (`BulletPool`)**:
   - At scene initialization, `BulletPool` pre-allocates `800` contiguous projectile records (`500` reserved for enemy patterns, `300` for player weapons and prism splinters).
   - Runtime `instantiate()` and `queue_free()` calls for projectiles are **strictly forbidden** during active combat. Spawning a bullet activates the next dormant slot (`active = true`); wall collisions, hits, or bullet-clearing shockwaves return the slot to the pool (`active = false`).
   - Supported data-driven trajectory types: `STRAIGHT`, `SPREAD_FAN`, `RADIAL_RING`, `HOMING_MISSILE`, `PIERCING_SLUG`, and `HITSCAN_RAIL_BEAM`.
2. **Three-Tier Luminance & Z-Index Threat Supremacy**:
   - **`Z = 10` (Player & Arena Ground VFX)**: Black Hole singularities, Perfect Reload shockwaves, and Cryo mist zones are hard-capped at **`Alpha <= 0.45` (`45%`)**.
   - **`Z = 30` (Player Projectiles)**: Rendered in cool/reward hues (`#00F0FF` Cyan for standard/homing, `#FFB800` Amber Gold for Final Round).
   - **`Z = 40` (Enemy Projectiles & Telegraphs)**: Always renders on top of all player VFX and actors; uses a mandatory `#FFFFFF` pure-white inner core (`55%` radius) surrounded by a `#FF2A3C` Vermilion or `#FF1E8A` Magenta outer rim.
3. **3-Tier Ballistic Impact & Physical Recoil Matrix (三级打击感与物理后坐力规范)**:

| Ballistic Tier (射击层级) | Shooter Recoil & Gun Feel (射手后坐力与枪体动效) | Camera & Hitstop (镜头反冲与顿帧) | Enemy Hit Reaction (敌方受击反馈与击退硬直) |
| :--- | :--- | :--- | :--- |
| **1. Standard Primary (`LMB`)**<br>*(常规轻武器射击)* | • **Shooter Slide**: `0.0 px` (never disturbs dodging)<br>• **Gun Sprite Kick**: `6.0 px` back, `5°` muzzle flip<br>• **Shell Casing**: Standard brass casing ejected at `95–135°` | • **Camera Kick**: `2.0 px` micro-nudge<br>• **Hitstop**: `0.0s` (continuous flow) | • **Hit-Flash**: `0.06s` pure `#FFFFFF`<br>• **Knockback**: `4.0 px` micro-jitter<br>• **Popup**: Standard white `-DMG` |
| **2. Primary Final Round (`LMB` Mag=1)**<br>*(轻武器尾弹重击)* | • **Pre-Fire Cue**: Metallic chamber click + amber muzzle ring when `ammo == 1`<br>• **Shooter Slide**: `4.0 px` crisp snap<br>• **Gun Sprite Kick**: `12.0 px` back, `18°` rise + 2x Golden Muzzle Cross-Blast + glowing hot casing | • **Camera Kick**: `6.5 px` directional kick opposite aim<br>• **Hitstop**: **`0.03s` (`30ms`)** tactile impact freeze | • **Hit-Flash**: `0.10s` `#FFFFFF` -> `#FFB800` gold tint<br>• **Knockback**: **`28.0 px` impulse** along bullet vector<br>• **Stagger**: **`+0.25s` delay** added to enemy `fire_cd`<br>• **Popup**: `1.35x` scaled Gold **`★尾弹暴击!`** |
| **3. Heavy Spender (`RMB` 45/65/90⚡)**<br>*(右键重火器轰击)* | • **Shooter Physical Recoil Slide**: Pushes player opposite `aim_dir` over `0.08s`:<br>  - Light (`45⚡` Swarm): **`8.0 px`** slide<br>  - Medium (`65⚡` Railgun): **`16.0 px`** slide<br>  - Ultimate (`90⚡` Black Hole): **`22.0 px`** slide<br>• **Body Squash**: `0.80x × 1.18x` spring + foot dust ring | • **Camera Kick**: **`12.0–18.0 px`** directional punch + `1.03x` zoom pulse<br>• **Hitstop**: **`0.045s–0.055s`** heavy freeze | • **Hit-Flash**: `0.14s` electric cyan/violet flash<br>• **Knockback**: **`45.0 px` heavy slam** (or continuous vortex pull for Black Hole)<br>• **Stagger**: **`+0.45s` delay** (or instant Weak-Point Interrupt on Elites/Bosses)<br>• **Kill Ragdoll Debris**: 12 metal parts blasted in a `45°` cone along `aim_dir` at `220–340 px/s` |

   - **Safe Shooter Recoil Rule**: The `8.0–22.0 px` shooter recoil slide on `RMB` Heavy Weapons clamps cleanly against arena walls and deployed shields and **never** pushes the player into out-of-bounds hazards or overrides active `Space` dodge-roll I-frames.
4. **Discrete Player Survival, Overcharge Aegis Shield (3-Pip Active Recharge) & Shield-Piercing Attacks**:
   - Player health is discrete: **`max_hp = 6` Hearts (`❤️`)** + **`max_aegis_shield = 1` Overcharge Aegis Shield (`🛡️`)** (expandable to `2` via defensive Relics/Forge).
   - **No Free Room Refill — Earned via 3 Aegis Charge Pips (`[□][□][□]`)**:
     - Once the Overcharge Aegis Shield breaks (`0/1 🛡️`), it **does NOT automatically refill on entering the next room**.
     - Instead, while `aegis_shield < max_aegis_shield` during active combat, the player earns **Aegis Charge Pips (`aegis_pips`, `0..3`)** through aggressive mastery:
       1. Unleashing any **`RMB` Heavy Spender (`>= 45⚡`)** $\rightarrow$ **`+1` Pip**;
       2. Triggering an **Elite / Boss Weak-Point Interrupt** $\rightarrow$ **`+1` Pip**;
       3. Completing **3 `[R]` Perfect Reloads** within active combat $\rightarrow$ **`+1` Pip**.
     - Reaching **`3/3` Pips** immediately resets `aegis_pips = 0` and reconstructs **`+1 🛡️` Overcharge Aegis Shield** with a cyan hexagonal flash!
   - **Standard Hits (`SHIELD_BLOCKABLE`) vs. Special Shield-Piercing Attacks (`SHIELD_PIERCING`)**:
     - **Standard Attacks (`is_shield_piercing == false`)**: Deduct `aegis_shield` before `hp`. Breaking a point of `aegis_shield` triggers an automatic **Aegis-Break Blank (`90.0 px` radius)** that vaporizes nearby enemy bullets and pushes enemies back `32.0 px`. **Crucially, absorbing a standard hit with `aegis_shield` (losing `0` Red Heart `hp`) PRESERVES the player's Hitless Boss clear status for the Master Chamber Core!**
     - **Special Shield-Piercing Attacks (`is_shield_piercing == true` — Un-interrupted Elite/Boss Signature Attacks, Execution Lasers & Corrupt Hazards)**: Marked visually by a jagged crimson-violet lightning rim (`#FF0055` + dark violet crackle). If the player fails to interrupt an Elite/Boss red-flash wind-up or dodge through it with `Space` I-frames, the attack **bypasses `aegis_shield` completely and deducts `-1 ❤️` directly from `hp`**, immediately disqualifying the Hitless Boss reward!
   - **Post-Hit Invulnerability (`INVULN_DURATION = 1.0s`)**: Taking any damage (Shield or HP) grants `1.0s` of blinking hurtbox invulnerability.
5. **Bullet-Clearing Synergy & Bounty Chip Drops**:
   - Whenever any player action clears enemy projectiles (`Perfect Reload` shockwave, `EMP` active item, `RMB` Black Hole, `DEPLOY_SHIELD_COVER` activation, or `EXPLOSIVE_BLAST` hazard), `BulletPool` counts the exact number of deactivated enemy bullets (`cleared_bullet_count`) and passes it to the Event Bus (triggering *Aegis Shatter Dynamo* `+28⚡` when `cleared_bullet_count >= 3`).
   - Killed enemies automatically magnet-fly **`Bounty Chips (悬赏工分币)`** to the player (`+12` Chips base, `+24` Chips under Overdrive Bet) and emit `enemy_killed` + `bounty_chips_changed`.

### States and Transitions

Each projectile slot in `BulletPool` transitions deterministically through four states:

| Projectile Slot State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`DORMANT`** | `active == false` in pool | $\rightarrow$ `IN_FLIGHT` on `_spawn_bullet()` | Zero CPU/draw cost; awaits reuse. |
| **`IN_FLIGHT`** | `active == true` inside arena bounds | $\rightarrow$ `GRAZED_IN_FLIGHT` on player Graze Ring intersect<br>$\rightarrow$ `IMPACT_RESOLVING` on actor/wall/shield hit<br>$\rightarrow$ `DORMANT` on shockwave clear | Updates position (`pos += vel * delta * cryo_mult`), performs homing/collision checks, renders at `Z = 30` (player) or `Z = 40` (enemy). |
| **`GRAZED_IN_FLIGHT`** | Enemy bullet with `grazed == true` | $\rightarrow$ `IMPACT_RESOLVING` on wall/actor hit<br>$\rightarrow$ `DORMANT` on clear | Continues flight trajectory so bullet patterns stay predictable, but cannot award a second Graze payout. |
| **`IMPACT_RESOLVING`** | Hit target or obstacle (`1 frame`) | $\rightarrow$ `DORMANT` (if `pierces == false`)<br>$\rightarrow$ `IN_FLIGHT` (if `pierces == true` and new target) | Applies damage, knockback impulse, hitstop, and hit-flash; emits `enemy_damaged` or player hurt event. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Emits `enemy_damaged`, `weakpoint_interrupted` (Elites/Bosses), `enemy_killed`, `bounty_chips_changed`; listens to bullet-clear signals | `Combat Event Bus & Data Schema` |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Bidirectional | Applies `RMB` shooter recoil slide impulse to `player_pos`; checks `in_iframes` and `ArenaInteractableData` (`DEPLOY_SHIELD_COVER`, `CRYO_SLOW_FIELD`, `PRISM_BULLET_SPLIT`) | `Player 3C, Dodge-Graze & Tactical Arena Interactables` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Upstream Producer | Spawns primary, Final Round, and Heavy Spender projectiles/beams with tier tags | `Dual-Gun, Active Reload & Overcharge Engine` |
| **Enemy AI, Elite/Boss Interrupts & Boss System** | Downstream Consumer | Receives damage, `28–45 px` knockback velocity impulses, `+0.25s–0.45s` attack stagger, and Boss DPS soft-cap evaluation | `Enemy AI, Elite/Boss Interrupts & Boss System` |

## Formulas

*(Note: `systems-designer` consulted for damage calculation, knockback impulse, and shooter recoil slide math.)*

### 1. Final Enemy Damage Calculation (`final_enemy_damage`)

The damage dealt to an enemy by any player projectile, beam, or hazard is defined as:

`final_enemy_damage = base_damage * (1.0 + (final_round_mult - 1.0) * int(is_final_round)) * (1.0 + PERFECT_RELOAD_DMG_BONUS * int(perfect_reload_buff_timer > 0.0)) * (1.0 + passive_damage_bonus)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `base_damage` | float | `8.0–95.0` | data file | Base damage of the weapon or hazard (`18.0` Revolver, `9.0` SMG, `95.0` Railgun) |
| `final_round_mult` | float | `1.5–4.0` | data file | Final Round damage multiplier (`2.5` for Revolver, `1.9`x3 for SMG, `* 1.6` with *Omega Firing Pin* passive) |
| `is_final_round` | bool | `true/false` | calculated | True when the projectile was fired as the last round in the magazine (`ammo == 1` pre-shot) |
| `PERFECT_RELOAD_DMG_BONUS` | float | `0.25` | data file | `+25%` damage buff granted for `2.5s` after a Perfect Reload |
| `perfect_reload_buff_timer` | float | `0.0–2.5` | calculated | Remaining duration of the active Perfect Reload buff |
| `passive_damage_bonus` | float | `0.0–1.0` | calculated | Additive damage bonus from equipped Passive Relics |

**Output Range:** `8.0` (unbuffed SMG pellet) to `195.0+` (buffed Revolver Final Round with *Omega Firing Pin*).
**Example:** Player fires the Peacemaker Revolver's **Final Round** (`base_damage = 18.0`, `final_round_mult = 2.5`, `is_final_round = true`) while `perfect_reload_buff_timer = 1.4s` (`+25%`) and *Omega Firing Pin* (`+60%` to Final Round -> `final_round_mult = 4.0`). `final_enemy_damage = 18.0 * 4.0 * 1.25 * 1.0 = 90.0` damage!

---

### 2. Enemy Knockback & Stagger Impulse (`enemy_knockback_distance`)

To make Final Rounds and Heavy Weapons feel physically devastating, enemy knockback displacement upon hit is defined as:

`enemy_knockback_distance = (KB_STANDARD * int(tier == 1) + KB_FINAL_ROUND * int(tier == 2) + KB_HEAVY_WEAPON * int(tier == 3)) * (1.0 - enemy_knockback_resistance)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `tier` | int | `1–3` | calculated | Ballistic tier (`1` = Standard Primary, `2` = Final Round, `3` = Heavy Spender) |
| `KB_STANDARD` | float | `4.0` | data file | Micro-jitter knockback (pixels) for normal primary hits |
| `KB_FINAL_ROUND` | float | `28.0` | data file | Heavy knockback (pixels) for Final Round hits (paired with `+0.25s` stagger) |
| `KB_HEAVY_WEAPON` | float | `45.0` | data file | Massive slam knockback (pixels) for `RMB` Heavy Weapon hits (paired with `+0.45s` stagger) |
| `enemy_knockback_resistance` | float | `0.0–0.85` | data file | Archetype resistance (`0.0` for Burst Bot, `0.4` for Elites, `0.85` for Bosses) |

**Output Range:** `0.6 px` to `45.0 px` displacement along projectile direction over `0.10s`.
**Example:** Hitting a Burst Bot (`enemy_knockback_resistance = 0.0`) with a **Final Round** (`tier = 2`) knocks it back `28.0 * (1.0 - 0.0) = 28.0 px` and delays its next attack by `0.25s`. Hitting it with the `65⚡` Railgun (`tier = 3`) slams it back `45.0 px`.

---

### 3. Shooter Physical Recoil Slide (`shooter_recoil_slide_px`)

When the player fires a Final Round or `RMB` Heavy Spender, the backward physical slide applied to the player over `0.08s` is defined as:

`shooter_recoil_slide_px = (RECOIL_FINAL_ROUND * int(is_final_round) + (RECOIL_HEAVY_LIGHT * int(heavy_cost == 45.0) + RECOIL_HEAVY_MED * int(heavy_cost == 65.0) + RECOIL_HEAVY_ULT * int(heavy_cost == 90.0)) * int(is_heavy_shot)) * int(not is_dodging)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `RECOIL_FINAL_ROUND` | float | `4.0` | data file | Crisp backward snap (pixels) when firing a Primary Final Round |
| `RECOIL_HEAVY_LIGHT` | float | `8.0` | data file | Backward slide (pixels) when firing a `45⚡` Light Heavy Weapon |
| `RECOIL_HEAVY_MED` | float | `16.0` | data file | Backward slide (pixels) when firing a `65⚡` Medium Heavy Weapon (Railgun) |
| `RECOIL_HEAVY_ULT` | float | `22.0` | data file | Backward slide (pixels) when firing a `90⚡` Ultimate Heavy Weapon (Black Hole) |
| `is_dodging` | bool | `true/false` | calculated | Suppresses recoil slide if the player is currently mid-dodge roll |

**Output Range:** `0.0 px` (standard shot or mid-dodge) to `22.0 px` (Ultimate `90⚡` Heavy shot), clamped safely against walls and cover.
**Example:** Player fires the `65⚡` Superconductor Railgun (`heavy_cost = 65.0`, `is_heavy_shot = true`, `is_dodging = false`). The player slides backward `16.0 px` opposite `aim_dir` over `0.08s` with foot-dust particles and a `15.0 px` directional camera kick.

## Edge Cases

- **If all 800 slots in `BulletPool` are active simultaneously**: The pool recycles the oldest `IN_FLIGHT` enemy projectile furthest from `player_pos` rather than dropping a newly fired player `Final Round` or `RMB` Heavy projectile, ensuring player attacks never fail to spawn.
- **If a piercing `Final Round` passes through multiple enemies in a single frame**: To prevent `hitstop_timer` (`0.03s`) from stacking additively into a `0.30s` freeze when piercing 10 enemies, `hitstop_timer` uses `maxf(current_hitstop, new_hitstop)` rather than addition.
- **If `shooter_recoil_slide_px` pushes the player against a solid wall, deployed shield, or pit edge**: The slide vector is clamped per-axis against arena bounds and cover collision boxes (`ARENA_RECT` + cover `Rect2`), preventing the player from ever clipping into walls or falling into hazards from their own gun recoil.
- **If an enemy is knocked back (`28.0–45.0 px`) into another enemy or arena wall**: The enemy clamps against `ARENA_RECT` and transfers a `10.0 px` secondary bump to any overlapping enemy without overlapping sprite centers.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Emits `enemy_damaged`, `weakpoint_interrupted`, `enemy_killed`, `bounty_chips_changed` |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Depends on (Upstream) | Hard | Reads `player_pos`, `in_iframes`, `effective_graze_radius`, and applies `shooter_recoil_slide_px` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depended on by (Downstream) | Hard | Calls `_spawn_bullet()` and `HITSCAN_RAIL_BEAM` with Ballistic Tier `1 / 2 / 3` parameters |
| **Enemy AI, Elite/Boss Interrupts & Boss System** | Depended on by (Downstream) | Hard | Receives damage, knockback impulses, and `+0.25s–0.45s` stagger delays |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 4, 8, and 9.)*

- **Ballistic Tier Visual Escalation**:
  - **Tier 1 (Standard `LMB`)**: `5.0 px` cyan projectile with `#FFFFFF` core (`Z = 30`); `9.0 px` muzzle flash (`0.05s`); standard brass shell casing (`6×3px` at `Z = 5`).
  - **Tier 2 (`Final Round`)**: `8.0–9.0 px` glowing Amber Gold (`#FFB800`) elongated slug/fan with trailing embers; **2x Golden Cross Muzzle Blast (`18.0 px`)**; oversized glowing red-hot shell casing (`8×4px`); golden shock-ring on enemy impact.
  - **Tier 3 (`RMB` Heavy Spender)**: `24.0 px` wide Railgun hyper-beam or `125.0 px` Black Hole vortex (`Z = 10`, `Alpha <= 45%`); directional foot-dust puff under player during the `8–22 px` recoil slide; 12 high-velocity metallic debris chunks blasted along `aim_dir` on enemy kill.
- **Audio Cues**:
  - `sfx_weapon_shoot.wav` (Tier 1 crisp transient), `sfx_weapon_final_round.wav` (Tier 2 metallic cannon ring + heavy punch), `sfx_weapon_heavy_fire.wav` (Tier 3 sub-bass plasma boom), `sfx_combat_hit.wav` (meaty impact tick).

📌 **Asset Spec** — Visual/Audio requirements are defined for all 3 Ballistic Tiers.

## Game Feel

- **Distinct Weight Between Light, Final, and Heavy Shots**: A player firing with eyes closed or audio muted can immediately feel the difference between a standard shot (`0 px` slide, `0s` hitstop), a Final Round (`4 px` snap, `0.03s` hitstop, `28 px` enemy knockback + stagger), and a Heavy Weapon (`8–22 px` shooter recoil slide, `0.05s` hitstop, `45 px` slam).
- **Fair Survival Cushion**: The `90.0 px` Armor-Break Blank and `1.0s` post-hit invulnerability ensure getting clipped once in a dense bullet curtain feels like a recoverable wake-up call rather than an instant stun-lock death.

## UI Requirements

- **Floating Damage & Crit Callouts (`Z = 50`)**:
  - Standard hits display clean `14px` white numbers (`-18`).
  - Final Round, Heavy Weapon, and Elite/Boss Interrupt hits display scaled `18px` Gold/Cyan numbers with an impact shake (`★暴击 -90!`).

> **📌 UX Flag — Pooled Bullet-Hell & Damage System**: Floating combat damage numbers and Armor/HP indicators are specified in `design/gdd/tactical-micro-hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `enemy_damaged`, `weakpoint_interrupted`, `enemy_killed`, `bounty_chips_changed` | Yes — exact signal signatures match |
| `design/gdd/player-3c-controller.md` | `PLAYER_HURTBOX_RADIUS` (`14.0 px`), `BASE_GRAZE_RADIUS` (`42.0 px`), `ArenaInteractableData` | Yes — collision radii and interactable hooks match |
| `design/art/art-bible.md` | Section 8 (`Z = 10` Alpha `<= 45%`, `Z = 30` Player Bullets, `Z = 40` Enemy Threats) | Yes — Z-index contract strictly enforced |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** 500 enemy projectiles and 150 player projectiles are active simultaneously in `BulletPool`, **WHEN** updated over 300 consecutive frames, **THEN** `0` runtime node `instantiate()` or `queue_free()` calls occur and frame time remains `<= 16.67ms` (`60+ FPS`).
- **GIVEN** the player fires a Primary **Final Round** (`tier = 2`) that hits a Burst Bot (`enemy_knockback_resistance = 0.0`), **WHEN** impact resolves, **THEN** `hitstop_timer` is set to `0.03s`, the enemy is knocked back `28.0 px` along the projectile vector, and the enemy's `fire_cd` is delayed by `+0.25s`.
- **GIVEN** the player fires a `65⚡` Medium or `90⚡` Ultimate `RMB` Heavy Weapon while not dodging, **WHEN** the shot unleashes, **THEN** the player character slides backward `16.0 px` (`65⚡`) or `22.0 px` (`90⚡`) opposite `aim_dir` over `0.08s` without clipping through arena walls or cover.
- **GIVEN** the player has `aegis_shield = 1` (`0/3` Pips) and `hp = 6`, **WHEN** hit by a standard enemy projectile (`is_shield_piercing == false`), **THEN** `aegis_shield` becomes `0`, `hp` remains `6` (preserving Boss Hitless eligibility), enemy bullets within `90.0 px` are cleared, and `aegis_shield` remains `0` across room transitions until the player earns `3/3` Aegis Charge Pips via Heavy casts, Interrupts, or 3x Perfect Reloads.
- **GIVEN** the player has `aegis_shield = 1` and `hp = 6`, **WHEN** hit by an un-interrupted Elite/Boss signature attack flagged `is_shield_piercing == true`, **THEN** the attack bypasses `aegis_shield` (`aegis_shield` remains `1`), deducts `-1` directly from `hp` (`hp` becomes `5`), and voids Boss Hitless eligibility.

## Open Questions

- *None — object pool capacity, 3-Tier Ballistic Impact & Recoil math, and Armor/HP survival rules are locked.*
