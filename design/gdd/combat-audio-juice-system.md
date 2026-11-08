# Combat Audio & Procedural Juice System

> **Status**: Approved
> **Author**: user + sound-designer + technical-artist + game-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs)

## Summary

Orchestrates the 4-Bus Audio Hierarchy with **Sidechain Ducking (`-4.0 dB` for `0.20s` so critical Final Round, Perfect Reload, Graze, and Weak-Point Interrupt cues are never masked)**, **Pitch-Escalation Dopamine Ladders** for consecutive Perfect Reloads and Dodge Grazes, **2-Layer Adaptive Overdrive BGM**, and the **Procedural Visual Juice Pipeline** (spring squash-and-stretch, directional camera kick, capped screen shake `<= 18.0 px`, and pooled `Z = 5` brass shell casings / robot debris).

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Combat Event Bus & Data Schema`, `Pooled Bullet-Hell & Damage System`, `Dual-Gun, Active Reload & Overcharge Engine`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Combat Audio & Procedural Juice System** delivers the visceral sensory punch ("Sensation" aesthetic) of **CHAMBER OVERDRIVE (膛室超载)** while strictly obeying **Pillar 1 (Sacrosanct 3C & Bullet Readability)**:
1. **4-Bus Audio Mix with Critical Cue Supremacy (Sidechain Ducking)**: In a fast twin-stick bullet-hell, audio is a primary gameplay telegraph. High-priority cues (`Final Round` chamber click, `[R] Perfect Reload` electric lock, `Space` Graze zip, `3/3` Aegis Shield reconstruction chime, and Elite/Boss `SHIELD_PIERCING` wind-up sirens) route through the `SFX_Combat_Critical` bus, automatically ducking BGM and standard gunfire by **`-4.0 dB` for `0.20s`** so the player can play by ear even in chaotic rooms.
2. **Pitch-Escalation Dopamine & Procedural Visual Juice**: Consecutive skill actions—such as grazing 2–3 bullets in a single roll or chaining 3 consecutive Perfect Reloads to reconstruct an Overcharge Aegis Shield—climb a musical semitone **Pitch Ladder (`1.00x -> 1.12x -> 1.25x`)**. Visually, every shot, dodge, and impact drives a zero-allocation procedural juice layer: spring squash-and-stretch deformations, directional camera recoil kicks, capped trauma shake (`<= 18.0 px`), and a persistent floor pool of spinning brass shell casings and blasted robot parts at `Z = 5` (`Value <= 32%`).

## Detailed Design

*(Note: `sound-designer` and `technical-artist` consulted for bus routing, polyphony caps, and procedural spring math.)*

### Core Rules

1. **4-Bus Audio Architecture & Sidechain Ducking Priority**:
   - All game audio routes through four dedicated `AudioServer` buses under `Master`:

| Audio Bus Name | Priority Tier | Routed Cues & Polyphony Cap | Mixing & Sidechain Ducking Rule |
| :--- | :--- | :--- | :--- |
| **1. `SFX_Combat_Critical`** | **Tier 1 (Highest)**<br>`0.0 dB` Base | • `ammo == 1` Final Round chamber click<br>• `[R]` Perfect Reload chime & Jam buzz<br>• `Space` Dodge Graze electric zip<br>• Elite/Boss `WEAKPOINT_WINDUP` siren & Interrupt blast<br>• `3/3` Aegis Shield lock & `LEGENDARY` drop fanfare<br>*(Max Polyphony: `8`)* | **Never ducked or culled.** Triggers a sidechain compressor on `SFX_Weapons_Impacts` and `BGM_Adaptive` (`-4.0 dB` attack `0.015s`, release `0.20s`). |
| **2. `SFX_Weapons_Impacts`** | **Tier 2**<br>`-2.5 dB` Base | • Standard `LMB` gunfire (`±6%` random pitch)<br>• `Final Round` cannon punch<br>• `RMB` Heavy Spender (`45/65/90⚡`) sub-bass blasts<br>• Enemy hit ticks & hazard explosions<br>*(Max Polyphony: `12`)* | Ducked `-4.0 dB` when `SFX_Combat_Critical` fires; per-cue minimum re-trigger interval of `0.035s` prevents phasing distortion during rapid Twin-SMG fire. |
| **3. `UI_And_Routing`** | **Tier 3**<br>`-1.5 dB` Base | • `🪙 Bounty Chip` pickup/salvage register ticks<br>• `[F]` Overdrive Bet hydraulic clamp slam<br>• *Hades*-style room-clear chime & Shop/Forge UI | Clean stereo mixes; unaffected by combat camera panning. |
| **4. `BGM_Adaptive`** | **Tier 4**<br>`-6.0 dB` Base | • **Layer A (`Stem_Base_Groove`)**: Driving industrial synth-rock rhythm<br>• **Layer B (`Stem_Overdrive_Lead`)**: High-voltage distorted synth/guitar lead | Crossfades Layer B to `0.0 dB` (`0.4s` fade) during **Overdrive Bet rooms**, **`OVERDRIVE_SURVIVAL` timers**, and **Boss Phases 2–3**; applies a `900 Hz` low-pass filter when `room_cleared == true` or inside Pit-Stops. |

2. **Pitch-Escalation Dopamine Ladders (连击音高阶梯)**:
   - **Dodge-Roll Graze Ladder**: Within a single `Space` roll (`max 2–3 grazes`), each successive grazed bullet scales `sfx_combat_graze.wav` pitch to **`1.00x` (1st) $\rightarrow$ `1.12x` (2nd) $\rightarrow$ `1.26x` (3rd)**.
   - **Perfect Reload & Aegis Reconstruction Ladder**: Chaining consecutive combat Perfect Reloads scales `sfx_weapon_perfect_reload.wav` pitch across **`1.00x` (1/3) $\rightarrow$ `1.08x` (2/3) $\rightarrow$ `1.18x` + Crystalline Shield Lock Chord (3/3)** when an Aegis Shield Pip is awarded!
   - **Bounty Chip Magnet Ladder**: Rapidly vacuuming dropped `🪙 Bounty Chips` steps pitch from `0.95x` up to `1.35x` (`+0.03x` per chip within `0.4s`).
3. **Procedural Visual Juice Pipeline (Zero-Allocation & Pillar-1 Safe)**:
   - **Spring Squash & Stretch (`sprite_scale_spring`)**:
     - `Space` Dodge Launch: `Vector2(1.22, 0.80)` snapping back over `0.12s`.
     - `[R]` Perfect Reload Snap: Weapon sprite scales `Vector2(1.30, 1.30) -> Vector2(1.0, 1.0)` over `0.10s`.
     - `RMB` Heavy Unleash (`45/65/90⚡`): Player body compresses `Vector2(0.80, 1.18)` alongside the `8/16/22 px` backward recoil slide.
   - **Directional Camera Kick + Trauma Shake (`<= 18.0 px` Hard Cap)**:
     - Firing applies an instant directional camera offset opposite `aim_dir` (`2.0 px` Standard, `6.5 px` Final Round, `12.0–18.0 px` Heavy Spender) that decays smoothly at `32.0 px/s`, layered with rotational/translational trauma shake hard-capped at **`MAX_SHAKE_OFFSET = 18.0 px`** (multiplied by user Accessibility `screen_shake_scale` `0.0–1.0`).
   - **Persistent Floor Battlefield Scars Pool (`Z = 5`, `Value <= 32%`)**:
     - Pre-allocated ring buffer of **`80` Brass Shell Casings** (`6×3px` standard brass; `8×4px` glowing ember casing on `Final Round`) and **`40` Robot Debris Chunks** (blasted in a `45°` cone along `aim_dir` on Heavy/Final kills).
     - All floor decals and casings render strictly at `Z = 5` with luminance **`Value <= 32%`** so they never compete with `Z = 40` enemy projectiles.

### States and Transitions

| Audio & Juice State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`COMBAT_STANDARD_MIX`** | `room_cleared == false`, normal room | $\rightarrow$ `COMBAT_OVERDRIVE_MIX` on Overdrive Bet / Survival / Boss P2+<br>$\rightarrow$ `CRITICAL_CUE_DUCKING` on Tier-1 cue<br>$\rightarrow$ `SANCTUARY_LOWPASS_MIX` on `room_cleared` | `Stem_Base_Groove` active; standard trauma decay and casing ejection active. |
| **`COMBAT_OVERDRIVE_MIX`** | `has_overdrive_bet == true` OR `OVERDRIVE_SURVIVAL` OR Boss Phase $\ge 2$ | $\rightarrow$ `CRITICAL_CUE_DUCKING` on Tier-1 cue<br>$\rightarrow$ `SANCTUARY_LOWPASS_MIX` on `room_cleared` | Unmutes `Stem_Overdrive_Lead` (`0.4s` crossfade); adds subtle peripheral pulse on beat. |
| **`CRITICAL_CUE_DUCKING`** | Tier-1 `SFX_Combat_Critical` cue triggered (`0.20s` window) | $\rightarrow$ Prior combat mix state after `0.20s` | Attenuates `SFX_Weapons_Impacts` and `BGM_Adaptive` by `-4.0 dB` so the critical telegraph cuts through 100% clearly. |
| **`SANCTUARY_LOWPASS_MIX`** | `room_cleared == true` or inside Node 4 Pit-Stop | $\rightarrow$ `COMBAT_STANDARD_MIX` / `COMBAT_OVERDRIVE_MIX` on next combat room start | Applies `900 Hz` low-pass filter to BGM (`-3.0 dB`); plays Old Rex grill sizzle / Bucky anvil ambience in Pit-Stops. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Upstream Producer | Subscribes at Stage 4 (`Priority 400`) to all weapon, reload, graze, interrupt, kill, and door signals | `Combat Event Bus & Data Schema` |
| **Pooled Bullet-Hell & Damage System** | Upstream Producer | Triggers Tier 1/2/3 ballistic hit SFX, `0.03s–0.055s` hitstop, directional debris cones, and Aegis Shield break/reconstruct cues | `Combat Audio & Procedural Juice System` |
| **Dual-Gun, Active Reload & Overcharge Engine** | Upstream Producer | Drives Final Round pre-chamber click, Perfect Reload pitch ladder, and Heavy Spender sub-bass booms | `Combat Audio & Procedural Juice System` |

## Formulas

*(Note: `systems-designer` and `sound-designer` consulted for pitch-escalation and camera kick/shake clamping math.)*

### 1. Streak Pitch-Escalation Multiplier (`streak_pitch_scale`)

For consecutive skill actions (Dodge Grazes within a roll, consecutive Perfect Reloads toward an Aegis Pip, or rapid Bounty Chip pickups), playback `pitch_scale` is computed as:

`streak_pitch_scale = clamp(BASE_PITCH + PITCH_STEP_PER_STACK * float(streak_count - 1) + randf_range(-PITCH_JITTER, PITCH_JITTER), MIN_PITCH_FLOOR, MAX_PITCH_CEILING)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `BASE_PITCH` | float | `1.00` | data file | Starting pitch multiplier for the 1st action in a streak |
| `PITCH_STEP_PER_STACK` | float | `0.03–0.12` | data file | Pitch increment per stack (`0.12` for Graze, `0.08` for Perfect Reload, `0.03` for Bounty Chips) |
| `streak_count` | int | `1–15` | calculated | Current consecutive action count |
| `PITCH_JITTER` | float | `0.00–0.05` | data file | Random variation (`0.05` for standard `LMB` gunfire, `0.0` for pitched streak ladders) |
| `MIN_PITCH_FLOOR` | float | `0.85` | constant | Minimum allowed playback pitch |
| `MAX_PITCH_CEILING` | float | `1.40` | constant | Maximum allowed playback pitch (prevents shrill aliasing) |

