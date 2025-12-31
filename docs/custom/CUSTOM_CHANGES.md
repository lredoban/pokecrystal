# Custom Changes Manifest - Nono Edition

This document tracks all custom modifications made to the pokecrystal codebase for the Nono Edition ROM hack. Use this to understand what's been changed and maintain compatibility when pulling upstream updates.

**Last Updated**: 2025-12-31

---

## Overview

The Nono Edition includes:
- Custom Pokemon (fakemon)
- Quality of life improvements
- Graphics conversion tools for modern workflows
- Custom documentation

**Upstream Compatibility Strategy**: All custom files are isolated in `docs/custom/`, `gfx/pokemon/*/` (new Pokemon), and `tools/` directories to minimize conflicts.

---

## Added Files (Safe from Upstream Conflicts)

These files are NEW and won't conflict with upstream updates:

### Custom Tools
- **`tools/convert_gbc.sh`** - PNG conversion utility for GBC format
  - Converts Figma/AI-generated PNGs to proper 4-color paletted format
  - Dependencies: pngquant, ImageMagick, Python 3 + Pillow
  - See: [docs/custom/graphics-conversion.md](graphics-conversion.md)

### Custom Documentation
- **`docs/custom/AI_SPRITE_PROMPTS.md`** - AI sprite generation guide
  - Prompts for generating Pokemon sprites with AI tools (Nano Banana, etc.)
  - Specifications for Game Boy Color constraints

- **`docs/custom/graphics-conversion.md`** - Graphics conversion tool documentation
  - Complete guide for `tools/convert_gbc.sh`
  - Troubleshooting and workflow examples

- **`docs/custom/CUSTOM_CHANGES.md`** - This file
  - Manifest of all custom modifications
  - Upstream update guidance

- **`docs/custom/completed-features.md`** - Completed feature list
  - Tracks implemented features for Nono Edition

- **`docs/custom/planned-features.md`** - Planned feature list
  - Future enhancements and ideas

