# Pit-Stop, Bounty Chip Economy & Rival Cast System

> **Status**: Approved
> **Author**: user + economy-designer + narrative-director + systems-designer + qa-lead
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Pillar 1 (Sacrosanct 3C Consistency), Pillar 2 (Action Fuels Firepower), Pillar 3 (Reload & Swap Are Offensive Verbs), Pillar 4 (Zero-Filler High-Stakes Routing)

## Summary

Governs the **4-Tier Global Rarity System (`COMMON / RARE / EPIC / LEGENDARY`)**, the in-run **`🪙 Bounty Chips (悬赏工分币)`** economy, **Old Rex's Randomized Black-Market Stall** (flash discounts, contraband overclocks, `60 🪙` Mystery Contraband Blind Boxes, and escalating Reroll Machine), **Bucky's Multi-Axis Forge** (Firepower/Final Round, Ballistic Handling, Active Reload Tuning, and **Muscle-Memory-Safe Exoskeleton Dodge/Graze upgrades**, plus strict **`+1 ❤️` heal cap**), and the **3-Category Cavern NPC & Rival Ecosystem** distinguishing Feature-Unlock NPCs, Conditional Quest-Givers, and Rival Hunters who evolve from Hidden Bosses into Playable Gunboys.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `7-Slot Loadout & Tactical Items System`, `Enemy AI, Elite/Boss Interrupts & Boss System`, `3-Door Routing, Overdrive Bet & Floor Generator`

## Overview

*(Note: `creative-director` not consulted — Lean mode.)*

**Pit-Stop, Bounty Chip Economy & Rival Cast System** brings strategic depth, loot excitement, and Space-Western personality to every non-combat Pit-Stop and Random Event room in **CHAMBER OVERDRIVE (膛室超载)**:
1. **4-Tier Global Rarity System (`COMMON / RARE / EPIC / LEGENDARY`)**: Every weapon, Dynamo Core, Active/Passive item, and Forge upgrade is tiered by rarity, directly linking occurrence probability to power budget (`1.0x -> 2.2x+`), loot beam presentation, shop pricing, and salvage value—while **Overdrive Bets (`-25⚡`)** completely eliminate Common drops (`0%` White) and multiply Epic/Legendary odds by `3x–4x`.
2. **Randomized Black-Market & Multi-Axis Tactical Forge (With Strict `+1 ❤️` Healing)**: Pit-Stops never feel static or overly forgiving. Healing is strictly capped at **`+1 ❤️` Red Heart** so every hit matters. **Old Rex's Black-Market** mixes randomized gear with `50% OFF` flash deals, `60 🪙` Mystery Contraband Blind Boxes (which can pop Legendary loot or an ambushing Bounty Elite!), and an escalating Reroll Machine. **Bucky's Forge** upgrades not just flat damage, but **weapon handling (fire rate/mag size), Active Reload sweet-spot & buff duration, and Muscle-Memory-Safe Dodge/Graze performance** (expanding Graze Ring radius, raising per-roll Graze cap to `3`, or extending I-frame ratio `0.28s -> 0.33s` without altering the sacred `0.42s` roll duration/distance).
3. **3-Category Cavern NPC & Rival Ecosystem (Not Everyone Is Playable)**: Characters encountered in Planet X's caverns are divided into three distinct narrative and mechanical roles: **(A) Feature-Unlock Specialist NPCs** (*Old Rex*, *Bucky*), **(B) Conditional Side-Quest Givers** (*Ada the Whistleblower*, *Dr. Mork*), and **(C) Select Rival Bounty Hunters** (*Vesper the Quota-Queen*, *Specimen Y-Jr.*) who transition across `Stranger -> Ambushing Hidden Boss -> Ship Crewmate -> Unlockable Playable Gunboy`.

## Detailed Design

*(Note: `economy-designer`, `narrative-director`, and `systems-designer` consulted for rarity probability tables, multi-axis forge rules, and the 3-role NPC architecture.)*

### Core Rules

1. **Global 4-Tier Rarity System (`RarityTier` — Applied to Weapons, Items, Cores & Forge Mods)**:
   - Every rollable asset and upgrade belongs to one of four rarity tiers, scaling both mechanical impact and economy values:

