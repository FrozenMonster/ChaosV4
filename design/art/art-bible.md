# Art Bible: CHAMBER OVERDRIVE (膛室超载)

> **Status**: Approved
> **Owned By**: art-director
> **Last Updated**: 2026-11-08
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-11-08 — lean mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

### Direction Name (视觉方向名称)
**Chibi-Tactical Neon Dungeon Pixel (潮玩大头地牢 × 高对比霓虹弹幕像素 — 融合《挺进地牢》《元气骑士》《霓虹深渊》《比特小队》《Nuclear Throne》《Tiny Rogues》视觉所长)**

### One-Line Visual Rule (一句话视觉铁律)
> **“暗色干净的工业地牢底板，衬托《挺进地牢/元气骑士》式黑粗描边的二头身角色与夸张大枪；高亮暖色白芯敌方弹幕永远置顶，一切我方冷色超载特效必须半透明让路。”**  
> *(“Clean, dark industrial-dungeon floors frame *Enter the Gungeon / Soul Knight*-style chunky black-outlined 2-head chibi gunners and oversized firearms; maximum-luminance warm enemy projectiles always render on top, while cool-toned player Overcharge VFX remain translucent and subordinate.”)*

### Supporting Visual Principles (三大核心视觉原则)

1. **Three-Tier Luminance & Z-Layer Supremacy (三级明度阶梯与弹幕绝对置顶原则)**
   - **Anchored Pillars**: **Pillar 1 (Sacrosanct 3C Consistency)** & **Pillar 3 (Reload & Swap Are Offensive Verbs)**
   - **Rule**:
     - **Tier 1 — Background Canvas ($\text{Value} \le 30\%, \text{Saturation} \le 25\%$):** *SYNTHETIK*-inspired dark slate-gray and deep cast-iron blue industrial floors with low-contrast grid lines. No high-gloss floor clutter.
     - **Tier 2 — Midground Entities & Player VFX ($\text{Value } 50\%\text{–}80\%, \text{Player VFX Alpha} \le 45\%$):** *Enter the Gungeon*-inspired 2-head chibi proportions, oversized firearms, and `1px–2px` solid black outlines for instant silhouette recognition. Player VFX (Perfect Reload shockwaves, Final Round blasts, `RMB` Heavy Spender black holes/rails) are capped at $\le 45\%$ alpha on ground/volume layers and strictly render below enemy projectiles.
     - **Tier 3 — Top-Layer Threat Plane ($\text{Value } 90\%\text{–}100\%, \text{Saturation } 85\%\text{–}100\%$):** All enemy bullets, sniper lasers, and Weak-Point Interrupt wind-ups use a warm glowing outer rim (vermilion/magenta/orange) with a pure `#FFFFFF` white core at the highest gameplay Z-index.
   - **Design Test**: *When any flashy player explosion or lighting effect competes with bullet readability, reduce player VFX opacity and push it below the threat Z-layer — in a grayscale screenshot with a small enemy bullet inside a player Black Hole, the bullet core and player silhouette must be readable within 0.1s.*

2. **Kinetic Risk-to-Voltage Telegraphy (风险操作即电压的动态视觉转化原则)**
   - **Anchored Pillars**: **Pillar 2 (Action Fuels Firepower)** & **Pillar 3 (Reload & Swap Are Offensive Verbs)**
   - **Rule**: Visual intensity of Overcharge generation scales strictly with execution risk:
     - **Normal Hit (`+1⚡`)**: Brief cool-white muzzle spark + 0.08s pure-white enemy hit-flash.
     - **Perfect Active Reload (`R`, `+14⚡`)**: Overhead sweet-spot snap triggers an expanding cyan-gold ring + gun squash-and-stretch recoil.
     - **Dodge-Roll Graze (`Space`, `+20⚡`)**: Passing near enemy bullets during I-frames arcs electric cyan-indigo lightning from the bullet into the player's reactor.
     - **Weak-Point Interrupt / Barrel Detonation (`+35–40⚡`)**: Enemy pulsing red wind-up shatters with a 0.045s hitstop and high-voltage siphon beam.
     - **Cost-Tiered Heavy Spenders (`RMB` 30 / 50 / 90⚡)**: Light (30⚡ Swarm), Medium (50⚡ Railgun), and Ultimate (90⚡ Black Hole) scale muzzle glow, recoil, and screen-shake proportionally.
   - **Design Test**: *With game audio muted, a viewer must be able to tell solely from the player's electric arc thickness, reload ring, and weapon glow which charging tier just triggered and whether `RMB` Heavy Weapon is ready.*

3. **Crosshair-Proximate Micro-HUD & Diegetic Door Wager Signage (准星贴身微距 HUD 与明牌赌注门禁原则)**
   - **Anchored Pillars**: **Pillar 1 (Sacrosanct 3C Consistency)**, **Pillar 3 (Reload & Swap Are Offensive Verbs)** & **Pillar 4 (Zero-Filler High-Stakes Routing)**
   - **Rule**:
     - **Combat Micro-UI**: Active Reload slider, Final Round warning, and Overcharge ready indicator sit within `64px` of the player character/crosshair so eyes never leave the bullet-hell zone.
     - **3-Category Previewed Doors & Overdrive Bet (`F`)**: Doors use bold neon header crests — **Armory Door (Amber Gold Gear & Gun)**, **Tactical Item Door (Electric Cyan Chip)**, and **Random Event Door (Violet Anomaly / Forge Flame)**. Locking an Overdrive Bet (`-25⚡`) clamps hydraulic hazard bars onto the door frame with a fiery 2x reward crest.
   - **Design Test**: *If a combat state cue or door choice requires looking to screen corners during combat or reading more than 3 words, redesign it into a player-proximate micro-bar or neon door crest.*

## 2. Mood & Atmosphere

Each game state shifts lighting temperature, contrast ratio, and 2D glow behavior while preserving the **Tier 1 Background Floor Cap ($\text{Value} \le 30\%$)** so combat readability never degrades.