**Output Range:** `0.85x` to `1.40x` playback pitch.
**Example:** Grazing 3 bullets in one roll (`BASE_PITCH = 1.00`, `PITCH_STEP_PER_STACK = 0.12`, `PITCH_JITTER = 0.0`):
- 1st Graze (`streak_count = 1`): `1.00x`
- 2nd Graze (`streak_count = 2`): `1.12x`
- 3rd Graze (`streak_count = 3`): `1.24x`

---

### 2. Combined Directional Camera Kick & Trauma Shake Offset (`final_camera_offset`)

Each rendered frame, the camera displacement vector `final_camera_offset` is bounded by:

`raw_offset = (-aim_dir * directional_kick_px) + Vector2(randf_range(-trauma_shake, trauma_shake), randf_range(-trauma_shake, trauma_shake))`

`final_camera_offset = raw_offset.limit_length(MAX_SHAKE_OFFSET) * user_screen_shake_setting`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `aim_dir` | Vector2 | unit vector | calculated | Normalized player aim direction |
| `directional_kick_px` | float | `0.0–18.0` | calculated | Recoil kick (`2.0` Standard, `6.5` Final Round, `12.0–18.0` Heavy Spender), decaying at `35.0 px/s` |
| `trauma_shake` | float | `0.0–16.0` | calculated | Omnidirectional explosion/hit shake, decaying at `28.0 px/s` |
| `MAX_SHAKE_OFFSET` | float | `18.0` | constant | Hard ceiling (`18.0 px`) preventing disorienting screen displacement |
| `user_screen_shake_setting` | float | `0.0–1.0` (default `1.0`) | data file | Player accessibility slider (`0%` to `100%` screen shake) |