| Rarity Tier (`rarity_tier`) | Visual Loot Beam & Frame | Power Budget & Design Scope | Base Shop Price (`🪙`) | Salvage Payout (`🪙`) |
| :--- | :--- | :--- | :--- | :--- |
| **1. `COMMON` (工业级·白)** | **Steel White (`#D1D5DB`)** | **`1.00x` Baseline**: Clean single-stat or single-hook effect (e.g., `+6%` reload sweet spot; `+12%` Forge base damage). | **`55 🪙`** | **`15 🪙`** |
| **2. `RARE` (军规级·蓝)** | **Electric Cyan (`#00F0FF`)** | **`1.35x` Enhanced**: Compound dual-stat bonus or enhanced proc (e.g., Perfect Reload clears bullets AND fires 2 homing bolts; Forge `+15%` fire rate & `+25%` mag size). | **`85 🪙`** | **`25 🪙`** |
| **3. `EPIC` (违禁级·紫)** | **Anomaly Violet (`#A855F7`)** | **`1.75x` Build-Defining**: Transforms weapon/action behavior (e.g., Final Round chains lightning across 3 targets; Forge `+10%` sweet spot & `+1.2s` Signature Buff duration). | **`130 🪙`** | **`40 🪙`** |
| **4. `LEGENDARY` (超载级·金)** | **Chamber Amber (`#FFB800`)**<br>+ Pillar Beam & Fanfare | **`2.20x+` Rule-Breaker**: Game-changing centerpiece (e.g., *Singularity Black Hole Cannon*, *Omega Core: Perfect Reload triggers Final Round effect*, or Exoskeleton *Phase Shifter* `+0.05s` I-frames & `3-Graze` cap). | **`190 🪙`** | **`65 🪙`** |

   - **Rarity Probability Matrix by Source (稀有度与获取途径挂钩表)**:

| Drop / Roll Source (产出途径) | `COMMON` (白) | `RARE` (蓝) | `EPIC` (紫) | `LEGENDARY` (金) |
| :--- | :--- | :--- | :--- | :--- |
| **Stratum 1 Standard Room Clear** | `58%` | `28%` | `11%` | **`3%`** |
| **Overdrive Bet Room Clear (`[F]` `-25⚡`)**<br>*(0% White Floor + 2-Choice Crate!)* | **`0%`** | `55%` | **`33%`** | **`12%`** |
| **Old Rex Mystery Contraband Box (`60 🪙`)** | `20%` *(or Chip Jackpot)* | `42%` | **`28%`** | **`10%`** *(or Elite Ambush)* |
| **Deep Strata (Floors 6–10 & Endless Loop)** | `15%` | `40%` | **`30%`** | **`15%`** |
| **Stratum Boss / Rival Hidden Boss Kill** | `0%` | `25%` | **`55%`** | **`20%`** *(Hitless = 100% Master Core)* |

2. **Old Rex's Randomized Black-Market Stall (老雷克斯随机黑市烧烤摊)**:
   - Expected player wallet entering Node 4 Pit-Stop is **`160–260 🪙 Bounty Chips`**.
   - **Randomized 4-Slot Layout**:
     1. **Slot 1 & Slot 2 (Dynamic Gear Racks)**: Rolls 1 Armory piece and 1 Tactical Item using Stratum rarity weights.
        - **`25%` Flash Discount Roll (`半价清仓`)**: One slot spawns at **`50% OFF`** price!
        - **`20%` Contraband Overclock Roll (`违禁超频装`)**: Guarantees `EPIC` or `LEGENDARY` rarity at `1.3x` price.
     2. **Slot 3 (`Mystery Contraband Blind Box` / 未鉴定走私盲盒 — Fixed `60 🪙`)**:
        - **50% High-Roll**: Unboxes a `RARE` (`45%`), `EPIC` (`40%`), or `LEGENDARY` (`15%`) weapon/relic!
        - **30% Resource Jackpot**: Explodes into **`90–130 🪙 Bounty Chips`** (net profit!) + `+50.0⚡` Overcharge.
        - **20% Corporate Tracker Ambush**: Triggers an anti-theft alarm, spawning 1 **Elite Bounty Enforcer** right inside the shop—defeating it drops a guaranteed `EPIC+` item plus `+45 🪙`!
     3. **Slot 4 (Strict Survival Ration — 限购 1 份【烤外星章鱼串】)**:
        - Restores strictly **`+1 ❤️` Red Heart** (never `+2 ❤️`, keeping survival tense). Base price **`65 🪙`** (increases to **`110 🪙`** for any subsequent purchase in the same run).
   - **Escalating Reroll Machine (`货架刷新投币机`)**: Players can pay **`25 🪙 -> 50 🪙 -> 90 🪙`** to reroll Slots 1–2 with a `+5%` cumulative bonus to `EPIC/LEGENDARY` weights per reroll.