| Game State (游戏状态) | Emotional Target (情绪目标) | Lighting & 2D Glow Character (光影与辉光特征) | Atmospheric Descriptors (氛围关键词) | Energy Level (能量级) |
| :--- | :--- | :--- | :--- | :--- |
| **(a) Standard Combat Skirmish**<br>*(常规交火房)* | Focused flow, surgical rhythm, kinetic control<br>*(专注心流、精准节奏、动感掌控)* | **Cool-Neutral Industrial (`5500K`)**: Low-ambient slate floor ($\text{Value } 18\%\text{–}25\%$); crisp localized point lights on muzzle flashes, Graze arcs, and warm enemy bullet cores. | Crisp, Mechanical, High-Contrast, Tactical, Kinetic<br>*(锐利、机械、高反差、战术、动感)* | **High (`7/10`)** — Steady pulse synced to reload cadence. |
| **(b) Overdrive Bet / Boss High-Voltage Combat**<br>*(超载赌注房 / Boss 高压战)* | Adrenaline surge, high-stakes danger, electric euphoria<br>*(肾上腺素飙升、高压博弈、电流狂热)* | **Split-Complementary Neon Clash (`3200K` Hazard vs. `6500K` Arc)**: Floor rim-lit by pulsing hazard strips; heightened bloom on Tier 3 warm bullets; Boss phase transitions pulse peripheral vignette without raising floor value above $30\%$. | Volatile, Overcharged, Relentless, Electrified, Razor-Sharp<br>*(狂暴、过载、窒息感、电弧交织、刀尖跳舞)* | **Maximum (`10/10`)** — Peak visual voltage and hitstop impact. |
| **(c) Post-Room Door Selection & Overdrive Wager**<br>*(清房门禁抉择与赌注注入)* | Calculated greed, anticipation, tactical agency<br>*(精明博弈、蓄势待发、路线掌控)* | **Directional Spotlight Framing (`4500K`)**: Arena center dims by $15\%$ after the Room-Clear wave; 2–3 forward doors ignite with saturated category neon crests (Amber/Cyan/Violet); injecting `-25⚡` snaps hydraulic hazard clamps with fiery `2x` embers. | Decisive, Gambling, Arcade-Lit, Telegraphing<br>*(果断、明牌赌局、街机灯牌、高辨识度)* | **Medium-Low (`4/10` → `6/10` on Bet Lock)** — Calm breath before the next plunge. |
| **(d) Pit-Stop (Black-Market Merchant & Rest/Forge)**<br>*(黑市商铺与锻造休整站)* | Safe relief, tinkerer's satisfaction, underground sanctuary<br>*(安全喘息、改装快感、地下避风港)* | **Warm Tungsten & Emerald Sanctuary (`3800K` + Teal accents)**: Soft pools of warm amber work-bench light and emerald healing mist; zero harsh red/magenta threat hues allowed in this room. | Cozy-Industrial, Cluttered-Workshop, Inviting, Restorative<br>*(工业暖意、工坊感、松弛、修复)* | **Low (`2/10`)** — Decompression pocket twice per floor. |
| **(e) Defeat / Quick-Restart & Victory Summary**<br>*(战败秒开与通关结算)* | **Defeat**: Instant "one more run" defiance<br>**Victory**: Cathartic mastery & power validation | **Defeat (`2500K` Power-Down)**: 0.25s CRT desaturation + red reactor flatline, instant `<1s` snap back to ignition.<br>**Victory (`6000K` Golden-Cyan Overdrive)**: Crisp dark telemetry slate (`#11151C`) with glowing Amber/Cyan data bars. | **Defeat**: Snappy, Frictionless, Unforgiving<br>**Victory**: Triumphant, Data-Rich, Prestigious | **Defeat**: Spike → Zero (`8 → 0 → 5`)<br>**Victory**: Sustained High (`8/10`) |

## 3. Shape Language

### Character Silhouette Philosophy (角色剪影哲学)
- **2-Head Chibi Proportions & Oversized Firearms (二头身潮玩比例与巨型枪械)**:
  - Characters use a compact `1:1` head-to-body ratio (`24x24px`–`32x32px` sprite footprint) bordered by a mandatory `1px–2px` solid black outline (`#0B0D12`).
  - Weapons are deliberately scaled to **`60%–85%` of character body width** and held clear of the torso silhouette so the player and viewer can identify the active weapon archetype (`Revolver`, `SMG`, `Shotgun`, `Railgun`, `Black Hole Cannon`) at `25%` thumbnail zoom.
- **Enemy Archetype Geometric Coding (敌方原型几何编码)**:
  - **Burst Bot (近中程连发兵 — Sharp Isosceles Triangle / 锐角三角)**: Forward-leaning angular chassis with twin shoulder vents; reads immediately as mobile, directional aggression.
  - **Ring Turret (环形弹幕塔 — Concentric Octagon / Heavy Circle / 同心八边形与厚重圆盘)**: Squat, radially symmetrical base with a glowing central core; communicates 360° area denial and zero mobility.
  - **Sniper Mech (蓄力狙击机甲 — Tall Narrow Diamond / Long Barrel / 瘦高菱形与超长枪管)**: Vertically elongated silhouette with a protruding laser sight-rail; telegraphs long-range precision and Weak-Point Interrupt (`+35⚡`) windows.
  - **Floor Bosses (楼层首领 — Interlocking Composite Geometry / 复合装甲巨构)**: `2.5x–3.5x` player scale combining heavy octagonal reactor housings with articulated weapon arms that physically break or shift silhouette across HP phases.

### Environment Geometry (环境几何语言)
- **Structural Walls & Floor Grids (90° Orthogonal & 45° Chamfered Steel / 正交网格与 45° 倒角钢板)**: Walls, pillars, and floor tiles use strict horizontal/vertical lines with `45°` industrial corner chamfers (`SYNTHETIK` precision), keeping visual noise low.
- **Tactical Cover — Interactive Tables (Organic Rounded Rectangles / 圆角木质掩体桌)**: Unflipped tables use warm-tinted rounded rectangular tops (`E` to flip); once flipped, they expose a reinforced metal underside bar with high-contrast directional bolts indicating cover orientation.
- **Arena Hazards — Explosive & Cryo Barrels (Bulging Cylinders with Hazard Chevrons / 鼓胀圆桶与警示斜纹)**: Interactive barrels use squat circular/cylindrical silhouettes with bold diagonal stripes so they never blend into square wall pillars.

