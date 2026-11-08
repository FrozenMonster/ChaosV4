# Tactical Micro-HUD & Screen UI System

> **Status**: Approved
> **Author**: user + ux-designer + ui-programmer + art-director + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 3 (Reload & Swap Are Offensive Verbs), Pillar 4 (Zero-Filler High-Stakes Routing)

## Summary

Governs the two-tier combat interface at `1280×720`: (1) the **`64px` Player-Proximate Micro-HUD** (weapon-specific overhead Active Reload slider, Final Round pip, Heavy Ready bracket, and Graze ring rendered in pure flat geometry with zero decorative clutter); and (2) the **Screen-Perimeter HUD** featuring the **Overcharge Aegis Shield (`🛡️` + `3-Pip` active reconstruction gauge)**, **4-Mode Room Objective Tracker**, **`45/65/90⚡` Overcharge bar**, **7-Slot Loadout panels**, **Hades-style exit crests with off-screen edge wayfinders**, and the **zero-pause `[7]/[8]/[9]/[G]` Swap-and-Salvage strip**.

> **Quick reference** — Layer: `Presentation` · Priority: `MVP` · Key deps: `Player 3C, Dodge-Graze & Tactical Arena Interactables`, `Dual-Gun, Active Reload & Overcharge Engine`, `7-Slot Loadout & Tactical Items System`, `3-Door Routing, Overdrive Bet & Floor Generator`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Tactical Micro-HUD & Screen UI System** translates every combat, survival, and routing state of **CHAMBER OVERDRIVE (膛室超载)** into zero-latency visual feedback without forcing the player's eyes away from incoming bullet curtains:
1. **Crosshair/Player-Proximate `64px` Micro-HUD ("Proximate Geometry")**: High-frequency combat states—the weapon-specific Active Reload sweet-spot slider (`[R]`), Final Round indicator (`ammo == 1`), `RMB` Heavy Ready bracket, and `Space` Graze Ring—sit within `64.0 px` of the player character or crosshair, rendered as ultra-clean flat geometric shapes (`Z = 50`, `Alpha <= 85%`) that never obscure enemy projectiles.
2. **Cohesive Perimeter HUD & Dynamic Objective / Wayfinder Telemetry**: Screen corners house the **Red Heart HP (`❤️`)**, **Overcharge Aegis Shield (`🛡️` + `3-Pip [□][□][□]` active recharge bar)**, **`🪙 Bounty Chips`**, **`45/65/90⚡` Overcharge Gauge**, **7-Slot Loadout**, and a **4-Mode Room Objective Tracker** (`EXTERMINATION`, `SABOTAGE_BEACONS`, `OVERDRIVE_SURVIVAL`, `CONDUIT_UPLOAD`). In non-rectangular rooms (L-Bend, Ring-Pit, Twin-Bridge), edge-clamped neon wayfinder arrows automatically guide the player toward off-screen Signal Beacons during combat and off-screen *Hades*-style exit doors upon room clear.

## Detailed Design

*(Note: `ux-designer` and `ui-programmer` consulted for focal hierarchy, Steam Deck `12px+` CJK legibility, and off-screen wayfinder projection.)*

### Core Rules

1. **Zone 1: Player-Proximate `64px` Micro-HUD (`Z = 50` — Zero Decorative Chrome)**:
   - **Overhead Weapon-Specific Active Reload Slider (`[R]`)**:
     - Appears at `player_pos + Vector2(-36, -36)` (`72×8px`) **only while `is_reloading == true`**, fading out within `0.15s` of completion.
     - Dynamically renders the active `PrimaryWeaponData` sweet-spot bracket (`0.22–0.40` early left for Twin-SMG, `0.42–0.62` centered for Revolver, `0.65–0.81` late right for Pump-Shotgun, widened `+0.08` with *Chrono Slide-Stop*).
     - On **Perfect Reload**, flashes Amber-Cyan and expands a micro-ring; on **Jammed Reload**, turns smoky crimson (`#78716C` / `#FF2A4B`), jitters horizontally (`±4.0 px`), and displays `[卡壳延迟]`.
   - **Crosshair & Muzzle Micro-Pips**:
     - **Final Round Pip (`ammo == 1`)**: `10×10px` glowing Amber Gold (`#FFB800`) bullet badge anchored `18px` right of the crosshair with a `★尾弹` micro-callout.
     - **Heavy Spender Ready Bracket (`overcharge >= heavy_cost` & `heavy_cd <= 0.0`)**: Cyan-Gold outer brackets `(( + ))` around the crosshair that snap in with a `0.12s` hydraulic pulse when `RMB` is ready to fire.