3. **Bucky's Multi-Axis Forge & Muscle-Memory-Safe Exoskeleton Tuning (巴克铁匠铺多维调校)**:
   - Interacting with Bucky's Workbench offers **1 Free Choice** (plus optional `85 🪙` paid tuning) between **Emergency Patch (`+1 ❤️` HP OR `+2` Aegis Shield Pips `[■][■][□]`)** and **Tactical Tuning (rolls 3 rarity-weighted upgrade cards across 4 categories)**:

| Tuning Axis (强化维度) | What It Upgrades (具体强化内容 — 按 白/蓝/紫/金 缩放) | Muscle-Memory & Pillar 1 Safety Rule (手感保护边界) |
| :--- | :--- | :--- |
| **Axis 1: Firepower & Final Round**<br>*(膛压与尾弹强化)* | • Primary/Heavy Base Damage **`+12% / +18% / +25% / +35%`**<br>• Final Round Multiplier **`+0.25x` to `+0.60x`** & Knockback **`+10px`** | Pure output escalation; preserves firing rhythm. |
| **Axis 2: Ballistic Handling**<br>*(射速、弹道与弹匣调校)* | • Fire Rate **`+12% to +25%`** (clamped at `0.04s` min interval)<br>• Magazine Capacity **`+20% to +40%`** (`min +1` round)<br>• Projectile Velocity **`+20%`** & Spread **`-35%`** | Makes weapons snappier and higher-capacity without altering player movement. |
| **Axis 3: Active Reload Performance**<br>*(主动换弹与专属 Buff 调校)* | • Reload Duration **`-10% to -22%`** faster<br>• Sweet-Spot Window Width **`+5% to +12%`** wider<br>• Weapon **Signature Buff Duration `+0.6s to +1.5s`** (`2.5s -> 4.0s`!) | Directly rewards `[R]` mastery and extends signature weapon windows. |
| **Axis 4: Exoskeleton Mobility & Dodge-Graze**<br>*(机动与闪避擦弹外骨骼 — 不改落点时长!)* | • **Graze Matrix**: Graze Ring radius **`+20% to +45%`** & Max Grazes per Roll **`2 -> 3` (`+30⚡`/roll)**<br>• **Phase Shifter**: Extends I-frame ratio within the `0.42s` roll from **`0.28s -> 0.33s`** (shrinking vulnerable recovery from `0.14s -> 0.09s`)<br>• **Servo Joints**: Walk speed **`+8% to +12%`** (capped at `+15%` global max) + Cryo slow immunity | **CRITICAL**: `DODGE_DURATION` (`0.42s`) and `DODGE_SPEED` (`640 px/s` roll distance) are **100% locked and never altered**, so the player's spatial dodge-landing muscle memory never breaks! |

4. **3-Category Cavern NPC & Rival Ecosystem (三类洞窟奇人生态 — 非全员自机化)**:
   - Characters met in Planet X's caverns are strictly categorized into three distinct functional groups:

| NPC Category (角色分类) | Characters (代表人物) | Core Gameplay Role, Quest Conditions & Unlock Payoffs (核心职能、条件任务与解锁要素) |
| :--- | :--- | :--- |
| **Category A: Feature-Unlock Specialist NPCs**<br>*(功能解锁型常驻 NPC — **不可操控**)* | **1. 「老烟枪」雷克斯 (Old Rex)**<br>*(Black-Market Boss)*<br>**2. 「炸膛大师」巴克 (Bucky)**<br>*(Master Gunsmith)* | • **Never Playable**; serve as permanent Pit-Stop & Ship Hub anchors.<br>• **Meta-Unlocks**: Recovering Rex's confiscated *Smuggler Star-Chart* (Floor 3) permanently unlocks the **Mystery Contraband Box & Reroll Machine**; bringing Bucky 3 Boss Scrap Cores permanently unlocks **Axis 3 (Reload) & Axis 4 (Exoskeleton) Forge Tuning**!<br>• **Sparring Easter Egg**: Triggering their optional sparring duel awards their signature `LEGENDARY` weapon blueprints into the global drop pool. |
| **Category B: Conditional Quest-Giver NPCs**<br>*(条件触发任务型奇遇 NPC — **不可操控**)* | **3. 「审计幽灵」算盘姐 (Ada)**<br>*(Ex-Corp Hacker)*<br>**4. 「标本狂人」莫克博士 (Dr. Mork)**<br>*(Xenobiologist)* | • **Never Playable**; appear in `RANDOM_EVENT_DOOR` rooms and **only issue high-stakes side quests when the player meets specific run conditions**:<br>  - **Ada's Audit Quest** *(Condition: Player holds `>= 140 🪙` OR has an active Overdrive Bet streak)*: Hands you a *Encrypted Ledger Drive*—clear the next **2 rooms without losing Red Heart `hp` (or within `45s` total)** to upload the evidence, immediately dropping an `EPIC/LEGENDARY` Relic and permanently unlocking the **Corporate Audit Relic Set**!<br>  - **Dr. Mork's Field Trial** *(Condition: Player equips a Heavy Spender or status weapon)*: Tasks you with killing the next Elite using an **Arena Interactable or Final Round**, unlocking new **Dynamo Cores** and Enemy Codex weak-point data. |
| **Category C: Rival Bounty Hunters**<br>*(宿敌同行猎人 — **可转化为隐藏 Boss 并解锁为【可操控角色】**)* | **5. 「卷王猎人」薇拉 (Vesper)**<br>*(Cyber-Sniper)*<br>**6. 「实习生」小 Y (Specimen Y-Jr.)**<br>*(Sample Y Mimic)* | • **Select Elite Rivals Only**: Progress through a 4-stage arc:<br>  1. `STRANGER_RIVAL`: Encountered in event rooms trading banter or wagering.<br>  2. `AMBUSH_HIDDEN_BOSS`: Triggered by specific run feats (e.g., Vesper ambushes on Node 6 when `stratum_bet_streak >= 2`; Specimen Y-Jr. mutates when entering an Anomaly room at `100⚡` Overcharge).<br>  3. `SHIP_ALLY`: Defeating their Hidden Boss form recruits them to the Ship Hub bar.<br>  4. `PLAYABLE_GUNBOY`: Unlocks as a **Playable Character** with a unique starter `Primary + Heavy + Dynamo + Passive Trait`! *(Anti-Clone Rule: When playing as Vesper, her ambush slot is replaced by a Corporate Bounty Clone so she never fights herself).* |

### States and Transitions

| Pit-Stop & NPC State | Condition | Allowed Transitions | Behavior |
| :--- | :--- | :--- | :--- |
| **`PIT_STOP_BROWSING`** | Player enters Node 4 Pit-Stop or Event Room | $\rightarrow$ `CONTRABAND_AMBUSH_ACTIVE` if Mystery Box rolls `20%` Elite trap<br>$\rightarrow$ `SIDE_QUEST_ACTIVE` on accepting Category B NPC quest<br>$\rightarrow$ `ROOM_CLEARED_ROUTING` | Old Rex's 4-slot shop and Bucky's Multi-Axis Forge are interactive; out-of-combat Overcharge farming remains locked. |
| **`CONTRABAND_AMBUSH_ACTIVE`** | Mystery Box (`60 🪙`) rolled `20%` Corporate Tracker | $\rightarrow$ `PIT_STOP_BROWSING` when Ambush Elite reaches `0 HP` | Seals exit doors temporarily; spawns 1 Elite Enforcer; drops guaranteed `EPIC/LEGENDARY` item + `45 🪙` on defeat. |
| **`SIDE_QUEST_ACTIVE`** | Accepted conditional quest from *Ada* or *Dr. Mork* | $\rightarrow$ `SIDE_QUEST_COMPLETED` when condition met in next 1–2 rooms<br>$\rightarrow$ `SIDE_QUEST_FAILED` if fail condition hit | Tracks quest progress in Top-Right HUD tracker; spawns bonus reward pod and permanent codex unlock upon completion. |