### UI Shape Grammar (UI 形状语法)
- **Tactical Frames (`45°` Cut-Corner Chamfers / 45° 切角战术框)**: All HUD bars, weapon cards, and telemetry panels use crisp `1px` borders with `45°` clipped corners (never soft pill-shapes or fantasy scrolls).
- **Arcade Trigger & Door Badges (Hard Hexagons & Chevrons / 硬朗六边形与箭头徽章)**: Dynamo Core icons, Overcharge tier pips, and Door Header Crests use bold geometric emblems (Hexagon for Cores, Shield/Gear for Armory, Diamond Chip for Relics).

### Hero Shapes vs. Supporting Shapes (主视觉形状与辅助形状层级)
- **Hero Shapes (High-Frequency Contrast & Dynamic Squash/Stretch)**: Player helmet/cloak silhouette, oversized weapon barrels, Enemy Weak-Point Interrupt reticles, and Tier 3 Bullet Cores (`#FFFFFF` circles/needles with warm glowing rims).
- **Supporting Shapes (Low-Frequency Static Grids)**: Floor metal plates, riveted wall borders, background pipes, and sub-floor cables — strictly flat, non-animated, and devoid of black outlines so they stay locked in Tier 1 background space.

## 4. Color System

### Primary Palette Table (核心七色调色板)

| Swatch Name (色板名称) | Hex Code | Value (明度) | Tier | World & Gameplay Meaning (世界观与玩法语义) |
| :--- | :--- | :--- | :--- | :--- |
| **Foundry Slate (铸铁暗灰)** | `#1A1E26` | `15%` | Tier 1 (BG) | Default industrial floor canvas; absorbs visual noise so bullets pop. |
| **Trench Iron (深沟钢蓝)** | `#2A3240` | `25%` | Tier 1 (BG) | Structural walls, recessed floor grids, and non-interactive cover trim. |
| **Gun-Runner Ivory (战术米白)** | `#F2F5FA` | `98%` | Tier 2/3 | Player helmet highlight, enemy hit-flash (`0.08s`), and bullet inner core (`#FFFFFF`). |
| **Overcharge Cyan (超载电青)** | `#00F0FF` | `94%` | Tier 2 (Player) | Player Overcharge energy, Dodge-Roll Graze arcs (`+20⚡`), and Tactical Item Doors. |
| **Threat Vermilion (致命朱红)** | `#FF2A3C` | `100%` | Tier 3 (Threat) | Standard enemy projectiles, sniper laser lock-ons, and Weak-Point Interrupt wind-ups. |
| **Barrage Magenta (弹幕洋红)** | `#FF1E8A` | `100%` | Tier 3 (Threat) | High-tier Ring/Boss bullet patterns and Elite Overdrive Bet hazard indicators. |
| **Chamber Amber (膛室琥珀金)** | `#FFB800` | `100%` | Tier 2 (Reward) | Final Round indicator, Perfect Reload sweet-spot flash (`+14⚡`), Scrap Shells, and Armory Doors. |

### Semantic Color Vocabulary (语义色彩词典)
- **Warm Red / Magenta (`#FF2A3C` / `#FF1E8A`) = Enemy Threat & Interrupt Opportunity**: Exclusively reserved for enemy attacks, hazard barrels, and interruptible red-flash wind-ups. **Rule**: Player projectiles and friendly buffs may *never* use pure red or magenta.
- **Electric Cyan / Teal (`#00F0FF` / `#14B8A6`) = Player Overcharge & Graze**: Represents player kinetic energy, primary bullets, Graze lightning siphons, and `RMB` Heavy Weapon readiness.
- **Amber Gold (`#FFB800`) = Chamber Mastery & Armory Economy**: Signals `Final Round` chambered state, `Perfect Reload` sweet-spot timing, Scrap Shell currency, and Armory Door rewards.
- **Anomaly Violet (`#A855F7`) = Spatial Distortion & High-Risk Events**: Used for Ultimate `RMB` Black Hole singularities (capped at $\le 45\%$ alpha), Random Event / Shrine Doors, and Overdrive Bet curses.
- **Sanctuary Emerald (`#10B981`) = Restoration & Pit-Stop Safety**: Strictly reserved for HP pickups, Pit-Stop Rest/Forge stations, and non-combat recovery cues.

### Per-Biome Color Temperature Progression (楼层生态色温演进 — Floor Value $\le 30\%$)
1. **Floor 1: Clockwork Foundry (发条铸造厂 — Neutral-Cool Gunmetal `5200K`)**:
   - **Floor/Wall Base**: `#1A1E26` (Slate) & `#282C34` (Oiled Iron) with muted brass seam accents (`#4A3B2C`, $\text{Value } 29\%$).
   - **Mood**: Classic tactical factory; maximum contrast for teaching core Graze and Active Reload colors.
2. **Floor 2: Cryo-Conduit Lab (深冷导管实验室 — Deep Sub-Zero Indigo `7000K`)**:
   - **Floor/Wall Base**: `#141B29` (Abyssal Navy) & `#1F2D3D` (Frosted Steel) with dark recessed coolant channels (`#183446`, $\text{Value } 27\%$).
   - **Mood**: Clinical, high-velocity testing wing; warm `#FF2A3C` / `#FFB800` enemy threats cut through the deep blue floor like laser scalpels.
3. **Floor 3: Core Reactor (核心反应堆 — Charred Obsidian & Sub-Crust Ember `3800K` Base)**:
   - **Floor/Wall Base**: `#181416` (Scorched Basalt) & `#2B2124` (Oxidized Hull); sub-floor magma grates are capped at `#47231E` ($\text{Value } 28\%, \text{Saturation } 25\%$) so they never compete with `#FF2A3C` enemy projectiles.
   - **Mood**: Claustrophobic high-heat furnace leading to the Core Reactor Boss.

