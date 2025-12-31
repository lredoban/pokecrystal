# AI Image Generation Prompts for Fakemon Sprites

## What You Need to Provide Me

For each Pokemon, you only need to give me:

1. **Front sprite PNG** (from AI generation)
2. **Back sprite PNG** (from AI generation)
3. **Footprint PNG** (from AI generation)
4. **Shiny color description** (just tell me: "shiny version should be gold and purple" or similar)
5. **Pokemon data** (name, stats, types, moves - can be text)

**I will create for you:**
- All `.asm` animation files (these are code files, not images)
- Shiny palette `.pal` file (I create this from your color description)
- All the integration code

---

## Prompt Templates for AI Image Generator

**Note:** Upload your Pokemon reference image (card/artwork) to the AI before using these prompts.

### 1. Front Sprite Prompt

**For the AI (upload your Pokemon image first, then use this prompt):**

```
Convert this Pokemon into a Generation 2 (Pokemon Crystal) front battle sprite:

Requirements:
- 56x56 pixels maximum
- 3/4 view perspective (standard Pokemon front-facing battle pose)
- Exactly 4 colors: white background, black outline, and 2 shades of the main color
- Paletted/indexed color mode
- Simple shading, clear silhouette
- Game Boy Color pixel art style

Style: Generation 2 Pokemon (Gold/Silver/Crystal era), pixelated, simple shading, like Cyndaquil/Totodile/Chikorita sprites from Pokemon Crystal.

Keep the design recognizable from the reference image but simplified for Game Boy limitations.
```

---

### 2. Back Sprite Prompt

**For the AI (upload your Pokemon image first, then use this prompt):**

```
Convert this Pokemon into a Generation 2 (Pokemon Crystal) back battle sprite:

Requirements:
- 56x56 pixels maximum
- Rear view, slightly elevated perspective (as seen from behind in battle)
- Same 4-color palette as would be used for the front sprite
- Shows the back/rear view of this Pokemon
- Simple shading, clear silhouette
- Game Boy Color pixel art style

Style: Generation 2 Pokemon (Gold/Silver/Crystal era), pixelated, like the back sprites in Pokemon Crystal battles.

Show this Pokemon from behind, keeping the same design and colors from the reference image.
```

---

### 3. Footprint Prompt

**For the AI (upload your Pokemon image first, then use this prompt):**

```
Create a footprint icon for this Pokemon:

Requirements:
- 16x16 pixels
- Only 2 colors: black silhouette on white background
- Bottom view showing where this Pokemon's feet/body touches the ground
- Simple, iconic silhouette (like a pawprint or foot shape)
- Based on this Pokemon's body type and size

Style: Simple, minimal, black silhouette, Game Boy style, like Pokedex footprints in Pokemon Crystal.

Look at the Pokemon's design and create an appropriate footprint (paws, claws, feet, or body contact points).
```

---

## How to Use These Prompts

### Step-by-Step Process:

1. **Upload your Pokemon reference image** (card/artwork) to nano-banana
2. **Copy and paste Prompt #1** to generate the front sprite
3. **Save the front sprite PNG**
4. **Upload the same reference image again**
5. **Copy and paste Prompt #2** to generate the back sprite
6. **Save the back sprite PNG**
7. **Upload the same reference image again**
8. **Copy and paste Prompt #3** to generate the footprint
9. **Save the footprint PNG**
10. **Give me all 3 PNG files** and I'll handle the rest!

---

## What About Shiny Colors?

**You don't need to generate a shiny image!** Just tell me the colors you want for the shiny version.

**Examples:**
- "Shiny version should be gold instead of orange"
- "Shiny should be purple and pink instead of blue"
- "Shiny should use green tones instead of red"

I'll create the `.pal` file from your description. The shiny palette file is just a text file with RGB color values - I create this, you just describe the colors!

---

## What About Animation Files?

**You don't need to create animation files!** The `.asm` animation files are code files that I write.

They just tell the game: "show frame 0 for 10 ticks, then frame 1 for 10 ticks, repeat"

**Simple approach (recommended):**
- Just give me the front and back sprites
- I'll create a basic animation that works automatically

**Advanced (optional):**
- If you want custom animation, you can generate 2-3 variations of the front sprite showing slight movement (head tilt, bounce, etc.)
- Upload these as "frame 0", "frame 1", "frame 2" and I'll use them

---

## Summary: What to Give Me

For each of your 9 Pokemon:

### Required (3 images from AI):
1. **Front sprite PNG** - Use Prompt #1 with your Pokemon image
2. **Back sprite PNG** - Use Prompt #2 with your Pokemon image
3. **Footprint PNG** - Use Prompt #3 with your Pokemon image

### Required (text/data you tell me):
4. **Pokemon name** - e.g., "Flamark"
5. **Types** - e.g., "FIRE" or "FIRE/FLYING"
6. **Stats** - HP, Attack, Defense, Speed, Special Attack, Special Defense
7. **Evolution info** - "Evolves at level 16 into [NAME]"
8. **Shiny colors** - "Shiny should be gold and blue"
9. **Moves** - What moves it learns at which levels

### I will create:
- All `.asm` animation files (code)
- Shiny palette `.pal` file (code)
- All integration into the game (code)
- Everything else needed!

---

## Tips for Better AI Results

- **If the AI doesn't get the palette right:** Ask it to "use exactly 4 colors: white, black, [light color], [dark color]"
- **If the sprite is too detailed:** Ask it to "simplify, use Game Boy limitations, more pixelated"
- **If the size is wrong:** Ask it to "make the Pokemon smaller, leave more white space around it"
- **Reference specific Pokemon:** "Make it similar to Cyndaquil's sprite style" or "like Totodile but [your design]"

---

## Step 4: Convert AI-Generated PNGs to GBC Format

**Important!** AI tools (nano-banana, Figma, etc.) often export PNGs in the wrong format for Game Boy Color. The build system requires **exactly 4 colors in paletted mode**.

### The Problem

AI/Figma exports usually have:
- ❌ Too many colors (8, 16, 256+)
- ❌ Wrong color mode (RGB/RGBA instead of indexed/paletted)
- ❌ Wrong palette ordering (not white→light→dark→black)

### The Solution: Conversion Tool

We provide a CLI tool that automatically converts any PNG to the correct format:

```bash
tools/convert_gbc.sh --type=pokemon input.png output.png
```

### Complete Workflow

After generating sprites with nano-banana:

```bash
# 1. Convert front sprite
tools/convert_gbc.sh --type=pokemon \
  raw/mypokemon-front.png \
  gfx/pokemon/mypokemon/front.png

# 2. Convert back sprite
tools/convert_gbc.sh --type=pokemon \
  raw/mypokemon-back.png \
  gfx/pokemon/mypokemon/back.png

# 3. Convert footprint
tools/convert_gbc.sh --type=footprint \
  raw/mypokemon-footprint.png \
  gfx/footprints/mypokemon.png

# 4. Build the ROM
make
```

### What the Tool Does Automatically

✅ Reduces to exactly 4 colors (or 2 for footprints)
✅ Removes transparency (converts to white background)
✅ Converts to indexed/paletted PNG format
✅ Ensures white is first color, black is last color
✅ Sorts middle colors by luminance
✅ Validates the output format

### Installation (One-Time Setup)

```bash
# Install dependencies
brew install pngquant imagemagick
pip3 install Pillow
```

### For More Details

See the complete [Graphics Conversion Guide](graphics-conversion.md) for:
- Detailed usage examples
- Troubleshooting tips
- Technical specifications
- Alternative workflows

---
