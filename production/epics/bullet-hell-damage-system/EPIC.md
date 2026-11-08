# Epic: Pooled Bullet-Hell & Damage System

> **Layer**: Core
> **GDD**: design/gdd/bullet-hell-damage-system.md
> **Architecture Module**: `src/combat/bullet_pool/`
> **Status**: Ready
> **Stories**: 2 stories

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 800-Slot Zero-Alloc BulletPool, Synergy Coalescing & Non-Blocking Hitstop | Logic | Ready | ADR-002, ADR-004 |
| 002 | 3-Tier Ballistic Recoil/Knockback & 3-Pip Overcharge Aegis Shield | Logic | Ready | ADR-002, ADR-004 |

## Overview

Implements the Dual-Track Projectile Pool (`800` zero-allocation circular/capsule slots + `24` custom polygon `Area2D` slots), **One-Way Non-Blocking Hitstop**, **Synergy Projectile Coalescing (`MAX_PLAYER_BURST_CAP = 24`)**, the **3-Tier Ballistic Impact & Recoil Matrix** (`0.03s` Final Round hitstop + `28px` knockback; `8/16/22px` Heavy Weapon shooter recoil slide), and the **3-Pip Overcharge Aegis Shield (`1/1 🛡️` active recharge, preserves Boss Hitless status against normal bullets)** versus **`SHIELD_PIERCING`** Elite/Boss signature attacks.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-002: Dual-Track Bullet Pool, Non-Blocking Hitstop & Projectile Coalescing | 800-slot `BulletPool`, One-Way Non-Blocking Hitstop, and `>24` player burst projectile coalescing | LOW |
| ADR-004: 3-Tier Enemy/Boss Customization & Crash-Proof Entity UID Handles | Monotonic 64-bit integer `entity_uid` handles prevent freed-instance and recycled-pool ABA crashes | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-bullet-hell-damage-system-001 | 800-slot zero-allocation BulletPool, One-Way Non-Blocking Hitstop (player delta unblocked), 3-Tier Ballistic Impact & Recoil (8/16/22px Heavy shooter slide), and 3-Pip Overcharge Aegis Shield vs SHIELD_PIERCING attacks | ADR-002, ADR-004 ✅ |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of `design/gdd/bullet-hell-damage-system.md` verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