### UI Palette & Divergence Rules (UI 调色板与场景分离规则)
- **HUD Backing (`#0D1017` at `85%` Opacity)**: Darker than Tier 1 floors (`10%` Value) so crosshair-proximate micro-bars (Active Reload slider, Final Round pip) remain legible over any floor or explosion.
- **Jammed / Mistimed Reload Cue (`#78716C` Muted Ash Gray)**: Uses desaturated smoky gray + mechanical stutter icon rather than bright red, preventing false-positive "enemy bullet hit" panic.

### Colorblind Safety & Multi-Modal Backup Cues (色觉无障碍与多模态冗余设计)
Every semantic color pair is reinforced by **shape, animation, and audio** so Deuteranopia, Protanopia, and Tritanopia players never rely on hue alone:

| Semantic Cue (语义信号) | Primary Color (主色) | Shape / Silhouette Backup (形状与剪影冗余) | Motion / Audio Backup (动态与音效冗余) |
| :--- | :--- | :--- | :--- |
| **Enemy Projectiles vs. Player Projectiles** | Warm Red (`#FF2A3C`) vs. Cool Cyan (`#00F0FF`) | **Enemy**: Solid `#FFFFFF` circular/diamond core (`100%` alpha) + thick outer ring.<br>**Player**: Elongated translucent streaks/bolts ($\le 75\%$ alpha, no white core). | Enemy bullets pulse radially on top Z-layer; player shots have directional motion trail. |
| **Enemy Weak-Point Interrupt Wind-Up** | Pulsing Crimson (`#FF2A3C`) | Expanding **4-point inward-snapping crosshair reticle (`><`)** + exclamation chevron (`!`) above enemy head. | High-pitched rising mechanical whine before attack release. |
| **Three Door Categories (Armory / Item / Event)** | Amber (`#FFB800`) / Cyan (`#00F0FF`) / Violet (`#A855F7`) | **Armory**: Crossed Gun & Gear crest.<br>**Tactical Item**: Diamond Circuit Chip crest.<br>**Event/Anomaly**: Split Lightning / Chalice crest. | Distinct header frame silhouettes + unique hover chime per door type. |
| **Active Reload Bar (Perfect vs. Normal vs. Jam)** | Amber-Cyan (`#FFB800`) vs. White vs. Ash Gray (`#78716C`) | **Perfect Zone**: Thickened vertical bracket (`[ ]`) with diamond center notch (`◆`) on the overhead slider. | Crisp metallic chamber *PING* + expanding ring vs. dull *CLUNK* on jam. |

## 5. Character Design Direction

### Player Character Visual Archetype (玩家角色视觉原型：战术枪械炼金术士)
- **Proportions & Core Silhouette (二头身战术比例与核心剪影)**: `2-head` chibi tactical gun-alchemist (`32×32px` base sprite canvas, `2px` solid `#0A0B0E` outer outline) combining compact, bouncy limb readability with high-tech foundry gear.
- **Focal Anchors (三大视觉锚点)**:
  1. **High-Contrast Cyan Visor (高对比青色护目镜)**: Glowing `#00F5D4` tactical visor and backpack Overcharge reactor core serve as the instant eye-magnet at the center of the screen, shifting brightness with current Overcharge voltage.
  2. **Kinetic Scarf / Long Coat (动态战术围巾与下摆)**: Secondary-motion cloth trails sharply during `Space` dodge-rolls and snaps into an electric cyan silhouette during active I-frames and Graze windows.
  3. **Detached Oversized Weapon Rig (分离式夸张大枪挂点)**: Weapons are drawn at `1.25x–1.6x` character width and held on a detached orbital pivot offset (`8px–12px` from torso center). The character's hands never occlude the receiver or barrel, keeping the active gun silhouette 100% readable at all aim angles.

### Instant Silhouette & Faction Differentiation (敌我与交互物一眼辨识规则)
Every entity category occupies a strict geometric, postural, and color-temperature lane so players identify threats in `< 0.1s` without reading health bars:

| Entity Category (实体类别) | Silhouette & Geometry (几何轮廓与体态) | Color & Luminance Signature (色彩与明度特征) | Key Telegraph / Visual Hook (核心动态提示) |
| :--- | :--- | :--- | :--- |
| **Player (玩家)** | Compact rounded-square `2-head` humanoid + trailing scarf + detached oversized firearm | Cool Cyan (`#00F5D4`) visor/reactor + Charcoal tactical coat (`Value 75%–90%`) | White-cyan I-frame dash afterimages; overhead Active Reload bar (`64px` proximate) |
| **Enemy: Burst Bot (散射近卫机兵)** | **Stocky Triangular Chassis (矮壮倒三角底盘)**: Wide dual-tread base, hunched forward-leaning torso, twin stubby muzzle ports | Crimson-Orange plating (`#FF2A54` / `#FF6B35`, `Value 75%–85%`) | Expands chest vents and flashes `#FF0055` before firing 3-way spread salvos |
| **Enemy: Ring Turret (环幕矩阵炮塔)** | **Octagonal / Circular Emitter (正八边形/圆形底座)**: Stationary or slow-hovering symmetrical core with 8 radial nozzle prongs | Deep Magenta-Violet ring (`#E01A4F` / `#FF007F`, `Value 80%–90%`) | Rotates 45° with pulsing radial core glow prior to 360° bullet-ring emission |
| **Enemy: Sniper Mech (狙击高塔机甲)** | **Tall Narrow Angular Frame (瘦高锐角立柱)**: Elongated vertical silhouette (`1.5x` player height), mono-optic head, long rail barrel | High-Alert Vermilion & Hazard Yellow accents (`#FF1E42` / `#FFD166`) | Projects a continuous tracking laser sight that locks and flashes red-white (`0.4s` Weak-Point Interrupt window) before firing |
| **Pit-Stop NPCs (整备站工匠/黑市商人)** | **Asymmetrical Relaxed Silhouette (非对称松弛轮廓)**: Aprons, welding rigs, heavy backpacks, zero aimed barrels, stationary workbench framing | Warm Amber & Brass Work-Lamp palette (`#FFB703` / `#FB8500`) + Soft Olive/Teal | Bathed in a calm radial point-light pool; gentle idle breathing/hammering loops, never abrupt combat lunges |
| **Interactive Hazards & Cover (交互掩体与爆炸物)** | **Crisp Geometric Primitives (高锐度几何体)**: Rectangular wooden tables (`[E]`) and cylindrical TNT barrels with `2px` black outlines | High-contrast top faces (`Value 65%–80%`): Warm Oak (`#C68B59`) or Hazard Red (`#E63946`) | Tables show bright `[E]` directional flip arrows on approach; barrels carry bold yellow-white hazard chevrons and pulse when damaged |

