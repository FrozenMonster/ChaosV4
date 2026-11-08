# 3-Door Routing, Overdrive Bet & Floor Generator

> **Status**: Approved
> **Author**: user + level-designer + systems-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 2 (Action Fuels Firepower), Pillar 4 (Zero-Filler High-Stakes Routing)

## Summary

Governs the zero-backtrack node-graph floor generator featuring **Hades-style natural exit framing across 5 non-rectangular room silhouettes**, **4 Differentiated Room Objective Modes (`EXTERMINATION`, `SABOTAGE_BEACONS`, `OVERDRIVE_SURVIVAL`, `CONDUIT_UPLOAD`)** with instant room-clear shockwave wipes, **1 to 3 spatially distributed exit doors** drawn from the **3 Core Door Categories (Armory, Tactical Items, Random Event / Pit-Stop)**, pre-door **`[F]` Overdrive Betting (`-25.0⚡`)**, and seamless progression from **Floors 1–3 (Bait Contract)** through **Stratum 10 (Sample Y Heart)** into the **Endless Overdrive Loop (`Floor 11 -> ∞`)**.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Dual-Gun, Active Reload & Overcharge Engine`, `7-Slot Loadout & Tactical Items System`, `Enemy AI, Elite/Boss Interrupts & Boss System`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**3-Door Routing, Overdrive Bet & Floor Generator** is the macro-pacing and spatial variety engine of **CHAMBER OVERDRIVE (膛室超载)**. Serving **Pillar 4 (Zero-Filler High-Stakes Routing)**, it eliminates empty-room backtracking and key-starvation RNG while avoiding the monotony of identical rectangular box rooms:
1. **Varied Arena Silhouettes & Spatially Distributed Exit Sockets (1–3 Doors)**: Combat rooms are selected from handcrafted non-uniform geometric templates (**Standard Chamber, L-Bend Corridor, Central Ring-Pit, Twin-Bridge Span, Irregular Cavern**). Exit doors are **not** forced into a static row on the top wall; instead, each room template places **`DoorSocket` anchors** naturally along its North, East, West, or corner wings, activating **1, 2, or 3 exits** depending on the node's position in the stratum graph (with off-screen directional neon indicators guiding the player to distant exits on room clear).
2. **3 Core Door Categories + Pre-Door Overdrive Bet (`[F]` `-25.0⚡`)**: Every exit door previews its reward category (**Armory Door**, **Tactical Item Door**, or **Random Event / Pit-Stop Door**). Before entering a combat door, the player can wager **`25.0⚡` surplus Overcharge** to clamp an **Overdrive Bet** onto the lock—spawning an Elite or hazard modifier in the next room in exchange for **2x Bounty Chips** and a **2-Choice High-Tier Reward Crate** (while consecutive bets draw the attention of ambushing Rival Boss *Vesper the Quota-Queen*).
3. **3-Tier Campaign & Endless Loop Scalability (`Floors 1–3 -> Stratum 10 -> Floor ∞`)**: Data-driven `StratumFloorData` resources power the initial 3-floor Bait Contract, expand cleanly across all 10 corporate/alien Strata, and loop infinitely once the player captures **Sample Y**.

## Detailed Design

*(Note: `level-designer` and `systems-designer` consulted for non-rectangular room topology, distributed exit sockets, and encounter budget math.)*

### Core Rules

1. **5 Non-Rectangular Arena Footprint Archetypes & Distributed Exit Sockets (`DoorSocket`)**:
   - Rooms are authored as `.tscn` templates across 5 distinct spatial footprints (`1.0x` to `1.6x` screen size, with smooth camera follow and `>= 75%` walkable clearance):

| Room Footprint Archetype (房间空间轮廓) | Spatial Geometry & Tactical Flow (地形特征与战术走位变化) | Distributed `DoorSocket` Placement (出口大门自然分布位置) |
| :--- | :--- | :--- |
| **1. Standard Foundry Chamber**<br>*(标准矩形/切角腔室)* | Balanced open arena with symmetric cover pylons and hazard drums. | North-Left, North-Right, or East wall sockets (`1–3` doors). |
| **2. L-Bend Mine Corridor**<br>*(L型折角巷战矿道)* | `90°` dogleg turn that breaks long sniper sightlines and creates corner ambush pockets. | Entry at South-West leg; exits distributed at **North-West elbow** and **East wing terminus** (doors are in separate wings, never side-by-side). |
| **3. Central Ring-Pit / Reactor Core**<br>*(中央深渊/反应堆环形室)* | Large impassable central chasm or furnace core; combat flows clockwise/counter-clockwise around the outer ring. | Exits placed at **12 o'clock (North)**, **3 o'clock (East)**, and **9 o'clock (West)** around the perimeter ring. |
| **4. Twin-Bridge Span**<br>*(双联狭窄天桥室)* | Two wide combat platforms connected by parallel narrow catwalks over a foundry pit; favors piercing Final Rounds and `Space` dodge-grazing across bridges. | Exits anchored on opposite ends of the **Upper North** and **North-East** platforms. |
| **5. Irregular Cavern / Hub Cross**<br>*(不对称异形溶洞/十字室)* | `45°` chamfered rock-and-steel walls withalcove pockets for `PROXIMITY_KEY_E` capacitors/launchpads. | Exits tucked into distinct directional alcoves (`North`, `North-West`, `South-East`). |

   - **Dynamic Exit Count (`1 to 3 Doors` per Room)**:
     - **1-Door Transition (`Single Exit`)**: Used on Node 3 (leading into the guaranteed mid-floor Pit-Stop) and Node 6 (leading into the Stratum Boss gate).
     - **2-Door Fork (`Dual Choice` — `65%` of combat nodes)**: Offers a clean binary choice (e.g., North wing **Armory Door** vs. East wing **Tactical Item Door**).
     - **3-Door Junction (`Triple Hub` — `35%` of combat nodes)**: Spawns in larger Hub/Ring rooms, offering **Armory**, **Tactical Item**, and **Random Event** exits across separate walls.
   - **Off-Screen Exit Wayfinder & Hades-Style Chamber Clear Presentation**:
     - Exit doors are naturally recessed into the perimeter architecture (North-West tunnel arch, East catwalk gate, etc. — just like *Hades* chamber exits). During active combat, doors are sealed by crimson laser barriers with dormant overhead holo-orbs.
     - The exact millisecond the room's objective completes (`ROOM CLEARED`), a **0.15s Overdrive Clear Pulse** radiates across the arena—**instantly vaporizing all remaining fodder enemies and active enemy projectiles**—while the reward pod drops near the player and the 1–3 exit barriers unseal with floating *Hades*-style neon category crests (plus edge-of-screen directional wayfinder arrows if an exit lies around an L-bend corner).
2. **4 Differentiated Room Objective Modes (`RoomObjectiveType` — Beyond Pure Extermination)**:
   - Combat rooms are not limited to repetitive "kill every mob" waves. When a combat node initializes, it pairs its spatial footprint with one of **4 distinct Room Objective Modes**, ensuring speed builds, defensive graze builds, and single-target burst builds each have rooms where they shine:

| Room Objective Mode (`RoomObjectiveType`) | Occurrence Weight | Win Condition & Instant-Clear Payoff | Best-Matched Room Footprints & Build Synergy |
| :--- | :--- | :--- | :--- |
| **1. `EXTERMINATION`**<br>*(常规歼灭战)* | `~45%` | Eliminate all 1–2 spawned enemy waves (`room_encounter_budget`). | **Standard Chamber / Irregular Cavern** — Rewards balanced AoE and Final Round burst. |
| **2. `SABOTAGE_BEACONS`**<br>*(破坏分布信标房)* | `~25%` | **3 to 4 armoured Corporate Signal Beacons (`220 HP` each)** are distributed across distant corners/wings of the room while infinite suppressor mobs spawn.<br>💥 **Payoff**: Destroying the final Beacon triggers an immediate chain overload that **instantly obliterates all remaining enemies and bullets** in the room! | **L-Bend Corridor / Twin-Bridge Span / Ring-Pit** — Rewards high mobility (*Kinetic Boots*, Launchpads), long-range piercing (*Revolver Final Round*, *Railgun*), and detonating nearby Fuel Drums to speed-snipe Beacons without fighting fodder. |
| **3. `OVERDRIVE_SURVIVAL`**<br>*(高压倒计时生存房)* | `~15%` | Corporate lockdown triggers a **`25.0s–30.0s` bullet-hell barrage** from wall emitters and aggressive waves.<br>💥 **Payoff**: Surviving until `timer == 0.0s` causes all enemies and turrets to self-destruct simultaneously, plus awards **`+1 🪙 Bounty Chip` per `5.0⚡` Overcharge** held at buzzer end! | **Central Ring-Pit / Standard Chamber** — Primary showcase for `Space` Dodge-Graze builds, *Aegis Shatter Dynamo*, `[Q]` *EMP Blank Pulse*, `[E]` *Deployable Shields*, and `90⚡` *Black Hole* bullet devouring. |
| **4. `CONDUIT_UPLOAD`**<br>*(终端超载上传房)* | `~15%` | Activate 1–2 Data Terminals (`[E]`) and hold the zone until upload reaches **`100%`** (`+5%/sec` passive tick, plus **`+12%` instant upload burst** on every **Perfect Reload** or enemy kill inside the zone!). Reaching `100%` vaporizes all remaining foes. | **Twin-Bridge / Hub Cross** — Rewards close-quarters knockback (*Bailiff Pump-Shotgun*, *Kinetic Blast Wave* reload buff) and *Holo-Decoy* zone control. |

3. **7-Node Stratum Pacing Curve (`~8–10 Minutes` per Stratum)**:
   - Each Stratum consists of a 7-step forward directed acyclic graph (DAG):
     - **Node 1 (Drop-Pod Entry Skirmish)**: Standard Chamber, medium-low enemy budget; forks into 2–3 exits.
     - **Nodes 2 & 3 (Build-Shaping Forks)**: L-Bend, Ring-Pit, or Twin-Bridge combat/event rooms; Node 3 funnels into Node 4.
     - **Node 4 (Guaranteed Mid-Stratum Pit-Stop / High-Value Event)**: Non-combat sanctuary featuring **Old Rex's Black-Market Stall** and **Bucky's Rest/Forge Workbench**, exiting into 2–3 doors.
     - **Nodes 5 & 6 (High-Voltage Overdrive Stretch)**: High-density combat rooms ideal for `[F]` Overdrive Bets; if the player triggers `>= 2` Overdrive Bets in the current stratum, Node 6 triggers a **Rival Hunter Ambush (e.g., *Vesper the Quota-Queen*)**!
     - **Node 7 (Stratum Boss Showdown)**: Bespoke Boss arena; defeating the Boss opens the Stratum Elevator (or Extraction vs. Endless Rift on landmark strata).
3. **The 3 Core Door Categories & Smart Anti-Duplicate Loot Filter**:
   - **Category 1 — `ARMORY_DOOR` (【枪械门】 — Amber Gold Crest)**:
     - Rewards: `Primary Weapon`, `Heavy Spender`, or `Dynamo Core`.
     - *Smart Pity Rule*: Never drops the exact ID currently equipped; if the player is still on their starter Dynamo Core by Node 3, weights unowned Dynamo Cores at `70%`.
   - **Category 2 — `TACTICAL_ITEM_DOOR` (【战术道具门】 — Electric Cyan Crest)**:
     - Rewards: `Active Item [Q]` (`25%` weight) or `Passive Relic [7]/[8]/[9]` (`75%` weight).
     - *Mutex & Duplicate Filter*: Automatically excludes already-equipped Relic IDs and any Relic sharing an active `exclusivity_group` tag.
   - **Category 3 — `SAFE_PIT_STOP_DOOR` (【安全屋：黑市/铁匠铺门】 — Emerald/Amber Sanctuary Crest, ~20% / Guaranteed Mid-Floor)**:
     - **100% Monster-Free Rule**: Whenever a door is marked as **Old Rex's Black-Market** or **Bucky's Forge**, the room is **guaranteed 100% free of hostile monsters**, serving as a pure safe sanctuary.
   - **Category 4 — `RANDOM_EVENT_DOOR` (【？未知随机事件门】 — Violet Anomaly Crest, ~25% Occasional Spawn)**:
     - Does NOT spawn after every room. When it appears, it is a true mystery gamble (**~50% Non-Combat Anomaly / Quest NPC** vs. **~50% High-Value Monster/Elite Ambush**):
       1. *Corporate "Voluntary Overtime" Blood Siphon / Ada's Side-Quest* (Non-combat risk/reward).
       2. *High-Value Bounty Ambush* (Monster encounter: defeat 1 Elite + fodder wave for `+45–60 🪙 Bounty Chips` + high-tier drop).
4. **Pre-Door Overdrive Bet (`[F]` Key — `-25.0⚡` Wager)**:
   - Standing within `42.0 px` of an unlocked `ARMORY_DOOR` or `TACTICAL_ITEM_DOOR` after `room_cleared` allows pressing **`[F]`** to spend **`25.0⚡` Overcharge** and lock in an **Overdrive Bet**:
     - **Hazard Applied to Next Room**: Increases next room's encounter budget by **`+35%`**, enemy HP by **`+25%`**, and rolls 1 hazard modifier: `ELITE_REINFORCER` (+1 Elite with `EliteModifierComponent`), `OVERCLOCKED_PROJECTILES` (`+20%` enemy bullet speed), or `DEADLINE_BLITZ_30S` (`30s` bonus timer).
     - **Reward Payoff**: Doubles all **`🪙 Bounty Chips` (`2.0x`)** dropped in the room and upgrades the room-clear reward pedestal into a **2-Choice High-Tier Crate (二选一高阶军械/道具箱)**!
5. **3-Floor Bait -> 10-Stratum Campaign -> Sample Y Endless Loop (`Floor 11 -> ∞`)**:
   - **Stratum 3 Clear (Bait Contract Reveal)**: Defeating *The Quota-Crusher* opens the Decoy Vault (playing the CEO's mocking lucky-cat recording). In Early Access / Quick-Run mode, players can extract or descend into Strata 4–10.
   - **Stratum 10 Clear (Chamber Zero — Sample Y Captured)**: Defeating the CEO Mech & Sample Y Guardian spawns two exit gates:
     - **Gate A (`EXTRACTION_BEACON`)**: Complete campaign victory & full ship-hub meta payout.
     - **Gate B (`SAMPLE_Y_ENDLESS_RIFT` — Requires `100.0⚡` Overcharge or free interaction)**: Triggers **Phase Collapse (`endless_loop_count += 1`)**, cycling into Floor 11, 12, ... $\infty$ with exponential enemy scaling and permanent Overdrive modifiers.

### States and Transitions

| Room & Routing State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`ROOM_COMBAT_ACTIVE`** | `room_cleared == false` (objective in progress: waves remaining, Beacons `> 0`, Survival `timer > 0`, or Upload `< 100%`) | $\rightarrow$ `ROOM_CLEARED_ROUTING` the instant the active `RoomObjectiveType` completes | Exit `DoorSocket` gates remain sealed by laser barriers; Overcharge generation is active (`72–100⚡` room budget). |
| **`ROOM_CLEARED_ROUTING`** | Room objective completed (`0.15s` Overdrive Clear Pulse vaporizes all remaining fodder & enemy bullets) | $\rightarrow$ `OVERDRIVE_BET_LOCKED` on `[F]` near a combat door (`>= 25⚡`)<br>$\rightarrow$ `ROOM_TRANSITIONING` on `[E]` at any unlocked door | Drops room reward pod; unseals 1–3 *Hades*-style recessed exits with floating neon crests and off-screen wayfinder arrows; disables out-of-combat Overcharge farming. |
| **`OVERDRIVE_BET_LOCKED`** | Player pressed `[F]` (`-25.0⚡`) on a target door | $\rightarrow$ `ROOM_TRANSITIONING` on `[E]` | Hydraulic hazard clamps slam onto the chosen door frame; increments `stratum_bet_streak` (triggers Rival Boss *Vesper* at `streak >= 2`). |
| **`ROOM_TRANSITIONING`** | Player pressed `[E]` at an active door | $\rightarrow$ `ROOM_COMBAT_ACTIVE` (or Pit-Stop `SAFE_SANCTUARY`) in next template | Loads next non-repeating room footprint template, applies Overdrive Bet modifiers if locked, and places player at entry spawn socket. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Emits `room_cleared`, `overdrive_bet_locked`, `door_entered`; loads `StratumFloorData` | `Combat Event Bus & Data Schema` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Bidirectional | Deducts `-25.0⚡` on `[F]` Overdrive Bet; uses `room_cleared` state to block out-of-combat reload farming | `Dual-Gun, Active Reload & Overcharge Engine` |
| **7-Slot Loadout & Tactical Items System** | Bidirectional | Queries equipped item IDs and `exclusivity_group` tags to roll non-duplicate Armory/Item door rewards | `7-Slot Loadout & Tactical Items System` |
| **Enemy AI, Elite/Boss Interrupts & Boss System** | Downstream Consumer | Spawns enemy waves using `room_encounter_budget`, `stratum_index`, `has_overdrive_bet`, and `endless_loop_count` | `Enemy AI, Elite/Boss Interrupts & Boss System` |

## Formulas

*(Note: `systems-designer` consulted for the encounter wave budget and Overdrive Bet reward formulas.)*

### 1. Single-Room Encounter Wave Budget (`room_encounter_budget`)

To ensure combat density scales smoothly across nodes, strata, Overdrive Bets, and Endless Loops while keeping standard room clear times at `18–25s`, the point budget `room_encounter_budget` spent by the wave spawner is defined as:

`room_encounter_budget = round((BASE_ROOM_BUDGET + NODE_BUDGET_STEP * float(node_index - 1) + STRATUM_BUDGET_STEP * float(stratum_index - 1)) * (1.0 + BET_BUDGET_BONUS * int(has_overdrive_bet)) * pow(ENDLESS_BUDGET_MULT, float(endless_loop_count)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `BASE_ROOM_BUDGET` | float | `10.0` | data file | Base spawn points for Stratum 1, Node 1 (`Burst Bot = 2 pts`, `Ring Turret = 3 pts`, `Sniper Mech = 3 pts`, `Elite = 6 pts`) |
| `NODE_BUDGET_STEP` | float | `2.0` | data file | Additional spawn points added per room node (`1..6`) within a stratum |
| `node_index` | int | `1–6` | calculated | Current room node index within the stratum (`Node 7` is Boss) |
| `STRATUM_BUDGET_STEP` | float | `4.0` | data file | Additional spawn points added per deeper Stratum (`1..10`) |
| `stratum_index` | int | `1–10` | calculated | Current subterranean stratum number |
| `BET_BUDGET_BONUS` | float | `0.35` | data file | `+35%` spawn budget increase when an Overdrive Bet (`-25⚡`) is active on the room |
| `ENDLESS_BUDGET_MULT` | float | `1.25` | data file | `1.25x` spawn budget multiplier per Sample Y Endless Loop |
| `endless_loop_count` | int | `0–99` | calculated | Completed Sample Y Endless Loops |

**Output Range:** `10` points (4–5 fodder mobs in Stratum 1, Node 1) to `56` points (Stratum 10, Node 6) in standard play; scales higher in Endless Loop (split across 2–3 spawn waves so concurrent enemy cap never exceeds `10` at once).
**Example:** Stratum 1, Node 2 (`node_index = 2`, `stratum_index = 1`, `endless_loop_count = 0`) with an active **Overdrive Bet** (`has_overdrive_bet = true`):
`room_encounter_budget = round((10.0 + 2.0 * 1 + 0.0) * 1.35 * 1.0) = round(12.0 * 1.35) = 16` points (e.g., `1 Elite [6 pts] + 2 Burst Bots [4 pts] + 2 Ring Turrets [6 pts] = 16 pts`).

---

### 2. Room Bounty Chip Payout & Overdrive Bet Multiplier (`room_bounty_chip_total`)

Total **Bounty Chips (`🪙悬赏工分币`)** earned from clearing a combat room is defined as:

`room_bounty_chip_total = round((sum_enemy_base_chips + ROOM_CLEAR_BONUS_CHIPS * float(stratum_index)) * (1.0 + OVERDRIVE_BET_CHIP_MULT * int(has_overdrive_bet)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `sum_enemy_base_chips` | int | `24–90` | calculated | Sum of base chips dropped by enemies killed in the room (`6–12 🪙` per mob, `25 🪙` per Elite) |
| `ROOM_CLEAR_BONUS_CHIPS` | float | `8.0` | data file | Flat completion bonus scaled by `stratum_index` |
| `stratum_index` | int | `1–10` | calculated | Current stratum index |
| `OVERDRIVE_BET_CHIP_MULT` | float | `1.0` | data file | `+100%` (`2.0x` total) Bounty Chip multiplier when `has_overdrive_bet == true` |

**Output Range:** `32 🪙` (Stratum 1 normal room) to `300+ 🪙` (high-stratum Overdrive Bet room).
**Example:** Clearing a Stratum 1 room with `sum_enemy_base_chips = 36 🪙` and `ROOM_CLEAR_BONUS_CHIPS = 8 🪙`: without Bet = `44 🪙`; with Overdrive Bet (`-25⚡`) = `44 * 2.0 = 88 🪙` plus a 2-Choice High-Tier Crate.

## Edge Cases

- **If a room's `room_encounter_budget` exceeds `22` points (e.g., late strata or Overdrive Bet rooms)**: Rather than spawning 12 enemies simultaneously in a cramped L-Bend or Twin-Bridge room, the spawner caps concurrent active enemies at **`MAX_CONCURRENT_ENEMIES = 7`** and queues remaining budget into a second reinforcement wave (`Wave 2`) that spawns with `0.8s` floor-telegraph rings as soon as active enemies drop to `<= 2`.
- **If the player clears a room in an L-Bend or Ring-Pit arena where one of the unlocked `DoorSocket` exits is off-screen**: An edge-clamped neon directional indicator (`↗ 【1】军械门` / `⬅ 【3】事件门`) remains visible on the screen border until the door enters the camera viewport.
- **If the player already locked an Overdrive Bet (`-25⚡`) on Door A (`ARMORY_DOOR`) but changes their mind and walks through Door B (`RANDOM_EVENT_DOOR`)**: Pressing `[F]` on a second combat door transfers the already-paid Bet lock to that door at zero extra cost; if they enter a non-bettable `RANDOM_EVENT_DOOR` instead, the `25.0⚡` wager is refunded so energy is never wasted by accident.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depends on (Upstream) | Hard | Deducts `-25.0⚡` for Overdrive Bets and sets `room_cleared` state |
| **7-Slot Loadout & Tactical Items System** | Depends on (Upstream) | Hard | Filters Armory & Tactical Item door reward crates against equipped IDs and `exclusivity_group` |
| **Enemy AI, Elite/Boss Interrupts & Boss System** | Depends on (Upstream) | Hard | Spawns Fodder, Elites, and Bosses using `room_encounter_budget` and `stratum_bet_streak` |
| **Pit-Stop, Bounty Chip Economy & Rival Cast System** | Depended on by (Downstream) | Hard | Populates Node 4 Pit-Stops, `RANDOM_EVENT_DOOR` encounters, and Rival Boss ambushes |
| **Tactical Micro-HUD & Screen UI System** | Depended on by (Downstream) | Hard | Renders 3-Door Header Cards, `[F]` Bet clamps, and off-screen door wayfinder arrows |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 4, 6, 7, and 9.)*

- **Distributed Door Header Crests & Hydraulic Bet Clamps (`Z = 20` & `Z = 50`)**:
  - Regardless of whether a door sits on a North, East, or West wall socket, its holographic Header Card (`96×54px`) floats cleanly above the doorframe in **Amber Gold (`#FFB800` Armory)**, **Electric Cyan (`#00F0FF` Tactical Item)**, or **Anomaly Violet (`#A855F7` Random Event)**.
  - Locking an Overdrive Bet (`[F]`) physically slams glowing crimson-gold hydraulic clamps onto the door arch and ignites a `★ 2X OVERDRIVE` flame badge.
- **Wave Spawn Floor Telegraphs (`Z = 10`)**:
  - Reinforcement waves (`Wave 2`) project `0.8s` pulsing warning circles on the floor (`Alpha <= 40%`) before enemies materialize so a reinforcing mob never spawns on top of the player without warning.

📌 **Asset Spec** — Visual/Audio requirements are defined for the 5 room footprints, directional door arches, and Overdrive Bet clamps.

## Game Feel

- **Fresh Spatial Puzzles in Every Room**: Fighting Sniper Mechs around an L-Bend corner or grazing through Ring Turret waves across a Twin-Bridge feels completely different from fighting in a flat box, keeping spatial awareness engaged throughout a 40-minute run.
- **Zero-Friction Forward Momentum**: The moment the last enemy explodes, the room reward drops, the distributed exit doors unseal with neon chimes, and off-screen wayfinders point the way—zero minimap squinting or empty-corridor walking required.

## UI Requirements

- **Door Header Cards (`Z = 50`)**: Display Category Title, Reward Icon, and `[E] 进入 | [F] 押注 25⚡ (双倍奖励)` prompts when within `42.0 px`.
- **Off-Screen Door Wayfinder Arrows (`Z = 50`)**: Compact edge-of-screen badges (`↗ 【军械门】`, `⬅ 【道具门】`) active only when `room_cleared == true` and a door socket is outside the camera rect.

> **📌 UX Flag — 3-Door Routing, Overdrive Bet & Floor Generator**: Door Header Cards and off-screen wayfinder indicators are specified in `design/gdd/tactical-micro-hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `room_cleared`, `overdrive_bet_locked`, `door_entered` signals | Yes — exact signal signatures match |
| `design/gdd/dual-gun-overcharge-engine.md` | `room_cleared` anti-farming gate, `-25.0⚡` Overdrive Bet cost | Yes — integrates directly with the `72–100⚡` room Overcharge budget |
| `design/gdd/enemy-and-boss-system.md` | `enemy_scaled_max_hp`, `OVERDRIVE_BET_HP_BONUS = 0.25`, Rival Boss *Vesper* trigger | Yes — `stratum_bet_streak >= 2` triggers Rival ambush |
| `design/narrative/world-lore.md` | 3-Floor Bait Contract -> 10 Strata -> Sample Y Endless Loop | Yes — Node 7 on Stratum 3 & Stratum 10 directly implement the lore milestones |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** a generated 7-Node Stratum, **WHEN** room templates are selected for Nodes 1–6, **THEN** no two consecutive rooms use the exact same room template ID, rooms utilize non-uniform footprints (Standard, L-Bend, Ring-Pit, Twin-Bridge, Cavern), and each room activates `1` to `3` spatially distributed `DoorSocket` exits.
- **GIVEN** `room_cleared` transitions to `true` in an L-Bend or Ring-Pit room where an active `DoorSocket` lies outside the current camera viewport, **WHEN** the HUD updates, **THEN** an edge-clamped directional wayfinder badge points toward the off-screen door until it enters the viewport.
- **GIVEN** the player has `>= 25.0⚡` Overcharge and presses `[F]` at an `ARMORY_DOOR` or `TACTICAL_ITEM_DOOR`, **WHEN** the player enters that door, **THEN** `25.0⚡` is deducted, the next room's `room_encounter_budget` increases by `+35%` with a hazard modifier, Bounty Chip drops are multiplied by `2.0x`, and clearing the room spawns a **2-Choice Reward Crate**.
- **GIVEN** a room initializes with `RoomObjectiveType = SABOTAGE_BEACONS` (3 distributed Beacons) or `OVERDRIVE_SURVIVAL` (`28.0s` timer), **WHEN** the player destroys the 3rd Beacon or the survival timer reaches `0.0s` while 5 fodder enemies and 40 enemy bullets are still active on screen, **THEN** the Overdrive Clear Pulse immediately vaporizes all 5 enemies and all 40 bullets, transitions to `ROOM_CLEARED_ROUTING`, and unseals the distributed exits.

## Open Questions

- *None — the 5 room footprint archetypes, distributed `DoorSocket` exits (`1–3` doors), Overdrive Bet math, and 3->10->Endless stratum generator are locked.*