2. **Zone 2: Top-Left Survival, Overcharge Aegis Shield (`3-Pip`) & Bounty Chip Panel**:
   - **Red Heart HP (`❤️`)**: `6` discrete segmented crimson heart cores (`16×16px` each). Flashes red-violet if struck by a **`SHIELD_PIERCING`** Elite/Boss signature attack.
   - **Overcharge Aegis Shield (`🛡️`) & 3-Pip Reconstruction Sub-Bar (`[□][□][□]`)**:
     - Displays active shield plates (`1/1 🛡️` base, `2/2 🛡️` max). While `aegis_shield > 0`, a subtle cyan hexagonal rim frames the HP bar (`Hitless Boss Protected` indicator).
     - When `aegis_shield < max_aegis_shield`, a **3-Pip Reconstruction Bar (`[■][■][□]`)** appears directly beneath the shield icon, filling `+1 Pip` on each **`RMB` Heavy cast**, **Elite/Boss Weak-Point Interrupt**, or **3rd `[R]` Perfect Reload** (and showing `⚡完美换弹 (2/3)` progress). Reaching `3/3` Pips plays a hexagonal shield-lock animation and restores `+1 🛡️`!
   - **Bounty Chips Counter (`🪙 悬赏工分币`)**: Tabular monospaced counter (`18px` Bold) that scales `1.25x -> 1.0x` whenever Chips are magnet-collected or salvaged.
3. **Zone 3: Top-Right 4-Mode Room Objective Tracker & Boss Bar**:
   - Dynamically adapts to the active `RoomObjectiveType` from `door-routing-and-floor-gen.md`:
     1. **`EXTERMINATION` (歼灭战)**: `👾 剩余敌军: X (第 1/2 波)`.
     2. **`SABOTAGE_BEACONS` (破坏信标房)**: `📡 摧毁巨企信标: [■][■][□] (剩余 1 座 — 击破即全屏清场!)` + edge-clamped target arrows pointing to surviving off-screen Beacons.
     3. **`OVERDRIVE_SURVIVAL` (高压倒计时生存房)**: High-contrast pulsing countdown timer `⏱️ 车间清场倒计时: 16.5s (坚持到底全灭敌军!)`, shifting to Amber Gold in the final `5.0s`.
     4. **`CONDUIT_UPLOAD` (终端超载上传房)**: Progress bar `⚡ 数据终端上传: 74% (圈内完美换弹/击杀 +12%!)`.
   - **Boss Encounter Header (Top-Center)**: During Node 7 Boss or Rival Ambush fights, displays the Boss health bar with `65%` / `30%` phase dividers, active `BossPartNode` sub-bars, and a golden **`★ 无伤大师核心合格 (Hitless Eligible)`** badge (which stays lit even if `Overcharge Aegis Shield` absorbs a normal hit, and shatters only if Red Heart `hp` is lost or pierced by `SHIELD_PIERCING`!).