### Expression, Pose & Procedural Animation Style (表情姿态与程序化动画风格)
- **Snappy 4-Frame Pixel Sheets (高张力4帧像素切片)**: Base character and enemy animations use tight 4-frame cycles (`Idle`, `Run`, `Dodge Roll`, `Wind-Up`) with zero muddy sub-pixel interpolation—every frame holds a strong key pose.
- **Procedural Juice Layer (程序化弹性与受击叠加)**:
  - **Squash & Stretch (弹性形变)**: Firing heavy weapons, landing from a `Space` roll, or snapping a Perfect Reload (`R`) applies a `0.08s` scale deformation (`1.25x` horizontal stretch on dodge launch, `0.80x` vertical squash on landing).
  - **Hit-Flash Shader (受击纯白闪白)**: Taking or dealing damage overrides the sprite palette with pure `#FFFFFF` (or `#00F5D4` on Weak-Point Interrupts) for `0.06s–0.08s`, paired with a `3px` directional knockback jitter.
  - **Dodge & Overdrive Afterimages (残影轨迹)**: `Space` dodge-rolls spawn 3 additive-alpha cyan ghost sprites (`Alpha 35% -> 10%`) along the movement vector, visually trace-mapping the player's Graze hitbox path.

### Camera Distance & Detail Survival / LOD Philosophy (镜头距离与像素细节留存规范)
- **Fixed Reference Viewport (基准视口与像素倍率)**: Authored at a native `640×360` pixel-art resolution scaled integer `2x` to `1280×720` (`3x` at `1080p`, `4x` at `1440p`). Camera zoom remains locked at `1.0x` during combat (allowing only `1.03x` micro-punch on `RMB` Ultimate Heavy shots).
- **Detail Survival Rule (3px Minimum Feature Rule / 3像素最小可辨特征铁律)**:
  - **Survives**: `2px` outer black outlines, visor glow, scarf silhouette, gun barrel/receiver contrast block, and enemy geometric core shapes.
  - **Culled / Forbidden**: No `1px` noise checkerboarding (dithering), belt buckles, facial mouth/nose pixels, or micro-text on sprites—any detail smaller than a `3×3px` cluster dissolves into shimmer during high-speed twin-stick movement and is strictly prohibited.

## 6. Environment Design Language

### Architectural Style: Modular Clockwork Foundry (建筑风格：模块化发条重工熔炉)
- **World Tie-In (世界观映射)**: The setting is an ever-shifting, automated subterranean munitions foundry. Rooms are constructed from heavy riveted steel floor plates, recessed under-floor energy conduits, brass pneumatic pistons, and hydraulic blast doors.
- **Structural Rhythm (空间结构韵律)**: Orthogonal `90°` walls and `45°` chamfered corner pillars establish a clean tactical grid that makes bullet ricochets, dodge-roll distances, and cover angles immediately predictable.

### Texture Philosophy: Low-Noise Flat-Value Pixel Tiles (材质哲学：低噪点平涂暗调砖块)
- **Tier-1 Luminance Compliance (严守第一阶梯暗部底板)**: All walkable floor tiles are restricted to **$\text{Value} \le 30\%$ and $\text{Saturation} \le 25\%$** (Dark Slate `#161922` to Cast-Iron Blue `#232938`).
- **Bevel & Grid Clarity Without Clutter (微倒角网格、零高光干扰)**:
  - Floor plates use flat-value fills with subtle `1px` recessed seams (`#101218`) and muted corner rivets (`#2C3344`) to provide movement speed reference without visual noise.
  - **Zero Specular Pinpoints**: Never place bright metallic highlights, glowing sparks, or high-contrast circular rivets on walkable floor tiles that could be mistaken for enemy projectiles at peripheral vision.
  - Under-floor power conduits use recessed dark glass with low-opacity (`Alpha <= 20%`) amber or cyan pulse lines that only brighten along door-lock tracks after room clear.

### Prop Density & Arena Clearance Rules (物件密度与战斗清场法则)
- **Combat Arena Interior (战斗区内场——绝对净空与高辨识交互物)**:
  - At least **75% of walkable arena floor** must remain unobstructed open space for bullet-hell dodging.
  - **Interactive Cover & Hazards Only**: Only gameplay-active props may occupy the central combat floor:
    1. **Flippable Tactical Tables (`[E]`)**: High-contrast warm wood/composite tops (`Value 65%`), `2px` black outline, and clear damage-crack stages (`100% -> 50% -> splintered`).
    2. **Explosive TNT / Fuel Barrels**: Crisp cylindrical silhouette, bright crimson body with hazard chevrons, instant chain-detonation radius ring on hit.
    3. **Solid Boss/Elite Pillars**: Thick `2px` black footprint border + bright top bevel (`#3E4756`) so players never snag on invisible collision corners.
- **Wall Perimeters & Out-of-Bounds Pits (墙体边缘与深渊外围——装饰退居边界)**:
  - All non-interactive decorative props (pipe manifolds, steam vents, scrap cranes, ammo crates, cable bundles) are strictly confined to the **outer `32px` wall perimeter** or sunken foundry pits outside the walkable collision boundary.
- **Pit-Stop Rooms (整备站安全屋——高密度叙事暖区)**:
  - Non-combat Pit-Stop nodes relax the open-floor rule in the upper half of the room to frame the **Black-Market Merchant stall** and **Rest/Forge Anvil** with hanging weapon racks, holographic blueprints, and warm overhead work lamps.

