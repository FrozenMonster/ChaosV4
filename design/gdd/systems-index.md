# Systems Index: CHAMBER OVERDRIVE (膛室超载)

> **Status**: Approved
> **Created**: 2026-11-08
> **Last Updated**: 2026-11-08
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

**CHAMBER OVERDRIVE (膛室超载)** is a top-down twin-stick bullet-hell action roguelite set on lawless Planet X, where a wise-cracking Space Gunboy battles through an ever-shifting subterranean cavern (from a 3-floor surface bait contract, down through a 10-stratum corporate conspiracy, and into an Endless Overdrive Loop powered by Sample Y). Mechanically, the game is built on four sacrosanct pillars: **Pillar 1 (Sacrosanct 3C Consistency)**, **Pillar 2 (Action Fuels Firepower)**, **Pillar 3 (Reload & Swap Are Offensive Verbs)**, and **Pillar 4 (Zero-Filler High-Stakes Routing)**.

To support this loop without spaghetti coupling or frame spikes during 500-bullet firefights, the game is decomposed into **11 modular systems** across 5 architectural layers:
1. **Combat Event Bus & Data Schema (inferred)**: Provides the foundational decoupled signal bus (`final_round_fired`, `perfect_reload_triggered`, `dodge_graze_triggered`, `weakpoint_interrupted`, `heavy_weapon_unleashed`) and typed `Resource` schemas so weapons, Dynamo Cores, and passive relics never hardcode references to each other.
2. **Player 3C, Dodge-Graze & Tactical Arena Interactables**: Locks base movement speed (`290 px/s`), 360° aiming, committed `Space` dodge-roll I-frames (`0.28s` I-frame + `0.14s` recovery), outer Graze absorption ring (`42px` radius), and unified **Proximity (`[E]`) & Ranged-Hit Tactical Arena Interactables** (`ArenaInteractableData` — deployable energy shields, overcharge capacitors, cryo-tanks, bullet-splitting prisms).
3. **Pooled Bullet-Hell & Damage System**: Pre-allocates 500+ enemy and player projectiles with zero runtime GC allocations, enforces the Three-Tier Luminance & Z-Index supremacy contract (`Z=40` for enemy threats), and resolves armor/HP damage, hit-flashes, and hitstop.
4. **Dual-Gun, Active Reload & Overcharge Engine**: Powers the core 30-second loop — `LMB` infinite-ammo primary weapon with Final-Round triggers, `[R]` overhead Active Reload sweet-spot slider (`+14⚡`), Two-Tier Overcharge harvesting (Tier-1 risk-weighted universal actions + Tier-2 Dynamo Cores), and instant `RMB` cost-tiered Heavy Spender weapons (`30 / 50 / 90⚡`).
5. **7-Slot Loadout & Tactical Items System**: Enforces the anti-bloat **7-Slot Loadout Schema** — 3 Armory slots (`1 Primary + 1 Heavy + 1 Dynamo Core`) and 4 Tactical Item slots (`1 Active Item [Q]` + `Max 3 Passive Items`, with `[7]/[8]/[9]` quick swap-and-salvage into **Bounty Chips / 悬赏工分币** when full).
6. **Enemy AI, Elite/Boss Interrupts & Boss System**: Drives enemy archetypes (Burst Bot, Ring Turret, Sniper Mech), **Elite & Boss-exclusive** high-visibility red-flash Weak-Point Interrupt windows (`+35⚡`), Boss DPS soft-cap resilience, and hitless Boss Master Chamber Core rewards.
7. **3-Door Routing, Overdrive Bet & Floor Generator**: Assembles zero-backtrack node-graph floors with 3 previewed forward door categories (**Armory Door**, **Tactical Item Door**, **Random Event Door**), pre-door `[F]` Overdrive Betting (`-25⚡` for 2x/upgraded rewards + elite hazards), and scalable progression from Floors 1–3 to Stratum 10 and the Sample Y Endless Loop (`Floor 11 -> ∞`).
8. **Pit-Stop, Bounty Chip Economy & Rival Cast System**: Manages **Bounty Chips (悬赏工分币)** currency, Old Rex's Black-Market Shop, Bucky's Rest/Forge Workbench, and the dynamic state machine turning fellow bounty hunters (like Vesper the Quota-Queen) between Pit-Stop NPCs, ambushing Hidden Bosses, and unlockable Playable Gunboys.
9. **Tactical Micro-HUD & Screen UI System (inferred)**: Renders the `64px` player-proximate Micro-HUD (Active Reload slider, Final Round pip, Graze ring) using pure flat geometry alongside perimeter 7-Slot HUD panels and 3-Door neon header cards.
10. **Combat Audio & Procedural Juice System (inferred)**: Orchestrates pitch-scaled arcade WAV SFX (gunshots, Final Round, Perfect Reload chime, Graze zip, Jam buzz), persistent floor brass shell casings, squash-and-stretch deformations, and directional screen shake.
11. **Save/Load, Ship Hub & Meta-Progression (inferred)**: Handles mid-run save states, the surface Bounty Ship Hub bar, unlockable Gunboy loadouts, Armory Codex flavor text, and Overdrive Protocol difficulty modifiers.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Combat Event Bus & Data Schema (inferred) | Core | MVP | Approved | design/gdd/combat-event-bus.md | — |
| 2 | Player 3C, Dodge-Graze & Tactical Arena Interactables | Core | MVP | Approved | design/gdd/player-3c-controller.md | — |
| 3 | Pooled Bullet-Hell & Damage System | Core | MVP | Approved | design/gdd/bullet-hell-damage-system.md | Combat Event Bus & Data Schema (inferred), Player 3C, Dodge-Graze & Tactical Arena Interactables |
| 4 | Dual-Gun, Active Reload & Overcharge Engine | Gameplay | MVP | Approved | design/gdd/dual-gun-overcharge-engine.md | Combat Event Bus & Data Schema (inferred), Player 3C, Dodge-Graze & Tactical Arena Interactables, Pooled Bullet-Hell & Damage System |
| 5 | 7-Slot Loadout & Tactical Items System | Gameplay | MVP | Not Started | design/gdd/loadout-and-items-system.md | Combat Event Bus & Data Schema (inferred), Dual-Gun, Active Reload & Overcharge Engine |
| 6 | Enemy AI, Interrupt Telegraphs & Boss System | Gameplay | MVP | Not Started | design/gdd/enemy-and-boss-system.md | Combat Event Bus & Data Schema (inferred), Pooled Bullet-Hell & Damage System, Dual-Gun, Active Reload & Overcharge Engine |
| 7 | 3-Door Routing, Overdrive Bet & Floor Generator | Progression | MVP | Not Started | design/gdd/door-routing-and-floor-gen.md | Dual-Gun, Active Reload & Overcharge Engine, 7-Slot Loadout & Tactical Items System, Enemy AI, Interrupt Telegraphs & Boss System |
| 8 | Pit-Stop, Scrap Economy & Rival Cast System | Economy | Vertical Slice | Not Started | design/gdd/pit-stop-and-rival-system.md | 7-Slot Loadout & Tactical Items System, Enemy AI, Interrupt Telegraphs & Boss System, 3-Door Routing, Overdrive Bet & Floor Generator |
| 9 | Tactical Micro-HUD & Screen UI System (inferred) | UI | MVP | Not Started | design/gdd/tactical-micro-hud.md | Player 3C & Dodge-Graze Controller, Dual-Gun, Active Reload & Overcharge Engine, 7-Slot Loadout & Tactical Items System, 3-Door Routing, Overdrive Bet & Floor Generator |
| 10 | Combat Audio & Procedural Juice System (inferred) | Audio | Vertical Slice | Not Started | design/gdd/combat-audio-juice-system.md | Combat Event Bus & Data Schema (inferred), Pooled Bullet-Hell & Damage System, Dual-Gun, Active Reload & Overcharge Engine |
| 11 | Save/Load, Ship Hub & Meta-Progression (inferred) | Persistence | Alpha | Not Started | design/gdd/meta-progression-and-save.md | 7-Slot Loadout & Tactical Items System, 3-Door Routing, Overdrive Bet & Floor Generator, Pit-Stop, Scrap Economy & Rival Cast System |

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | Foundation systems everything depends on | Event bus, data schemas, player 3C controller, pooled bullet-hell physics & damage |
| **Gameplay** | The systems that make the game fun | Dual-gun Overcharge engine, Active Reload, 7-slot loadout & relics, enemy AI & bosses |
| **Progression** | How the player advances through runs and strata | 3-Door previewed routing, Overdrive Bets, 3->10->Endless floor generator |
| **Economy** | Resource creation, spending, and NPC encounters | Scrap Shells, Black-Market Shop, Rest/Forge Pit-Stop, Rival-to-Boss/Playable cast |
| **Persistence** | Save state and long-term continuity | Run save/load, Bounty Ship Hub, unlockable Gunboys, Armory Codex |
| **UI** | Player-facing information displays | 64px crosshair/player Micro-HUD, 7-slot perimeter HUD, 3-Door neon header cards |
| **Audio** | Sound and visceral combat feedback | Arcade WAV SFX bus, procedural shell casings, hitstop & camera shake |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the 30-second combat loop and 5-minute 3-Door Overdrive Bet loop to function (8 systems). | First playable production build | Design FIRST |
| **Vertical Slice** | Required for a complete, juicy 3-Floor Bait Contract run with Pit-Stop NPCs, Rival Hidden Bosses, and full audio/VFX polish (2 systems). | Steam Next Fest Demo / Vertical Slice | Design SECOND |
| **Alpha** | Ship Hub meta-progression, unlockable Gunboy characters, and full 10-Stratum + Endless Loop persistence (1 system). | Alpha milestone | Design THIRD |
| **Full Vision** | Extended Armory codex flavor, additional Overdrive Pact modifiers, and Steam achievements. | Beta / Release | Design as needed |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **Combat Event Bus & Data Schema (inferred)** — Defines the global combat trigger signals and `Resource` base types that every weapon, Dynamo Core, enemy, and UI widget subscribes to.
2. **Player 3C & Dodge-Graze Controller** — Establishes the sacred movement speed, `Space` dodge-roll I-frames, outer Graze detection ring, and `[E]` table-flipping physics.

