# Story 001: 4-Bus Sidechain Ducking (-4.0 dB), Pitch Ladders & Capped 18px Shake

> **Epic**: Combat Audio & Procedural Juice System
> **Status**: Done
> **Layer**: Presentation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-11-08
> **Last Updated**: 2026-11-08

## Context

**GDD**: `design/gdd/combat-audio-juice-system.md`
**Requirement**: `TR-combat-audio-juice-system-001`

**ADR Governing Implementation**: ADR-006
**ADR Decision Summary**: Implements pure `RefCounted` `AudioJuiceLogic` managing `-4.0 dB` (`0.20s`) sidechain ducking on critical cues, consecutive Graze/Reload pitch ladders, and `<= 18.0 px` camera shake clamping.
**ADR Version**: 2026-11-08

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: None

**Control Manifest Rules (this layer)**:
- Required: Trigger `-4.0 dB` ducking for `0.20s` on `SFX_Combat_Critical`; clamp camera offset to `18.0 px`.
- Forbidden: Pausing audio during `hitstop_timer`.
- Guardrail: `MAX_SHAKE_OFFSET = 18.0 px`.

---

## Acceptance Criteria

*From GDD `design/gdd/combat-audio-juice-system.md`, scoped to this story:*

- [x] **GIVEN** a critical combat cue fires, **WHEN** `trigger_critical_cue_ducking()` is called, **THEN** secondary buses attenuate by `-4.0 dB` for `0.20s` and recover to `0.0 dB`.
- [x] **GIVEN** 3 consecutive Dodge Grazes (`step = 0.12`), **WHEN** `compute_streak_pitch()` runs, **THEN** pitch climbs `1.00 -> 1.12 -> 1.24`.
- [x] **GIVEN** simultaneous directional recoil (`16.0 px`) and trauma shake (`14.0 px`), **WHEN** `compute_final_camera_offset()` runs, **THEN** total displacement is strictly `<= 18.0 px`.

---

## Implementation Notes

Implemented in `src/audio/audio_juice_logic.gd` (`55 lines`).

---

## Out of Scope

- Save file verification (handled by Epic 11).

---

## Files

- `src/audio/audio_juice_logic.gd`
- `tests/unit/test_epics_9_to_11.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/test_epics_9_to_11.gd` — exists and passes (`4/4 Passed`)

**Status**: [x] Verified in `tests/unit/test_epics_9_to_11.gd`

---

## Dependencies

- Depends on: `production/epics/combat-event-bus/story-001-event-bus-and-trace.md`
- Unlocks: None
