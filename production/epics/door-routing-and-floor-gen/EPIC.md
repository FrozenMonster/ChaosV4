# Epic: 3-Door Routing, Overdrive Bet & Floor Generator

> **Layer**: Feature
> **GDD**: design/gdd/door-routing-and-floor-gen.md
> **Architecture Module**: `src/progression/floor_router/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories door-routing-and-floor-gen`

## Overview

Implements the 7-Node Stratum DAG generator featuring **5 Non-Rectangular Room Footprints** (Standard, L-Bend, Central Ring-Pit, Twin-Bridge, Irregular Cavern), **4 Differentiated Room Objective Modes** (`EXTERMINATION`, `SABOTAGE_BEACONS`, `OVERDRIVE_SURVIVAL`, `CONDUIT_UPLOAD`) with instant Overdrive Clear Pulse wipes, **1 to 3 spatially distributed *Hades*-style exit doors**, pre-door **`[F]` Overdrive Betting (`-25.0⚡` for 2x Chips + 0% Common 2-Choice Crates)**, and progression from Floors 1–3 to Stratum 10 and the Sample Y Endless Loop (`Floor 11 -> ∞`).

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-005: 6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity System | `stream_topology` and `stream_spawns` coordinate hashing ensures reproducible room layouts and wave budgets | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-door-routing-and-floor-gen-001 | 5 non-rectangular room footprints, 4 RoomObjectiveType modes with instant Overdrive Clear Pulse, 1-3 Hades-style distributed exits, and -25 Overdrive Bet | ADR-005 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/door-routing-and-floor-gen.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