### Core Layer (depends on foundation)

1. **Pooled Bullet-Hell & Damage System** — depends on: `Combat Event Bus & Data Schema (inferred)`, `Player 3C & Dodge-Graze Controller`
2. **Dual-Gun, Active Reload & Overcharge Engine** — depends on: `Combat Event Bus & Data Schema (inferred)`, `Player 3C & Dodge-Graze Controller`, `Pooled Bullet-Hell & Damage System`

### Feature Layer (depends on core)

1. **7-Slot Loadout & Tactical Items System** — depends on: `Combat Event Bus & Data Schema (inferred)`, `Dual-Gun, Active Reload & Overcharge Engine`
2. **Enemy AI, Interrupt Telegraphs & Boss System** — depends on: `Combat Event Bus & Data Schema (inferred)`, `Pooled Bullet-Hell & Damage System`, `Dual-Gun, Active Reload & Overcharge Engine`
3. **3-Door Routing, Overdrive Bet & Floor Generator** — depends on: `Dual-Gun, Active Reload & Overcharge Engine`, `7-Slot Loadout & Tactical Items System`, `Enemy AI, Interrupt Telegraphs & Boss System`
4. **Pit-Stop, Scrap Economy & Rival Cast System** — depends on: `7-Slot Loadout & Tactical Items System`, `Enemy AI, Interrupt Telegraphs & Boss System`, `3-Door Routing, Overdrive Bet & Floor Generator`

