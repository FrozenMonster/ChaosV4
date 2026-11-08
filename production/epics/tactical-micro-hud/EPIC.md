# Epic: Tactical Micro-HUD & Screen UI System

> **Layer**: Presentation
> **GDD**: design/gdd/tactical-micro-hud.md
> **Architecture Module**: `src/ui/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories tactical-micro-hud`

## Overview

Implements the `1280×720` (`Z = 50`) two-tier interface: (1) the **`64px` Player-Proximate Micro-HUD** (weapon-specific overhead Active Reload slider, Final Round pip, `RMB` Heavy Ready bracket, and Graze Ring in pure flat geometry); and (2) the **Screen-Perimeter HUD** featuring the **3-Pip Overcharge Aegis Shield bar (`🛡️` + `[■][■][□]`)**, **Top-Right 4-Mode Room Objective Tracker**, **`45/65/90⚡` Overcharge bar**, **7-Slot Loadout panels**, **off-screen edge wayfinder arrows**, and the **inline `[7]/[8]/[9]/[G]` Swap-and-Salvage strip**.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader | Thin `Node2D`/`CanvasLayer` views read `RefCounted` state and resolve all strings through `ThemeSkinCatalog` | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-tactical-micro-hud-001 | 64px Player-Proximate Micro-HUD, 3-Pip Aegis Shield reconstruction bar, 4-Mode Room Objective Tracker, and edge-clamped off-screen wayfinder arrows | ADR-006 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/tactical-micro-hud.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
