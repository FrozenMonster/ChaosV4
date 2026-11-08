<!-- PROTOTYPE - NOT FOR PRODUCTION -->
# Prototype Report: CHAMBER OVERDRIVE (Stage 1 3C & Overcharge Loop)

*Date*: 2026-11-08
*Path*: Engine Prototype (`prototypes/chamber_overdrive_proto/prototype_arena.tscn`)
*Verdict*: **PROCEED** (Ready for Stage 1 Art Bible & Stage 2 Systems Decomposition)

---

## 1. Core Questions Tested

1. **Does the 30-second combat loop (Primary Skirmish -> Risk-Weighted Overcharge Generation -> Active Reload / Final Round -> Cost-Tiered Heavy Spender Swap) feel intuitive and exciting without hurting 3C?**
   - **Result**: Yes. Locking player movement speed (`290 px/s`) and dodge-roll I-frames (`0.28s` I-frame + outer `42px` Graze ring) while delegating build variety to **Active Reload triggers**, **Dynamo Cores**, and **Cost-Tiered Heavy Weapons (30 / 50 / 90 Energy)** preserves 100% muscle-memory predictability.
2. **Does the Two-Tier Overcharge Economy (Tier-1 Universal Base Actions + Tier-2 Dynamo Cores) solve the "dominant strategy / overpowered weapon spam" problem?**
   - **Result**: Yes. The `90 Energy` Singularity Black Hole feels godlike when fired, but because it requires multiple high-risk actions (e.g., Weak-Point Interrupt `+35`, Dodge Graze `+20`, Demolition Barrel `+40`, Perfect Reload `+14`), it cannot be spammed AFK. Meanwhile, the `30 Energy` Swarm Missiles can be woven into every reload cycle.
3. **Does the 3-Door Routing (`Armory Door`, `Tactical Item Door [1 Active + 3 Passives]`, `Random Event Door`) + Overdrive Bet create meaningful choices between rooms?**
   - **Result**: Yes. Capping Passive Items at **3 slots** forces meaningful swap-and-salvage decisions instead of visual bloat, and injecting `25 Overcharge` into a door before entering creates immediate tension.

---

## 2. Validated Tuning Knobs (Carry forward to Stage 2 GDDs)

| Parameter | Prototype Value | Notes for Stage 2 GDD |
| :--- | :--- | :--- |
| `BASE_MOVE_SPEED` | `290.0 px/s` | Crisp evasion against `210–370 px/s` enemy projectiles |
| `DODGE_DURATION` / `DODGE_IFRAME_END` | `0.42s` / `0.28s` | `0.14s` end recovery makes dodge direction a real commitment |
| `GRAZE_RADIUS` | `42.0 px` (vs `14.0 px` hitbox) | Rewards bold rolls through bullet curtains (`+20` energy, max 2 per roll) |
| `ACTIVE_RELOAD_SWEET_SPOT` | `0.42–0.64` (`~22%` width) | Generous enough during bullet-hell dodging; widenable via Passive slot |
| `TIER_1_OVERCHARGE_VALUES` | Hit `+1`, Final `+8`, Reload `+14`, Graze `+20`, Interrupt `+35` | Strict risk-to-reward progression |
| `HEAVY_WEAPON_COSTS` | Light `30`, Medium `50`, Ultimate `90` | Prevents ultimate spam while keeping light spenders frequent |
| `LOADOUT_CAPS` | `1 Primary, 1 Heavy, 1 Dynamo | 1 Active, 3 Passives` | Core structural rule for Inventory & UI GDDs |