### Presentation Layer (depends on features)

1. **Tactical Micro-HUD & Screen UI System (inferred)** — depends on: `Player 3C & Dodge-Graze Controller`, `Dual-Gun, Active Reload & Overcharge Engine`, `7-Slot Loadout & Tactical Items System`, `3-Door Routing, Overdrive Bet & Floor Generator`
2. **Combat Audio & Procedural Juice System (inferred)** — depends on: `Combat Event Bus & Data Schema (inferred)`, `Pooled Bullet-Hell & Damage System`, `Dual-Gun, Active Reload & Overcharge Engine`

### Polish Layer (depends on everything)

1. **Save/Load, Ship Hub & Meta-Progression (inferred)** — depends on: `7-Slot Loadout & Tactical Items System`, `3-Door Routing, Overdrive Bet & Floor Generator`, `Pit-Stop, Scrap Economy & Rival Cast System`

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Combat Event Bus & Data Schema (inferred) | MVP | Foundation | systems-designer, lead-programmer | S |
| 2 | Player 3C & Dodge-Graze Controller | MVP | Foundation | game-designer, gameplay-programmer | M |
| 3 | Pooled Bullet-Hell & Damage System | MVP | Core | systems-designer, engine-programmer | M |
| 4 | Dual-Gun, Active Reload & Overcharge Engine | MVP | Core | game-designer, systems-designer | L |
| 5 | 7-Slot Loadout & Tactical Items System | MVP | Feature | systems-designer, game-designer | M |
| 6 | Enemy AI, Interrupt Telegraphs & Boss System | MVP | Feature | game-designer, ai-programmer | M |
| 7 | 3-Door Routing, Overdrive Bet & Floor Generator | MVP | Feature | level-designer, systems-designer | M |
| 8 | Tactical Micro-HUD & Screen UI System (inferred) | MVP | Presentation | ux-designer, ui-programmer | S |
| 9 | Pit-Stop, Scrap Economy & Rival Cast System | Vertical Slice | Feature | economy-designer, narrative-director | M |
| 10 | Combat Audio & Procedural Juice System (inferred) | Vertical Slice | Presentation | sound-designer, technical-artist | S |
| 11 | Save/Load, Ship Hub & Meta-Progression (inferred) | Alpha | Polish | systems-designer, gameplay-programmer | M |