### Environmental Storytelling Guidelines (环境叙事准则)
1. **Diegetic Door Header Crests & Overdrive Bet Clamps (门头明牌纹章与超载赌注液压锁)**:
   - Every forward exit door displays its room category directly on an overhead neon foundry arch: **Armory Door** (Amber Gold Gear & Crossed Barrels), **Tactical Item Door** (Electric Cyan Circuit Matrix), or **Random Event / Pit-Stop Door** (Violet Anomaly Coil / Warm Forge Flame).
   - Injecting an **Overdrive Bet (`F`, `-25⚡`)** physically slams heavy red-hot hydraulic hazard clamps over the door frame, ignites warning strobes, and flips the overhead holo-sign to a fiery `2X OVERDRIVE` badge.
2. **Persistent Battle Scars & Shell Casings (持久化战场痕迹与弹壳叙事)**:
   - Spent brass shell casings, shattered Burst Bot chassis plates, scorch decals from TNT barrels / `RMB` Heavy Spenders, and splintered table debris **persist on the floor (`Value <= 32%`, zero collision)** for the duration of the room.
   - By the moment the final enemy falls, the dark slate floor visually chronicles the exact path of the player's firefight.
3. **Biome Progression Cues (生态层递进视觉线索)**:
   - As runs progress from outer Assembly Yards to the Core Reactor, recessed floor conduits shift from dormant industrial slate to hotter pulsing furnace seams (while keeping walkable floor surface Value strictly $\le 30\%$).

## 7. UI/HUD Visual Direction

### 7.1 Spatial Hierarchy: Player-Proximate Micro-HUD vs. Screen-Perimeter HUD
In a high-density twin-stick bullet-hell, forcing the player's eyes to travel 500px to the screen corners during combat causes unavoidable hits. At `1280×720` base resolution, the HUD is partitioned into two focal zones:

| Zone (区域) | Radius / Placement (范围/位置) | Elements Included (包含元素) | UX & Visual Rules (交互与视觉规范) |
| :--- | :--- | :--- | :--- |
| **Player-Proximate Micro-HUD**<br>*(角色近距微缩 HUD)* | Within **`64px`** of player sprite or cursor<br>*(角色或准星 **`64px`** 半径内)* | 1. **Overhead Active Reload Slider (`R`)**: `40×6px` bar at `Y: -28px` above head; high-contrast yellow sweet-spot (`+14⚡`).<br>2. **Final Round Badge (`LMB`)**: Amber/gold micro-pip (`10×10px`) beside crosshair/muzzle when mag `= 1`.<br>3. **Dodge-Roll Graze Ring (`Space`)**: Outer cyan dashed arc (`36px`–`42px` radius) pulsing electric blue on graze (`+20⚡`).<br>4. **Heavy Ready Pip (`RMB`)**: Crosshair bracket glow when Overcharge meets equipped Heavy cost (`30/50/90⚡`). | **Zero permanent clutter (零常驻遮挡)**: Dynamic elements appear during active states and fade within `150ms` of completion. Opacity capped at `85%` so enemy bullets passing underneath remain 100% visible. |
| **Top-Left Perimeter HUD**<br>*(左上角状态栏)* | `16px` margin from top-left edge | 1. **HP Hearts (生命之心)**: Crisp segmented crimson cores (`16×16px` each).<br>2. **Armor Shields (护甲盾牌)**: Cyan hexagonal plates.<br>3. **Scrap Shells (废料弹壳)**: Brass shell icon + tabular numeric counter. | High-contrast dark backdrop (`#0A0D14` at `85%` alpha, `1px` bevel) ensures legibility over any arena floor. |
| **Bottom-Left Overcharge & Armory HUD**<br>*(左下角超载槽与军械栏)* | `16px` margin from bottom-left edge | 1. **Overcharge Bar (`0–100⚡`)**: Horizontal `180×14px` geometric bar with hard vertical threshold ticks at **`30⚡` / `50⚡` / `90⚡`**.<br>2. **3 Armory Slots (3槽军械区)**: Primary Gun (`LMB`), Heavy Weapon (`RMB`, cost badge `30/50/90⚡`), Dynamo Core. | Fill shifts color by tier (`<30⚡` Slate, `30–49⚡` Cyan, `50–89⚡` Amber, `90–100⚡` Magenta). |
| **Bottom-Right Tactical Slots**<br>*(右下角战术道具栏)* | `16px` margin from bottom-right edge | **4 Tactical Item Slots (4槽战术区)**:<br>- **1 Active Item (`Q`)**: `32×32px` frame with cooldown sweep.<br>- **3 Passive Relics (`[7]/[8]/[9]`)**: Three `28×28px` slots. When full (`3/3`), new drops show a **`[7]/[8]/[9] Swap & Salvage (+Scrap)`** banner. | Keybind badges (`Q`, `7`, `8`, `9`) sit anchored at the bottom-right corner of each slot in `12px` bold pixel-aligned text. |

### 7.2 Typography & Chinese Readability (字体排印与中文可读性规范)
- **Font Stack**: `Noto Sans CJK SC` (Production packaged font) / `STHeiti Medium` (macOS prototype fallback) + monospaced tabular numerals for ammo, Overcharge `⚡`, and Scrap counters.
- **Weight & Stroke Treatment**: Medium (`500`) to Bold (`700`) weights only (thin strokes are forbidden). All floating combat text and HUD labels use a `1px` solid `#080A0F` outer outline + `1px` drop shadow.
- **720p Size Hierarchy & Steam Deck Floor**:
  - **Hard Minimum Size**: **`12px`** (nothing below `12px` is permitted for Steam Deck legibility).
  - **Body & Tooltip Descriptions**: **`14px–16px`**.
  - **HUD Counters & Door Headers**: **`18px–22px`** Bold.

