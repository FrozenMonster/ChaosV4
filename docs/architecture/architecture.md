# Master Technical Architecture: CHAMBER OVERDRIVE (膛室超载)

> **Status**: Approved
> **Engine**: Godot 4.7.2 (`GDScript`, `Forward+` Renderer, `Godot Physics 2D`)
> **Last Updated**: 2026-11-08
> **Owned By**: technical-director + lead-programmer

---

## 1. Executive Summary & Five Non-Negotiable Engineering Tenets

This document translates all 11 approved GDDs of **CHAMBER OVERDRIVE (膛室超载)** into a production-ready Godot 4.7.2 architecture. To simultaneously guarantee **lightning-fast MVP/Demo iteration**, **surgical single-file AI/developer edits**, **zero-scene sub-second automated testing**, **60+ FPS performance at *Enter the Gungeon* scale**, and **future-proof DLC / Steam Workshop MOD extensibility**, the architecture enforces five core tenets:

1. **Single-File Edit Locality & `<= 200` Line Script Cap (单点修改局部性铁律)**:
   - Every weapon, Heavy Spender, Dynamo Core, Passive Relic, Enemy, Boss, and HUD panel is encapsulated in **its own self-contained file (`80–200 lines max`)**.
   - Global tuning numbers live in **one canonical file (`src/core/balance_config.gd`, `<= 100 lines`)**. Adjusting a weapon's reload buff, a relic's effect, or global Overcharge numbers **never requires reading or editing more than 1 small file**.
2. **Pure `RefCounted` Logic Core vs. Thin `Node2D` View (零场景极速可测试性铁律)**:
   - All math, state machines, Overcharge ledgers, 3-Pip Aegis Shield rules, 4-Stage Stat Pipelines, and RNG loot tables are implemented as **pure `RefCounted` GDScript classes** with zero dependency on `Node2D`, textures, audio, or the SceneTree.
   - `Node2D` scripts act strictly as thin visual/input wrappers. As a result, **100+ unit and 1,000-room balance simulation tests run in `< 0.5 seconds` in `--headless` mode without instantiating a single `.tscn` scene**.
3. **6-Stream Coordinate-Hashed Deterministic RNG & Pity Engine (多通道隔离与坐标哈希随机种子系统)**:
   - A single 8-character shareable `Master_Seed` (e.g., `X9-G7K2`) forks into **6 isolated `RandomNumberGenerator` streams** (`TOPOLOGY`, `LOOT`, `SHOP_FORGE`, `SPAWNS`, `COMBAT`, `COSMETIC`) and uses stateless coordinate hashing `hash(master_seed, stratum, node, roll_idx)` plus a deterministic **Bad-Luck Protection Pity Accumulator**. Firing 500 extra bullets in Room 1 **never** alters the loot or shop inventory of Room 2, and `Alt+F4` save-scumming cannot reroll Mystery Contraband Boxes.
4. **3-Phase Progressive Implementation Strategy (MVP 极速落地 $\rightarrow$ 1.0 规模化 $\rightarrow$ DLC/MOD 无损演进)**:
   - **Phase 1 (MVP / First Demo)**: Uses simple array-backed `_draw()` pooling, direct `res://` loading, and lightweight `<= 40 lines` interface contracts (namespace prefix `"base:id"`, integer `entity_uid` handles, and `> 24` player burst projectile coalescing) for maximum iteration speed.
   - **Phase 2 (1.0 Commercial Release — 200+ Weapons/Items)**: Drops in `MultiMeshInstance2D` single-draw-call GPU rendering inside `BulletPool` and threaded stratum streaming inside `ContentRegistry` with **zero changes to weapon/item/enemy scripts**.
   - **Phase 3 (DLC & Steam Workshop MODs)**: Enables `.pck` DLC mounting and `user://mods/<mod_id>/` scanning with per-relic `NaN`/error fault isolation.
5. **Non-Blocking Player 3C & Crash-Proof Synergy Guards (玩家 3C 永不冻结与极端组合防崩护栏)**:
   - Hitstop (`hitstop_timer`) dilates `world_delta` (`0.18x` on enemies/hazards) while **player movement, aiming, and Active Reload sliders always run at `1.0x` unblocked `delta`**.
   - Cross-frame references use integer `entity_uid` handles (never raw `Node` pointers), and player burst spawns exceeding `MAX_PLAYER_BURST_CAP = 24` automatically coalesce excess projectiles into damage multipliers (`Synergy Coalescing`), preventing frame drops without losing a single point of player DPS.

---

## 2. Five-Layer Unidirectional System Architecture