4. **Zone 4: Bottom Perimeter Overcharge Gauge (`45 / 65 / 90⚡`) & 7-Slot Loadout Bar**:
   - **Bottom-Left Overcharge Bar (`0–100⚡` / `130⚡`) & 3 Armory Slots**:
     - `260×18px` chamfered bar with hard vertical threshold ticks at **`45⚡` (Light)**, **`65⚡` (Medium)**, and **`90⚡` (Ultimate)**. Crossing the equipped Heavy Weapon's cost tick triggers a `0.12s` hydraulic bounce (`1.22x` scale) on the Heavy slot icon.
     - Displays `Slot_Primary` (name + `ammo / mag_size`), `Slot_Heavy` (name + `cost⚡` + cooldown overlay), and `Slot_Dynamo` (name + burst `+⚡` badge).
   - **Bottom-Right 4 Tactical Item Slots (`[Q]` Active + `[7]/[8]/[9]` Passives)**:
     - `Slot_Active` (`[Q]`) displays radial cooldown sweep (`READY [Q]` when `0.0s`).
     - `Slot_Passives[0..2]` (`[7]`, `[8]`, `[9]`) flash their border whenever their `When -> If -> Do` hook fires.
5. **Zone 5: Distributed Exit Header Cards, Off-Screen Wayfinders & Inline `[7]/[8]/[9]/[G]` Swap Banner**:
   - **Off-Screen Edge Wayfinder Arrows**: Whenever an active Signal Beacon (during `SABOTAGE_BEACONS`) or an unlocked `DoorSocket` exit (during `ROOM_CLEARED_ROUTING`) lies outside the camera viewport, a compact badge clamps to the screen margin (`36px` inset) pointing along the target vector (`↗ 【1】军械门 [可押注]`, `⬅ 【3】老雷克斯黑市`).
   - **On-Screen *Hades*-Style Door Header Cards (`96×54px`)**: Floating above each visible unlocked exit, showing Category Crest, Reward Preview, and **`[E] 进门 | [F] 押注 25⚡ (双倍赏金币 & 二选一宝箱)`**.
   - **Inline Swap-and-Salvage Strip (`AWAITING_PASSIVE_SWAP`)**: When standing near a 4th Passive Relic drop, a non-blocking bottom-center banner displays the candidate Relic alongside **`[7] 替换槽1 (+20🪙) | [8] 替换槽2 (+20🪙) | [9] 替换槽3 (+20🪙) | [G] 直接粉碎核销 (+20🪙)`**.

### States and Transitions

| UI / HUD State | Condition | Allowed Transitions | Active HUD Layers |
| :--- | :--- | :--- | :--- |
| **`COMBAT_HUD_ACTIVE`** | `room_cleared == false` in standard/elite room | $\rightarrow$ `BOSS_HUD_ACTIVE` on Boss/Rival spawn<br>$\rightarrow$ `ROUTING_HUD_ACTIVE` on `room_cleared` | `64px` Micro-HUD + Perimeter 7-Slot & Aegis Shield bars + Top-Right Room Objective Tracker (+ Beacon wayfinders if `SABOTAGE_BEACONS`). |
| **`BOSS_HUD_ACTIVE`** | Active Stratum Boss or Rival Hidden Boss | $\rightarrow$ `ROUTING_HUD_ACTIVE` on Boss defeat | Adds Top-Center Boss Bar with `65%/30%` phase notches, `BossPartNode` durability bars, and `★ 无伤大师核心合格` status badge. |
| **`ROUTING_HUD_ACTIVE`** | `room_cleared == true` (`1–3` exits unlocked) | $\rightarrow$ `PASSIVE_SWAP_OVERLAY` when approaching 4th Passive drop<br>$\rightarrow$ `COMBAT_HUD_ACTIVE` on entering next door | Hides combat objective tracker; activates *Hades*-style Door Header Cards (in-view) and edge-clamped Door Wayfinder Arrows (off-screen). |
| **`PASSIVE_SWAP_OVERLAY`** | `Slot_Passives.size() == 3` near uncollected Relic | $\rightarrow$ `ROUTING_HUD_ACTIVE` after `[7]/[8]/[9]` swap or `[G]` salvage | Pops up the non-blocking bottom-center `[7]/[8]/[9]/[G]` comparison strip without pausing player movement. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Upstream Producer | Subscribes at Stage 4 (`Priority 400`) to `reload_started`, `perfect_reload_triggered`, `overcharge_changed`, `bounty_chips_changed`, `loadout_changed`, `room_cleared` | `Combat Event Bus & Data Schema` |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Upstream Producer | Supplies `player_pos`, `in_iframes`, `effective_graze_radius`, and `[E]` proximity interactable prompts | `Tactical Micro-HUD & Screen UI System` |
| **Pooled Bullet-Hell & Damage System** | Upstream Producer | Supplies `hp`, `aegis_shield`, `aegis_pips (0..3)`, `is_shield_piercing` warning state, and floating damage/crit callout events | `Tactical Micro-HUD & Screen UI System` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Upstream Producer | Supplies weapon-specific `[sweet_start, sweet_end]`, `reload_progress`, `ammo`, and `45/65/90⚡` Heavy thresholds | `Tactical Micro-HUD & Screen UI System` |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Upstream Producer | Supplies active `RoomObjectiveType` progress and world coordinates of distributed `DoorSocket` exits & Signal Beacons | `Tactical Micro-HUD & Screen UI System` |

