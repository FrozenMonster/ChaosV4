# Dual-Gun, Active Reload & Overcharge Engine

> **Status**: Approved
> **Author**: user + game-designer + systems-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Defines the core 30-second combat loop engine: infinite-ammo `LMB` Primary Weapons differentiated by **weapon-specific Active Reload sweet-spot zones (`[R]`), unique Final Round projectiles, and weapon-specific Perfect Reload Signature Buffs**, paired with a mathematically calibrated **Two-Tier Overcharge Economy (`72–100⚡` expected yield per standard combat room)** that fuels **1 to 2 casts per room** of instant `RMB` Heavy Spender weapons (`45⚡ / 65⚡ / 90⚡`).

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Combat Event Bus & Data Schema`, `Player 3C, Dodge-Graze & Tactical Arena Interactables`, `Pooled Bullet-Hell & Damage System`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Dual-Gun, Active Reload & Overcharge Engine** is the mechanical heart of **CHAMBER OVERDRIVE (膛室超载)**. It replaces passive ammo scavenging and boring reload downtime with a high-voltage rhythm loop built on two core innovations:
1. **Weapon-Specific Active Reload Profiles & Signature Buffs (`LMB` + `[R]`)**: Every Primary Weapon has infinite reserve ammo, a distinct magazine cadence, a unique **Final Round** when firing the last chambered bullet (`ammo == 1`), a **custom Active Reload sweet-spot placement/width** on the overhead slider, and a **weapon-specific Perfect Reload Signature Perk**. Switching from a Revolver to a Twin-SMG or Pump-Shotgun fundamentally changes both when you tap `[R]` and what offensive buff you gain for the next `2.5s`.
2. **Calibrated "1–2 Overcharge Actions Per Room" Economy (`0–100⚡` -> `RMB` Heavy Spenders)**: Tier-1 universal combat skills (hits, Final Rounds, Perfect Reloads, Dodge Grazing, and Elite/Boss Interrupts) and Tier-2 pluggable **Dynamo Cores** are strictly calibrated so a standard 20-second medium-density room yields **`72⚡–100⚡` total Overcharge**. Combined with tiered `RMB` Heavy Weapon costs (**`45⚡` Light / `65⚡` Medium / `90⚡` Ultimate**), multi-second heavy cooldowns, and a strict **Zero Out-of-Combat Farming** rule, players are guaranteed **1 to 2 devastating Heavy Weapon casts (or 1 Heavy cast + 1 Door Overdrive Bet) per room**—never starving, yet never mindlessly spamming.

## Detailed Design

*(Note: `game-designer` and `systems-designer` consulted for weapon archetype differentiation and the per-room Overcharge budget model.)*

### Core Rules

1. **Primary Weapon Archetypes: Custom Reload Windows, Final Rounds & Signature Buffs (`LMB` + `[R]`)**:
   - Each `PrimaryWeaponData` resource defines its own magazine size, reload duration, sweet-spot position (`sweet_spot_start` to `sweet_spot_end`), Final Round behavior (`ammo == 1`), and **Perfect Reload Signature Buff (`2.5s` duration)**:

| Primary Weapon (主武器原型) | Mag & Reload Time | Active Reload Sweet-Spot Profile (`[R]` 换弹条甜区特征) | Final Round (`ammo == 1` 专属尾弹) | Perfect Reload Signature Buff (`[R]` 专属完美换弹 Buff — `2.5s`) |
| :--- | :--- | :--- | :--- | :--- |
| **1. Peacemaker Revolver**<br>*(「维和者」重型左轮)* | `6 Rounds`<br>`1.15s` Reload | **Mid-Bar Balanced Zone (`0.42–0.62`, Width `20%`)**:<br>Classic rhythmic cylinder-snap cadence. | **Piercing High-Explosive Slug (`2.5x` DMG)**:<br>Pierces all enemies in line + `28px` knockback + `0.03s` hitstop. | **【快枪手凝神 (Gunslinger Focus)】**:<br>Next **2 shots are guaranteed Crits (`+40%` DMG)** with **2x projectile speed** (`1640 px/s` near-hitscan) + `85px` bullet-clear ring. |
| **2. Vector Twin-SMG**<br>*(「矢量」双持冲锋枪)* | `16 Rounds`<br>`0.95s` Reload | **Early-Bar Speed Zone (`0.22–0.40`, Width `18%`)**:<br>Fast snap-mag tap immediately after clip empties. | **Triple Shock-Fan Burst (`3 × 1.8x` DMG)**:<br>Fires 3 wide arc-lightning bolts that stagger (`+0.25s`) hit enemies. | **【超频狂飙 (Overclock Cadence)】**:<br>Firing cadence increases by **`+35%` fire rate** with **`0.0°` spread (laser-tight accuracy)** for `2.5s` + `85px` bullet-clear ring. |
| **3. Bailiff Pump-Shotgun**<br>*(「催收员」重型泵动霰弹)* | `4 Rounds`<br>`1.35s` Reload | **Late-Bar Heavy Zone (`0.65–0.81`, Width `16%`)**:<br>Deliberate, narrower late-bar pump requiring composure under fire. | **Dragon's Breath Concussion Slug (`2.8x` DMG)**:<br>Heavy blast cone + `36px` knockback + `0.03s` hitstop. | **【膛压过载震波 (Kinetic Blast Wave)】**:<br>Expands the instant Perfect Reload bullet-clear & knockback shockwave to **`125px` radius** (`25.0` AoE damage) and adds **`+3` bonus pellets** to the next shot. |

2. **Three-Outcome Active Reload Resolution (`[R]`)**:
   - **Perfect Reload (`sweet_spot_start <= progress <= effective_sweet_end`)**: Instantly completes reload (`0.0s` remaining), refills magazine, grants **`+8.0⚡` Overcharge** (if in active combat), activates the weapon's **Signature Buff for `2.5s`**, and emits `perfect_reload_triggered`.
   - **Normal Reload (No `[R]` input; bar reaches `1.0`)**: Refills magazine at standard `reload_time` with no bonus and no penalty.
   - **Jammed Reload (`[R]` pressed outside sweet spot)**: Locks out further `[R]` attempts for this reload cycle, reduces remaining reload speed by **`32%` (`JAM_SPEED_PENALTY = 0.32`)**, and emits `reload_jammed`.
3. **Calibrated Two-Tier Overcharge Economy (`0–100⚡` Cap — Target: `72–100⚡` Per Room)**:
   - **Strict Anti-Farming Rule (脱战零充能铁律)**: Overcharge energy can **only** be generated while `room_cleared == false` and at least 1 hostile enemy is alive in the room. Firing into empty air or performing Perfect Reloads out of combat grants `0.0⚡`.
   - **Tier 1: Risk-Weighted Universal Base Actions**:

| Tier-1 Action (基础充能动作) | Overcharge Yield (`⚡`) | Cooldown / Anti-Spam Rule (防刷爆限制) | Expected Triggers / Room (`20s` 房间期望) | Expected Room Yield (`⚡`) |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Firing Hit (`Normal Hit`)** | **`+0.5⚡`** | Awarded once per firing action that hits $\ge 1$ enemy (multi-pellet shotgun/SMG bursts do not multiply per pellet) | `~24` landed shots | **`+12.0⚡`** |
| **Final Round Hit (`Final Round`)** | **`+4.0⚡`** | Requires emptying clip (`ammo == 1`) and hitting an enemy | `3` clips emptied | **`+12.0⚡`** |
| **Perfect Active Reload (`[R]`)** | **`+8.0⚡`** | Only awarded during active combat (`room_cleared == false`) | `2–3` Perfect Reloads | **`+16.0⚡ – +24.0⚡`** |
| **Dodge-Roll Graze (`Space`)** | **`+10.0⚡`** | Max `2` grazes per roll (`+20.0⚡` cap) + `0.80s` post-graze recharge cooldown | `2–3` grazed bullets | **`+20.0⚡ – +30.0⚡`** |
| **Elite / Boss Weak-Point Interrupt** | **`+22.0⚡`** | **Exclusive to Elites & Bosses** during red-flash wind-ups (replaces mob multi-kill income in single-target Boss fights) | `0` in mob rooms / `1–2` in Elite/Boss rooms | **`0⚡` (Mob) / `+22–44⚡` (Boss)** |

   - **Tier 2: Difficulty-Weighted Pluggable Dynamo Cores (`DynamoCoreData` — 1 Equipped Slot)**:

| Dynamo Core (充能核心流派) | Difficulty Tier | Trigger Condition | Overcharge Burst (`⚡`) | Internal Cooldown | Expected Room Yield (`⚡`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Rampage Dynamo**<br>*(狂暴连杀核心)* | **Easy** | Kill an enemy within `3.0s` of a previous kill | **`+6.0⚡`** | `1.5s` | **`+12.0⚡ – +18.0⚡`** (2–3 chain kills) |
| **2. Aegis Shatter Dynamo**<br>*(神盾碎弹核心)* | **Medium** | Clear $\ge 3$ enemy bullets at once via Perfect Reload shockwave, `[Q]` EMP, or Shield deploy | **`+14.0⚡`** | `2.5s` | **`+14.0⚡ – +28.0⚡`** (1–2 bullet clears) |
| **3. Tactical Saboteur Dynamo**<br>*(战术机关/爆破核心)* | **Hard** | Hit or affect an enemy using any **Tactical Arena Interactable** (Fuel Drum, Cryo Tank, Prism, Capacitor) | **`+22.0⚡`** | `3.0s` | **`+22.0⚡`** (1–2 arena interactables per room) |

   - **Total Expected Room Yield**: **`12 + 12 + 20 + 20 + 18 = ~82⚡` per room** (ranging from **`72⚡` to `100⚡`** depending on player execution).
4. **Instant `RMB` Cost-Tiered Heavy Spenders (Calibrated for 1–2 Casts Per Room)**:
   - Pressing **Right Mouse Button (`RMB`)** fires the equipped Heavy Weapon immediately without weapon-swap delay, deducting its `overcharge_cost`, applying shooter physical recoil slide (`8 / 16 / 22 px`), and entering a dedicated **`heavy_fire_cooldown`** so even with full energy, Heavy Weapons cannot be machine-gun spammed:

| Heavy Weapon (`RMB` 重火器) | Tier & Cost (`⚡`) | Cooldown (`heavy_cd`) | Casts Per Room (at `~82⚡` Yield) | Combat Behavior & Role |
| :--- | :--- | :--- | :--- | :--- |
| **1. Swarm Micro-Missiles**<br>*(蜂群微型导弹)* | **Light Tactical**<br>**`45.0⚡`** | **`2.5s`** | **1–2 Casts / Room** | Launches 5 homing missiles (`34.0` DMG each, `8.0 px` shooter recoil slide) to clean up scattered flankers. |
| **2. Superconductor Railgun**<br>*(超导电磁轨道炮)* | **Medium Burst**<br>**`65.0⚡`** | **`3.5s`** | **1 Cast / Room**<br>*(2 if entering with surplus)* | Instant full-screen piercing beam (`95.0` DMG, `16.0 px` shooter recoil slide, `0.045s` hitstop); instantly interrupts Elite/Boss wind-ups. |
| **3. Singularity Black Hole**<br>*(奇点坍缩黑洞炮)* | **Ultimate Warper**<br>**`90.0⚡`** | **`5.0s`** | **1 Ultimate Cast / Room** | Spawns a `3.2s` gravitational vortex (`22.0 px` shooter recoil slide, `0.055s` hitstop) that pulls all enemies together and devours enemy bullets within `150.0 px`. |

### States and Transitions

| Weapon & Reload State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`READY_TO_FIRE`** | `ammo > 0` and `not is_reloading` | $\rightarrow$ `FIRING_COOLDOWN` on `LMB` (`ammo > 1`)<br>$\rightarrow$ `ACTIVE_RELOAD_SLIDING` on `LMB` Final Round (`ammo == 1`) or manual `[R]` | `LMB` fires primary (`+0.5⚡` on hit); `RMB` fires Heavy Spender anytime if `overcharge >= cost` and `heavy_cd <= 0.0`. |
| **`FIRING_COOLDOWN`** | `0.0 < fire_cd <= fire_interval` | $\rightarrow$ `READY_TO_FIRE` when `fire_cd <= 0.0` | Enforces weapon cadence (`0.20s` Revolver, `0.09s` SMG, `0.48s` Shotgun); modified by Overclock buff (`+35%` rate). |
| **`ACTIVE_RELOAD_SLIDING`** | `is_reloading == true` and `not reload_jammed` | $\rightarrow$ `READY_TO_FIRE` (with `2.5s` Signature Buff + `+8⚡`) on sweet-spot `[R]`<br>$\rightarrow$ `RELOAD_JAMMED` on missed `[R]`<br>$\rightarrow$ `READY_TO_FIRE` when `reload_progress >= 1.0` | Overhead slider moves `0.0 -> 1.0` over `reload_time`. Player can `Space` dodge-roll or fire `RMB` Heavy Weapon without interrupting the reload bar. |
| **`RELOAD_JAMMED`** | `is_reloading == true` and `reload_jammed == true` | $\rightarrow$ `READY_TO_FIRE` when `reload_progress >= 1.0` | Slider speed reduced by `32%`; further `[R]` inputs ignored until reload finishes. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Emits `primary_weapon_fired`, `final_round_fired`, `perfect_reload_triggered`, `reload_jammed`, `heavy_weapon_unleashed`, `overcharge_changed` | `Combat Event Bus & Data Schema` |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Upstream Producer | Receives `dodge_graze_triggered` (`+10.0⚡`) and `interactable_triggered` (`+22.0⚡` with Saboteur Dynamo) | `Player 3C, Dodge-Graze & Tactical Arena Interactables` |
| **Pooled Bullet-Hell & Damage System** | Bidirectional | Spawns Tier 1/2/3 projectiles; receives `enemy_damaged` (`+0.5⚡` / `+4.0⚡`), `weakpoint_interrupted` (`+22.0⚡`), and `cleared_bullet_count` | `Pooled Bullet-Hell & Damage System` |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Downstream Consumer | Deducts `-25.0⚡` when player presses `[F]` to lock an Overdrive Bet on a door; sets `room_cleared` flag to gate out-of-combat charging | `3-Door Routing, Overdrive Bet & Floor Generator` |

## Formulas

*(Note: `systems-designer` consulted for the per-room Overcharge balance equation and weapon-specific reload math.)*

### 1. Expected Single-Room Overcharge Yield & Heavy Cast Ratio (`expected_heavy_casts_per_room`)

To guarantee that a player in a standard combat room can unleash **1 to 2 Overcharge actions** without spamming, the net room Overcharge generation `room_overcharge_generated` and resulting `expected_heavy_casts_per_room` are defined as:

`room_overcharge_generated = (N_hits * CHARGE_NORMAL_HIT + N_finals * CHARGE_FINAL_ROUND + N_reloads * CHARGE_PERFECT_RELOAD + N_grazes * CHARGE_DODGE_GRAZE + N_interrupts * CHARGE_INTERRUPT + N_dynamo * dynamo_bonus) * int(not room_cleared)`

`expected_heavy_casts_per_room = room_overcharge_generated / heavy_weapon_cost`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `CHARGE_NORMAL_HIT` | float | `0.5` | data file | Overcharge gained per primary firing action that hits an enemy (`N_hits ~ 24` per room -> `12.0⚡`) |
| `CHARGE_FINAL_ROUND` | float | `4.0` | data file | Overcharge gained per Final Round hit (`N_finals ~ 3` per room -> `12.0⚡`) |
| `CHARGE_PERFECT_RELOAD` | float | `8.0` | data file | Overcharge gained per combat Perfect Reload (`N_reloads ~ 2.5` per room -> `20.0⚡`) |
| `CHARGE_DODGE_GRAZE` | float | `10.0` | data file | Overcharge gained per grazed bullet (`N_grazes ~ 2.0` per room -> `20.0⚡`) |
| `CHARGE_INTERRUPT` | float | `22.0` | data file | Overcharge gained per Elite/Boss Weak-Point Interrupt (`0` in mob room, `1–2` in Boss room) |
| `dynamo_bonus` | float | `6.0–22.0` | data file | Tier-2 Dynamo Core burst (`+6.0` Easy, `+14.0` Medium, `+22.0` Hard; `~18.0⚡` per room) |
| `heavy_weapon_cost` | float | `45.0–90.0` | data file | Energy cost of equipped `RMB` Heavy Spender (`45.0` Light, `65.0` Medium, `90.0` Ultimate) |

**Output Range:** `room_overcharge_generated` ranges from **`72.0⚡` to `100.0⚡`** in a standard 20-second combat room (`~82.0⚡` median), yielding **`expected_heavy_casts_per_room = 0.91` to `1.82` casts per room**.
**Example:** In a standard room, a player lands 24 primary hits (`12⚡`), 3 Final Rounds (`12⚡`), 2 Perfect Reloads (`16⚡`), 2 Dodge Grazes (`20⚡`), and 1 Saboteur Dynamo barrel hit (`22⚡`) -> `room_overcharge_generated = 82.0⚡`.
- With **Light Swarm Missiles (`45⚡`)**: `82.0 / 45.0 = 1.82` -> **1–2 casts per room**.
- With **Medium Railgun (`65⚡`)**: `82.0 / 65.0 = 1.26` -> **1 cast per room** (plus `17⚡` carry-over toward an Overdrive Door Bet).
- With **Ultimate Black Hole (`90⚡`)**: `82.0 / 90.0 = 0.91` -> **1 cast per room** when combined with `>= 8⚡` carry-over or 1 extra Perfect Reload!

---

### 2. Weapon-Specific Active Reload Progress & Sweet-Spot Window (`reload_step` & `is_sweet_spot_hit`)

Each frame during `ACTIVE_RELOAD_SLIDING`, slider progression and sweet-spot validation are defined as:

`reload_step = (delta / weapon_reload_time) * (1.0 - JAM_SPEED_PENALTY * int(reload_jammed))`

`is_sweet_spot_hit = int(reload_progress >= weapon_sweet_start and reload_progress <= min(0.92, weapon_sweet_end + passive_sweet_bonus))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `weapon_reload_time` | float | `0.95–1.35` | data file | Weapon-specific reload duration (`0.95s` SMG, `1.15s` Revolver, `1.35s` Shotgun) |
| `JAM_SPEED_PENALTY` | float | `0.32` | data file | `32%` reload speed reduction when `[R]` is pressed outside the sweet spot |
| `weapon_sweet_start` | float | `0.22–0.65` | data file | Weapon-specific sweet-spot start (`0.22` SMG early, `0.42` Revolver mid, `0.65` Shotgun late) |
| `weapon_sweet_end` | float | `0.40–0.81` | data file | Weapon-specific sweet-spot end (`0.40` SMG, `0.62` Revolver, `0.81` Shotgun) |
| `passive_sweet_bonus` | float | `0.0–0.08` | calculated | Bonus window width from *Chrono Slide-Stop* passive (`+8%` width) |