### Custom Pokemon Assets
- **`gfx/pokemon/satotoro/`** - Satotoro (Pokemon #252)
  - `front.png`, `back.png` - Sprites
  - `shiny.pal` - Shiny palette
  - `anim.asm`, `anim_idle.asm` - Animations
  - `normal.gbcpal`, `back.gbcpal`, `front.gbcpal` - Generated palettes
  - `*.2bpp`, `*.2bpp.lz` - Generated tile data (from build)

- **`gfx/footprints/satotoro.png`** - Satotoro footprint

- **`data/pokemon/base_stats/satotoro.asm`** - Satotoro base stats
- **`data/pokemon/dex_entries/satotoro.asm`** - Satotoro Pokedex entry

---

## Modified Core Files

These core files have been modified and may conflict with upstream updates.

### Pokemon Data Files

#### `constants/pokemon_constants.asm`
**Modified**: Added Satotoro constant
**Lines**: Around line 252 (added `const SATOTORO ; fc`)
**Merge Strategy**:
- If upstream adds Pokemon, renumber Satotoro and all custom Pokemon
- Keep custom Pokemon at end of list before EGG

#### `data/pokemon/base_stats.asm`
**Modified**: Included Satotoro base stats
**Lines**: End of file (added `INCLUDE "data/pokemon/base_stats/satotoro.asm"`)
**Merge Strategy**:
- If upstream adds Pokemon, add custom includes after upstream additions
- Keep custom includes grouped together

#### `data/pokemon/names.asm`
**Modified**: Added Satotoro name
**Lines**: After CELEBI entry
**Merge Strategy**:
- If upstream changes, maintain same order as pokemon_constants.asm
- Add custom names in same position as their constants

#### `data/pokemon/cries.asm`
**Modified**: Added Satotoro cry, removed one dummy entry
**Lines**: After CELEBI entry (added `mon_cry CRY_CLEFAIRY, -50, 200 ; SATOTORO`)
**Merge Strategy**:
- Match cry table to pokemon_constants.asm order
- Remove dummy entries as needed to maintain table size

#### `data/pokemon/evos_attacks.asm`
**Modified**: Added Satotoro evolution and moveset
**Lines**: End of file (added `SatotoroEvosAttacks:` section)
**Merge Strategy**:
- If upstream changes format, update custom Pokemon data to match
- Keep custom Pokemon at end of file

#### `data/pokemon/evos_attacks_pointers.asm`
**Modified**: Added Satotoro pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `data/pokemon/egg_move_pointers.asm`
**Modified**: Added Satotoro pointer (NoEggMoves)
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `data/pokemon/dex_entries.asm`
**Modified**: Added Satotoro Pokedex entry label and include
**Lines**: End of file
**Merge Strategy**:
- Keep custom Pokemon at end, grouped together

#### `data/pokemon/dex_entry_pointers.asm`
**Modified**: Added Satotoro pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `data/pokemon/palettes.asm`
**Modified**: Added Satotoro palette includes, removed dummy entry
**Lines**: After CELEBI palettes
**Merge Strategy**:
- Match palette table to pokemon_constants.asm order
- Maintain table size assertions

#### `data/pokemon/pic_pointers.asm`
**Modified**: Added Satotoro pic pointers, removed unused dummy
**Lines**: After CELEBI entry
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `data/pokemon/menu_icons.asm`
**Modified**: Added Satotoro icon (ICON_MONSTER)
**Lines**: After CELEBI icon
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `data/pokemon/dex_order_alpha.asm`
**Modified**: Added Satotoro in alphabetical position
**Lines**: After SANDSLASH (alphabetically)
**Merge Strategy**:
- Insert custom Pokemon in alphabetical order by name
- May need to re-sort if upstream adds Pokemon

#### `data/pokemon/dex_order_new.asm`
**Modified**: Added Satotoro at end
**Lines**: After CELEBI
**Merge Strategy**:
- Keep custom Pokemon at end in discovery order

#### `data/pokemon/gen1_order.asm`
**Modified**: Added Satotoro at end
**Lines**: After CELEBI
**Merge Strategy**:
- Keep custom Pokemon at end

### Graphics Files

#### `gfx/footprints.asm`
**Modified**: Added Satotoro footprint include
**Lines**: End of appropriate section (footprints are grouped by 8)
**Merge Strategy**:
- Add custom footprints at end of last group
- May need to create new group if adding many Pokemon

#### `gfx/pics.asm`
**Modified**: Added Satotoro sprite includes in "Pics 20" section
**Lines**: Section "Pics 20" (added `SatotoroFrontpic:` and `SatotoroBackpic:`)
**Merge Strategy**:
- If "Pics 20" grows too large, create "Pics 21" section
- Maintain SECTION size limits (16KB max)

#### `gfx/pokemon/anims.asm`
**Modified**: Added Satotoro animation include
**Lines**: End of file (added `SatotoroAnimation:` include)
**Merge Strategy**:
- Keep custom Pokemon at end, grouped together

#### `gfx/pokemon/anim_pointers.asm`
**Modified**: Added Satotoro animation pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `gfx/pokemon/idles.asm`
**Modified**: Added Satotoro idle animation include
**Lines**: End of file
**Merge Strategy**:
- Keep custom Pokemon at end, grouped together

#### `gfx/pokemon/idle_pointers.asm`
**Modified**: Added Satotoro idle pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `gfx/pokemon/johto_frames.asm`
**Modified**: Added Satotoro frames include
**Lines**: End of file
**Merge Strategy**:
- Keep custom Pokemon at end, grouped together

#### `gfx/pokemon/frame_pointers.asm`
**Modified**: Added Satotoro frame pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

#### `gfx/pokemon/bitmasks.asm`
**Modified**: Added Satotoro bitmask include
**Lines**: End of file
**Merge Strategy**:
- Keep custom Pokemon at end, grouped together

#### `gfx/pokemon/bitmask_pointers.asm`
**Modified**: Added Satotoro bitmask pointer
**Lines**: After CELEBI pointer
**Merge Strategy**:
- Maintain same order as pokemon_constants.asm

### Gameplay Modifications

#### `data/wild/johto_grass.asm`
**Modified**: Added Satotoro to Route 29 wild encounters
**Lines**: Route 29 section (lines 1240-1241, 1248-1249, 1256-1257)
**Merge Strategy**:
- If upstream changes Route 29 encounters, re-apply Satotoro additions
- **Temporary change** for testing - may be removed later

#### `maps/ElmsLab.asm`
**Modified**: Added bicycle to starter items
**Lines**: Line 508 (added `verbosegiveitem BICYCLE` in AideScript_GiveYouBalls)
**Merge Strategy**:
- If upstream changes AideScript_GiveYouBalls, re-add bicycle line
- Quality of life improvement - optional to keep

#### `gfx/title/logo.png`
**Modified**: Custom logo
**Lines**: N/A (binary file)
**Merge Strategy**:
- Keep custom version, or merge manually if upstream updates logo
- Backup custom version before pulling upstream

---

## Modified Documentation Files

#### `docs/custom/completed-features.md`
**Modified**: Updated with completed features
**Status**: Custom file - safe from conflicts

#### `docs/custom/planned-features.md`
**Modified**: Updated with planned features
**Status**: Custom file - safe from conflicts

---

## Upstream Update Procedure

### Step 1: Backup Custom Changes

Before pulling upstream:

```bash
# Create a backup branch
git checkout -b backup-before-upstream-$(date +%Y%m%d)
git push origin backup-before-upstream-$(date +%Y%m%d)
```

### Step 2: Pull Upstream Changes

```bash
# Fetch upstream (assuming you have upstream remote set)
git fetch upstream

# Merge upstream changes
git merge upstream/master
```

### Step 3: Resolve Conflicts

Common conflict scenarios:

**New Pokemon Added Upstream:**
- Renumber custom Pokemon constants (Satotoro, etc.)
- Update all pointer tables to match new numbering
- Rebuild: `make clean && make`

**Graphics Build System Changed:**
- Review changes to `Makefile`, `gfx/*.mk`
- Ensure `tools/convert_gbc.sh` still works
- May need to update conversion script

**Starter/Gameplay Code Changed:**
- Review `maps/ElmsLab.asm` changes
- Re-apply bicycle modification if needed
- Test gameplay changes

### Step 4: Test Build

```bash
# Clean build
make clean
make

# Test in emulator
open -a SameBoy pokecrystal.gbc

# Verify custom Pokemon appear correctly
# Verify bicycle is given at start
# Verify Satotoro on Route 29
```

### Step 5: Commit Merge

```bash
git add .
git commit -m "Merge upstream updates

- Resolved conflicts in [list files]
- Renumbered custom Pokemon if needed
- Re-applied custom modifications

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Branch Strategy

**Main branches:**
- `nono-edition` - Main development branch (current)
- `master` - Original pokecrystal (for reference)

**Upstream remote:**
```bash
# Add if not present:
git remote add upstream https://github.com/pret/pokecrystal.git
```

---

## Custom Tools Dependencies

External dependencies (not in repository):
- **pngquant** - Color quantization tool
- **ImageMagick** - Image manipulation
- **Python 3 + Pillow** - Palette sorting

Install via:
```bash
brew install pngquant imagemagick
pip3 install Pillow
```

---

## Summary

**Low Conflict Risk:**
- All documentation in `docs/custom/`
- Conversion tool in `tools/`
- New Pokemon assets in `gfx/pokemon/satotoro/`

**Medium Conflict Risk:**
- Pokemon data tables (names, cries, stats, etc.)
- Graphics pointer tables
- **Resolution**: Maintain same order as constants, add custom at end

**Higher Conflict Risk:**
- `maps/ElmsLab.asm` - starter modifications
- `data/wild/johto_grass.asm` - encounter tables
- `gfx/title/logo.png` - custom logo
- **Resolution**: Re-apply changes after merging, or keep separate branch

---

*This manifest is maintained manually. Update when adding new custom features or modifying core files.*
