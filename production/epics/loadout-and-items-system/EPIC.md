# Epic: 7-Slot Loadout & Tactical Items System

> **Layer**: Feature
> **GDD**: design/gdd/loadout-and-items-system.md
> **Architecture Module**: `src/features/loadout/` & `src/content/relics/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories loadout-and-items-system`

## Overview

Implements the anti-bloat **7-Slot Loadout Schema** (`3 Armory Slots` + `4 Tactical Item Slots` with inline `[7]/[8]/[9]` swap-and-salvage and `[G]` direct salvage into **`🪙 Bounty Chips`**), the **80/20 Hybrid Item Engine** (`When -> If -> Do` composable blocks + `custom_behavior_script` escape hatch for rule-breaking Legendaries), **Additive Bullet Decorators**, **`exclusivity_group` Mutex Filtering**, and the **4-Stage Commutative Stat Pipeline (`StatPipeline`)**.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-001: Combat Event Bus, F3 Trace Buffer & Per-Frame Recursion Guard | Stage 200 listener hooks in slot order `0 -> 1 -> 2` with recursion depth cap `<= 2` | LOW |
| ADR-003: 80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality | 80/20 hybrid item definitions, 4-Stage commutative math, and per-relic `NaN` fault isolation | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-loadout-and-items-system-001 | 7-Slot Loadout Schema (3 Armory + 1 Active + 3 Passives), 80/20 Hybrid When->If->Do & custom_behavior_script items, and 4-Stage Commutative StatPipeline | ADR-001, ADR-003 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/loadout-and-items-system.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