**Output Range:** `is_sweet_spot_hit` evaluates to `1` (Perfect Reload) or `0` (Jammed Reload).
**Example:** Firing the **Vector Twin-SMG** (`weapon_reload_time = 0.95s`, early sweet spot `0.22–0.40`). Tapping `[R]` at `0.28s` (`reload_progress = 0.295`) falls inside `[0.22, 0.40]` -> `is_sweet_spot_hit = 1`, instantly finishing the reload, granting `+8.0⚡`, and activating **Overclock Cadence (`+35%` fire rate, `0°` spread)** for `2.5s`.

## Edge Cases

- **If the player empties their magazine and presses `[R]` in an already cleared room (`room_cleared == true`)**: The player can still practice and trigger the **Perfect Reload** instant refill and visual flash, but **Overcharge gained is `0.0⚡`**, completely preventing out-of-combat energy farming before opening a door.
- **If the player presses `RMB` to fire a Heavy Weapon while `is_reloading == true`**: The `RMB` Heavy Weapon fires immediately without canceling or resetting the overhead Active Reload slider, allowing seamless `Final Round -> RMB Railgun -> [R] Perfect Reload` combos.
- **If a multi-pellet weapon (Pump-Shotgun with 7 pellets) hits multiple enemies on the same click**: `CHARGE_NORMAL_HIT` (`+0.5⚡`) is awarded **once per firing action** that connects with at least one enemy, preventing shotguns from generating `7x` more base energy than revolvers.
- **If the player triggers multiple Dodge Grazes within `0.80s` across back-to-back rolls**: After `MAX_GRAZE_PER_ROLL` (`2` grazes = `+20.0⚡`) is reached, a `0.80s` graze capacitor cooldown prevents consecutive stationary bullet-bumping from exceeding the room energy budget.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Uses `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData` and emits weapon/reload/overcharge signals |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Depends on (Upstream) | Hard | Supplies `dodge_graze_triggered` (`+10⚡`) and `interactable_triggered` events |
| **Pooled Bullet-Hell & Damage System** | Depends on (Upstream) | Hard | Spawns projectiles/beams and reports `enemy_damaged`, `weakpoint_interrupted`, and `cleared_bullet_count` |
| **7-Slot Loadout & Tactical Items System** | Depended on by (Downstream) | Hard | Reads equipped `Primary`, `Heavy`, `Dynamo Core`, and `Passive` modifiers |
| **Tactical Micro-HUD & Screen UI System** | Depended on by (Downstream) | Hard | Renders the weapon-specific overhead sweet-spot bar and `45 / 65 / 90⚡` Overcharge threshold ticks |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 4, 7, and 8.)*