**Output Range:** `0.0 px` to `18.0 px` maximum displacement.
**Example:** Player fires a `65⚡` Railgun (`directional_kick_px = 14.0`) that simultaneously detonates a Fuel Drum (`trauma_shake = 12.0`). Even if `raw_offset` momentarily reaches `24.0 px`, `limit_length(18.0)` clamps it strictly to `18.0 px`.

## Edge Cases

- **If 8 enemies are hit on the exact same frame by a `90⚡` Black Hole or Fuel Drum blast**: The `SFX_Weapons_Impacts` bus deduplicates identical `sfx_combat_hit.wav` requests within a `0.035s` window into a single slightly louder (`+1.5 dB`) composite hit sound, preventing 8 overlapping waveforms from clipping the audio output.
- **If `hitstop_timer` (`0.03s–0.055s`) is active**: Audio playback and `BGM_Adaptive` **never pause or stutter** during hitstop frames—only gameplay physics and animations freeze for those `30–55ms`, keeping audio crisp and continuous.
- **If `shells.size()` exceeds `80` or `debris_list.size()` exceeds `40` in a long Survival or Boss room**: The ring buffer overwrites the oldest dormant floor decal (`O(1)` index wrap) with zero memory growth.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Depends on (Upstream) | Hard | Subscribes at Stage 4 (`Priority 400`) to all combat and routing signals |
| **Pooled Bullet-Hell & Damage System** | Depends on (Upstream) | Hard | Supplies Ballistic Tier `1 / 2 / 3` hit events and Aegis Shield state changes |
| **Dual-Gun, Active Reload & Overcharge Engine** | Depends on (Upstream) | Hard | Supplies `ammo == 1` pre-chamber state, Perfect Reload streaks, and Heavy Spender casts |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 1, 6, 8, and 9.)*

