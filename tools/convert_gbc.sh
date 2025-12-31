#!/usr/bin/env bash
#
# convert_gbc.sh - Game Boy Color PNG Converter
# Converts any PNG to GBC-compatible format (4-color paletted PNG)
#
# Usage:
#   convert_gbc.sh input.png output.png
#   convert_gbc.sh --type=pokemon input.png output.png
#   convert_gbc.sh --type=footprint input.png output.png
#   convert_gbc.sh --type=title input.png output.png
#   convert_gbc.sh --reverse input.png output.png  # reverse palette order
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
TYPE="pokemon"
REVERSE=false
BATCH=false

# Print functions
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo "ℹ $1"
}

# Show usage
usage() {
    cat <<EOF
Game Boy Color PNG Converter

Usage:
  $(basename "$0") [OPTIONS] INPUT OUTPUT

Arguments:
  INPUT    Input PNG file (any format)
  OUTPUT   Output PNG file (GBC-compatible format)

Options:
  --type=TYPE     Conversion type: pokemon, footprint, title (default: pokemon)
  --reverse       Reverse palette order (darkest to lightest)
  --batch         Batch mode: INPUT is a directory pattern
  -h, --help      Show this help message

Examples:
  # Convert Pokemon sprite
  $(basename "$0") --type=pokemon raw/sprite.png gfx/pokemon/mypokemon/front.png

  # Convert footprint
  $(basename "$0") --type=footprint raw/footprint.png gfx/footprints/mypokemon.png

  # Convert with reversed palette
  $(basename "$0") --type=pokemon --reverse raw/sprite.png output.png

Dependencies:
  - pngquant (install: brew install pngquant)
  - ImageMagick (install: brew install imagemagick)
  - Python 3 with Pillow (install: pip3 install Pillow)

EOF
    exit 0
}

# Check dependencies
check_dependencies() {
    local missing=()

    if ! command -v pngquant &> /dev/null; then
        missing+=("pngquant")
    fi

    if ! command -v magick &> /dev/null; then
        missing+=("ImageMagick")
    fi

    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    else
        if ! python3 -c "import PIL" 2>/dev/null; then
            missing+=("python3-pillow")
        fi
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        echo ""
        echo "To install on macOS:"
        for dep in "${missing[@]}"; do
            case "$dep" in
                pngquant)
                    echo "  brew install pngquant"
                    ;;
                ImageMagick)
                    echo "  brew install imagemagick"
                    ;;
                python3)
                    echo "  brew install python3"
                    ;;
                python3-pillow)
                    echo "  pip3 install Pillow"
                    ;;
            esac
        done
        return 1
    fi
    return 0
}

# Validate PNG format
validate_output() {
    local file="$1"
    local expected_colors="$2"

    if [ ! -f "$file" ]; then
        print_error "Output file not created: $file"
        return 1
    fi

    # Check if it's a valid PNG
    if ! file "$file" | grep -q "PNG image data"; then
        print_error "Not a valid PNG file: $file"
        return 1
    fi

    # Check color count using ImageMagick
    local colors
    colors=$(magick identify -format "%k" "$file" 2>/dev/null || echo "unknown")

    if [ "$colors" != "$expected_colors" ]; then
        print_warning "Color count: expected $expected_colors, found $colors"
        # Don't fail, just warn - sometimes close enough is okay
    fi

    # Check color mode
    local colortype
    colortype=$(magick identify -format "%[colorspace]" "$file" 2>/dev/null || echo "unknown")

    print_success "Converted: $file ($colors colors, $colortype)"
    return 0
}

# Convert Pokemon sprite (4 colors, white first, black last)
convert_pokemon() {
    local input="$1"
    local output="$2"
    local reverse="$3"

    local temp1 temp2
    temp1="$(mktemp).png"
    temp2="$(mktemp).png"

    print_info "Converting Pokemon sprite: $input → $output"

    # Stage 1: Resize to max 56x56 and quantize to 4 colors
    print_info "Stage 1/4: Resizing to 56x56 max..."

    # Resize first for better quantization quality
    # Note: 56x56\> means "shrink to fit 56x56 if larger, but don't enlarge"
    # Using -filter point for crisp pixel art (no smoothing/dithering)
    magick "$input" -filter point -resize 56x56\> "$temp1"
    print_success "Resized to fit 56x56"

    print_info "  └─ Quantizing to 4 colors..."
    # Then quantize to 4 colors
    if pngquant --nofs --quality=100-100 --speed 1 --strip 4 \
        "$temp1" --output "$temp1.tmp" 2>/dev/null; then
        mv "$temp1.tmp" "$temp1"
        print_success "Quantization complete"
    else
        print_warning "pngquant failed, falling back to ImageMagick"
        magick "$temp1" -colors 4 +dither "$temp1"
    fi

    # Stage 2: Enforce palette format (indexed, remove alpha)
    print_info "Stage 2/4: Enforcing palette format..."
    magick "$temp1" \
        -background white -alpha remove -alpha off \
        -type Palette -colors 4 +dither \
        -define png:color-type=3 \
        -define png:bit-depth=8 \
        "$temp2"
    print_success "Format enforced"

    # Stage 3: Sort palette and ensure white/black positions
    print_info "Stage 3/4: Sorting palette (white first, black last)..."
    python3 - "$temp2" "$output" "$reverse" <<'PYTHON'
import sys
from PIL import Image

def luminance(rgb):
    """Calculate luminance using standard formula"""
    return 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]