## Formulas

*(Note: `systems-designer` consulted for off-screen wayfinder viewport clamping and combat popup scaling math.)*

### 1. Off-Screen Wayfinder Margin Projection (`wayfinder_screen_pos`)

When a target world position `target_world_pos` (an off-screen `DoorSocket` or Signal Beacon) lies outside the active camera viewport rectangle, its edge-clamped screen indicator position is computed via ray-box intersection against the inset safe-margin rectangle:

`dir_vec = normalize(target_world_pos - camera_center_world)`

`t_edge = min((SAFE_HALF_W - abs(0.0)) / max(0.001, abs(dir_vec.x)), (SAFE_HALF_H - abs(0.0)) / max(0.001, abs(dir_vec.y)))`

`wayfinder_screen_pos = SCREEN_CENTER + dir_vec * t_edge`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `SCREEN_CENTER` | Vector2 | `(640.0, 360.0)` | constant | Center of the `1280×720` logical viewport |
| `SAFE_HALF_W` | float | `604.0` | data file | Half-width of the safe indicator boundary (`640.0 - 36.0 px` margin inset) |
| `SAFE_HALF_H` | float | `280.0` | data file | Half-height of the safe indicator boundary (inset above/below perimeter HUD bars) |
| `dir_vec` | Vector2 | unit vector | calculated | Normalized direction from camera center to off-screen door or beacon |
| `t_edge` | float | `280.0–665.0` | calculated | Ray distance from screen center to the first intersected safe-margin edge |

**Output Range:** Screen coordinates strictly clamped along the perimeter of `Rect2(36, 80, 1208, 560)`, never overlapping top/bottom HUD bars.
**Example:** In an L-Bend room, the East `ARMORY_DOOR` is off-screen directly to the right (`dir_vec = (1.0, 0.0)`). `t_edge = min(604.0 / 1.0, 280.0 / 0.001) = 604.0`. `wayfinder_screen_pos = (640, 360) + (604, 0) = (1244, 360)`, placing the `➡ 【1】军械门` badge neatly along the right screen edge.

---

### 2. Tiered Floating Combat Text Scale & Decay (`popup_render_scale`)

To visually separate standard hits (`Tier 1`) from Final Rounds, Heavy Weapons, and Weak-Point Interrupts (`Tier 2/3`) without obscuring bullets, floating combat text scale over its lifetime `t_elapsed` (`0.0s` to `POPUP_DURATION = 0.85s`) is defined as:

