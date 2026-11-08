# Story 002: 3-Tier Ballistic Recoil/Knockback & 3-Pip Overcharge Aegis Shield

> **Epic**: Pooled Bullet-Hell & Damage System
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/bullet-hell-damage-system.md`
**Requirement**: `TR-bullet-hell-damage-system-001`

**ADR Governing Implementation**: ADR-002, ADR-004
**ADR Decision Summary**: Implements the 3-Tier Ballistic Impact & Recoil Matrix (`4px` Final Round snap + `28px` enemy knockback; `8/16/22px` Heavy shooter recoil slide + `45px` slam) and the 3-Pip Overcharge Aegis Shield (`1/1 🛡️`, zero free room refill, rebuilt via 3 Pips from Heavy casts, Interrupts, or 3x Perfect Reloads, bypassed by `SHIELD_PIERCING`).
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Overcharge Aegis Shield (`1/1 🛡️`) never refills automatically on room entry; requires `3/3` Pips.
- Forbidden: Allowing normal shield hits to void Boss Hitless status, or allowing `SHIELD_PIERCING` attacks to be blocked by the shield.
- Guardrail: `INVULN_DURATION = 1.0s` post-hit protection.

---

## Acceptance Criteria

*From GDD `design/gdd/bullet-hell-damage-system.md`, scoped to this story:*

- [ ] **GIVEN** the player has `aegis_shield = 1` and `hp = 6`, **WHEN** hit by a normal bullet (`is_shield_piercing = false`), **THEN** `aegis_shield` becomes `0`, `hp` stays `6` (`boss_hitless_valid` remains `true`), and `aegis_shield` stays `0` across room transitions until `3/3` Pips are earned (1 Heavy cast + 1 Interrupt + 3 Perfect Reloads).
- [ ] **GIVEN** the player has `aegis_shield = 1` and `hp = 6`, **WHEN** hit by an un-interrupted Elite/Boss signature attack (`is_shield_piercing = true`), **THEN** `aegis_shield` stays `1`, `hp` drops to `5`, and `boss_hitless_valid` becomes `false`.
- [ ] **GIVEN** Ballistic Tier 1 (`LMB`), Tier 2 (`Final Round`), and Tier 3 (`RMB` `45/65/90⚡`), **WHEN** recoil and enemy knockback are computed, **THEN** shooter recoil slide equals `0 / 4 / 8–22 px` and enemy knockback equals `4 / 28 / 45 px` (scaled by `1.0 - enemy_knockback_resistance`).

---

## Implementation Notes

*Derived from ADR-002 & ADR-004 Implementation Guidelines:*

Implement `AegisAndDamageLogic` (`extends RefCounted` in `src/combat/bullet_pool/aegis_and_damage_logic.gd`, `<= 160 lines`).

---

## Out of Scope

- Story 001: Projectile slot pooling and burst coalescing.

---

## Files

- `src/combat/bullet_pool/aegis_and_damage_logic.gd`
- `tests/unit/bullet-hell-damage-system/recoil_and_aegis_shield_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/bullet-hell-damage-system/recoil_and_aegis_shield_test.gd` — must exist and pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/bullet-hell-damage-system/story-001-bullet-pool-and-coalescing.md`
- Unlocks: `production/epics/dual-gun-overcharge-engine/story-001-overcharge-ledger-and-heavy.md`
