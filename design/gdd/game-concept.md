# Game Concept: CHAMBER OVERDRIVE (膛室超载)

*Created: 2026-11-08*
*Status: Approved*

---

## Elevator Pitch

> An adrenaline-fueled top-down twin-stick bullet-hell Roguelite where you master a "Generator & Spender" dual-gun engine. Harvest Overcharge energy in real time through diverse combat actions—dodge-roll grazing, timed Active Reloads, weak-point interrupts, environmental chain reactions, and elemental detonations—to unleash devastating heavy weapons in combat or inject surplus charge into room doors as high-stakes "Overdrive Bets."

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Action Roguelite / Top-Down Twin-Stick Bullet Hell |
| **Platform** | PC (Steam — Windows, macOS, Linux, Steam Deck Verified target) |
| **Target Audience** | Mid-core to Hardcore action roguelite and twin-stick shooter fans |
| **Player Count** | Single-player |
| **Session Length** | 30–45 minutes per full run (8–12 minutes per biome) |
| **Monetization** | Premium (Steam paid release, no microtransactions) |
| **Estimated Scope** | Medium (6–10 months, solo/small team with CCGS agent pipeline) |
| **Comparable Titles** | *Enter the Gungeon*, *Hades*, *DOOM Eternal*, *Nuclear Throne* |

---

## Core Fantasy

You are a wise-cracking **Space "Gunboy" (intergalactic cowboy & bounty hunter)** who took the ultimate "100-Million Star-Cred" bounty on lawless **Planet X**: dive to the bottom of an ever-shifting subterranean cavern to retrieve the mysterious **Sample Y**—only to read the microscopic fine print after landing (*99,999,950 Creds pre-deducted for drop-pod fuel, oxygen tax, and respawn fees*). Refusing to work for free, you dance on the razor's edge of a mechanical bullet hell, turning every bold dodge-roll graze, timed Active Reload, and weak-point interrupt into raw Overcharge firepower. As you descend from the 3-floor surface bait-trap into a 10-stratum corporate conspiracy (and an Endless Overdrive Loop beyond), you cross paths with eccentric rival hunters and survivors—some becoming skewer-grilling Black-Market Merchants, some ambushing you as Hidden Bosses, and others joining your ship crew as newly unlockable Playable Gunboys.

---

## Unique Hook

It combines *Enter the Gungeon*'s tight dodge-roll and table-flipping bullet-hell positioning **AND ALSO** introduces a **Dual-Gun Overcharge Engine + Active Reload / Final-Round Trigger Architecture** paired with **Zero-Backtrack "Overdrive Bet" Door Routing**:
1. **Generator & Spender Dual-Gun Loop**: Your primary weapon has infinite ammo and rock-solid, handcrafted 3C feel; your secondary Overcharge Heavy Weapon has no passive ammo drops and is fueled by a **Two-Tier Overcharge Economy**:
   - **Tier 1 (Risk-Weighted Universal Base Actions)**: Core skillful actions always grant baseline Overcharge scaled strictly by execution difficulty and risk—e.g., normal hits (+1), timed Perfect Reloads (+14), high-risk Dodge-Roll Grazing through enemy bullets (+20 per graze with diminishing cap), and **Elite/Boss-only Weak-Point Red-Flash Interrupts (+35)**.
   - **Tier 2 (Difficulty-Weighted Dynamo Cores + Cost-Tiered Heavy Spenders)**: Equipping a customizable **Dynamo Core** adds specialized charging rules where higher-skill or harder-to-set-up triggers yield larger energy bursts (e.g., simple Multi-Kill Core gives +12, while triggering a Ranged/Proximity **Tactical Arena Interactable** or 3-Stack Elemental Detonation Core yields +35–40). On the output side, Heavy Weapons are balanced by **tiered Overcharge Energy Costs** matching their power (Light Tactical Spenders: 30 Energy; Mid-Tier Burst: 50 Energy; Ultimate Screen-Warpers like the Black Hole Cannon: 90 Energy).
