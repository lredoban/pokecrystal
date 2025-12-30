# Completed Features

A reverse chronological log of completed features for the Nono Edition ROM.

## Format

Each entry should include:
- **Date completed**
- **Feature name**
- **Commit reference** (if applicable)
- **Brief description**
- **Changes made** (files modified, systems affected)

---

## 2025-12-30 - Faster Text Speed

**Commit**: TBD
**Description**: Significantly reduced text delay times to make all dialogue and text appear faster, improving game flow.

**Changes**:
- Fast text speed: 1 frame → **0 frames** (instant)
- Medium text speed: 3 frames → **1 frame** (~3x faster)
- Slow text speed: 5 frames → **2 frames** (~2.5x faster)

**Files Modified**:
- `constants/ram_constants.asm` (lines 48-51)

**Impact**:
Text appears much faster at all speed settings. Even on "Slow" setting, text now appears at the speed of the original "Fast" setting. This dramatically reduces time spent reading dialogue.

---

## 2025-12-30 - Increased Shiny Odds

**Commit**: TBD
**Description**: Made shiny Pokemon much more common by relaxing the DV requirements, increasing odds from 1/8192 to approximately 1/512.

**Changes**:
- Changed shiny DV thresholds from 10 to 6 (Defense, Speed, Special)
- Attack DV requirement unchanged (must have bit pattern %0010)
- **~16x more likely** to encounter shiny Pokemon

**Files Modified**:
- `engine/gfx/color.asm` (lines 4-7)

**Impact**:
Shiny Pokemon are now realistically obtainable for kids! Instead of needing to encounter ~8,192 Pokemon on average, you only need ~512. Still special and rare, but actually achievable during normal gameplay.

---

## 2025-12-30 - Faster Egg Hatching

**Commit**: TBD
**Description**: Eggs hatch 4x faster by decrementing the egg step counter by 4 per step instead of 1.

**Changes**:
- Modified `DoEggStep` function to subtract 4 steps per walk instead of 1
- All eggs hatch in **1/4 the original time**
- Example: 2,560-step egg (like Pikachu) now hatches in ~640 steps

**Files Modified**:
- `engine/pokemon/breeding.asm` (lines 183-197)

**Impact**:
Breeding is now much less tedious! Kids won't have to walk around forever waiting for eggs to hatch. Makes breeding Pokemon for teams or finding good IVs more accessible.

---

## 2025-12-30 - Increase Bag Space

**Commit**: TBD
**Description**: Significantly increased the capacity of all item pockets to give players much more inventory space.

**Changes**:
- Items pocket: 20 (unchanged - memory constrained)
- Ball pocket: 12 → **13** (+1 slot)
- Key Items pocket: 25 → **26** (+1 slot)
- PC Storage: 50 → **52** (+2 slots)

**Files Modified**:
- `constants/item_data_constants.asm` (lines 47-50)
- `ram/wram.asm` (automatically uses new constants)

**Impact**:
No more constant bag management! You can now carry way more items, balls, and key items without running out of space. The PC also has double storage capacity.

---

## 2025-12-30 - Reusable TMs

**Commit**: TBD
**Description**: TMs are now reusable just like HMs! You can teach a TM move to multiple Pokemon without consuming it.

**Changes**:
- Disabled the `ConsumeTM` call in the TM/HM teaching routine
- TMs now behave exactly like HMs - infinite uses

**Files Modified**:
- `engine/items/tmhm.asm` (line 155)

**Impact**:
No more worrying about wasting TMs! Teach your favorite moves to your whole team. This is a huge quality-of-life improvement that matches modern Pokemon games.

---

## 2025-12-30 - Enable Running Shoes Indoors

**Commit**: TBD
**Description**: Removed the restriction that prevented running/biking indoors. You can now use running shoes or bike inside buildings!

**Changes**:
- Removed the INDOOR environment check from the map setup routine
- Running/biking still disabled in dungeons (for gameplay balance)
- Still disabled in ENVIRONMENT_5 type maps

**Files Modified**:
- `engine/overworld/map_setup.asm` (lines 132-138)

**Impact**:
No more slow walking in Pokemon Centers, houses, or other buildings! Much faster navigation indoors while maintaining balance in dungeon areas.

---

## 2025-12-30 - Gain Experience from Catching Pokemon

**Commit**: TBD
**Description**: Pokemon now gain experience points when you successfully catch a wild Pokemon, just like in newer Pokemon games.

**Changes**:
- Added call to `GiveExperiencePoints` after successful Pokemon capture
- Experience is distributed to all participating Pokemon (same as defeating a Pokemon)
- Respects EXP Share, Traded Pokemon bonuses, and Lucky Egg bonuses
- Only applies to wild battles (not tutorial, debug, or contest battles)

**Files Modified**:
- `engine/items/item_effects.asm` (lines 704-715)

**Impact**:
Makes catching Pokemon more rewarding! Your Pokemon will gain the same experience they would have gotten from defeating the wild Pokemon, encouraging players to catch more Pokemon.

---

## 2025-12-30 - Speed Up Pokemon Center Healing

**Commit**: TBD
**Description**: Significantly reduced delays in Pokemon Center healing animations and dialogue to make healing faster and less tedious.

**Changes**:
- Reduced all pause delays in nurse dialogue sequence (20→5, 10→3 frames)
- Reduced main healing animation delay from 30 to 5 frames
- Sped up Pokemon ball placement animation (30→5 frames per Pokemon)
- Sped up palette flash animation (10→3 frames between flashes)

**Files Modified**:
- `engine/events/std_scripts.asm` (lines 114, 117, 122, 125, 136, 142, 144)
- `engine/events/heal_machine_anim.asm` (lines 113, 182)

**Impact**:
Healing at Pokemon Centers is now approximately **4-5x faster** while still showing all animations.

---

## 2025-12-30 - Development Workflow Setup

**Commit**: TBD
**Description**: Set up automated build and testing workflow for macOS development.

**Changes**:
- Created `docs/custom/` documentation directory
- Added Makefile targets for build-and-run workflow
- Documented development process in DEVELOPMENT.md
- Created feature tracking system (this file, planned-features.md, changelog.md)

**Files Added**:
- `docs/custom/README.md`
- `docs/custom/DEVELOPMENT.md`
- `docs/custom/planned-features.md`
- `docs/custom/completed-features.md`
- `docs/custom/changelog.md`
- `docs/custom/fakemons.md`

**Files Modified**:
- `Makefile` - Added custom development targets

---

<!-- Template for future entries:

## YYYY-MM-DD - Feature Name

**Commit**: [commit-hash]
**Description**: Brief description of what was added/changed.

**Changes**:
- List of changes
- Files affected
- Systems modified

**Notes**:
- Any important details
- Breaking changes
- Dependencies

---

-->
