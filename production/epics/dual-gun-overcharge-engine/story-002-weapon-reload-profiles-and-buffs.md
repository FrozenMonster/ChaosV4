# Story 002: Self-Contained Primary Weapon Reload Profiles & Signature Buffs

> **Epic**: Dual-Gun, Active Reload & Overcharge Engine
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/dual-gun-overcharge-engine.md`
**Requirement**: `TR-dual-gun-overcharge-engine-001`

**ADR Governing Implementation**: ADR-003
**ADR Decision Summary**: Enforces Single-File Edit Locality (`<= 200 lines`) where each Primary Weapon (`gun_peacemaker.gd`, `gun_vector_smg.gd`, `gun_bailiff_shotgun.gd`) encapsulates its own Active Reload sweet-spot window (`[sweet_start, sweet_end]`), Final Round behavior, and `2.5s` Signature Buff.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: 1 self-contained file per weapon (`<= 100 lines` each) in `src/content/weapons/`; modifying a weapon's reload window or Signature Buff touches ONLY that weapon's file.
- Forbidden: Centralizing weapon-specific buff logic inside a giant `if/else` switch in `player.gd`.
- Guardrail: Jammed reload reduces slider speed by `32%` (`JAM_SPEED_PENALTY = 0.32`).

---

## Acceptance Criteria

*From GDD `design/gdd/dual-gun-overcharge-engine.md`, scoped to this story:*

- [ ] **GIVEN** `gun_peacemaker.gd` (`0.42–0.62`), `gun_vector_smg.gd` (`0.22–0.40`), and `gun_bailiff_shotgun.gd` (`0.65–0.81`), **WHEN** `[R]` is pressed inside each weapon's sweet spot, **THEN** reload completes instantaneously and activates that weapon's exact Signature Buff (*Gunslinger Focus* 2x speed +40% crit for 2 shots, *Overclock Cadence* +35% fire rate & 0° spread, or *Kinetic Blast Wave* `125px` clear & +3 pellets) for `2.5s`.
- [ ] **GIVEN** an active reload slider, **WHEN** `[R]` is pressed outside `[sweet_start, sweet_end]`, **THEN** `reload_jammed` becomes `true`, remaining reload speed drops by `32%`, and further `[R]` inputs for that reload cycle are ignored.

---

## Implementation Notes

*Derived from ADR-003 Implementation Guidelines:*

Create `src/combat/weapons/active_reload_controller.gd` (`<= 120 lines`) and the three self-contained weapon modules in `src/content/weapons/` (`gun_peacemaker.gd`, `gun_vector_smg.gd`, `gun_bailiff_shotgun.gd`).

---

## Out of Scope

- Story 001: Overcharge ledger and Heavy Spender costs.

---

## Files

- `src/combat/weapons/active_reload_controller.gd`
- `src/content/weapons/gun_peacemaker.gd`
- `src/content/weapons/gun_vector_smg.gd`
- `src/content/weapons/gun_bailiff_shotgun.gd`
- `tests/unit/dual-gun-overcharge-engine/weapon_reload_profiles_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/dual-gun-overcharge-engine/weapon_reload_profiles_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/dual-gun-overcharge-engine/story-001-overcharge-ledger-and-heavy.md`
- Unlocks: None