2. **Active Reload & Final-Round Triggers**: Reloading is never dead downtime—emptying your magazine triggers a **Final Round** effect, and hitting the sweet spot on the overhead **Active Reload** slider instantly chambers the next mag while firing off tactical relic effects.
3. **Overdrive Bet Door Routing, Customizable Arena Interactables & Bounty Chip Economy**: No tedious empty-room backtracking or derivative table-flipping clones. Combat arenas feature data-driven **Proximity (`[E]`) & Ranged-Hit Tactical Interactables** (pop-up energy shields, overcharge capacitors, cryo tanks, bullet-splitting prisms). After clearing a room, choose between 3 previewed forward doors using **Bounty Chips (悬赏工分币)** and optionally inject surplus Overcharge into a door as an **Overdrive Bet**.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Challenge** (obstacle course, mastery) | 1 | Tight bullet patterns, Active Reload timing windows, dodge-roll positioning, Overdrive Bet risk-reward |
| **Sensation** (sensory pleasure) | 2 | Punchy hitstop, normalized screen shake, crisp reload clicks, high-contrast neon projectiles |
| **Expression** (self-expression, creativity) | 3 | Choosing how you generate Overcharge (Dynamo Cores) and chaining Final-Round / Reload / Swap triggers |
| **Discovery** (exploration, secrets) | 4 | Discovering weapon-relic synergies, high-risk Shrine contracts, and boss flawless rewards |
| **Fantasy** (make-believe, role-playing) | 5 | Being an unstoppable tactical gunslinger inside an ever-shifting clockwork foundry |
| **Submission** (relaxation, comfort zone) | 6 | Tight 30–45 min runs with instant restart and muscle-memory 3C consistency |
| **Narrative** (drama, story arc) | 7 | Environmental storytelling and NPC merchants/gunsmiths in Pit-Stop rooms and Hub |
| **Fellowship** (social connection) | N/A | Single-player experience (community sharing of crazy build seeds and clips) |

### Key Dynamics (Emergent player behaviors)
- Players intentionally roll *through* dense enemy bullet waves rather than away from them when they need Overcharge energy to finish off an elite.
- Players count their remaining magazine rounds to make sure their **Final Round** lands on a high-priority target, immediately followed by a rhythm-timed **Perfect Reload** to trigger a shockwave or lightning nova.
- Players weigh their current HP, Scrap Shells, and Overcharge bar at the end of each room: *"Do I spend my Overcharge to bet on a double-reward elite room, or save it and take the Pit-Stop door to heal and upgrade my core mod?"*

### Core Mechanics (Systems we build)
1. **Precision 3C & Committed Dodge Roll**: 8-way movement, 360° aiming, dodge roll with front-loaded I-frames, outer Graze detection ring, end recovery frames, and interactive table-flipping cover.
2. **Active Reload & Final-Round Trigger System**: Overhead reload bar with Perfect / Good / Jammed zones; modular relic hooks bound to `OnFinalRound`, `OnPerfectReload`, `OnWeaponSwap`, and `OnDodgeGraze`.
3. **Dual-Gun Overcharge & Multi-Source Dynamo System**: Primary infinite-ammo weapon + Secondary Overcharge heavy weapon; pluggable Dynamo Cores that convert Graze, Perfect Reloads, Weak-Point Interrupts, Multi-Kills, Elemental Reactions, or Bullet Destruction into Overcharge energy.
4. **Previewed Door Graph, Overdrive Bets & Pit-Stop Economy**: Hand-crafted room templates connected in a forward-moving node graph (Combat Doors, Black-Market Shop + Rest/Forge Pit-Stop Doors, High-Risk Event Doors) with Scrap Shell currency and pre-door Overdrive Betting.
5. **High-Readability Bullet Pool & Boss DPS Soft-Cap**: Object-pooled projectile manager supporting 500+ concurrent bullets with strict foreground/background contrast rules and anti-one-shot Boss resilience.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Competence** (mastery, skill growth) | Every mechanical skill (dodging, reload timing, interrupting enemy wind-ups, weapon swapping) directly converts into visible firepower and flawless boss rewards | Core |
| **Autonomy** (freedom, meaningful choice) | Choosing your Dynamo charging style, routing through previewed doors, deciding when to wager Overcharge on Overdrive Bets, and choosing between Healing vs. Upgrading at Pit-Stops | Core |
| **Relatedness** (connection, belonging) | Recurring eccentric gunsmith and merchant NPCs in the Hub and Pit-Stops who react to your run streaks and weapon choices | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — Mastering flawless Boss kills (Master Cores), unlocking the full Armory codex, and clearing higher Overdrive Contract tiers.
- [x] **Explorers** (discovery, understanding systems, finding secrets) — Experimenting with Dynamo Core + Trigger Relic + Heavy Weapon combinations and discovering secret Shrine interactions.
- [ ] **Socializers** (relationships, cooperation, community) — Minimal (sharing build screenshots and Steam achievements).
- [x] **Killers/Competitors** (domination, PvP, leaderboards) — Speedrun timers, highest Overdrive Bet streak records, and aggressive push-forward combat pacing.

