# Epic: Dual-Gun, Active Reload & Overcharge Engine

> **Layer**: Core
> **GDD**: design/gdd/dual-gun-overcharge-engine.md
> **Architecture Module**: `src/combat/weapons/` & `src/content/weapons/`
> **Status**: Ready
> **Stories**: 2 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Calibrated 72–100⚡ Overcharge Ledger, Anti-Farming Gate & RMB Heavy Spenders | Logic | Ready | ADR-003, ADR-006 |
| 002 | Self-Contained Primary Weapon Reload Profiles & Signature Buffs | Logic | Ready | ADR-003 |

## Overview

Implements the core 30-second combat loop: self-contained Primary Weapon files (`gun_peacemaker.gd`, `gun_vector_smg.gd`, `gun_bailiff_shotgun.gd`) each with custom Active Reload sweet-spot brackets (`0.42–0.62`, `0.22–0.40`, `0.65–0.81`), unique Final Rounds, and `2.5s` Signature Buffs (*Gunslinger Focus*, *Overclock Cadence*, *Kinetic Blast Wave*), paired with the calibrated **Two-Tier Overcharge Economy (`72–100⚡` room yield, zero out-of-combat farming)** and instant `RMB` Heavy Spenders (`45 / 65 / 90⚡` for 1–2 casts per room).

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-003: 80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality | Self-contained `<= 200 line` weapon files and centralized `balance_config.gd` tuning | LOW |
| ADR-006: Pure `RefCounted` Testability, Skin Decoupling & 3-Phase DLC/MOD Loader | Pure `RefCounted` `OverchargeLedger` and `ActiveReloadController` for `<0.5s` headless unit testing | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-dual-gun-overcharge-engine-001 | Weapon-specific Active Reload sweet spots and 2.5s Signature Buffs, calibrated 72-100 Overcharge room yield vs 45/65/90 Heavy Spender costs (1-2 casts/room), and zero out-of-combat farming | ADR-003, ADR-006 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/dual-gun-overcharge-engine.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