Dependencies flow strictly top-to-bottom (`Presentation / Features -> Core -> Foundation`). Lower layers communicate upward exclusively via `CombatEventBus` signals:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ LAYER 5: POLISH, PERSISTENCE & MOD/SKIN CATALOG                                  │
│ • SaveManager (meta_profile.sav + .bak | active_run_checkpoint.sav)              │
│ • ContentRegistry ("base:id" / "dlc:id" / "mod:id") & ThemeSkinCatalog           │
├──────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 4: PRESENTATION, MICRO-HUD & AUDIO JUICE (Thin Node2D / CanvasLayer Views) │
│ • MicroHUDView (64px Reload Slider, Final Pip, Graze Ring, Z=50)                 │
│ • PerimeterHUDView (3-Pip Aegis Shield, 45/65/90⚡ Bar, 4-Mode Tracker, Wayfinder)│
│ • AudioJuiceDirector (4-Bus Sidechain Ducking -4dB, Pitch Ladders, Scar Pool)    │
├──────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 3: FEATURE MODULES (Self-Contained <=200 Line Files)                       │
│ • LoadoutAndRelicManager (7-Slot Schema, 80% When->If->Do + 20% Custom Script)   │
│ • EnemyAndBossDirector (Tier1 Table | Tier2 Elite Plugins | Tier3 4D Bosses)     │
│ • FloorRouterAndGenerator (5 Footprints, 4 Objectives, Hades Exits, -25⚡ Bet)   │
│ • PitStopAndRivalManager (4-Tier Rarity, Blind Box Shop, 4-Axis Forge, 3 NPCs)   │
├──────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 2: CORE COMBAT ENGINE (Pure RefCounted Logic + Pooled Server)              │
│ • Player3CController (290 px/s, 0.42s Roll, Graze Ring, ArenaInteractables)      │
│ • BulletPoolServer (800-Slot Pool + Area2D Special Pool, 3-Tier Recoil, Aegis)   │
│ • DualGunOverchargeEngine (Weapon Reload Profiles/Buffs, 72-100⚡ Room Economy)  │
├──────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 1: FOUNDATION (Zero-Dependency Singletons & Pure Math Cores)               │
│ • BalanceConfig (Single source of truth for all global tuning numbers)           │
│ • CombatEventBus (4-Stage Priority 100->400, 32 Procs/Frame Cap, F3 Trace Log)   │
│ • DeterministicRNGService (6 Isolated Streams + Coordinate Hash + Pity Counter)  │
│ • StatPipeline (4-Stage Commutative Math: Flat -> Pct_Add -> Mult -> Clamp)      │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. File Routing & Single-File Edit Locality Map (`<= 200` Lines Per File)

To guarantee that any future feature tweak or AI agent task touches **only 1 small file** without scanning the entire repository, the codebase is organized by strict locality:

| What You Want to Change / Add (修改目标) | Exact Single File to Open (`<= 200` Lines) | Files You NEVER Need to Touch |
| :--- | :--- | :--- |
| **Global 3C, Overcharge, Rarity, or Economy numbers** | `src/core/balance_config.gd` | Any weapon, enemy, or UI script |
| **A specific Primary Weapon's reload window, Final Round, or Signature Buff** | `src/content/weapons/gun_<id>.gd` (e.g., `gun_peacemaker.gd`) | `player_3c.gd`, `hud.gd`, or other guns |
| **A specific Heavy Spender (`45/65/90⚡`) behavior** | `src/content/heavy/heavy_<id>.gd` (e.g., `heavy_railgun.gd`) | Primary weapon or enemy scripts |
| **A specific Passive Relic or Active Item** | `src/content/relics/relic_<id>.tres` (or `.gd` for 20% custom Legendaries) | `loadout_manager.gd` or `bullet_pool.gd` |
| **A specific Elite Component or Boss Fight** | `src/content/enemies/elite_<id>.gd` or `boss_<id>.gd` | Fodder mob scripts or room router |
| **A specific Arena Interactable (`[E]` or Ranged Hit)** | `src/content/interactables/interact_<id>.gd` | Player movement or door scripts |
| **World Lore names, NPC titles, or Currency labels** | `src/core/theme_skin_catalog.gd` | Any gameplay logic or save file |

---

## 4. Core Architecture Decision Records (ADR Index)

| ADR ID | Title & File Path | Primary Problem Solved | Status |
| :--- | :--- | :--- | :--- |
| **ADR-001** | [Combat Event Bus, F3 Trace Buffer & Per-Frame Recursion Guard](adr-001-combat-event-bus-and-recursion-guard.md) | Decouples all 11 systems, prevents infinite relic loops (`depth <= 2`, `32 procs/frame`), and eliminates "signal black-box debugging" via an `F3` ring-buffer trace log. | Accepted |
| **ADR-002** | [Dual-Track Bullet Pool, Non-Blocking Hitstop & Projectile Coalescing](adr-002-dual-track-bullet-pool-and-nonblocking-hitstop.md) | Guarantees 60+ FPS with 500+ bullets (`_draw` in MVP $\rightarrow$ `MultiMeshInstance2D` in 1.0 + `Area2D` pool for custom shapes), keeps player 3C unblocked during hitstop, and coalesces `>24` player burst pellets into damage multipliers. | Accepted |
| **ADR-003** | [80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality](adr-003-hybrid-composable-item-engine-and-stat-pipeline.md) | Combines zero-code `When->If->Do` data blocks (80% items) with custom script hooks (20% Legendaries), commutative 4-stage math, and `<= 200` line single-file locality. | Accepted |
| **ADR-004** | [3-Tier Enemy/Boss Customization & Crash-Proof Entity UID Handles](adr-004-three-tier-enemy-boss-and-uid-handles.md) | Separates fodder tables, Elite plugins, and 4D Boss timelines while replacing raw `Node` references with integer `entity_uid` handles to eliminate null-reference crashes. | Accepted |
| **ADR-005** | [6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity System](adr-005-multi-stream-deterministic-rng-and-pity.md) | Prevents combat actions from polluting loot/shop seeds, blocks `Alt+F4` save-scumming via `hash(seed, stratum, node)`, and guarantees fair Epic/Legendary drops via PRD pity. | Accepted |
| **ADR-006** | [Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader](adr-006-refcounted-testability-skin-and-mod-loader.md) | Enables `<0.5s` headless unit/balance testing without scenes, instant world-lore re-skinning via `ThemeSkinCatalog`, and zero-rewrite progression from MVP to DLCs & Steam Workshop MODs. | Accepted |
