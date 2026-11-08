# Control Manifest: CHAMBER OVERDRIVE (膛室超载)

> **Manifest Version**: 2026-11-08
> **Engine**: Godot 4.7.2 (`GDScript`, `Forward+`, `Godot Physics 2D`)
> **Source ADRs**: ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, ADR-006

This manifest is the mandatory coding cheat-sheet read by every developer and AI agent before writing or modifying any production `.gd` file.

---

## 1. Global Rules (Applies to Every File)

### MUST DO (必须执行)
1. **Single-File Edit Locality (`<= 200` Lines Cap)**: Keep every `.gd` script at or under **`200 lines`**. Every weapon (`src/content/weapons/gun_<id>.gd`), Heavy Spender (`src/content/heavy/heavy_<id>.gd`), Relic (`src/content/relics/relic_<id>.tres/.gd`), and Boss (`src/content/bosses/boss_<id>.gd`) must be self-contained in its own single file.
2. **Centralized Tuning (`balance_config.gd`)**: Read all baseline 3C, Overcharge (`72–100⚡` room budget, `45/65/90⚡` Heavy costs), and 4-Tier Rarity weights from `src/core/balance_config.gd`.
3. **Pure `RefCounted` Domain Logic**: Implement all math, Overcharge ledgers, Active Reload sliders, 3-Pip Aegis Shield rules, 4-Stage Stat Pipelines, and RNG tables in pure `RefCounted` classes so unit tests run in `< 0.5s` via `godot --headless` without loading `.tscn` scenes.
4. **Namespace-Prefixed IDs & `ThemeSkinCatalog`**: Address all items, weapons, NPCs, and currencies using `"base:<id>"` (or `"dlc:<id>"`, `"mod:<id>"`) and resolve display strings via `ThemeSkinCatalog.get_text(id, default_zh)`.
5. **100% Static Typing**: Every variable, parameter, and return value in GDScript must carry an explicit type annotation (`var speed: float = 290.0`, `func calc() -> float:`).

### NEVER DO (严禁触犯)
1. **NEVER freeze player `delta` during Hitstop**: `hitstop_timer` must only scale `world_delta` (`0.18x`) for enemies and hazards; `_update_player(delta)` and `_update_weapons(delta)` must **always** execute at `1.0x` unblocked `delta` (ADR-002).
2. **NEVER call global `randf()` / `randi()` for gameplay**: Always use the appropriate channel on `DeterministicRNGService` (`stream_topology`, `stream_loot`, `stream_shop_forge`, `stream_spawns`, `stream_combat`, `stream_cosmetic`) (ADR-005).
3. **NEVER hold raw `Node` references to enemies/hazards across frames**: Always store integer `entity_uid: int` handles and resolve via `EnemyRegistry.get_alive(entity_uid)` (ADR-004).
4. **NEVER call `instantiate()` or `queue_free()` for projectiles/casings in combat**: Always use `BulletPool` (`800` slots) and the `Z = 5` floor scar ring buffer (`80` shells, `40` debris) (ADR-002).
5. **NEVER exceed `Alpha 0.45` (`45%`) on player ground/volume VFX**: Keep `Z = 10` player VFX at `<= 0.45` alpha so `Z = 40` enemy projectiles remain 100% visible.

---

## 2. Per-Layer Guardrails

| Layer | Allowed Dependencies | Key Guardrails |
| :--- | :--- | :--- |
| **Layer 1: Foundation**<br>(`BalanceConfig`, `CombatEventBus`, `DeterministicRNGService`, `StatPipeline`) | None (`RefCounted` / Autoload) | • `CombatEventBus` enforces Stage `100->200->300->400` order, `MAX_RECURSION_DEPTH = 2`, `MAX_PROCS_PER_FRAME = 32`, and `F3` 64-entry trace ring buffer.<br>• `StatPipeline` enforces Stage 4 safety clamps (`290.0–333.5 px/s` speed, `0.42s` dodge duration). |
| **Layer 2: Core Combat**<br>(`Player3C`, `BulletPool`, `OverchargeEngine`) | Layer 1 only | • Coalesce player burst spawns `> 24` into damage multipliers (`MAX_PLAYER_BURST_CAP = 24`).<br>• Gate all Overcharge gain behind `room_cleared == false` (zero out-of-combat farming).<br>• Overcharge Aegis Shield (`1/1 🛡️`) never refills automatically on room entry; requires `3/3` Pips (`RMB` Heavy, Interrupt, or 3x Perfect Reload). |
| **Layer 3: Features**<br>(`Loadout`, `Enemy/Boss`, `FloorRouter`, `PitStop`) | Layers 1–2 | • Fodder mobs never emit Weak-Point Interrupt UI.<br>• Un-interrupted Elite/Boss signature attacks set `is_shield_piercing = true` (bypasses Aegis Shield to hit Red Heart `hp`).<br>• Healing in Pit-Stops is strictly capped at `+1 ❤️` per interaction. |
| **Layer 4: Presentation**<br>(`MicroHUD`, `PerimeterHUD`, `AudioJuice`) | Layers 1–3 (Read/Signal only) | • UI and Audio scripts must **never** mutate gameplay math or HP/Overcharge state.<br>• `SFX_Combat_Critical` triggers `-4.0 dB` sidechain ducking for `0.20s`. |
| **Layer 5: Persistence & MODs**<br>(`SaveManager`, `ContentRegistry`, `ThemeSkinCatalog`) | Layers 1–3 | • `meta_profile.sav` writes atomically with `.bak` SHA-256 fallback.<br>• `active_run_checkpoint.sav` saves only on `room_cleared` / door entry with coordinate-hashed RNG seeds. |