### Flow State Design

- **Onboarding curve**: First room teaches Move, Shoot, Dodge Roll, and Table Flip; second room highlights the Active Reload sweet spot and Dual-Gun Overcharge swap via responsive visual/audio cues without wall-of-text tutorials.
- **Difficulty scaling**: Base biome difficulty scales across 3–4 floors, while **Overdrive Bets** let skilled players self-modulate difficulty room by room for faster snowballing.
- **Feedback clarity**: Distinct audio-visual cues for Graze ticks, Final Round chambering (distinct metallic click + muzzle tint), Perfect Reload flash, and enemy Weak-Point interrupt windows.
- **Recovery from failure**: Instant "Quick Restart" (< 1 second reload into room 1), plus guaranteed Pit-Stop (Shop + Rest/Forge) nodes twice per floor so a single mistake doesn't doom a run.

---

## Core Loop

### Moment-to-Moment (30 seconds)
1. **Skirmish & Harvest Overcharge**: Move and fire with your handcrafted Primary Weapon while reading enemy bullet patterns. Generate Overcharge energy via your active **Dynamo Core**—dodging through bullets (Graze), hitting Perfect Reloads, interrupting red-flash enemy wind-ups, detonating arena hazards, or triggering elemental reactions.
2. **Final Round & Active Reload Combo**: Fire the last bullet in your clip to trigger your **Final Round** modifier, then tap `R` inside the overhead slider's sweet spot for a **Perfect Reload** (0.15s instant reload + bonus Overcharge + `OnPerfectReload` relic proc).
3. **DirectUnleash Heavy Spender (RMB)**: When the Overcharge gauge hits threshold, press **Right Mouse Button (`RMB`)** to fire your **Overcharge Heavy Weapon** directly without awkward weapon-swap downtime, while **`Space`** executes your Dodge Roll, **`Q`** triggers your Active Item, **`E`** flips cover tables / enters doors, and **`R`** performs Active Reload.

### Short-Term (5-15 minutes — Biome Progression, Loadout Slots & 3 Door Categories)
1. **Strict 7-Slot Player Loadout Schema (Prevents Visual Clutter & Balance Bloat)**:
   - **Armory Group (3 Slots)**: `Primary Weapon` (Cap: 1, infinite ammo) + `Heavy Spender Weapon` (Cap: 1, tiered Overcharge cost: 25 / 50 / 90) + `Dynamo Core` (Cap: 1, difficulty-weighted Tier-2 Overcharge rules).
   - **Tactical Item Group (4 Slots)**: `Active Item` (Cap: 1, cooldown/charge-based tactical skill) + `Passive Items` (Cap: 3, high-impact modifiers affecting movement/dodge perks or weapon/reload performance; picking up a 4th requires swapping & salvaging an existing one into Scrap Shells).
