# Epic: Combat Event Bus & Data Schema

> **Layer**: Foundation
> **GDD**: design/gdd/combat-event-bus.md
> **Architecture Module**: `src/core/event_bus/` & `src/core/schemas/`
> **Status**: Ready
> **Stories**: 2 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 4-Stage Priority Event Bus, Recursion Guard & F3 Trace Ring Buffer | Logic | Ready | ADR-001 |
| 002 | 7-Slot Equipment, 4-Tier Rarity & ArenaInteractable Resource Schemas | Logic | Ready | ADR-001, ADR-006 |

## Overview

Implements the foundational decoupled signal relay (`CombatEventBus`) with deterministic 4-Stage priority ordering (`100 -> 200 -> 300 -> 400`), hard recursion and per-frame proc circuit breakers (`MAX_RECURSION_DEPTH = 2`, `MAX_PROCS_PER_FRAME = 32`), an `F3` 64-entry event trace ring buffer, and the typed `.tres` `Resource` schemas (`PrimaryWeaponData`, `HeavyWeaponData`, `DynamoCoreData`, `ActiveItemData`, `PassiveRelicData`, `ArenaInteractableData`) carrying 4-Tier Rarity tags.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-001: Combat Event Bus, F3 Trace Buffer & Per-Frame Recursion Guard | 4-Stage priority dispatch, `depth <= 2` & `32 procs/frame` guard, and `F3` 64-entry trace ring buffer | LOW |
| ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader | Pure `RefCounted` logic cores for `<0.5s` headless testing and `"base:id"` namespace schemas | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-combat-event-bus-001 | 4-Stage priority dispatch (100->200->300->400) with MAX_RECURSION_DEPTH = 2, MAX_PROCS_PER_FRAME = 32, and F3 64-entry trace ring buffer | ADR-001 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/combat-event-bus.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
