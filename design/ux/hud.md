# HUD UX Specification: CHAMBER OVERDRIVE (膛室超载)

> **Status**: Approved
> **Viewport**: `1280×720` (`Z = 50` Overlay, Steam Deck Verified `>= 12px` CJK Typography)
> **Source GDD**: `design/gdd/tactical-micro-hud.md`
> **Last Updated**: 2026-11-08

---

## 1. Spatial Hierarchy ("Perimeter Chrome, Proximate Geometry")

1. **Zone 1 — `64px` Player-Proximate Micro-HUD (Pure Flat Geometry, Zero Decorative Chrome)**:
   - **Overhead Active Reload Slider (`76×8px` at `Y: -38px`, flips to `Y: +28px` when `player_pos.y < 135px`)**: Dynamically renders weapon-specific yellow sweet-spot bracket (`0.22–0.40` Twin-SMG, `0.42–0.62` Revolver, `0.65–0.81` Pump-Shotgun).
   - **Final Round Pip (`ammo == 1`)**: Amber Gold (`#FFB800`) badge beside crosshair/player.
   - **Dodge-Roll Graze Ring (`Space`)**: `42.0 px` cyan ring (`80%` alpha during `0.28s` I-frames, `16%` alpha idle).
2. **Zone 2 — Top-Left Survival, 3-Pip Overcharge Aegis Shield & Bounty Chips**:
   - Displays `❤️ 生命: 6/6`, `🛡️ 过载盾: 1/1 (重构: [■][■][□])`, and `🪙 赏金币: N`.
3. **Zone 3 — Top-Right 4-Mode Room Objective Tracker & Boss Bar**:
   - Dynamically switches between `👾 歼灭战`, `📡 破坏巨企信标 (3座)`, `⏱️ 高压倒计时生存`, and `⚡ 终端上传`.
   - Top-Center Boss Header displays `65% / 30%` phase dividers, `BossPartNode` sub-bars, and the `★ 无伤大师核心合格` badge.
4. **Zone 4 — Bottom Perimeter `45 / 65 / 90⚡` Overcharge Bar & 7-Slot Loadout**:
   - `320×22px` Overcharge gauge with vertical tick marks at `45⚡`, `65⚡`, and `90⚡`.
   - 3 Armory Slots (`LMB` Primary, `RMB` Heavy, Dynamo Core) + 4 Tactical Slots (`[Q]` Active + `[7]/[8]/[9]` Passives).
5. **Zone 5 — Off-Screen Edge Wayfinders & Inline `[7]/[8]/[9]/[G]` Swap Banner**:
   - Clamps directional badges along `Rect2(36, 80, 1208, 560)` for off-screen Beacons and *Hades*-style exit doors.