### Interactions with Other Systems

| Connected System | Direction | Data / Signals Exchanged | Interface Owner |
| :--- | :--- | :--- | :--- |
| **Combat Event Bus & Data Schema** | Bidirectional | Uses `rarity_tier` across all `Resource` schemas; emits `bounty_chips_changed` and `loadout_changed` | `Combat Event Bus & Data Schema` |
| **7-Slot Loadout & Tactical Items System** | Bidirectional | Injects Bucky's Forge stat modifiers into the 4-Stage Stat Pipeline; supplies `salvage_chip_value` (`15/25/40/65 🪙`) by rarity | `7-Slot Loadout & Tactical Items System` |
| **Player 3C, Dodge-Graze & Tactical Arena Interactables** | Downstream Consumer | Applies Axis 4 Exoskeleton upgrades (`graze_radius`, `MAX_GRAZE_PER_ROLL = 3`, `DODGE_IFRAME_END = 0.33s`) while keeping `DODGE_DURATION = 0.42s` locked | `Player 3C, Dodge-Graze & Tactical Arena Interactables` |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Upstream Producer | Passes `has_overdrive_bet` and `stratum_index` to shift rarity weights (`0%` Common on Overdrive Bet) | `3-Door Routing, Overdrive Bet & Floor Generator` |

## Formulas

*(Note: `economy-designer` and `systems-designer` consulted for dynamic rarity weighting and shop/forge pricing math.)*

### 1. Dynamic Rarity Weight & Equipment Drop Chance (`Base * (1 + X%)`)

Standard monster encounter rooms are **not** guaranteed to drop equipment on every clear (defaulting to `🪙 Bounty Chips` when no equipment drops). Both the **Equipment Drop Probability** and the **4-Tier Rarity Weights** scale multiplicatively with the player's **Overcharge Boost Factor `X%`** (`x_pct = (overcharge / max_overcharge) * 0.50 + bet_tier * 0.20`):

`final_equip_drop_chance = clamp(BASE_EQUIP_DROP_CHANCE (0.35) * (1.0 + x_pct), 0.0, 0.95)`

`w_common = 60.0`

`w_rare = 26.0 * (1.0 + 0.50 * x_pct)`

`w_epic = 11.0 * (1.0 + 1.20 * x_pct)`

`w_legendary = 3.0 * (1.0 + 2.00 * x_pct)`

The exact same `(1.0 + k * x_pct)` Overcharge multiplier also boosts **Bucky's Forge card stat magnitudes (`Base * (1 + 0.5 * X%)`)**, **Old Rex's Black-Market discounts & Mystery Contraband Box payouts (`Base * (1 + X%)`)**, and **Random Event beneficial outcome weights & chip rewards (`Base * (1 + X%)`)**.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `stratum_index` | int | `1–10` | calculated | Current subterranean stratum (`1..10`) |
| `has_overdrive_bet` | bool | `true/false` | calculated | True if the player injected `-25.0⚡` Overdrive Bet into the room door |

**Output Range:** Normalized probabilities summing to `100%`.
**Example:** On Stratum 1 (`stratum_index = 1`):
- **Normal Room (`has_overdrive_bet = false`)**: `w = [58.0, 28.0, 11.0, 3.0]` $\rightarrow$ **`58%` Common, `28%` Rare, `11%` Epic, `3%` Legendary**.
- **Overdrive Bet Room (`has_overdrive_bet = true`)**: `w = [0.0, 55.0, 33.0, 12.0]` $\rightarrow$ **`0%` Common, `55%` Rare, `33%` Epic, `12%` Legendary**!

---

### 2. Black-Market Dynamic Item Price (`final_shop_price`)

The cost in **`🪙 Bounty Chips`** for an item of rarity `R` in Old Rex's Black-Market is defined as:

`final_shop_price = round(base_rarity_price * (1.0 + STRATUM_PRICE_SLOPE * float(stratum_index - 1)) * (0.50 if is_flash_discount else (1.30 if is_contraband_overclock else 1.0)) * (0.85 if rex_quest_completed else 1.0))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `base_rarity_price` | float | `55.0–190.0` | data file | Base price by rarity (`55` Common, `85` Rare, `130` Epic, `190` Legendary) |
| `STRATUM_PRICE_SLOPE` | float | `0.06` | data file | `+6%` price scaling per deeper stratum (matching higher Chip drops) |
| `is_flash_discount` | bool | `true/false` | calculated | True if the slot rolled the `25%` Half-Price Flash Deal (`0.50x`) |
| `is_contraband_overclock` | bool | `true/false` | calculated | True if the slot rolled the `20%` Overclocked Contraband bonus (`1.30x`) |
| `rex_quest_completed` | bool | `true/false` | data file | True if the player completed Old Rex's Smuggler Star-Chart quest (`15%` permanent VIP discount) |

**Output Range:** `23 🪙` (discounted Common) to `375 🪙` (deep-stratum Contraband Legendary).
**Example:** A `RARE` weapon (`base_rarity_price = 85.0`) on Stratum 2 (`stratum_index = 2`) with a Flash Discount (`is_flash_discount = true`, `rex_quest_completed = false`) costs `round(85.0 * 1.06 * 0.50 * 1.0) = 45 🪙 Bounty Chips`.

## Edge Cases

- **If the player rolls Bucky's Axis 4 Exoskeleton upgrade (*Phase Shifter* `+0.05s` I-frames) multiple times**: `DODGE_IFRAME_END` is hard-capped by the 4-Stage Stat Pipeline at **`0.34s`** (out of `0.42s` total `DODGE_DURATION`), ensuring at least `0.08s` of post-roll recovery always remains and `DODGE_DURATION` (`0.42s`) never changes.
- **If the player opens a `60 🪙` Mystery Contraband Box and triggers the `20%` Elite Ambush while at `1 ❤️` HP**: The Ambush Elite spawns with a `1.2s` warning telegraph (`0.8s` floor ring + alarm) at the opposite end of the shop stall so the player is never cheap-shot on the frame they press `[E]`.
- **If the player meets a Category B Quest-Giver (*Ada*) when they do NOT meet her condition (`< 140 🪙` and `0` Overdrive Bet streak)**: Instead of a dead room, Ada offers a smaller fallback interaction (trading `25 🪙` for a `RARE` intel buff or a free `+25.0⚡` Overcharge battery) and hints at how to trigger her main quest next time.

## Dependencies

| Dependency | Direction | Type | Interface / Data Exchanged |
| :--- | :--- | :--- | :--- |
| **7-Slot Loadout & Tactical Items System** | Depends on (Upstream) | Hard | Uses `rarity_tier`, 4-Stage Stat Pipeline, and rarity-scaled salvage payouts (`15/25/40/65 🪙`) |
| **Enemy AI, Elite/Boss Interrupts & Boss System** | Depends on (Upstream) | Hard | Spawns Rival Hidden Bosses (`RivalHunterBrain`) and Shop Ambush Elites |
| **3-Door Routing, Overdrive Bet & Floor Generator** | Depends on (Upstream) | Hard | Places Node 4 Pit-Stops, `RANDOM_EVENT_DOOR` NPCs, and passes `has_overdrive_bet` to rarity formulas |
| **Save/Load, Ship Hub & Meta-Progression** | Depended on by (Downstream) | Hard | Persists NPC quest unlocks (*Rex*, *Bucky*, *Ada*, *Mork*) and unlocked Playable Gunboys (*Vesper*, *Specimen Y-Jr.*) |

## Visual/Audio Requirements

*(Note: Aligned with `design/art/art-bible.md` Sections 2, 4, 5, 7, and 8.)*

- **4-Tier Rarity Loot Beams & Card Frames (`Z = 20` & `Z = 50`)**:
  - Dropped crates, shop items, and Bucky's Forge cards display unmistakable color-coded borders and vertical light beams (**Steel White `#D1D5DB`**, **Electric Cyan `#00F0FF`**, **Anomaly Violet `#A855F7`**, **Chamber Amber Gold `#FFB800`**) paired with 1/2/3/4 star notches for colorblind accessibility.
- **Audio Cues**:
  - Sizzling grill ambient loop at Old Rex's stall; rhythmic anvil clangs at Bucky's Forge; ascending slot-machine reel spin + jackpot fanfare (or siren klaxon on Elite trap!) when opening the `60 🪙` Mystery Contraband Box.

