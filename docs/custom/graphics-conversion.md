# Graphics Conversion Tool

This guide explains how to convert graphics from modern tools (Figma, AI generators, etc.) to Game Boy Color compatible format.

## Problem

Game Boy Color graphics require very specific formats:
- **Exactly 4 colors** for most graphics (Pokemon sprites, etc.)
- **Paletted PNG** mode (indexed color), not RGB/RGBA
- **Specific palette ordering**: white first, black last, sorted by luminance

Modern tools like Figma and AI generators (Nano Banana, etc.) export PNGs that don't meet these requirements.

## Solution

We provide `tools/convert_gbc.sh` - a command-line tool that converts any PNG to GBC-compatible format.

---

## Installation

### 1. Install Dependencies

On macOS with Homebrew:

```bash
brew install pngquant imagemagick
pip3 install Pillow
```

**What these do:**
- **pngquant**: Industry-standard color quantization (reduces colors with high quality)
- **ImageMagick**: Image manipulation and palette control
- **Pillow**: Python library for palette sorting

### 2. Verify Installation

```bash
which pngquant
which magick
python3 -c "import PIL; print('Pillow installed')"
```

---

## Usage

### Basic Conversion

```bash
tools/convert_gbc.sh input.png output.png
```

By default, converts to Pokemon sprite format (4 colors, white first, black last).

### Specify Graphic Type

```bash
# Pokemon sprite (4 colors, specific palette)
tools/convert_gbc.sh --type=pokemon input.png output.png

# Footprint (2 colors, black on white)
tools/convert_gbc.sh --type=footprint input.png output.png

# Title screen graphic (4-shade grayscale)
tools/convert_gbc.sh --type=title input.png output.png
```

### Reverse Palette Order

Some Pokemon use reversed palette ordering (darkest to lightest):
- Spearow, Fearow, Farfetch'd, Hitmonlee, Scyther, Jynx, Porygon, Porygon2

```bash
tools/convert_gbc.sh --type=pokemon --reverse input.png output.png
```

---

## Examples

### Converting Pokemon Sprites

From Figma or AI export to GBC format:

```bash
# Front sprite
tools/convert_gbc.sh --type=pokemon \
  raw/exports/mypokemon-front.png \
  gfx/pokemon/mypokemon/front.png

# Back sprite
tools/convert_gbc.sh --type=pokemon \
  raw/exports/mypokemon-back.png \
  gfx/pokemon/mypokemon/back.png
```

### Converting Footprints

```bash
tools/convert_gbc.sh --type=footprint \
  raw/exports/mypokemon-footprint.png \
  gfx/footprints/mypokemon.png
```

### Converting Title Graphics

```bash
tools/convert_gbc.sh --type=title \
  raw/logo-design.png \
  gfx/title/logo.png
```

---

## How It Works

The conversion process has three stages:

### Stage 1: Color Quantization

Uses `pngquant` to reduce the image to exactly 4 colors while maintaining quality:
- Advanced color quantization algorithm (Modified Median Cut + K-means)
- Preserves visual quality even with only 4 colors
- Falls back to ImageMagick if pngquant fails

### Stage 2: Format Enforcement

Uses `ImageMagick` to ensure proper PNG format:
- Converts to paletted/indexed mode (color type 3)
- Removes alpha channel (replaces transparency with white)
- Sets bit depth to 8

### Stage 3: Palette Sorting

Uses `Python + Pillow` to enforce GBC palette requirements:
- Calculates luminance for each color: `L = 0.299*R + 0.587*G + 0.114*B`
- Sorts colors by luminance (lightest to darkest)
- Forces palette[0] = white (255,255,255)
- Forces palette[3] = black (0,0,0)
- Middle 2 positions = sorted midtones
- Remaps all pixels to new palette

---

## Troubleshooting

### "Missing dependencies" Error

**Problem**: Tools not installed

**Solution**:
```bash
brew install pngquant imagemagick
pip3 install Pillow
```

### "Color count: expected 4, found X"

**Problem**: Input image has too many similar colors

