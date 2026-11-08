# Epic: Player 3C, Dodge-Graze & Tactical Arena Interactables

> **Layer**: Foundation
> **GDD**: design/gdd/player-3c-controller.md
> **Architecture Module**: `src/combat/player_3c/` & `src/content/interactables/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories player-3c-controller`

## Overview

Implements the sacrosanct top-down 3C movement controller (`290.0 px/s` zero-inertia 8-way movement + 360° aiming), committed `0.42s` `Space` dodge roll (`0.28s` I-frame + `42.0 px` Graze Ring yielding `+10.0⚡` Overcharge per bullet grazed, up to `2` base or `3` with Exoskeleton Forge tuning), and the unified data-driven **Tactical Arena Interactables** system supporting both **Proximity (`[E]`)** devices (Deployable Shield Pylon, Overcharge Capacitor Tap-Box, Kinetic Launchpad) and **Ranged Hit-Trigger** objects (Volatile Fuel Drum, Cryo-Coolant Tank, Refractor Prism).

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-002: Dual-Track Bullet Pool, Non-Blocking Hitstop & Projectile Coalescing | Player `delta` never freezes during hitstop; controls remain 100% responsive | LOW |
| ADR-003: 80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality | Enforces Stage 4 safety clamps (`290–333.5 px/s` walk speed, locked `0.42s` roll duration) and `<= 200` line single-file locality | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-player-3c-controller-001 | Sacrosanct 290.0 px/s base move speed, 0.42s committed dodge roll (0.28s I-frame + 42px Graze Ring yielding +10 Overcharge, max 2 base per roll), and customizable Proximity [E] / Ranged-Hit ArenaInteractableData | ADR-002, ADR-003 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/player-3c-controller.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