`popup_render_scale = (1.0 + CRIT_INITIAL_BOOST * int(is_crit_or_interrupt) * max(0.0, 1.0 - t_elapsed / CRIT_SNAP_TIME))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `is_crit_or_interrupt` | bool | `true/false` | calculated | True for Final Round hits, `RMB` Heavy hits, and Elite/Boss Weak-Point Interrupts |
| `CRIT_INITIAL_BOOST` | float | `0.45` | data file | `+45%` initial pop-in scale (`1.45x`) for critical/interrupt callouts |
| `CRIT_SNAP_TIME` | float | `0.16` | data file | Duration (`0.16s`) over which the `1.45x` pop-in snaps down to `1.0x` |
| `t_elapsed` | float | `0.0–0.85` | calculated | Time elapsed since the popup spawned |

**Output Range:** `1.0x` (`14px`) for standard hits; `1.45x -> 1.0x` (`18px` base -> `26px` peak pop) for crits and interrupts.
**Example:** Player lands a Peacemaker Final Round (`is_crit_or_interrupt = true`). At `t_elapsed = 0.0s`, `popup_render_scale = 1.0 + 0.45 * 1.0 = 1.45x` in Amber Gold (`★尾弹暴击 -90!`), snapping to `1.0x` over `0.16s` while drifting upward.

## Edge Cases

- **If the player stands near the top border of the arena (`player_pos.y < 135.0`) while reloading**: The overhead Active Reload bar (`normally at Y: -36px`) flips automatically below the player's feet (`Y: +28px`) so it is never clipped by the top perimeter HUD bar or screen edge.
- **If rapid-fire Twin-SMG shots generate 10+ damage popups on the same enemy within `0.5s`**: Each new popup applies a alternating horizontal fan offset (`±18.0 px`) and recycles the oldest popup on that enemy if active popups exceed `6`, preventing an unreadable wall of overlapping numbers.
- **If an Elite or Boss begins a `SHIELD_PIERCING` signature wind-up while the player has `aegis_shield > 0`**: The Weak-Point reticle flashes with a distinct **`⚠️破盾穿甲! 重击打断 (+22⚡)`** warning tag in crimson-violet (`#FF0055`), explicitly warning the player that their Aegis Shield will NOT block this attack if left un-interrupted.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Subscribes to Stage 4 (`Priority 400`) UI update signals |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Depends on (Upstream) | Hard | Reads `player_pos`, Graze Ring state, and `[E]` interactable prompt data |
| **Pooled Bullet-Hell & Damage System** | Depends on (Upstream) | Hard | Reads `hp`, `aegis_shield`, `aegis_pips`, `is_shield_piercing`, and damage popup events |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depends on (Upstream) | Hard | Reads weapon-specific `[sweet_start, sweet_end]`, `reload_progress`, and `45/65/90⚡` thresholds |
| **7-Slot Loadout & Tactical Items System** | Depends on (Upstream) | Hard | Reads 7-Slot loadout data and `AWAITING_PASSIVE_SWAP` candidate data |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Depends on (Upstream) | Hard | Reads `RoomObjectiveType` progress and `DoorSocket` / Signal Beacon world coordinates |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 4, 7, and 8.)*

- **"Perimeter Chrome, Proximate Geometry" Contract**:
  - `64px` Micro-HUD elements use pure flat geometric bars with `1px` `#080A0F` outlines (`Alpha <= 85%`, zero ornamental rivets).
  - Perimeter HUD panels use `45°` chamfered `#0D1017` dark-slate plates (`85%` opacity) with crisp CJK typography (`Noto Sans CJK SC` / `STHeiti Medium`, hard minimum font size **`12px`** at `1280×720` for Steam Deck legibility).
- **Audio Cues**:
  - Subtle hydraulic tick when Overcharge crosses `45⚡ / 65⚡ / 90⚡`; crystalline hexagonal lock chime when `aegis_pips` reaches `3/3` and restores `+1 🛡️` Overcharge Aegis Shield.

📌 **Asset Spec** — Visual/Audio requirements are defined for all HUD panels, 3-Pip Aegis Shield indicators, and wayfinder badges.

## Game Feel