2. **Zero-Backtrack Previewed Door Selection (3 Core Door Categories + Pit-Stop)**: Clearing a room unlocks 2–3 forward doors directly matching the item taxonomy:
   - **Category 1: Armory Doors (枪械门)**: Drops `Primary Weapons`, `Heavy Spenders`, or `Dynamo Cores`.
   - **Category 2: Tactical Item Doors (道具门)**: Drops `Active Items (Cap 1)` or `Passive Items (Cap 3)`.
   - **Category 3: Random Event / Anomaly Doors (随机事件门)**: Dynamic risk-reward combinations of **Currency (Scrap Shells), HP/Armor, Overcharge Energy, and Special Monsters**—including Black-Market Merchant & Rest/Forge Pit-Stops, HP-for-Upgrade Blood Reactors, Overcharge Extraction Shrines, and Timed Bounty Elites.
3. **Pre-Door "Overdrive Bet" (Risk/Reward Wager)**: Before opening an Armory or Item Combat Door, the player may inject surplus Overcharge energy into the door lock to activate an **Overdrive Bet** (e.g., *+1 Elite Reinforcer*, *Faster Enemy Projectiles*, or *35s Blitz Timer*). Winning the bet upgrades the room's drop rarity or adds bonus Scrap Shells.
4. **Floor Boss Showdown**: Every 6–8 rooms culminates in a multi-phase bullet-hell Boss. Defeating the Boss hitless awards a **Master Chamber Core** (permanent Max HP + Overcharge capacity up for the run).

### Session-Level (30-45 minutes — 3-Floor Bait Contract, 10-Stratum Conspiracy & Endless Loop)
A standard run spans 3 distinct subterranean strata on Planet X (approx. 10 minutes each) culminating in the Decoy Vault Boss, while the full expandable world architecture scales seamlessly across **10 Strata** down to the true **Sample Y** heart—plus an **Endless Overdrive Loop (Floor 11 $\rightarrow \infty$)** where players pump Overcharge into Sample Y like a cosmic slot machine to farm the corrupt megacorp into bankruptcy. Along the way, recurring fellow bounty hunters dynamically act as Pit-Stop NPCs, Black-Market Merchants, Hidden Bosses, and unlockable Playable Gunboys (see `design/narrative/world-lore.md`).

### Long-Term Progression
Players spend meta-currency (**Overdrive Sparks**) in the Hub Foundry to:
- Unlock new Primary Weapon & Heavy Spender starter loadouts with distinct playstyles.
- Unlock new **Dynamo Cores** (e.g., *Berserker Heat Core*, *Elemental Conduit Core*, *Demolition Core*) and **Trigger Relics** added to the run drop pool.
- Unlock optional **Overdrive Protocol Modifiers** (escalating difficulty pacts for veteran replayability).

### Retention Hooks
- **Curiosity**: Discovering how new Dynamo Cores interact with Final-Round and Weapon-Swap relics.
- **Investment**: Completing the Armory Codex and unlocking alternate starting Gun-Runner loadouts.
- **Mastery**: Pulling off consecutive Perfect Reload chains, surviving max-stack Overdrive Bets, and earning hitless Boss Master Cores.

---

## Game Pillars

### Pillar 1: Sacrosanct 3C Consistency (铁板一块的恒定 3C 手感)
Base character movement speed, dodge-roll distance, I-frame timing, and handcrafted weapon recoil/cadence are sacred and never degraded by passive modifiers or visual clutter.

*Design test*: If a proposed item or synergy slows player movement, alters dodge-roll recovery frames, or spawns opaque player explosions that hide enemy bullets, we reject or redesign it so player 3C and bullet readability remain 100% predictable.

### Pillar 2: Action Fuels Firepower (操作即弹药，多流派充能)
Devastating heavy weapons cannot be spammed passively or hoarded via random ammo drops; they are earned dynamically in combat through the player's chosen Dynamo playstyle (grazing, reload timing, weak-point interrupts, arena destruction, or elemental chains).

*Design test*: When designing a screen-clearing heavy weapon (like a Black Hole Cannon), instead of nerfing its damage until it feels weak, we balance it via its Overcharge energy cost so it always feels godlike when earned.

