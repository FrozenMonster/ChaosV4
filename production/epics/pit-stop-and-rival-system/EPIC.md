# Epic: Pit-Stop, Bounty Chip Economy & Rival Cast System

> **Layer**: Feature
> **GDD**: design/gdd/pit-stop-and-rival-system.md
> **Architecture Module**: `src/progression/pit_stop/`
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories pit-stop-and-rival-system`

## Overview

Implements the **4-Tier Global Rarity System (`COMMON / RARE / EPIC / LEGENDARY`)**, the **`🪙 Bounty Chips`** economy, **Old Rex's Randomized Black-Market Stall** (`50% OFF` flash deals, contraband overclocks, `60 🪙` Mystery Contraband Blind Box, and escalating Reroll Machine), **Bucky's 4-Axis Forge** (Firepower, Ballistic Handling, Active Reload Tuning, and **Muscle-Memory-Safe Exoskeleton Dodge/Graze upgrades**, plus strict **`+1 ❤️` heal cap**), and the **3-Category Cavern NPC & Rival Ecosystem** (Feature-Unlock Specialists, Conditional Quest-Givers, and Rival Hunters who evolve from Hidden Bosses into Playable Gunboys).

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-003: 80/20 Hybrid Composable Item Engine, 4-Stage Stat Pipeline & Single-File Locality | Bucky's 4-Axis Forge mods plug into `StatPipeline` while preserving locked `0.42s` roll duration | LOW |
| ADR-005: 6-Stream Coordinate-Hashed Deterministic RNG & Bad-Luck Pity System | Coordinate-hashed `stream_loot` / `stream_shop_forge` + `epic_pity_bonus` prevent `Alt+F4` Mystery Box save-scumming | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-pit-stop-and-rival-system-001 | 4-Tier Global Rarity (COMMON/RARE/EPIC/LEGENDARY), +1 HP heal cap, Randomized Black-Market with 60-Chip Mystery Box, 4-Axis Forge, and 3-Category NPC/Rival ecosystem | ADR-003, ADR-005 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/pit-stop-and-rival-system.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