- All combat SFX use `44.1 kHz`, `16-bit PCM` `.wav` files for zero-latency triggering; adaptive music stems use seamless `.ogg` loops.
- Persistent floor casings and debris strictly obey `Z = 5` and `Value <= 32%`.

📌 **Asset Spec** — Audio bus specs, WAV cue list, and `Z = 5` battlefield scar limits are defined.

## Game Feel

- **Eyes-Closed Audio Telegraphy**: A player can hear the exact click when their gun reaches its Final Round (`ammo == 1`), hear the ascending chime of 3 consecutive Perfect Reloads locking their Overcharge Aegis Shield back into place, and hear an Elite's rising `SHIELD_PIERCING` siren over the music thanks to `-4.0 dB` sidechain ducking.

## UI Requirements

- **Settings Sliders**: Exposes `Master Volume`, `SFX Volume`, `BGM Volume`, and `Screen Shake Intensity (0%–100%)` in the Pause/Settings menu.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | Stage 4 (`Priority 400`) presentation listeners | Yes — executes after all Stage 1–3 math and physics |
| `design/gdd/bullet-hell-damage-system.md` | 3-Tier Ballistic Impact & Recoil Matrix, `3-Pip` Aegis Shield | Yes — matches hitstop (`0.03s–0.055s`) and camera kick values |
| `design/art/art-bible.md` | Section 8 (`Z = 5` Debris/Shells `Value <= 32%`, `.wav` / `.ogg` standards) | Yes — full compliance |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** `BGM_Adaptive` and `SFX_Weapons_Impacts` are playing at full combat volume, **WHEN** any cue on `SFX_Combat_Critical` triggers (`Perfect Reload`, `Dodge Graze`, `Weak-Point Interrupt`, or `Final Round`), **THEN** `BGM_Adaptive` and `SFX_Weapons_Impacts` attenuate by `-4.0 dB` for `0.20s` and recover smoothly.
- **GIVEN** the player performs 3 consecutive Dodge Grazes in a roll or 3 consecutive combat Perfect Reloads, **WHEN** each SFX plays, **THEN** playback `pitch_scale` increases strictly along the configured `streak_pitch_scale` ladder (`1.00x -> 1.12x -> 1.24x` for Graze; `1.00x -> 1.08x -> 1.18x` + Shield Lock chime for Reload).
- **GIVEN** simultaneous explosions and a `90⚡` Heavy Weapon shot occur on the same frame, **WHEN** `final_camera_offset` is computed, **THEN** total camera displacement never exceeds `18.0 px` (`0.0 px` when `user_screen_shake_setting == 0.0`).
- **GIVEN** a combat room where 200+ shots are fired and 15 enemies are destroyed, **WHEN** floor decals are inspected, **THEN** active shell casings never exceed `80` and debris chunks never exceed `40` at `Z = 5`.

## Open Questions

- *None — 4-Bus audio routing, sidechain ducking, pitch ladders, and procedural juice caps are locked.*
