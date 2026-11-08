# Accessibility Requirements: CHAMBER OVERDRIVE (膛室超载)

> **Status**: Approved
> **Accessibility Tier**: **Standard+ (Action Bullet-Hell Readability & Multi-Modal Redundancy)**
> **Last Updated**: 2026-11-08

## 1. Visual & Colorblind Accessibility
- **Three-Tier Luminance Hierarchy**: Walkable floors remain `<= 30%` Value; player ground/volume VFX are capped at `<= 45%` Alpha (`Z = 10`); enemy threats render at `90%–100%` Value with `#FFFFFF` inner cores at `Z = 40`.
- **Multi-Modal Colorblind Backups**:
  - **Enemy vs. Player Bullets**: Solid `#FFFFFF` circular cores on enemy bullets vs. elongated streaks on player shots.
  - **4-Tier Rarity (`COMMON / RARE / EPIC / LEGENDARY`)**: Paired with 1 / 2 / 3 / 4 star notches in addition to White / Cyan / Violet / Gold colors.
  - **3 Door Categories**: Paired with distinct Gear / Chip / Anomaly icons.
  - **`SHIELD_PIERCING` Attacks**: Marked by jagged electric border geometry + `⚠️` warning glyph + rising siren audio cue.

## 2. Motor & Screen-Shake Controls
- **Screen Shake Intensity Slider (`0%–100%`)**: Exposes `user_screen_shake_setting` (`0.0–1.0`) in settings, hard-capped at `18.0 px` max displacement.
- **Full Keybind & Controller Remapping**: Supports remapping `WASD`, `Space` (Dodge), `LMB` (Primary), `RMB` (Heavy), `R` (Reload), `Q` (Active), `E` (Interact), and `F` (Overdrive Bet).

## 3. Typography & Steam Deck Legibility
- **Hard Minimum Font Size**: **`12px`** at `1280×720` viewport using Medium/Bold CJK strokes (`Noto Sans CJK SC` / `STHeiti Medium`) with `1px` dark outlines.
