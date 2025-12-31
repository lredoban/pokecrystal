# Quick Guide: Adding Custom Pokemon

This is a **quick reference guide** for adding custom Pokemon to pokecrystal. For the complete official tutorial, see:

**📖 Official Wiki**: [Add a new Pokémon - pokecrystal Wiki](https://github.com/pret/pokecrystal/wiki/Add-a-new-Pok%C3%A9mon)

---

## ⚠️ Important Limits

- **Maximum**: 253 Pokemon total (including originals)
- **Why**: Species IDs are single bytes (0-255)
  - `0x00` = no Pokemon
  - `0xFF` = end-of-list marker
  - `0xFD` = EGG
- **Current count**: 251 original + Satotoro = 252 (1 slot remaining!)

For adding beyond 253 species, consult the "16-bit extension project" by ax6.

---

## Quick Checklist

When adding a Pokemon, you need to modify **~20 files**:

### 1. Constants & Names
- [ ] `constants/pokemon_constants.asm` - Add constant (e.g., `const MYPOKEMON`)
- [ ] `data/pokemon/names.asm` - Add name (max 10 chars, padded with `@`)

### 2. Base Data
- [ ] `data/pokemon/base_stats/mypokemon.asm` - Create stats file
- [ ] `data/pokemon/base_stats.asm` - Include stats file
- [ ] `data/pokemon/cries.asm` - Add cry reference
- [ ] `data/pokemon/menu_icons.asm` - Add menu icon

### 3. Moves & Evolution
- [ ] `data/pokemon/evos_attacks.asm` - Define evolutions & level-up moves
- [ ] `data/pokemon/evos_attacks_pointers.asm` - Add pointer
- [ ] `data/pokemon/egg_moves.asm` - Define egg moves (or use `NoEggMoves`)
- [ ] `data/pokemon/egg_move_pointers.asm` - Add pointer

### 4. Pokedex
- [ ] `data/pokemon/dex_entries/mypokemon.asm` - Create entry file
- [ ] `data/pokemon/dex_entries.asm` - Include entry (in correct ROM bank!)
- [ ] `data/pokemon/dex_entry_pointers.asm` - Add pointer
- [ ] `data/pokemon/dex_order_new.asm` - Add in discovery order
- [ ] `data/pokemon/dex_order_alpha.asm` - Add in alphabetical order

### 5. Graphics
- [ ] `gfx/pokemon/mypokemon/front.png` - Front sprite (56x56 max, 4 colors)
- [ ] `gfx/pokemon/mypokemon/back.png` - Back sprite (56x56 max, 4 colors)
- [ ] `gfx/pokemon/mypokemon/shiny.pal` - Shiny palette
- [ ] `gfx/footprints/mypokemon.png` - Footprint (16x16, 2 colors)

### 6. Animation
- [ ] `gfx/pokemon/mypokemon/anim.asm` - Battle animation
- [ ] `gfx/pokemon/mypokemon/anim_idle.asm` - Idle animation
- [ ] `gfx/pokemon/anims.asm` - Include animation
- [ ] `gfx/pokemon/idles.asm` - Include idle animation

### 7. Pointers & Includes
- [ ] `data/pokemon/pic_pointers.asm` - Add pic pointers
- [ ] `gfx/pics.asm` - Include sprites in ROM bank
- [ ] `data/pokemon/palettes.asm` - Include palettes
- [ ] `gfx/pokemon/anim_pointers.asm` - Add animation pointer
- [ ] `gfx/pokemon/idle_pointers.asm` - Add idle pointer
- [ ] `gfx/pokemon/frame_pointers.asm` - Add frame pointer
- [ ] `gfx/pokemon/bitmask_pointers.asm` - Add bitmask pointer
- [ ] `gfx/pokemon/johto_frames.asm` or `kanto_frames.asm` - Include frames
- [ ] `gfx/pokemon/bitmasks.asm` - Include bitmasks
- [ ] `gfx/footprints.asm` - Include footprint

### 8. Compatibility
- [ ] `data/pokemon/gen1_order.asm` - Add for Time Capsule compatibility (optional)

---

## Key Details from Official Wiki

### ROM Bank Sections for Pokedex Entries

Pokedex entries must be included in the correct ROM bank based on species ID:

Edit `data/pokemon/dex_entries.asm`:
- **IDs 1-64**: Bank 1 section
- **IDs 65-128**: Bank 2 section
- **IDs 129-192**: Bank 3 section
- **IDs 193-256**: Bank 4 section

### Kanto vs Johto Frames

- Use `gfx/pokemon/johto_frames.asm` for Johto Pokemon (most custom Pokemon)
- Use `gfx/pokemon/kanto_frames.asm` for Kanto Pokemon only

### Sprite Dimensions

Front sprites can be:
- 40×40 pixels (5×5 tiles)
- 48×48 pixels (6×6 tiles)
- 56×56 pixels (7×7 tiles) - maximum

Back sprites: typically 48×48 pixels

### Color Requirements

- **4 colors exactly**: white, black, + 2 midtones
- **Paletted PNG** format (indexed color)
- **Palette order**: white first, black last, sorted by luminance

### Animation Files

The build process **automatically generates**:
- Compressed tiles (`.2bpp.lz`)
- Bitmasks
- Frame data

You only need to create:
- Source sprites (`.png`)
- Animation scripts (`.asm`)

---

## Workflow with Our Tools

### Step 1: Create Graphics with AI

Use AI tools (Nano Banana, etc.) to generate:
- Front sprite
- Back sprite
- Footprint

See [AI_SPRITE_PROMPTS.md](AI_SPRITE_PROMPTS.md) for prompts.

### Step 2: Convert Graphics

Use our conversion tool to fix format issues:

```bash
# Convert front sprite
tools/convert_gbc.sh --type=pokemon \
  raw/mypokemon-front.png \
  gfx/pokemon/mypokemon/front.png

# Convert back sprite
tools/convert_gbc.sh --type=pokemon \
  raw/mypokemon-back.png \
  gfx/pokemon/mypokemon/back.png

# Convert footprint
tools/convert_gbc.sh --type=footprint \
  raw/mypokemon-footprint.png \
  gfx/footprints/mypokemon.png
```

See [graphics-conversion.md](graphics-conversion.md) for details.

### Step 3: Create Data Files

Create the necessary `.asm` files:
- `data/pokemon/base_stats/mypokemon.asm`
- `data/pokemon/dex_entries/mypokemon.asm`
- `gfx/pokemon/mypokemon/anim.asm`
- `gfx/pokemon/mypokemon/anim_idle.asm`
- `gfx/pokemon/mypokemon/shiny.pal`

### Step 4: Update All Pointer Files

Go through the checklist above and update all ~20 files.

**Tip**: Look at Satotoro's integration as a reference example.

### Step 5: Build & Test

```bash
# Build ROM
make

# Test in emulator
open -a SameBoy pokecrystal.gbc
```

---

## Common Issues

### "Section is too big"

**Problem**: ROM bank exceeded 16KB limit

**Solution**: Move sprites to a different section in `gfx/pics.asm`
- Example: We moved Satotoro to "Pics 20" section

### Wrong palette order

**Problem**: Some Pokemon need reversed palette (darkest to lightest)

**Pokemon affected**: Spearow, Fearow, Farfetch'd, Hitmonlee, Scyther, Jynx, Porygon, Porygon2

**Solution**: Use `--reverse` flag with conversion tool or adjust manually

### Table size mismatches

**Problem**: Added Pokemon but forgot to update pointer tables

**Solution**: Check `assert_table_length NUM_POKEMON` errors and update all pointer files

---

## Example: Satotoro

See our first custom Pokemon as a complete example:

**Files created**:
- `data/pokemon/base_stats/satotoro.asm`
- `data/pokemon/dex_entries/satotoro.asm`
- `gfx/pokemon/satotoro/front.png`
- `gfx/pokemon/satotoro/back.png`
- `gfx/pokemon/satotoro/shiny.pal`
- `gfx/pokemon/satotoro/anim.asm`
- `gfx/pokemon/satotoro/anim_idle.asm`
- `gfx/footprints/satotoro.png`

**Files modified**: All pointer tables and includes

See commit history for details: `git log --oneline --grep="Satotoro"`

---

## Resources

- **Official Tutorial**: [pokecrystal Wiki - Add a new Pokémon](https://github.com/pret/pokecrystal/wiki/Add-a-new-Pok%C3%A9mon)
- **Graphics Conversion**: [graphics-conversion.md](graphics-conversion.md)
- **AI Sprite Generation**: [AI_SPRITE_PROMPTS.md](AI_SPRITE_PROMPTS.md)
- **Custom Changes Manifest**: [CUSTOM_CHANGES.md](CUSTOM_CHANGES.md)
- **Fakemon Tracker**: [fakemons.md](fakemons.md)

---

*This is a quick reference guide. For complete details, always refer to the [official wiki tutorial](https://github.com/pret/pokecrystal/wiki/Add-a-new-Pok%C3%A9mon).*