---

## Circular Dependencies

- **None found.** Potential bidirectional coupling between Weapons/Relics (`#4` & `#5`) and Enemies/Bullets (`#3` & `#6`) is cleanly broken by placing **Combat Event Bus & Data Schema (`#1`)** at the Foundation layer.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **Pooled Bullet-Hell & Damage System** | Technical | 500+ active projectiles + player shockwaves could cause GDScript GC spikes or hide enemy bullets. | Pre-allocated object pool (`BulletPool`), zero runtime `instantiate()`, Player VFX Alpha `<= 45%`, and `Z=40` threat layer lock. |
| **Dual-Gun, Active Reload & Overcharge Engine** | Design | Players might either starve for Overcharge against single bosses or spam `90⚡` Black Holes non-stop in mob rooms. | Validated in Stage 1 prototype: Two-Tier Overcharge economy (`+20⚡` Graze, `+35⚡` Boss Weak-Point Interrupt) + tiered `30/50/90⚡` Heavy costs. |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Scope | Expanding from 3 floors to 10 strata + Endless Loop could balloon room-authoring workload. | Data-driven `StratumConfig` resources + modular room template pool + `EndlessLoopScaling` math formula. |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 11 |
| Design docs started | 4 |
| Design docs reviewed | 4 |
| Design docs approved | 4 |
| MVP systems designed | 4/8 |
| Vertical Slice systems designed | 0/2 |

---

## Next Steps

- [x] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (starting with `/design-system combat-event-bus`)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check technical-setup` when MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