- **Weapon-Specific Overhead Reload Bar (`Z = 50`)**:
  - The yellow sweet-spot bracket dynamically shifts position and width on the `72px` overhead bar when switching weapons (**Left-aligned `0.22–0.40`** for Twin-SMG, **Centered `0.42–0.62`** for Revolver, **Right-aligned `0.65–0.81`** for Pump-Shotgun) so the player visually reads each gun's rhythm.
- **Signature Buff Visual Auras (`2.5s` Duration)**:
  - **Gunslinger Focus (Revolver)**: Golden targeting laser sight + bright amber barrel glow.
  - **Overclock Cadence (Twin-SMG)**: Cyan electric sparks venting from dual receivers + rapid cyan tracer stream.
  - **Kinetic Blast Wave (Shotgun)**: `125px` expanding golden-cyan shockwave ring (`Z = 10`, `Alpha <= 42%`) + glowing orange pump receiver.

📌 **Asset Spec** — Visual/Audio requirements are defined for all weapon reload profiles and signature buffs.

## Game Feel

- **Every Gun Has Its Own Muscle-Memory Rhythm**: Snapping an early `0.25s` reload on the Twin-SMG feels frantic and aggressive, while waiting until `0.72s` on the Pump-Shotgun feels heavy and deliberate.
- **Earned, High-Impact Heavy Casts**: Because `RMB` Heavy Weapons happen **1 to 2 times per room** rather than every 2 seconds, pressing `RMB` to unleash a `65⚡` Railgun or `90⚡` Black Hole always feels like a room-turning climax.

