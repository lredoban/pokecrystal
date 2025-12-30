# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a disassembly of Pokémon Crystal for Game Boy Color, written in Game Boy assembly language (Z80-based). The project builds authentic ROMs that match the original game's binary checksums using the RGBDS toolchain (rgbasm, rgblink, rgbfix, rgbgfx).

## Build Commands

### Building ROMs

```bash
# Build pokecrystal.gbc (v1.0)
make

# Build pokecrystal11.gbc (v1.1)
make crystal11

# Build Australian version
make crystal_au

# Build debug versions
make crystal_debug
make crystal11_debug

# Build Virtual Console patch
make crystal11_vc

# Build all targets
make all
```

### Cleaning

```bash
# Remove built ROMs and object files
make tidy

# Remove all generated files including graphics
make clean
```

### Verification

```bash
# Verify ROM checksums match original game
make compare
```

### Building with Local RGBDS

If you need a specific RGBDS version locally:

```bash
make RGBDS=rgbds-1.0.0/
```

### Tools

The `tools/` directory contains C programs that process graphics, animations, and patches. Build them with:

```bash
make tools
```

Tools are automatically built when building ROMs (unless running `make clean`, `make tidy`, or `make tools`).

## Architecture

### Memory Banking System

The Game Boy ROM is divided into 128 banks of 4KB ($4000 bytes) each, numbered $00 to $7F. Code and data are organized into `SECTION`s that are placed into specific banks via `layout.link`. If you add code and get "Section is too big" errors, you need to move code into a new section or reorganize existing sections.

### Core Files

- **main.asm**: Top-level file that INCLUDEs all other code, organized by ROM bank sections
- **home.asm**: INCLUDEs all files from `home/` directory (bank 0, always accessible)
- **audio.asm**: Audio engine and music data
- **ram.asm**: RAM variable definitions
- **includes.asm**: Prelude file automatically included in all assembly files (constants, macros, hardware definitions)

### Directory Structure

