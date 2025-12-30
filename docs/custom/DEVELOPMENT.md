# Development Workflow

This guide explains how to build, test, and iterate on the Nono Edition ROM.

## Prerequisites

### Required Tools

1. **RGBDS 1.0.0+** - Game Boy assembler toolchain
   ```bash
   brew install rgbds
   ```

2. **SameBoy** - Game Boy emulator (native macOS app)
   ```bash
   brew install --cask sameboy
   ```

3. **Build tools** - make, gcc (should already be installed on macOS)
   ```bash
   xcode-select --install  # if needed
   ```

## Quick Start

### Build and Run

The fastest way to test your changes:

```bash
make run
```

This will:
1. Build `pokecrystal.gbc` (v1.0)
2. Launch it in SameBoy emulator
3. Show build errors if any

### Build Debug Version and Run

For debugging with symbols:

```bash
make run-debug
```

This builds `pokecrystal_debug.gbc` with the `_DEBUG` flag enabled.

### Clean Rebuild

If you're getting weird errors or want a fresh build:

```bash
make rebuild
```

This runs `make clean && make` to remove all generated files and rebuild from scratch.

## Development Workflow

### Typical Iteration Cycle

1. **Make Changes** - Edit assembly files, graphics, data, etc.
2. **Build & Test** - `make run` to build and launch in emulator
3. **Test in Emulator** - SameBoy will open with your ROM loaded
4. **Iterate** - Make more changes and repeat

### Testing Checklist

When implementing a feature:
- [ ] Build succeeds with no errors
- [ ] ROM runs in SameBoy without crashes
- [ ] Feature works as intended
- [ ] No regressions in existing features
- [ ] Graphics display correctly (if applicable)
- [ ] Text displays correctly (if applicable)

### Debugging Tips

**Build Errors**:
- Read error messages carefully - they show file and line numbers
- "Section is too big" means you need to reorganize code into different banks
- Run `make clean` if you get mysterious errors

**Runtime Issues**:
- Use the debug build: `make run-debug`
- Check the symbol file: `pokecrystal_debug.sym` maps addresses to labels
- Use SameBoy's debugger (console tab) to inspect memory

**Graphics Issues**:
- Graphics are generated from PNG files in `gfx/`
- Ensure PNGs are paletted (4 colors max for most graphics)
- Run `make clean` to regenerate all graphics

## Build Targets Reference

### Standard Builds
```bash
make                 # Build pokecrystal.gbc (v1.0)
make crystal11       # Build pokecrystal11.gbc (v1.1)
make crystal_debug   # Build debug version
```

### Custom Development Targets
```bash
make run             # Build and launch in SameBoy
make run-debug       # Build debug version and launch
make dev             # Alias for 'make run'
make rebuild         # Clean and rebuild
make help            # Show available targets
```

### Cleaning
```bash
make tidy            # Remove ROMs and object files
make clean           # Remove all generated files (graphics too)
```

### Verification
```bash
make compare         # Verify ROM matches original checksums
                     # (Will fail for custom ROM - that's expected!)
```

## SameBoy Emulator

### Controls
- Arrow keys: D-pad
- Z: A button
- X: B button
- Enter: Start
- Shift: Select

### Useful Features
- Save states: File > Save State (Cmd+S)
- Load states: File > Load State (Cmd+L)
- Reset: Emulation > Reset (Cmd+R)
- Console debugger: View > Console
- Memory viewer: View > Memory Viewer

### Settings
Access Preferences with Cmd+, to configure:
- Display filters and scaling
- Frame blending for smoother animation
- Color correction (Game Boy Color palette)
- Save file location

## File Organization

### Source Code
- `main.asm` - Top-level file, includes all code
- `home/` - Core routines (bank 0)
- `engine/` - Game systems (battle, overworld, menus, etc.)
- `data/` - Game data (Pokemon stats, moves, trainers, maps)
- `maps/` - Map scripts and events
- `constants/` - Assembly constants
- `macros/` - Assembly macros

### Graphics
- `gfx/` - Graphics source files (PNG) and generated files
- `gfx/pokemon/` - Pokemon sprites
- `gfx/trainers/` - Trainer sprites
- `gfx/tilesets/` - Map tilesets

### Audio
- `audio/` - Music and sound effects

### Tools
- `tools/` - C programs for processing graphics, compression, etc.
- Built automatically when needed

## Common Issues

### "SameBoy not found"
Install with Homebrew:
```bash
brew install --cask sameboy
```

Or download from: https://sameboy.github.io/

### "rgbasm: command not found"
Install RGBDS:
```bash
brew install rgbds
```

### "Section is too big"
Your code doesn't fit in the allocated 4KB bank. Solutions:
1. Move some code to a new SECTION
2. Reorganize sections in `layout.link`
3. Optimize code size

### Build Errors After Pulling Updates
Clean and rebuild:
```bash
make rebuild
```

## Resources

- **CLAUDE.md** - AI assistant guide (in repository root)
- **STYLE.md** - Code style conventions
- **Official docs** - `docs/` directory has detailed documentation
- **Tutorial wiki** - https://github.com/pret/pokecrystal/wiki/Tutorials