**Solutions**:
1. Simplify your design in Figma/AI (use fewer colors)
2. Pre-process with fewer colors: `magick input.png -colors 4 +dither simplified.png`
3. The warning is often harmless - try building anyway

### Output Looks Wrong

**Problem**: Palette ordering incorrect for specific Pokemon

**Solution**: Try `--reverse` flag:
```bash
tools/convert_gbc.sh --type=pokemon --reverse input.png output.png
```

### Transparency Not Working

**Problem**: GBC doesn't support alpha transparency

**Solution**: The script automatically converts transparency to white background. Design with opaque colors instead.

---

## Technical Details

### Game Boy Color Palette Format

**RGB555 Format:**
- 5 bits per channel (Red, Green, Blue)
- Each channel: 0-31 (not 0-255)
- Packed as 16-bit little-endian: `(B << 10) | (G << 5) | R`

**Palette Requirements:**
- Pokemon sprites: 4 colors (white, midtone1, midtone2, black)
- Footprints: 2 colors (white, black)
- Some graphics: 4 grayscale shades

### File Formats

**Input**: Any PNG format (RGB, RGBA, indexed, grayscale)

**Output**:
- Pokemon/Title: PNG color type 3 (indexed), 8-bit, 4 colors
- Footprint: PNG color type 0 (grayscale), 2-bit, 2 colors

### Build Integration

The conversion tool is a **pre-processor** - run it **before** building:

1. Export PNG from Figma/AI (any format)
2. Run `tools/convert_gbc.sh` to convert
3. Run `make` to build ROM

The existing Makefile expects properly formatted PNGs and doesn't need modification.

---

## Workflow Example

Complete workflow for adding a new Pokemon:

```bash
# 1. Export graphics from AI/Figma
# (save to raw/ directory)

# 2. Convert all graphics
tools/convert_gbc.sh --type=pokemon \
  raw/satotoro-front.png \
  gfx/pokemon/satotoro/front.png

tools/convert_gbc.sh --type=pokemon \
  raw/satotoro-back.png \
  gfx/pokemon/satotoro/back.png

tools/convert_gbc.sh --type=footprint \
  raw/satotoro-footprint.png \
  gfx/footprints/satotoro.png

# 3. Build ROM
make

# 4. Test in emulator
open -a SameBoy pokecrystal.gbc
```

---

## Shell Aliases (Optional)

Add to `~/.zshrc` or `~/.bashrc` for convenience:

```bash
# Pokemon sprite conversion
alias gbc-pokemon='tools/convert_gbc.sh --type=pokemon'
alias gbc-footprint='tools/convert_gbc.sh --type=footprint'
alias gbc-title='tools/convert_gbc.sh --type=title'
```

Usage:
```bash
gbc-pokemon raw/sprite.png gfx/pokemon/mypokemon/front.png
```

---

## Alternative Tools

If you prefer GUI tools:

**GIMP** (recommended by FAQ.md):
1. Open PNG in GIMP
2. Image → Mode → Indexed Color
3. Maximum colors: 4
4. Dithering: None
5. Export as PNG

**Cons**: Manual process, harder to ensure exact palette ordering

**Pros**: Visual control, no command line needed

---

## Related Documentation

- [AI Sprite Generation Prompts](AI_SPRITE_PROMPTS.md) - How to generate sprites with AI
- [Adding Fakemon Guide](../plans/) - Complete guide for adding custom Pokemon
- [Custom Changes Manifest](CUSTOM_CHANGES.md) - List of all custom modifications

---

## Getting Help

If you encounter issues:

1. Check dependencies are installed: `tools/convert_gbc.sh --help`
2. Try with `--reverse` flag for palette issues
3. Simplify your design (fewer colors, less detail)
4. Check [pokecrystal FAQ](../FAQ.md) for general graphics issues
5. Ask on pret Discord: #pokecrystal channel

---

*This tool is part of the Nono Edition custom modifications. See [CUSTOM_CHANGES.md](CUSTOM_CHANGES.md) for details.*