## UI Requirements

- **Dynamic Sweet-Spot Bar**: Overhead `72×8px` bar renders `sweet_spot_start` and `sweet_spot_end` directly from the active `PrimaryWeaponData`.
- **Overcharge Bar Threshold Notches (`45⚡ / 65⚡ / 90⚡`)**: Perimeter Overcharge gauge displays clear tick marks at `45`, `65`, and `90` with a hydraulic bounce when the equipped Heavy Weapon's threshold is crossed.

> **📌 UX Flag — Dual-Gun, Active Reload & Overcharge Engine**: Overhead reload bar profiles and `45/65/90⚡` Overcharge threshold ticks are consolidated in `design/gdd/tactical-micro-hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData`, reload & overcharge signals | Yes — all resource fields and signal signatures match |
| `design/gdd/player-3c-controller.md` | `dodge_graze_triggered`, `MAX_GRAZE_PER_ROLL = 2` | Yes — calibrated to `+10.0⚡` per graze (`+20.0⚡` max per roll) |
| `design/gdd/bullet-hell-damage-system.md` | 3-Tier Ballistic Impact, Final Round knockback (`28px`), Heavy shooter recoil slide (`8/16/22px`) | Yes — heavy cost tiers updated to `45 / 65 / 90⚡` |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** the player equips the Peacemaker Revolver (`0.42–0.62`), Vector Twin-SMG (`0.22–0.40`), or Bailiff Pump-Shotgun (`0.65–0.81`), **WHEN** `reload_started` fires, **THEN** the overhead sweet-spot zone matches that weapon's exact `[start, end]` range and triggering a Perfect Reload applies that weapon's unique Signature Buff (*Gunslinger Focus*, *Overclock Cadence*, or *Kinetic Blast Wave*) for `2.5s`.
- **GIVEN** a standard combat room (`room_cleared == false`) where the player performs 24 primary hits (`+12⚡`), 3 Final Round hits (`+12⚡`), 2 Perfect Reloads (`+16⚡`), 2 Dodge Grazes (`+20⚡`), and 1 Saboteur Dynamo trigger (`+22⚡`), **THEN** total Overcharge generated equals `82.0⚡`, allowing `1` cast of a `65⚡` Medium Heavy Weapon or `1` cast of a `45⚡` Light Heavy Weapon plus a `25⚡` Overdrive Door Bet.
- **GIVEN** all enemies in the room are dead (`room_cleared == true`), **WHEN** the player fires primary shots and performs a Perfect Reload, **THEN** `overcharge_changed` delta equals `0.0⚡` (zero out-of-combat farming).
- **GIVEN** the player has `100.0⚡` Overcharge and fires the `45.0⚡` Light Heavy Weapon (`heavy_cd = 2.5s`), **WHEN** the player presses `RMB` again `0.5s` later (`55.0⚡` remaining), **THEN** the shot is blocked until the `2.5s` cooldown expires.

## Open Questions

- *None — weapon-specific reload profiles, signature buffs, and the `72–100⚡` per-room Overcharge budget (`45/65/90⚡` Heavy costs) are locked.*