📌 **Asset Spec** — Visual/Audio requirements are defined for the 4 Rarity Tiers, Pit-Stop stalls, and the 6 Cavern NPCs/Rivals.

## Game Feel

- **Loot Dopamine With Player Agency**: Watching an Overdrive Bet (`-25⚡`) strip away all White items and pop a glowing Amber Gold `LEGENDARY` pillar makes every risk feel tangibly rewarded.
- **Gunsmithing That Respects Muscle Memory**: Upgrading your gun's reload sweet-spot width or your exoskeleton's Graze Ring radius makes your character feel noticeably sharper and deadlier without ever throwing off your dodge-roll timing.

## UI Requirements

- **3-Card Forge & Shop Selection Overlay**: Clean non-cluttered comparison cards colored by `rarity_tier` showing exact stat deltas (`+18% 射速 | +2 弹匣容量 [军规级·蓝]`).
- **Active Side-Quest Tracker Badge**: Displayed under the Top-Right Room Objective Tracker while an *Ada* or *Dr. Mork* quest is active (`📋 算盘姐委托: 无伤通过下 1 间 [1/2]`).

> **📌 UX Flag — Pit-Stop, Bounty Chip Economy & Rival Cast System**: Shop/Forge selection cards and Side-Quest tracker badges will be included in `design/ux/`.

## Cross-References

| Referenced System / Document | Specific Section / Value Referenced | Alignment Verified |
| :--- | :--- | :--- |
| `design/gdd/combat-event-bus.md` | `rarity_tier` on all 7-Slot `Resource` schemas, `bounty_chips_changed` | Yes — synced across all schemas |
| `design/gdd/player-3c-controller.md` | `DODGE_DURATION = 0.42s` (locked), `BASE_GRAZE_RADIUS = 42.0 px` | Yes — Axis 4 Exoskeleton upgrades preserve `0.42s` roll duration |
| `design/gdd/loadout-and-items-system.md` | 4-Stage Stat Pipeline, Salvage payouts (`15/25/40/65 🪙` by rarity) | Yes — Forge mods plug directly into Stage 1/2 of the stat pipeline |
| `design/narrative/world-lore.md` | *Old Rex*, *Bucky*, *Vesper*, *Specimen Y-Jr.*, plus Quest-Givers *Ada* & *Dr. Mork* | Yes — 3-Category NPC ecosystem matches lore |

## Acceptance Criteria

*(Note: `qa-lead` consulted to ensure all criteria are independently testable.)*

- **GIVEN** a room cleared with an active Overdrive Bet (`has_overdrive_bet == true`), **WHEN** `effective_rarity_weight` rolls the 2-Choice Reward Crate on Stratum 1, **THEN** `w_common` equals `0.0` (`0%` Common items) and `RARE / EPIC / LEGENDARY` probabilities equal `55% / 33% / 12%`.
- **GIVEN** the player interacts with Old Rex's healing ration or Bucky's emergency heal option, **WHEN** the heal is applied, **THEN** it restores strictly `+1 ❤️` Red Heart (never exceeding `+1 ❤️` per interaction).
- **GIVEN** the player selects an Axis 4 Exoskeleton upgrade (*Phase Shifter* or *Graze Matrix*) at Bucky's Forge, **WHEN** the player performs a `Space` dodge roll, **THEN** `effective_graze_radius`, `MAX_GRAZE_PER_ROLL`, or `DODGE_IFRAME_END` increases as specified while total `DODGE_DURATION` (`0.42s`) and roll distance remain 100% unchanged.
- **GIVEN** the three NPC categories (`Category A: Specialist`, `Category B: Conditional Quest-Giver`, `Category C: Rival Hunter`), **WHEN** the player completes *Ada*'s or *Old Rex*'s questline versus defeating *Vesper*'s Hidden Boss form, **THEN** *Ada* and *Rex* unlock permanent item pools/shop features while remaining non-playable NPCs, whereas *Vesper* unlocks as a selectable Playable Gunboy.

## Open Questions

- *None — the 4-Tier Rarity System, `+1 ❤️` heal cap, Randomized Black-Market, 4-Axis Forge, and 3-Category NPC ecosystem are locked.*