- **Eyes Stay Locked on the Action**: Because reload sweet spots, Final Round state, Heavy Weapon readiness, and Graze arcs sit within `64px` of the player/crosshair, players never get hit because they were squinting at a corner ammo counter.
- **Tangible "Offense Rebuilds Defense" Feedback**: Watching the `3-Pip [■][■][□]` Aegis bar light up each time you land a Perfect Reload chain or unleash a Heavy Weapon—and hearing the shield snap back online mid-fight—creates an addictive survival rhythm.

## UI Requirements

- Consolidates all HUD and on-screen telemetry requirements across all 8 MVP systems into a single `CanvasLayer` / batched `Node2D` overlay at `Z = 50`.

> **📌 UX Flag — Tactical Micro-HUD & Screen UI System**: In Pre-Production, `/ux-design` will reference this GDD to produce `design/ux/hud.md` and `design/accessibility-requirements.md`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/bullet-hell-damage-system.md` | `aegis_shield` (`1/1 🛡️`), `aegis_pips` (`3-Pip` active recharge), `is_shield_piercing` | Yes — HUD directly renders the 3-Pip Aegis reconstruction bar and piercing warning |
| `design/gdd/dual-gun-overcharge-engine.md` | Weapon-specific `sweet_spot_start/end` (`0.22–0.40` SMG, `0.42–0.62` Revolver, `0.65–0.81` Shotgun), `45/65/90⚡` Heavy costs | Yes — overhead slider and Overcharge bar ticks match 100% |
| `design/gdd/door-routing-and-floor-gen.md` | 4 `RoomObjectiveType` modes, distributed `DoorSocket` wayfinders, `[F]` `-25⚡` Overdrive Bet | Yes — Top-Right tracker and edge wayfinders cover all 4 room modes and off-screen exits |
| `design/art/art-bible.md` | Section 7 (`64px` Micro-HUD, `12px` minimum font size, colorblind shape backups) | Yes — full compliance |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** the player switches between Twin-SMG (`0.22–0.40`), Revolver (`0.42–0.62`), and Pump-Shotgun (`0.65–0.81`) and triggers a reload, **WHEN** the overhead Active Reload bar renders at `Z = 50`, **THEN** the yellow sweet-spot bracket dynamically positions and scales to match the active weapon's exact range (and flips to `Y: +28px` below the player if `player_pos.y < 135.0`).
- **GIVEN** the player's Overcharge Aegis Shield is broken (`aegis_shield == 0`, `aegis_pips == 0`), **WHEN** the player performs 1 `RMB` Heavy cast (`+1 Pip`), 1 Elite Weak-Point Interrupt (`+1 Pip`), and 3 combat Perfect Reloads (`+1 Pip`), **THEN** the top-left reconstruction bar advances `[■][□][□] -> [■][■][□] -> [■][■][■]` and immediately restores `aegis_shield = 1`.
- **GIVEN** an active room with `RoomObjectiveType = SABOTAGE_BEACONS` or `ROOM_CLEARED_ROUTING` where a Signal Beacon or unlocked `DoorSocket` lies outside the `1280×720` camera view, **WHEN** `wayfinder_screen_pos` is evaluated, **THEN** a directional neon wayfinder badge clamps cleanly along `Rect2(36, 80, 1208, 560)` pointing to the off-screen target.
- **GIVEN** a Boss fight where the player's `aegis_shield` absorbs a normal projectile (`is_shield_piercing == false`, `hp` remains `6/6`), **WHEN** the Boss header UI updates, **THEN** the `★ 无伤大师核心合格` badge remains active; whereas if hit by an un-interrupted `is_shield_piercing == true` attack (`hp` drops to `5/6`), the badge immediately marks Hitless as failed.

## Open Questions

- *None — all 5 HUD zones, the 3-Pip Overcharge Aegis Shield bar, 4-Mode Objective Tracker, and off-screen wayfinder formulas are locked.*
