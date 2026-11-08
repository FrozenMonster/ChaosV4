extends RefCounted
class_name BalanceConfig
## Single Source of Truth for all global tuning parameters (ADR-003).
## Modifying any global 3C, Overcharge, Rarity, or Economy value touches ONLY this file.

# --- Player 3C Constants (Pillar 1: Sacrosanct 3C Lock) ---
const BASE_MOVE_SPEED: float = 290.0
const MAX_SPEED_MULT: float = 1.15
const DODGE_DURATION: float = 0.42
const DODGE_IFRAME_END: float = 0.28
const DODGE_SPEED: float = 640.0
const DODGE_RECOVERY_FACTOR: float = 0.42
const PLAYER_HURTBOX_RADIUS: float = 14.0
const BASE_GRAZE_RADIUS: float = 42.0
const MAX_GRAZE_PER_ROLL: int = 2

# --- Tier-1 Overcharge Generation (Calibrated for 72-100⚡ Room Budget) ---
const CHARGE_NORMAL_HIT: float = 0.5
const CHARGE_FINAL_ROUND: float = 4.0
const CHARGE_PERFECT_RELOAD: float = 8.0
const CHARGE_DODGE_GRAZE: float = 10.0
const CHARGE_INTERRUPT: float = 22.0
const BASE_MAX_OVERCHARGE: float = 100.0
const OVERDRIVE_BET_COST: float = 25.0

# --- Heavy Spender Cost Tiers (1-2 Casts Per Room) ---
const HEAVY_COST_LIGHT: float = 45.0
const HEAVY_COST_MEDIUM: float = 65.0
const HEAVY_COST_ULTIMATE: float = 90.0

# --- Overcharge Aegis Shield (3-Pip Active Reconstruction) ---
const AEGIS_PIPS_REQUIRED: int = 3
const PERFECT_RELOADS_PER_PIP: int = 3
const INVULN_DURATION: float = 1.0

# --- Loot Drop & Overcharge Multiplicative Boost Constants (Base * (1 + X%)) ---
const BASE_EQUIP_DROP_CHANCE: float = 0.35
const MAX_OVERCHARGE_DROP_BOOST: float = 0.80 # At 100⚡, drop chance = 0.35 * (1 + 0.80) = 63.0%
const BASE_WEIGHT_COMMON: float = 60.0
const BASE_WEIGHT_RARE: float = 26.0
const BASE_WEIGHT_EPIC: float = 11.0
const BASE_WEIGHT_LEGENDARY: float = 3.0
# --- Event Bus & Bullet Pool Safety Caps (ADR-001 & ADR-002) ---
const MAX_RECURSION_DEPTH: int = 2
const MAX_PROCS_PER_FRAME: int = 32
const MAX_PLAYER_BURST_CAP: int = 24
const MAX_SHAKE_OFFSET: float = 18.0
