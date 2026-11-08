# Enemy AI, Elite/Boss Interrupts & Boss System

> **Status**: Approved
> **Author**: user + game-designer + ai-programmer + systems-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Establishes a **3-Tier Enemy & Granular Boss Customization Architecture**: (1) Data-driven `MovementArchetype + BulletPatternData` for rapid fodder mob production (with **zero cluttering interrupt prompts on fodder**); (2) Composable **`EliteModifierComponent` plugins** (directional shields, blink ambushes, tether links) for Elites; and (3) a **4-Dimensional Boss Customization Framework** (`BossAttackTimeline` scripts, destructible `BossPartNode` multi-hitboxes, `BossArenaController` hazard hooks, and `RivalHunterBrain` mirror mechanics) paired with **Elite/Boss-exclusive Weak-Point Interrupts (`+22.0⚡`)**, Boss DPS Soft-Cap resilience, and hitless **Master Chamber Core** rewards.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat Event Bus & Data Schema`, `Pooled Bullet-Hell & Damage System`, `Dual-Gun, Active Reload & Overcharge Engine`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Enemy AI, Elite/Boss Interrupts & Boss System** governs all hostile combatants across Planet X's 10 Strata and Endless Loop. To avoid the common pitfall where Elites and Bosses feel like mere "upscaled fodder with more HP" while keeping ordinary mob production fast, this system enforces a **3-Tier Customization Hierarchy**:
1. **Tier 1 — Fodder Mobs (Data-Driven `MovementArchetype` + `BulletPatternData`)**: Standard room enemies (Burst Bots, Ring Turrets, Sniper Mechs) are authored rapidly via `.tres` resources. Crucially, **fodder mobs never trigger Weak-Point Interrupt reticles**, keeping multi-mob arenas visually clean.
2. **Tier 2 — Elite Combatants (Composable `EliteModifierComponent` Plugins + Custom Interrupt Rules)**: Elites mount 1–2 modular behavior components—such as **Rotating Directional Shields**, **Blink Ambush Teleporters**, **Sub-Unit Shield Tethers**, or **Corporate Laser Beacons**—and expose high-priority **Weak-Point Interrupt windows (`+22.0⚡`)** when their tactical defense is outplayed or during signature wind-ups.
3. **Tier 3 — Stratum Bosses & Rival Hunter Hidden Bosses (4D Granular Customization)**: Bosses are bespoke centerpiece encounters built with **Custom Attack Timeline Coroutines (`BossAttackTimeline`)**, **Destructible Multi-Part Hitboxes (`BossPartNode`)**, **Boss-Specific Arena Interactable Hooks (`BossArenaController`)**, and—for humanoid fellow bounty hunters like *Vesper the Quota-Queen*—a **`RivalHunterBrain`** that dodge-rolls, fires signature weapons, and exposes interruptible **Active Reload Jam windows**.

## Detailed Design

*(Note: `game-designer`, `ai-programmer`, and `systems-designer` consulted for the 3-Tier AI hierarchy, 4D Boss customization, and interrupt rules.)*

### Core Rules

1. **Tier 1: Fodder Mob Architecture (Zero Interrupt Clutter)**:
   - Fodder mobs combine a `MovementArchetype` enum (`KITE_STRIKER`, `STATIONARY_ANCHOR`, `LONG_RANGE_PERCH`, `RUSHER_CHARGER`) with a `BulletPatternData` resource (`projectile_count`, `spread_angle_deg`, `burst_waves`, `wave_interval`, `spin_deg_per_sec`, `bullet_speed`).
   - **No Interrupt UI on Fodder**: Fodder mobs display a brief `0.35s` muzzle-glow wind-up before firing so players can time `Space` dodge-roll grazes, but **never** spawn `⚡弱点打断` reticles or emit `weakpoint_interrupted`.
   - **MVP Fodder Roster**:
     - **`burst_bot` (散射近卫机兵 — Triangle Chassis)**: `85 HP`, `KITE_STRIKER` (`150px` preferred range), fires 3-way `18°` spread bursts (`250 px/s`).
     - **`ring_turret` (环幕矩阵炮塔 — Octagonal Core)**: `105 HP`, `STATIONARY_ANCHOR`, emits 8-bullet `360°` radial rings (`210 px/s`) rotating `22.5°` per salvo.
     - **`sniper_mech` (高塔狙击机甲 — Tall Diamond Frame)**: `75 HP`, `LONG_RANGE_PERCH`, projects a tracking red sightline (`0.50s`) before firing a `370 px/s` high-velocity slug.
2. **Tier 2: Granular Elite Customization (`EliteModifierComponent` Plugin System)**:
   - Elites (spawned in Overdrive Bet rooms, Bounties, and mid-stratum waves) attach 1–2 modular `EliteModifierComponent` child nodes/scripts that customize their combat puzzle and Weak-Point exposure:

| Elite Component Plugin (`EliteModifierComponent`) | Granular Tactical Behavior | Custom Weak-Point Interrupt Condition (`+22.0⚡`) |
| :--- | :--- | :--- |
| **1. `DirectionalShieldComponent`**<br>*(定向防爆能量盾组件)* | Projects a front-facing `110°` energy barrier that blocks standard frontal `LMB` shots. | Flanking behind the Elite via `Space` dodge-roll OR striking the shield with a piercing **Final Round / `RMB` Railgun** shatters the shield and opens a `0.90s` Weak-Point Interrupt window. |
| **2. `BlinkAmbushComponent`**<br>*(折跃伏击狙击组件)* | Teleports across the arena every `6.0s` (or after losing `35%` HP), leaving a proximity mine at its departure point. | Immediately after blinking in, channels a `0.85s` red-flash heavy snipe that can be interrupted by any Final Round or `RMB` Heavy hit. |
| **3. `TetherGuardianComponent`**<br>*(超导护卫连线组件)* | Projects an energy tether to 1–2 nearby fodder mobs, granting them `+40%` fire rate and `50%` damage reduction. | While tethering, the Elite's back reactor core pulses red; dealing `>= 45.0` burst damage interrupts the tether, stunning the Elite and all linked mobs for `1.8s`. |
| **4. `HazardDropperComponent`**<br>*(违章空投信标组件)* | Periodically lobs corporate laser-grid pylons or volatile drums into the arena. | Shooting the airborne canister mid-throw or hitting the Elite during its `0.85s` launch calibration triggers a self-detonation interrupt. |

3. **Tier 3: 4-Dimensional Boss & Rival Hunter Customization Framework**:
   - Every Stratum Boss and Rival Hidden Boss is authored using four granular customization hooks:
   - **Dimension A — Phase State Machine & Scripted Attack Timelines (`BossPhaseStateMachine` + `BossAttackTimeline`)**:
     - Bosses transition across **3 HP Phases (`P1: 100%–65%`, `P2: 65%–30%`, `P3: <30%`)**, clearing active enemy bullets and triggering a visual/armor transformation at each threshold.
     - Each Boss attack is an authored `BossAttackTimeline` script controlling frame-exact movement choreography, multi-stage bullet-hell choreography, hazard spawns, and custom **Weak-Point Interrupt windows**.
   - **Dimension B — Multi-Part Hitboxes & Destructible Sub-Parts (`BossPartNode`)**:
     - Large mechanical Bosses (e.g., Floor 3 Boss **「考勤防暴主脑·铁算盘 (The Quota-Crusher)」**) attach independent `BossPartNode` sub-hitboxes (such as *Left Homing Pod `350 HP`* and *Right Laser Clamp `350 HP`*).
     - Destroying a `BossPartNode` permanently disables or degrades that specific Boss attack pattern for the rest of the fight, triggers an immediate **`+22.0⚡` Part-Break Interrupt**, and exposes the central core (`+30%` damage taken for `2.5s`).
   - **Dimension C — Boss-Specific Arena Interactable Hooks (`BossArenaController`)**:
     - Allows a Boss fight to wire custom logic into the room's `ArenaInteractableData` objects (e.g., Boss activates a `90%` armor shell that must be cracked by luring its charge into a **Cryo-Coolant Tank** or triggering a **Proximity `[E]` EMP Pylon**).
   - **Dimension D — Rival Hunter Mirror Brain (`RivalHunterBrain` for Humanoid Hidden Bosses)**:
     - Used for fellow Space Gunboys turned Hidden Bosses (e.g., **「卷王猎人·薇拉 (Vesper the Quota-Queen)」**, **「老烟枪·雷克斯 (Old Rex)」**, **「实习生·小Y (Specimen Y-Jr.)」**):
       - **Reactive Dodge Roll**: Rivals can dodge-roll laterally with cyan/crimson afterimages when the player fires a slow projectile, repositioning to flank.
       - **Visible Overhead Reload & Jam Window**: After firing their signature combo, Rivals display an overhead Active Reload bar; when they enter a scripted **Overheat / Reload Wind-Up (`0.85s`)**, a red-flash Weak-Point reticle appears—hitting them with a **Final Round** or **`RMB` Heavy Spender** punishes their reload for **`+22.0⚡` Overcharge** and a `1.8s` stagger!
4. **Elite & Boss Weak-Point Interrupt Resolution (`+22.0⚡` + `1.8s` Stagger)**:
   - During any active `0.85s` (`0.75s` in Boss P2/P3) Weak-Point Interrupt window on an Elite or Boss:
     - **Valid Interrupt Triggers**: (a) Any Primary **Final Round** hit, (b) Any **`RMB` Heavy Spender** hit, (c) Any **Tactical Arena Interactable** blast/shock, or (d) Accumulating **`>= 45.0` burst damage** within the window.
     - **Payoff**: Cancels the Elite/Boss attack, triggers a `0.045s` hitstop, emits `weakpoint_interrupted`, grants **`+22.0⚡` Overcharge**, and applies **`VULNERABLE_STAGGER` (`1.8s` stun + `+30%` incoming damage taken)**.
5. **Boss DPS Soft-Cap & Hitless "Master Chamber Core" Reward**:
   - **Boss DPS Soft-Cap**: If player damage dealt to a Boss within a rolling `1.0s` window exceeds **`18%` of Boss `max_hp`**, excess damage in that window is multiplied by **`0.35` (`35%`)**—*except* direct Weak-Point Interrupt hits and `BossPartNode` break bursts, which bypass the soft-cap at `100%` value to reward skillful play.
   - **Hitless Master Chamber Core (无伤首领奖励「大师膛室核心」)**: Defeating any Stratum Boss without losing a single point of `hp` or `armor` during the encounter awards a **Master Chamber Core (`+1 Max HP Heart` restored + `+15.0⚡ Max Overcharge Capacity`)**.

### States and Transitions

| Elite / Boss State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`TACTICAL_NEUTRAL`** | Executing phase movement & standard patterns | $\rightarrow$ `WEAKPOINT_WINDUP` on signature skill timer or shield break<br>$\rightarrow$ `PHASE_TRANSITION` at `65%` / `30%` HP | Executes `MovementArchetype` / `RivalHunterBrain` positioning and `BulletPatternData` salvos. |
| **`WEAKPOINT_WINDUP`** | `0.0 < windup_timer <= 0.85s` (Elites & Bosses only) | $\rightarrow$ `VULNERABLE_STAGGER` on valid Interrupt hit<br>$\rightarrow$ `SIGNATURE_UNLEASH` if `windup_timer` reaches `0.0` un-interrupted | Displays inward-snapping red crosshair reticle (`><`) + rising audio whine; tracks `window_damage_accumulated`. |
| **`VULNERABLE_STAGGER`** | Interrupted (`1.8s` duration) or `BossPartNode` destroyed (`2.5s`) | $\rightarrow$ `TACTICAL_NEUTRAL` when timer expires | Attack canceled; movement and firing halted; incoming damage multiplied by `1.30x`; awards `+22.0⚡` Overcharge on entry. |
| **`SIGNATURE_UNLEASH`** | `windup_timer` expired without interrupt | $\rightarrow$ `TACTICAL_NEUTRAL` after timeline finishes | Executes high-threat multi-wave barrage or beam sweep defined in `BossAttackTimeline`. |
| **`PHASE_TRANSITION`** | Boss HP crosses `65%` or `30%` | $\rightarrow$ `TACTICAL_NEUTRAL` (Next Phase) after `1.0s` | Clears surrounding bullets (`80px`), plays armor-shedding animation, activates next phase's `BossAttackTimeline` set. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Emits `weakpoint_interrupted` (`+22.0⚡`) and `enemy_killed`; listens to `interactable_triggered` for `BossArenaController` puzzles | `Combat Event Bus & Data Schema` |
| **Pooled Bullet-Hell & Damage System** | Bidirectional | Spawns `BulletPatternData` waves into `BulletPool`; receives Tier 1/2/3 damage, `28–45px` knockback, and Boss DPS Soft-Cap evaluation | `Pooled Bullet-Hell & Damage System` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Upstream Producer | Final Rounds (`LMB`) and Heavy Spenders (`RMB`) act as instant Weak-Point Interrupt keys; receives `+22.0⚡` per interrupt | `Dual-Gun, Active Reload & Overcharge Engine` |
| **Pit-Stop, Bounty Chip Economy & Rival Cast System** | Bidirectional | Supplies Rival Hunter run state (whether *Vesper* or *Old Rex* spawns as a Friendly NPC or ambushing Hidden Boss) | `Pit-Stop, Bounty Chip Economy & Rival Cast System` |

## Formulas

*(Note: `systems-designer` consulted for Stratum/Endless scaling and Boss DPS Soft-Cap math.)*

### 1. Stratum, Overdrive Bet & Endless Loop Enemy HP Scaling (`enemy_scaled_max_hp`)

To support seamless progression from **Floors 1–3 (Bait Contract)** through **Stratum 10 (Sample Y Heart)** and into **Endless Overdrive Loop (`Floor 11 -> ∞`)**, enemy and Boss maximum HP scales according to:

`enemy_scaled_max_hp = round(base_archetype_hp * (1.0 + STRATUM_HP_SLOPE * float(stratum_index - 1)) * pow(ENDLESS_LOOP_MULT, float(endless_loop_count)) * (1.0 + OVERDRIVE_BET_HP_BONUS * int(has_overdrive_bet)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `base_archetype_hp` | float | `75.0–1800.0` | data file | Base Floor-1 HP (`85.0` Burst Bot, `320.0` Elite, `1400.0` Floor Boss) |
| `STRATUM_HP_SLOPE` | float | `0.22` | data file | `+22%` linear HP growth per Stratum from Floor 1 to Stratum 10 |
| `stratum_index` | int | `1–10` | calculated | Current subterranean stratum index (`1..3` in initial act, `1..10` in full campaign) |
| `ENDLESS_LOOP_MULT` | float | `1.35` | data file | `1.35x` exponential HP multiplier per completed Sample Y Endless Loop |
| `endless_loop_count` | int | `0–99` | calculated | Number of times the player has looped via the Sample Y dimension rift (`0` during Strata 1–10) |
| `OVERDRIVE_BET_HP_BONUS` | float | `0.25` | data file | `+25%` HP modifier when the player locked a `-25⚡` Overdrive Bet on the room door |

**Output Range:** `75.0 HP` (Floor 1 Sniper Mech) to `4,172.0 HP` (Stratum 10 Boss) in standard campaign; scales smoothly into `10,000+ HP` in deep Endless Loops.
**Example:** A Burst Bot (`base_archetype_hp = 85.0`) on Floor 3 (`stratum_index = 3`, `endless_loop_count = 0`) inside an Overdrive Bet room (`has_overdrive_bet = true`) has `round(85.0 * (1.0 + 0.22 * 2) * 1.0 * 1.25) = round(85.0 * 1.44 * 1.25) = 153 HP`.

---

### 2. Boss Rolling 1-Second DPS Soft-Cap & Interrupt Bypass (`effective_boss_damage`)

To prevent degenerate build combinations from one-shotting Bosses while still rewarding skillful Weak-Point Interrupts and `BossPartNode` breaks at 100% damage, incoming Boss damage is governed by:

`effective_boss_damage = raw_damage * int(is_interrupt_or_part_break or rolling_1s_damage <= boss_max_hp * DPS_SOFT_CAP_PCT) + (raw_damage * DPS_OVERFLOW_ATTENUATION) * int(not is_interrupt_or_part_break and rolling_1s_damage > boss_max_hp * DPS_SOFT_CAP_PCT)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `raw_damage` | float | `8.0–300.0` | calculated | Incoming damage after `final_enemy_damage` calculation (and `1.30x` if in `VULNERABLE_STAGGER`) |
| `is_interrupt_or_part_break` | bool | `true/false` | calculated | True if this hit triggers `weakpoint_interrupted` or breaks a `BossPartNode` (bypasses soft-cap!) |
| `rolling_1s_damage` | float | `0.0–5000.0` | calculated | Total damage already dealt to this Boss within the last `1.0s` sliding window |
| `boss_max_hp` | float | `1400.0–10000.0` | calculated | Scaled maximum HP of the Boss |
| `DPS_SOFT_CAP_PCT` | float | `0.18` | data file | `18%` of Boss Max HP per second soft-cap threshold (minimum `~5.5s` theoretical kill time per phase without interrupts) |
| `DPS_OVERFLOW_ATTENUATION` | float | `0.35` | data file | `35%` damage multiplier applied to non-interrupt damage exceeding the `18%/s` threshold |

**Output Range:** `100%` of `raw_damage` under normal fire or on any Weak-Point Interrupt / Part Break; `35%` of `raw_damage` when sustained non-interrupt DPS exceeds `18% Max HP / sec`.
**Example:** Against a `2000 HP` Boss (`18%` soft-cap = `360 DMG/s`), the player has already dealt `380 DMG` in the last `0.6s`. A subsequent normal SMG shot (`20 DMG`) deals `20 * 0.35 = 7.0 DMG`. However, if the Boss opens a Weak-Point window and the player fires a `95 DMG` `RMB` Railgun (`is_interrupt_or_part_break = true`), it deals the full **`95.0 DMG`** plus `+22.0⚡` Overcharge!

## Edge Cases

- **If a standard fodder mob is hit by a Final Round or `RMB` Heavy Weapon during its `0.35s` pre-fire glow**: It takes normal knockback and `+0.25s–0.45s` stagger from `Pooled Bullet-Hell & Damage System`, but **does not** emit `weakpoint_interrupted` or grant `+22.0⚡` Overcharge (strictly Elite/Boss-only).
- **If a Boss crosses a Phase Transition threshold (`65%` or `30%` HP) while in `VULNERABLE_STAGGER` or `WEAKPOINT_WINDUP`**: The phase transition takes precedence, cleanly ending the current wind-up/stagger and resetting `rolling_1s_damage = 0.0` for the new phase.
- **If an AOE attack (e.g., `RMB` Railgun or `EXPLOSIVE_BLAST`) hits both a Boss's destructible `BossPartNode` AND its main body hitbox on the same frame**: The `BossPartNode` absorbs the hit priority first so the player is rewarded with progress toward breaking the weapon part rather than double-dipping damage on a single beam.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Emits `weakpoint_interrupted` (Elites/Bosses), `enemy_killed`, `bounty_chips_changed` |
| **Pooled Bullet-Hell & Damage System** | Depends on (Upstream) | Hard | Spawns `BulletPatternData` salvos and receives Tier 1/2/3 hits and knockback |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depends on (Upstream) | Hard | Consumes `+22.0⚡` from Elite/Boss interrupts; supplies Final Round & Heavy interrupt triggers |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Depended on by (Downstream) | Hard | Spawns Fodder, Elites, and Bosses according to `stratum_index`, `has_overdrive_bet`, and `endless_loop_count` |
| **Pit-Stop, Bounty Chip Economy & Rival Cast System** | Depended on by (Downstream) | Hard | Configures Rival Hidden Boss ambushes (*Vesper*, *Old Rex*, *Specimen Y-Jr.*) and unlocks defeated Rivals |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 3, 4, 5, and 8.)*

- **Clear Visual Separation Between Fodder, Elites, and Bosses**:
  - **Fodder Mobs**: Standard `1.0x` scale (`32–42px`), clean `2px` black outline, brief muzzle flash before firing (zero overhead reticle clutter).
  - **Elites**: `1.35x` scale, metallic gold-crimson hazard trim, visible component attachments (front energy shield arc, tether beam), and a crisp inward-snapping red reticle (`><`) + `⚡弱点破绽!` tag during `WEAKPOINT_WINDUP`.
  - **Bosses & Rivals**: Multi-part animated sprites (`64×64px`–`128×128px`) or chibi Rival Gunboys with distinct silhouettes, top-center Boss HP bar with `65%` / `30%` phase notches and destructible part sub-bars.

📌 **Asset Spec** — Visual/Audio requirements are defined for Fodder, Elite components, and Multi-Part / Rival Bosses.

## Game Feel

- **Clean Mob Rooms, Electrifying Elite/Boss Duels**: Because fodder rooms aren't cluttered with red interrupt text, when an Elite or Boss *does* flash crimson and wind up a signature attack, it commands 100% of the player's attention—and slamming a Final Round or `RMB` Railgun into that window for a `0.045s` hitstop, `1.8s` armor-break stun, and `+22.0⚡` Overcharge feels unforgettable.
- **Tactical Part-Breaking**: Blowing off a Boss's missile shoulder pod mid-fight and watching it spark and stop firing missiles gives immediate, tangible feedback that your aiming choices matter.

## UI Requirements

- **Elite/Boss Weak-Point Reticle (`Z = 50`)**: Inward-snapping 4-corner red reticle (`#FF2A3C`) + `⚡重击打断 (+22⚡)` micro-tag rendered only on Elites and Bosses during `WEAKPOINT_WINDUP`.
- **Boss Top-Center Health Bar & Part Indicators**: Displays Boss name/title (e.g., `【考勤防暴主脑·铁算盘】` or `【乱入宿敌：卷王猎人·薇拉】`), phase dividers at `65%` and `30%`, and active `BossPartNode` durability pips.

> **📌 UX Flag — Enemy AI, Elite/Boss Interrupts & Boss System**: Elite/Boss interrupt reticles and the Boss top health bar are consolidated in `design/gdd/tactical-micro-hud.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `weakpoint_interrupted(enemy_id, is_boss_or_elite, ...)` | Yes — strictly restricted to Elites and Bosses |
| `design/gdd/bullet-hell-damage-system.md` | `BulletPool` (`800` slots), Tier 2/3 knockback & stagger (`28–45px`) | Yes — `enemy_knockback_resistance` (`0.0` Fodder, `0.4` Elite, `0.85` Boss) matches |
| `design/gdd/dual-gun-overcharge-engine.md` | `CHARGE_INTERRUPT = 22.0⚡` | Yes — exact `+22.0⚡` payout matches the room/Boss Overcharge budget |
| `design/narrative/world-lore.md` | 10 Strata, Endless Loop, Rival Hunters (*Vesper*, *Old Rex*, *Bucky*, *Specimen Y-Jr.*) | Yes — Rival Bosses directly powered by `RivalHunterBrain` |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** a room containing 6 standard Fodder Mobs (`burst_bot`, `ring_turret`, `sniper_mech`), **WHEN** they wind up and fire their attacks, **THEN** `0` `weakpoint_interrupted` signals or interrupt UI reticles are ever spawned.
- **GIVEN** an Elite with `DirectionalShieldComponent` or a Boss in `WEAKPOINT_WINDUP` (`0.85s` window), **WHEN** struck by a Primary Final Round, an `RMB` Heavy Weapon, or `>= 45.0` burst damage, **THEN** the attack is canceled, `weakpoint_interrupted` fires granting `+22.0⚡` Overcharge, and the Elite/Boss enters `VULNERABLE_STAGGER` (`1.8s` stun, `1.30x` damage taken).
- **GIVEN** a Boss with a destructible `BossPartNode` (*Left Missile Pod*, `350 HP`), **WHEN** the part's HP is reduced to `0.0`, **THEN** the missile pod attack timeline is permanently disabled for the rest of the encounter and the Boss immediately suffers a `+22.0⚡` Part-Break Interrupt.
- **GIVEN** a Boss with `2000 Max HP` (`18%` DPS soft-cap = `360 DMG/s`), **WHEN** the player deals `400 DMG` within `0.5s`, **THEN** subsequent standard shots within that `1.0s` window are attenuated to `35%` damage, whereas a Weak-Point Interrupt hit deals `100%` un-attenuated damage.
- **GIVEN** the player defeats a Stratum Boss while taking `0` Armor or HP damage during the room, **WHEN** the Boss dies, **THEN** a **Master Chamber Core** spawns granting `+1 Max HP Heart` and `+15.0⚡ Max Overcharge`.

## Open Questions

- *None — the 3-Tier AI hierarchy, Elite component plugins, 4D Boss customization hooks, and DPS soft-cap rules are locked.*