### 7.3 Iconography & Animation Feel
1. **Overcharge Threshold Hydraulic Bounce**: Crossing `30⚡`, `50⚡`, or `90⚡` triggers a snappy `120ms` bounce (`scale 1.0 -> 1.22 -> 1.0`) + `1-frame` white flash on the `RMB` Heavy Weapon frame.
2. **Jammed Reload Warning (`R` Miss)**: Missing the Active Reload sweet spot turns the overhead bar smoky ash/crimson, applies horizontal jitter (`±4px`), and stamps a **`卡壳 / JAMMED`** micro-tag.
3. **3-Door Header Cards & Overdrive Bet (`F`)**: Floating header cards above each cleared door show the category crest and `[E] 进入 / [F] 超载押注 -25⚡` prompt; pressing `F` slams hydraulic clamps onto the frame with a `2x` flame seal.

### 7.4 Art vs. UX Readability Conflict Resolution ("Perimeter Chrome, Proximate Geometry")
- **Conflict**: Elaborate industrial gauges (rivets, brass bezels, glass tubes) vs. zero-latency bullet-hell readability.
- **Resolution**: All player-proximate gauges (`64px` Micro-HUD & Overcharge bar) are rendered as **100% pure flat geometric bars with `1px` dark outlines and zero decorative chrome**; industrial foundry framing (chamfered steel plates, corner rivets, hazard stripes) is strictly restricted to outer HUD borders, post-combat Door Header Cards, and Pit-Stop overlays.

## 8. Asset Standards

### 8.1 Sprite & Texture Resolution Tiers

| Asset Category (资产类别) | Base Pixel Canvas (基础像素画布) | Display Scale / Notes (渲染缩放与规范说明) |
| :--- | :--- | :--- |
| **Player & Standard Enemies (玩家与常规敌人)** | `16×16` px or `24×24` px | Scaled `2x–3x` (`32×32`–`72×72` screen px); chibi 1:1 head-to-body ratio, `1px–2px` `#0B0C10` outline |
| **Elite / Heavy Enemies (精英/重装敌人)** | `32×32` px or `48×48` px | Scaled `2x`; reinforced silhouette with distinct weapon mount points |
| **Boss Frames & Multi-Part Cores (Boss 主体与部件)** | `64×64` px to `128×128` px | Modular sprite parts (chassis, turrets, destructible vents) for independent hit-flash and rotation |
| **Detached Handguns & Heavy Weapons (独立挂载武器)** | `16×8` px to `32×16` px | Pivoted at grip `(0.25, 0.5)` for 360° aiming; oversized muzzle/breech silhouettes |
| **Projectiles & Casings (弹幕与弹壳)** | `4×4` px to `16×16` px | High-value `#FFFFFF` core + saturated rim for contrast against dark floors |
| **Tilemap & Arena Props (地形瓦片与掩体道具)** | `16×16` px cell (`32×32` px display) | Modular walls, hazard grates, and flip-tables aligned to collision grid |
| **Packed Sprite Atlases (合并精灵图集)** | Max `2048×2048` px | `2px` transparent padding between frames to prevent UV edge bleeding |

### 8.2 File Formats & Naming Conventions
Per `project.yaml`, all asset filenames, directories, and scene files enforce **`snake_case`**, while custom GDScript classes/resources use **`PascalCase`** and constants use **`SCREAMING_SNAKE`**.
- **Sprites & UI Textures (`.png`)**: `RGBA8`, lossless compression (`spr_<category>_<entity>_<state>.png`, `ui_<element>_<state>.png`).
- **Combat & UI SFX (`.wav`)**: `44.1 kHz`, `16-bit PCM` uncompressed for zero-latency playback (`sfx_<category>_<action>.wav`).
- **Music & Ambient Loops (`.ogg`)**: Ogg Vorbis `44.1 kHz`, seamless loop (`bgm_<zone>_<layer>.ogg`).
- **Shaders & Materials (`.gdshader` / `.tres`)**: `shd_<effect_name>.gdshader`, `mat_<effect_name>.tres`.

### 8.3 Godot 4.7.2 Import & Rendering Rules
1. **Global Project Settings (`project.godot`)**:
   - `rendering/textures/canvas_textures/default_texture_filter = 0` (**`Nearest`**) for razor-sharp pixel edges.
2. **Texture Import Preset (`.import`)**:
   - `compress/mode = 0` (**`Lossless`**) and `mipmaps/generate = false` to prevent block artifacts or outline bleeding on pixel art.
3. **Godot 4.7.2 Glow & Tonemapping Alignment**:
   - `WorldEnvironment` 2D Glow processes before tonemapping using screen blending; selective bloom is triggered via `CanvasItemMaterial` (`Add` / `Unshaded`) or raw `modulate > 1.0` strictly on Tier 3 threat cores, Final Round tracers, and Perfect Reload arcs.

### 8.4 Performance & VFX Hard Budgets (60+ FPS Target on PC & Steam Deck)

| Budget Category (预算指标) | Hard Limit (硬性上限) | Technical Enforcement Strategy (技术执行策略) |
| :--- | :--- | :--- |
| **Concurrent Projectiles (同屏并发弹幕)** | **500+ active bullets** | Pre-allocated object pools (`MultiMeshInstance2D` or batched custom `_draw()`); zero runtime `instantiate()`/`queue_free()` in combat |
| **Draw Calls per Combat Room (单房间绘制调用)** | **`≤ 150` Draw Calls** | Shared texture atlases; minimal unique `ShaderMaterial` instances |
| **Active Particle Emitters (同屏活跃粒子发射器)** | **`≤ 24` `GPUParticles2D`** | Total simultaneous particles `≤ 1,200` |
| **2D Texture VRAM Budget (2D 显存预算)** | **`≤ 128 MB`** | Lossless packed sprite sheets |
| **Player VFX Opacity Cap (玩家特效透明度上限)** | **Alpha `≤ 0.45` (`45%`)** | All persistent/area player VFX (`RMB` Black Hole, shockwaves, ground decals) capped at `≤ 45%` alpha |