### Pillar 3: Reload & Swap Are Offensive Verbs (换弹与切枪皆是进攻连招)
Reloading and weapon swapping are never passive downtime; every empty clip (Final Round), timed reload (Perfect Reload), and weapon switch is an active combat trigger.

*Design test*: If a new relic idea is just "+15% flat damage," we rewrite it into an active hook (e.g., *"Perfect Reload fires a piercing arc that marks enemies for +40% Heavy Weapon damage"*).

### Pillar 4: Zero-Filler High-Stakes Routing (零垃圾时间的明牌博弈推进)
Every room transition presents a meaningful tactical choice between previewed combat rewards, Overdrive Bet risk-taking, and Shop/Pit-Stop recovery vs. upgrading—never walking through empty corridors.

*Design test*: If a map mechanic requires the player to backtrack across cleared rooms or leave a chest unopened due to RNG key starvation, we cut it in favor of forward door choices and Overdrive Bets.

### Anti-Pillars (What This Game Is NOT)

- **NOT an AFK Auto-Battler**: We will NOT build passive orbitals or self-aiming screen-wipers that play the game without aiming, dodging, or managing Overcharge, because that destroys Pillar 1 and Pillar 2.
- **NOT an Uncontrolled Part-Salad**: We will NOT build randomized gun-part soup where 80% of combinations feel clunky or broken; every Primary and Heavy weapon is a handcrafted archetype enhanced by structured Trigger Relics.
- **NOT a Stat-Grind RPG**: We will NOT sell permanent "+50% HP / +50% Damage" meta-upgrades that force players to grind 20 failed runs before the game is winnable; skill and in-run build synergy can win on Run #1.

---

## Visual Identity Anchor

- **Direction Name**: **High-Contrast Tactical Industrial Pixel / Crisp 2D Stylized (高对比战术工业像素/锐利2D)**
- **One-Line Visual Rule**: *"Dark, low-saturation industrial floors; glowing, high-saturation warm enemy threats; cool, translucent player effects."*
- **Supporting Principles**:
  1. **Three-Tier Luminance Hierarchy**: Background floors stay below 35% value/saturation; player and interactable cover sit at mid-high contrast with crisp outlines; enemy projectiles and interrupt wind-ups sit at 90–100% luminance with warm red/magenta/orange cores and white inner centers.
     - *Design test*: Take a combat screenshot and convert it to grayscale—if enemy bullets and the player silhouette do not immediately pop out from the floor and player VFX, adjust value/alpha immediately.
  2. **Player VFX Alpha Cap**: All player-generated ground puddles, shockwaves, and explosions are capped at $\le 45\%$ opacity and rendered on a Z-layer *below* enemy projectiles.
     - *Design test*: Can a player clearly see a single small enemy bullet passing straight through the middle of their own Black Hole or explosion VFX?
  3. **Readable Micro-UI**: The overhead **Active Reload bar** and **Overcharge ready flash** sit directly adjacent to the player character/crosshair so the player never has to look away from the action to the screen corners during bullet-hell dodging.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| *Enter the Gungeon* | Crisp dodge-roll I-frames, table-flipping cover, Blank screen-clears, punchy gun feel, hitless Boss rewards | Replace empty-room backtracking and RNG key starvation with forward previewed doors, Overdrive Bets, and Dual-Gun Overcharge | Validates the core top-down bullet-hell 3C foundation |
| *Hades* | Forward previewed room reward doors, Shop/Fountain/Forge pacing, action-slot build synergies | Applied to twin-stick gunplay with pre-door Overdrive Betting and Rest-vs-Forge Pit-Stops | Eliminates exploration downtime and gives players agency over their build path |
| *DOOM Eternal* | Aggressive "use the right tool to generate/spend resources" combat rhythm | Translated into a 2D twin-stick Generator (Primary) & Spender (Overcharge Heavy) weapon swap loop | Prevents passive turtling and keeps combat electric |
| *Gears of War* / *Synthetik* | Active Reload timing bar and final-round mechanical satisfaction | Expanded into the core roguelite relic trigger engine (`OnPerfectReload`, `OnFinalRound`) | Turns reloading from a chore into a micro-skill dopamine hit |

