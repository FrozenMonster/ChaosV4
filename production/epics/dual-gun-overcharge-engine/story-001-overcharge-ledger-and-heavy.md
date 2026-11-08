# Story 001: Calibrated 72–100⚡ Overcharge Ledger, Anti-Farming Gate & RMB Heavy Spenders

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

**ADR Governing Implementation**: ADR-003, ADR-006
**ADR Decision Summary**: Pure `RefCounted` `OverchargeEngineLogic` calibrated for `72–100⚡` room yield (`+0.5 / +4 / +8 / +10 / +22⚡` Tier-1 + `+6 / +14 / +22⚡` Tier-2 Dynamos), gated by `room_cleared == false` to block out-of-combat farming, fueling `45 / 65 / 90⚡` `RMB` Heavy Spenders (`1–2` casts per room).
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Read all charge/cost constants from `BalanceConfig`; gate all Overcharge gains behind `room_cleared == false`; enforce `heavy_cd` (`2.5s / 3.5s / 5.0s`).
- Forbidden: Awarding Overcharge per shotgun pellet (must be once per firing action) or when `room_cleared == true`.
- Guardrail: `72–100⚡` expected yield per standard room (`1–2` Heavy casts).

---

## Acceptance Criteria

*From GDD `design/gdd/dual-gun-overcharge-engine.md`, scoped to this story:*

- [ ] **GIVEN** a combat room (`room_cleared == false`) with 24 primary hits (`+12⚡`), 3 Final Rounds (`+12⚡`), 2 Perfect Reloads (`+16⚡`), 2 Dodge Grazes (`+20⚡`), and 1 Saboteur Dynamo (`+22⚡`), **WHEN** accumulated in `OverchargeEngineLogic`, **THEN** total Overcharge generated equals `82.0⚡` (`1.26` casts of a `65⚡` Medium Heavy Weapon or `1.82` casts of a `45⚡` Light Heavy Weapon).
- [ ] **GIVEN** `room_cleared == true`, **WHEN** the player triggers Perfect Reloads or hits, **THEN** Overcharge gained equals `0.0⚡`.
- [ ] **GIVEN** the player has `100.0⚡` and fires a `45.0⚡` Heavy Weapon (`cd = 2.5s`), **WHEN** pressing `RMB` again `0.5s` later, **THEN** the cast is blocked until `heavy_cd_timer` reaches `0.0s`.

---

## Implementation Notes

*Derived from ADR-003 & ADR-006 Implementation Guidelines:*

Implement `OverchargeEngineLogic` (`extends RefCounted` in `src/combat/weapons/overcharge_engine_logic.gd`, `<= 160 lines`).

---

## Out of Scope

- Story 002: Per-weapon Active Reload sweet-spot profiles and Signature Buffs.

---

## Files

- `src/combat/weapons/overcharge_engine_logic.gd`
- `tests/unit/dual-gun-overcharge-engine/overcharge_ledger_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/dual-gun-overcharge-engine/overcharge_ledger_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/bullet-hell-damage-system/story-002-recoil-and-aegis-shield.md`
- Unlocks: `production/epics/dual-gun-overcharge-engine/story-002-weapon-reload-profiles-and-buffs.md`