- **constants/**: Assembly constants for all game systems (Pokemon, items, moves, maps, battle, etc.)
- **macros/**: Assembly macro definitions for data structures and scripting languages
  - `macros/scripts/`: Special-purpose scripting languages (maps, events, text, audio, battle anims, movement)
- **home/**: Core routines in bank 0 (always accessible without banking)
- **engine/**: Game logic organized by subsystem
  - `battle/`, `battle_anims/`: Battle system and animations
  - `pokemon/`: Pokemon data, stats, evolution, breeding, PC system
  - `overworld/`: Map traversal, NPCs, player movement
  - `events/`: Special events, field moves, item usage
  - `menus/`: Menu systems, UI
  - `items/`: Item effects and inventory
  - `gfx/`: Graphics loading and rendering
  - `pokedex/`: Pokedex functionality
  - `phone/`, `pokegear/`: Phone and Pokegear systems
  - `link/`: Link cable trading and battling
  - `movie/`: Intro, title screen, credits
  - `rtc/`: Real-time clock
  - `tilesets/`: Tileset and palette management
  - `printer/`: Game Boy Printer support
- **data/**: Game data tables (Pokemon stats, moves, trainers, maps, wild encounters, etc.)
- **maps/**: Map scripts and events
- **gfx/**: Graphics source files (.png) and generated files (.2bpp, .1bpp, .gbcpal)
- **audio/**: Music and sound effects
- **mobile/**: Mobile Adapter GB features (Japan-only)
- **lib/**: Additional libraries
- **vc/**: Virtual Console specific code
- **tools/**: C programs for graphics processing, compression, patch generation

### Banking and Code Organization

Code is organized into banks (SECTION declarations in main.asm). Related functionality is grouped:
- Each SECTION maps to a 4KB bank in the final ROM
- `home/` code lives in bank 0 and is always accessible
- Other code requires banking (`farcall` macro) to access from different banks
- The linkerscript `layout.link` defines which sections go in which banks

### Special-Purpose Languages

The game uses several domain-specific languages defined via macros in `macros/scripts/`:
- **Map scripts**: Define map layouts, events, NPCs, warps (see docs/map_event_scripts.md)
- **Event commands**: Scripting language for in-game events (see docs/event_commands.md)
- **Text commands**: Text formatting and control codes (see docs/text_commands.md)
- **Movement commands**: NPC and player movement sequences (see docs/movement_commands.md)
- **Battle commands**: Move effects and battle logic (see docs/move_effect_commands.md)
- **Battle animations**: Animation scripting (see docs/battle_anim_commands.md)
- **Music commands**: Music composition (see docs/music_commands.md)

## Style Guide (STYLE.md)

### Comments

- Use tabs for indentation, spaces for alignment
- Comments lead with space after semicolon
- 80 char soft limit (not enforced)
- Capitalization/punctuation don't matter but be consistent
- Comments go above code, not inline or below
- Use two newlines to separate paragraphs

### Labels

- ROM labels: `PascalCase:` (local), `PascalCase::` (global)
- Local jumps: `.snake_case`
- RAM labels: `wPascalCase` (WRAM), `sPascalCase` (SRAM), `vPascalCase` (VRAM), `hPascalCase` (HRAM)
- Hardware registers: `rName` (e.g., `rBGP`)
- Constants: `UPPER_CASE`
- Align related constant definitions

### Directives

- Meta directives uppercase: `SECTION`, `INCLUDE`, `INCBIN`, `MACRO`/`ENDM`, `DEF`, `PURGE`
- Data macros lowercase: `db`, `dw`, `RGB`
- Code macros lowercase: `farcall`, `callfar`, `predef`, etc.

### Macros

- Lowercase macro names preferred (unless acronyms)
- Only `shift` when required or more readable
- See STYLE.md for detailed macro conventions

## Graphics

### Image Formats

- Most `.png` files are paletted PNGs with exactly 4 colors
- Pokemon images: first color white, last color black
- Some `.png` files are grayscale (share palettes with other graphics)
- `.2bpp` and `.1bpp` files contain tile data, generated from `.png`
- `.gbcpal` files contain Game Boy Color palette data
- Use tools like Paint, GIMP, GraphicsGale that properly support paletted PNGs

### Graphics Pipeline

The Makefile contains extensive rules for converting PNG graphics to Game Boy tile data:
1. `.png` -> `.2bpp`/`.1bpp` (via `rgbgfx` tool)
2. `.png` -> `.gbcpal` (palette extraction)
3. Pokemon pics have special animation processing via `tools/pokemon_animation_graphics` and `tools/pokemon_animation`
4. Various graphics use tools/gfx for deduplication, whitespace removal, etc.

### Compression

Some graphics use LZ compression (`.lz` files). Rules are in `gfx/lz.mk` for matching original compression.

## Version Control

- Main branch: `master`
- The project aims for byte-perfect matching with original ROMs
- `make compare` verifies your build matches checksums in `roms.sha1`

## Documentation

Extensive documentation in `docs/`:
- Event scripting: docs/event_commands.md
- Map scripts: docs/map_event_scripts.md
- Map setup: docs/map_setup_scripts.md
- Text formatting: docs/text_commands.md
- Movement: docs/movement_commands.md
- Battle effects: docs/move_effect_commands.md
- Battle animations: docs/battle_anim_commands.md
- Music: docs/music_commands.md
- Bug documentation: docs/bugs_and_glitches.md, docs/design_flaws.md

Additional resources:
- Online docs: https://pret.github.io/pokecrystal/
- Wiki (tutorials): https://github.com/pret/pokecrystal/wiki
- Symbols database: https://github.com/pret/pokecrystal/tree/symbols
- Discord: #pokecrystal on pret Discord server

## Common Issues

### RGBDS Version

This project requires **rgbds 1.0.0 or newer**. Errors like "UNION already defined", "Macro not defined", or "Expression must be 8-bit" indicate an outdated rgbds version.

### Section Size Errors

"Section is too big" or "Unable to place section in bank" means code doesn't fit in the allocated 4KB bank. Solutions:
1. Move some code to a new SECTION
2. Reorganize existing sections in layout.link
3. Optimize code size

### Build Errors After Changes

Run `make clean` to remove stale object files, then rebuild.

## Assembly Programming

This is Z80-style Game Boy assembly. Key concepts:
- 8-bit CPU with 8-bit registers (a, b, c, d, e, h, l) and 16-bit pairs (bc, de, hl)
- Memory-mapped I/O for graphics, sound, input
- Banking system for accessing >32KB ROM
- `farcall` macro for cross-bank function calls
- `predef` macro for calling predefined functions by ID

Resources:
- Assembly tutorial: https://github.com/pret/pokecrystal/wiki/Assembly-programming
- GB ASM tutorial: https://eldred.fr/gb-asm-tutorial/
- Pan Docs (hardware reference): https://gbdev.io/pandocs/

## Working with This Codebase

When modifying code:
1. Read existing code first before proposing changes
2. Follow STYLE.md conventions
3. Test builds with `make` after changes
4. Use `make compare` to verify you haven't broken matching (if that's a goal)
5. Check docs/ for relevant documentation on game systems
6. Understand the banking system when adding new code
7. Remember this is assembly - changes can have subtle effects on ROM layout

Map editing:
- Use Polished Map tool for `.blk` layout files
- Scripts are in `maps/` directory as `.asm` files
- See docs/map_event_scripts.md for scripting reference

Version-specific builds:
- `_CRYSTAL11` is defined for v1.1 builds
- `_CRYSTAL_AU` is defined for Australian builds
- `_DEBUG` is defined for debug builds
- Use `if DEF(_CRYSTAL11)` conditionals for version-specific code