def sort_palette(colors, reverse=False):
    """Sort colors by luminance, ensuring white first and black last"""
    white = (255, 255, 255)
    black = (0, 0, 0)

    # Separate whites, blacks, and midtones
    midtones = [c for c in colors if c not in [white, black]]

    # Sort midtones by luminance
    midtones.sort(key=luminance, reverse=(not reverse))

    # Ensure we have exactly 2 midtones
    while len(midtones) < 2:
        # Fill with gray if needed
        gray_value = 192 if len(midtones) == 0 else 64
        midtones.append((gray_value, gray_value, gray_value))
    midtones = midtones[:2]

    # Build final palette: white, lightest midtone, darkest midtone, black
    if reverse:
        return [white, midtones[1], midtones[0], black]
    else:
        return [white, midtones[0], midtones[1], black]

# Read arguments
input_file = sys.argv[1]
output_file = sys.argv[2]
reverse_mode = sys.argv[3].lower() == 'true'

# Open image
img = Image.open(input_file)

if img.mode != 'P':
    print(f"Warning: Image is not paletted (mode={img.mode}), converting...", file=sys.stderr)
    img = img.convert('P', palette=Image.Palette.ADAPTIVE, colors=4)

# Get current palette
palette = img.getpalette()
if palette is None:
    print("Error: No palette found in image", file=sys.stderr)
    sys.exit(1)

# Extract colors (first 12 bytes = 4 colors × 3 channels)
current_colors = []
for i in range(0, min(12, len(palette)), 3):
    current_colors.append((palette[i], palette[i+1], palette[i+2]))

# Ensure we have exactly 4 colors
while len(current_colors) < 4:
    current_colors.append((128, 128, 128))
current_colors = current_colors[:4]

# Sort palette
new_colors = sort_palette(current_colors, reverse_mode)

# Create mapping from old colors to new indices
color_map = {}
for old_color in current_colors:
    best_match = 0
    best_dist = float('inf')
    for new_idx, new_color in enumerate(new_colors):
        dist = sum((a-b)**2 for a, b in zip(old_color, new_color))
        if dist < best_dist:
            best_dist = dist
            best_match = new_idx
    color_map[old_color] = best_match

# Create new image with sorted palette
new_img = Image.new('P', img.size)
new_palette = [c for color in new_colors for c in color] + [0] * (256*3 - 12)
new_img.putpalette(new_palette)

# Remap pixels using pure PIL (no numpy)
pixels = img.load()
new_pixels = new_img.load()

for y in range(img.size[1]):
    for x in range(img.size[0]):
        old_idx = pixels[x, y]
        if old_idx < len(current_colors):
            old_color = current_colors[old_idx]
            new_idx = color_map[old_color]
            new_pixels[x, y] = new_idx

new_img.save(output_file, optimize=False)

print(f"✓ Palette sorted: {['#%02x%02x%02x' % c for c in new_colors]}", file=sys.stderr)
PYTHON

    # Clean up temp files
    rm -f "$temp1" "$temp2"

    # Stage 4: Validate output
    print_info "Stage 4/4: Validating output format..."
    validate_output "$output" 4
}

# Convert footprint (2 colors, black on white)
convert_footprint() {
    local input="$1"
    local output="$2"

    print_info "Converting footprint: $input → $output"
    print_info "Stage 1/2: Resizing to 16x16..."

    # Resize to 16x16 and convert to 2 colors (black on white)
    magick "$input" \
        -filter point -resize 16x16\> \
        -background white -alpha remove \
        -colorspace Gray -colors 2 +dither \
        -type Bilevel \
        -define png:color-type=0 \
        -define png:bit-depth=2 \
        "$output"

    print_success "Footprint converted and resized to 16x16"

    print_info "Stage 2/2: Validating output..."
    validate_output "$output" 2
}

# Convert title graphic (4-shade grayscale)
convert_title() {
    local input="$1"
    local output="$2"

    print_info "Converting title graphic: $input → $output"

    magick "$input" \
        -colorspace Gray -colors 4 +dither \
        -type Grayscale \
        -define png:bit-depth=8 \
        "$output"

    validate_output "$output" 4
}

# Main conversion function
convert_file() {
    local input="$1"
    local output="$2"

    # Check input exists
    if [ ! -f "$input" ]; then
        print_error "Input file not found: $input"
        return 1
    fi

    # Create output directory if needed
    mkdir -p "$(dirname "$output")"

    # Convert based on type
    case "$TYPE" in
        pokemon)
            convert_pokemon "$input" "$output" "$REVERSE"
            ;;
        footprint)
            convert_footprint "$input" "$output"
            ;;
        title)
            convert_title "$input" "$output"
            ;;
        *)
            print_error "Unknown type: $TYPE"
            return 1
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --type=*)
            TYPE="${1#*=}"
            shift
            ;;
        --reverse)
            REVERSE=true
            shift
            ;;
        --batch)
            BATCH=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# Check for required arguments
if [ $# -lt 2 ]; then
    print_error "Missing required arguments"
    usage
fi

INPUT="$1"
OUTPUT="$2"

# Main execution
main() {
    echo "Game Boy Color PNG Converter"
    echo "----------------------------"

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    # Convert file(s)
    if convert_file "$INPUT" "$OUTPUT"; then
        echo ""
        print_success "Conversion complete!"
        print_info "You can now use this file in your build: make"
    else
        echo ""
        print_error "Conversion failed"
        exit 1
    fi
}

main