**Non-game inspirations**: Arcade pinball machines (tactile lights, escalating multiplier callouts, mechanical plunger satisfaction) and John Wick / Gun-Kata choreography (seamless reloading and gun-swapping in close quarters).

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18–38 |
| **Gaming experience** | Mid-core to Hardcore |
| **Time availability** | 30–60 minute sessions on weeknights; multi-run sessions on weekends and Steam Deck |
| **Platform preference** | PC (Steam) & Steam Deck |
| **Current games they play** | *Enter the Gungeon*, *Hades I/II*, *Nuclear Throne*, *Tiny Rogues*, *Synthetik*, *Dead Cells* |
| **What they're looking for** | Tight, responsive twin-stick gunplay where skill is rewarded and builds come online quickly without tedious walking or bad chest RNG |
| **What would turn them away** | Sluggish movement, screen clutter hiding enemy bullets, spongy enemies when out of ammo, or overpowered AFK builds that remove the need to play |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | **Godot 4.7.2 (GDScript, Forward+)** — Fast 2D rendering, clean `Resource`-based data-driven weapon/relic architecture, native signal system for combat hooks |
| **Key Technical Challenges** | 1) Object pooling for 500+ bullets at 60+ FPS; 2) Frame-accurate Active Reload & Dodge Graze detection; 3) Event-bus decouple for `OnPerfectReload`/`OnFinalRound`/`OnSwap` relic chains without frame spikes |
| **Art Style** | Crisp 2D Top-Down Pixel / Stylized Sprites with 2D dynamic lighting and shader-driven hit-flashes |
| **Art Pipeline Complexity** | Low-to-Medium (handcrafted weapon silhouettes, modular enemy families, shader-driven projectile variations) |
| **Audio Needs** | Moderate-to-High (distinct mechanical reload cues, pitch-scaled Graze ticks, adaptive Overdrive combat layers) |
| **Networking** | None (Single-player local; Steam Cloud & Leaderboards via GodotSteam in Release phase) |
| **Content Volume** | Full Vision: 3–4 Biomes, 12 Primary Guns, 12 Heavy Spenders, 10 Dynamo Cores, 50+ Trigger Relics, 25+ Enemies, 6 Bosses |
| **Procedural Systems** | Node-graph room sequence generator assembling hand-authored room `.tscn` templates with dynamic Overdrive Bet modifiers |

---

## Risks and Open Questions

### Design Risks
- **Active Reload Cognitive Load**: Checking the Active Reload bar while dodging dense bullet patterns could feel overwhelming if visual/audio cues aren't intuitive. *Mitigation*: Test reload window generosity (e.g., 150ms–200ms sweet spot) and distinct audio rhythm cues in the Stage 1 prototype.
- **Overcharge Economy Snowballing or Starvation**: Players might either starve for Heavy Weapon energy against single bosses or spam Heavy Weapons non-stop in mob rooms. *Mitigation*: Include Weak-Point Interrupts and Graze on boss attacks so bosses remain rich energy sources, and cap Overcharge storage at 2–3 charges.

### Technical Risks
- **Projectile & Relic Trigger Frame Spikes**: Firing a multi-pellet shotgun where every pellet triggers an elemental chain could cause GDScript frame hitches. *Mitigation*: Enforce pre-allocated `BulletPool` and per-frame trigger caps in Stage 2 ADRs and `control-manifest.md`.

### Market Risks
- **Crowded Action Roguelite Genre on Steam**: Standing out requires immediate visual and mechanical readability in the first 5 seconds of the Steam trailer and Next Fest demo. *Mitigation*: Highlight the visceral "Graze -> Perfect Reload Shockwave -> Heavy Weapon Swap -> Overdrive Door Bet" loop visually.

### Scope Risks
- **Enemy & Boss Handcrafted Pattern Volume**: Bullet-hell games live and die by enemy pattern variety. *Mitigation*: Build a reusable data-driven `BulletPatternEmitter` resource in Stage 2 so one enemy script can drive dozens of distinct bullet patterns.

