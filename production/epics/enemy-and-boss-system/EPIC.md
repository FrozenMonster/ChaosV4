# Epic: Enemy AI, Elite/Boss Interrupts & Boss System

> **Layer**: Feature
> **GDD**: design/gdd/enemy-and-boss-system.md
> **Architecture Module**: `src/combat/enemies/` & `src/content/bosses/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories enemy-and-boss-system`

## Overview

Implements the **3-Tier Enemy & Granular Boss Customization Architecture**: (1) Data-driven `MovementArchetype + BulletPatternData` for fodder mobs (with **zero cluttering interrupt prompts on fodder**); (2) Modular **`EliteModifierComponent` plugins** (Directional Shield, Blink Ambush, Tether Guardian) with `0.85s` Weak-Point Interrupt windows (`+22.0⚡`); and (3) **4D Boss Customization** (`BossAttackTimeline` scripts, destructible `BossPartNode` sub-hitboxes, `BossArenaController` hooks, and `RivalHunterBrain` mirror AI), plus `SHIELD_PIERCING` un-interrupted attacks, Boss DPS Soft-Cap (`18%/s`), and Hitless **Master Chamber Core** rewards.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-004: 3-Tier Enemy/Boss Customization & Crash-Proof Entity UID Handles | 3-Tier AI hierarchy, self-contained `boss_<id>.gd` files (`<= 200 lines`), and 64-bit integer `entity_uid` handles | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-enemy-and-boss-system-001 | 3-Tier AI (Fodder tables with zero interrupt UI, Elite plugins, 4D Boss timelines with BossPartNode breaks), integer entity_uid handles, and Hitless Master Chamber Core | ADR-004 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/enemy-and-boss-system.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
