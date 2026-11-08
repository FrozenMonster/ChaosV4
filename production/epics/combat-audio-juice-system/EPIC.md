# Epic: Combat Audio & Procedural Juice System

> **Layer**: Presentation
> **GDD**: design/gdd/combat-audio-juice-system.md
> **Architecture Module**: `src/audio/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories combat-audio-juice-system`

## Overview

Implements the 4-Bus Audio Hierarchy (`SFX_Combat_Critical`, `SFX_Weapons_Impacts`, `UI_And_Routing`, `BGM_Adaptive`) with **`-4.0 dB` Sidechain Ducking (`0.20s`)** on critical cues, **Pitch-Escalation Dopamine Ladders** for consecutive Dodge Grazes and Perfect Reloads, **2-Layer Adaptive Overdrive BGM**, and the **Procedural Visual Juice Pipeline** (spring squash-and-stretch, directional camera kick, capped trauma shake `<= 18.0 px`, and pooled `Z = 5` brass shell casings / robot debris).

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader | Stage 400 presentation listener cleanly decoupled from gameplay math and hitstop | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-combat-audio-juice-system-001 | 4-Bus audio hierarchy with -4.0 dB Sidechain Ducking on critical cues, streak pitch-escalation ladders, and capped 18.0 px camera shake | ADR-006 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/combat-audio-juice-system.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