### Open Questions
- **Question 1**: What is the optimal Active Reload sweet-spot window and penalty for a missed reload (slight delay vs. mild self-spark) so it feels rewarding rather than punishing? *(Resolved via Stage 1 `/prototype`)*
- **Question 2**: Should the Secondary Heavy Weapon fire a single massive shot per swap, or drain the Overcharge bar continuously over a few seconds? *(Resolved via Stage 1 `/prototype`)*

---

## MVP Definition

**Core hypothesis**: Players find the 30-second combat loop (**Primary Gun Skirmish + Multi-Source Overcharge Harvesting + Active Reload/Final-Round Triggers + Heavy Weapon Swap**) and the 5-minute **Previewed Door + Overdrive Bet + Pit-Stop** loop immediately thrilling and readable.

**Required for MVP**:
1. **Player 3C & Dodge-Graze Controller**: 8-way movement, 360° aim, Dodge Roll with I-frames + Graze ring + recovery, table cover flip, and Blank screen-clear.
2. **Active Reload & Final-Round Weapon System**: Overhead reload slider (Perfect / Normal / Fail) + Final-Round detection + 2 Primary Weapons & 2 Heavy Spender Weapons.
3. **Multi-Source Overcharge Engine**: Overcharge bar fueled by Dodge Graze, Perfect Reload, Weak-Point Interrupts, and Barrel Detonations.
4. **Trigger Relic & Dynamo Core Prototype Set**: 3 Dynamo Cores + 6 Trigger Relics (`OnPerfectReload`, `OnFinalRound`, `OnWeaponSwap`, `OnDodgeGraze`).
5. **Pooled Bullet-Hell Combat & 3 Enemy Archetypes**: High-contrast pooled enemy projectiles, Sniper/Burst/Ring enemy types with interruptible red-flash wind-ups, and 1 Mini-Boss.
6. **Node-Graph Door Loop & Pit-Stop**: Combat Door with Overdrive Bet toggle, Scrap Shell drops, and 1 Pit-Stop room (Black-Market Shop + Rest/Forge Workbench).

**Explicitly NOT in MVP** (defer to later):
- Multiple biomes, narrative cutscene dialogues, meta-progression hub town, localization, and Steamworks achievements.

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 5 combat room templates, 1 Pit-Stop, 2 Primary + 2 Heavy guns, 3 Enemies, 1 Boss | Core 3C, Active Reload, Overcharge Swap, Overdrive Bet, Rest/Forge | 4–6 weeks |
| **Vertical Slice** | 1 complete Biome (15 rooms), 4 Primary + 4 Heavy guns, 4 Dynamo Cores, 15 Relics, 8 Enemies, 1 Multi-Phase Boss | Full HUD, audio juice, gamepad support, Steam store page trailer ready | 8–10 weeks |
| **Alpha** | 3 Biomes, 8 Primary + 8 Heavy guns, 35 Relics, 18 Enemies, 4 Bosses | Meta-progression Hub, save/load, Overdrive Contracts | 16–20 weeks |
| **Full Vision** | 4 Biomes, 12 Primary + 12 Heavy guns, 10 Dynamo Cores, 50+ Relics, 25+ Enemies, 6 Bosses | Full polish, Steam Deck verification, localization, Achievements & Cloud | 28–36 weeks |

---

## Next Steps

- [x] Get concept approval from user
- [x] Fill in CLAUDE.md technology stack based on engine choice (`/setup-engine`)
- [ ] **Prototype core idea** (`/prototype`) — validate 3C, Active Reload, Overcharge Swap & Overdrive Bet in Godot 4.7
- [ ] Create Art Bible (`/art-bible`) — lock luminance hierarchy and bullet readability rules
- [ ] Pass Concept -> Systems Design gate (`/gate-check systems-design`)
- [ ] Decompose concept into systems (`/map-systems`) & author GDDs (`/design-system`)
- [ ] Author data-driven ADRs (`/create-architecture`, `/architecture-decision`) & Control Manifest (`/create-control-manifest`)