#### Strict Z-Index Layering Contract
- **`Z = 0` (`Floor`)**: Tilemap base plates & static room geometry ($\text{Value} \le 30\%$).
- **`Z = 5` (`Debris/Shells`)**: Persistent brass casings, scorch marks, shattered robot debris.
- **`Z = 10` (`Player Ground VFX`)**: Dash afterimages, reload shockwave rings, Black Hole wells (**Alpha `≤ 0.45`**).
- **`Z = 20` (`Actors & Cover`)**: Player body + weapon sprite, enemies, flip-tables, explosive barrels (`y_sort_enabled = true`).
- **`Z = 30` (`Player Projectiles`)**: Primary bullets, Final Round slugs, Swarm missiles, Railgun beams.
- **`Z = 40` (`Enemy Threats`)**: Enemy bullets (`#FF2A3C` / `#FF1E8A` with `#FFFFFF` core), sniper lasers, Weak-Point Interrupt reticles — **always renders above player VFX and characters**.
- **`Z = 50` (`Micro-HUD`)**: Overhead Active Reload slider, Final Round pip, and floating combat callouts.

### 8.5 Art vs. Technical Trade-off Record
- **Trade-off Evaluated**: *Per-Bullet Dynamic `PointLight2D` Shadow-Casting vs. 60+ FPS Bullet-Hell Performance & Luminance Clarity.*
- **Decision**: Projectiles **never** attach `PointLight2D` nodes (which would destroy 500-bullet frame times and raise floor luminance above 30%). Instead, bullets use unshaded high-value pixel cores (`#FFFFFF` center + saturated rim) paired with a **single full-screen `WorldEnvironment` 2D Glow pass (`O(1)` cost)**, while real `PointLight2D` nodes are capped at `≤ 8` per room for static foundry vents and Pit-Stop work lamps.

## 9. Reference Direction

### 同源 2D 像素动作肉鸽参考矩阵 (Curated Pixel-Art Action Roguelite Reference Matrix)
我们聚焦于画风高度同源、经过海量玩家验证的 **6 款标杆级 2D 俯视角像素射击/动作肉鸽游戏**，综合各家之所长，同时明确规避各自的视觉痛点：

| Reference Title (参考作品) | What We Take (精准汲取的视觉与动效优点) | What We Avoid / Diverge From (明确规避的痛点与差异化边界) |
| :--- | :--- | :--- |
| **1. 《挺进地牢》<br>(*Enter the Gungeon*)** | **角色/枪械比例与物理交互天花板**：<br>• `2头身` Q版大头小人 + `1px–2px` 纯黑外描边；<br>• **分离式夸张大枪挂点**（缩略图尺寸下也能一眼认出是左轮、冲锋枪还是重炮）；<br>• 掀翻木桌当掩体（`[E]`）的多阶段破损动画；<br>• 满地永久留存的黄铜弹壳、焦黑弹坑与亮白内芯的圆润敌方子弹。 | **规避暖黄碎石地板噪点与后期全屏遮挡**：<br>• 拒绝高明度的暖黄/棕红地砖（会吃掉暖色子弹对比度），地板明度严控 $\le 30\%$；<br>• 拒绝后期不透明的夸张玩梗爆炸挡住敌方子弹（严格执行**我方地面/爆炸特效 Alpha $\le 45\%$** 铁律）。 |
| **2. 《元气骑士》<br>(*Soul Knight*)** | **干净讨喜的像素块面、武器脑洞辨识度与极简状态栏**：<br>• 干净利落、绝不脏乱的像素块面着色（高亲和力、一眼看清主次结构）；<br>• 轻型/中型/终极重火器极具反差感的造型剪影与蓄力光效；<br>• 左上角“生命 + 护甲 + 能量槽”直白清爽的街机可读性。 | **规避纯自动锁敌的弱准星感与召唤物堆叠**：<br>• 我们强调双摇杆精准手瞄与主动换弹，因此强化准星周围 `64px` 微距 HUD（头顶换弹滑块、尾弹提示）；<br>• 严禁满屏召唤物/跟班宠物遮挡走位视线。 |
| **3. 《霓虹深渊》&《比特小队》<br>(*Neon Abyss* & *Juicy Realm*)** | **深暗底板上的果冻级霓虹色彩与三门明牌灯箱**：<br>• 在暗色工业地牢底板上，用高饱和的**电光青（超载/擦弹）**、**琥珀金（尾弹/完美换弹）**、**霓虹紫（黑洞/事件门）**打造强烈的视觉多巴胺；<br>• 极具张力的果冻感道具图标与房间门头霓虹灯牌（一眼分清【枪械门】【道具门】【随机事件门】）。 | **规避全屏高饱和彩光污染**：<br>• 霓虹高光严格限定在“子弹核心、换弹冲击波边缘、门头灯牌”三个焦点上，背景墙面与地板绝不滥用刺眼霓虹色。 |
| **4. 《废土之王》<br>(*Nuclear Throne*)** | **教科书级的帧级打击感（Game Feel & Juice）**：<br>• 命中敌人的瞬间触发 `0.06s–0.08s` **纯白剪影闪白（Hit-Flash）** + 击退微震；<br>• 右键重火器开火与炸药桶引爆时的**瞬间顿帧（Hitstop `0.04s`）**与方向性相机反冲；<br>• 角色翻滚与开枪时富有弹性的挤压拉伸（Squash & Stretch）。 | **规避早期 8-bit 粗糙噪点画质**：<br>• 不采用无描边的粗糙低分辨率色块，保持《挺进地牢》/《元气骑士》级别的清晰黑边与精致像素细节。 |
| **5. 《小小肉鸽》&《传说法师》<br>(*Tiny Rogues* & *Wizard of Legend*)** | **高辨识度蓄力红闪预警与冲刺残影**：<br>• 敌人在释放高危弹幕前，周身浮现极其醒目的**红色收缩十字框与蓄力闪光**（完美服务于我们的“弱点打断 `+35⚡`”机制）；<br>• 翻滚冲刺（`Space`）时干净利落的半透明青色像素残影拖尾，清晰标示擦弹轨迹；<br>• 进门前一目了然的奖励图标与“超载押注（`[F]` 双倍风险/双倍收益）”门框锁死动效。 | **规避复杂繁琐的地面法阵纹理**：<br>• 预警圈与擦弹环全部使用极简高对比几何圆弧，绝不绘制复杂花哨的哥特/魔法花纹干扰视线。 |
