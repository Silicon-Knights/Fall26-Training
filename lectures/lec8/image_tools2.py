
"""Image tools for the convolution accelerator workshop.

No pip or Pillow required on Windows/WSL.

Usage:
    python3 image_tools.py prepare my_photo.jpg
    python3 image_tools.py show
    python3 image_tools.py check
"""

from pathlib import Path
import base64
import shutil
import struct
import subprocess
import sys
import zlib

BASE = Path(__file__).resolve().parent
SIZE = 128

WEIGHTS_BLUR = [1, 2, 1, 2, 4, 2, 1, 2, 1]
WEIGHTS_EDGE = [-1, 0, 1, -2, 0, 2, -1, 0, 1]


def save_png(path, pixels, width, height):
    # Write an 8-bit grayscale PNG using standard Python.
    def chunk(name, data):
        body = name + data
        return (struct.pack(">I", len(data)) + body
                + struct.pack(">I", zlib.crc32(body) & 0xffffffff))

    raw = b"".join(
        b"\x00" + bytes(pixels[y*width:(y+1)*width])
        for y in range(height)
    )

    header = struct.pack(">IIBBBBB", width, height, 8, 0, 0, 0, 0)

    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw))
        + chunk(b"IEND", b"")
    )

    path.write_bytes(png)


def load_image(path):
    # Windows handles JPG/PNG decoding and resizing.
    # Python receives only the 128x128 grayscale pixel data.
    image_path = Path(path).resolve()

    if not image_path.is_file():
        raise FileNotFoundError(f"Image not found: {image_path}")

    if shutil.which("wslpath"):
        image_path = subprocess.check_output(
            ["wslpath", "-w", str(image_path)], text=True
        ).strip()

    powershell = shutil.which("powershell.exe") or shutil.which("powershell")

    if not powershell:
        raise RuntimeError(
            "Windows PowerShell is required for image loading. "
            "Run this script in Windows or WSL."
        )

    # Base64-encode the path so special characters are handled safely.
    encoded_path = base64.b64encode(
        str(image_path).encode("utf-8")
    ).decode("ascii")

    script = r"""
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$path = [Text.Encoding]::UTF8.GetString(
    [Convert]::FromBase64String('PATH_TOKEN')
)

$source = [System.Drawing.Bitmap]::new($path)
$small = [System.Drawing.Bitmap]::new(128, 128)
$graphics = [System.Drawing.Graphics]::FromImage($small)

try {
    $graphics.InterpolationMode =
        [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear

    $graphics.DrawImage($source, 0, 0, 128, 128)

    $pixels = [byte[]]::new(128 * 128)

    for ($y = 0; $y -lt 128; $y++) {
        for ($x = 0; $x -lt 128; $x++) {
            $color = $small.GetPixel($x, $y)

            $gray = [Math]::Round(
                0.299 * $color.R +
                0.587 * $color.G +
                0.114 * $color.B
            )

            $pixels[$y * 128 + $x] = [byte]$gray
        }
    }

    [Console]::Write([Convert]::ToBase64String($pixels))
}
finally {
    $graphics.Dispose()
    $small.Dispose()
    $source.Dispose()
}
""".replace("PATH_TOKEN", encoded_path)

    command = base64.b64encode(
        script.encode("utf-16le")
    ).decode("ascii")

    result = subprocess.run(
        [powershell, "-NoProfile", "-NonInteractive",
         "-EncodedCommand", command],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        raise RuntimeError(
            "Could not load image:\n" + result.stderr
        )

    pixels = list(base64.b64decode(result.stdout.strip()))

    if len(pixels) != SIZE * SIZE:
        raise ValueError("Image conversion returned incorrect pixel count")

    return pixels


def prepare(path):
    if not path:
        raise SystemExit("Usage: python3 image_tools.py prepare image.jpg")

    pixels = load_image(path)

    save_png(BASE / "input_preview.png", pixels, SIZE, SIZE)

    with open(BASE / "input_image.mem", "w") as f:
        for pixel in pixels:
            f.write(f"{pixel:02x}\n")

    print(f"Prepared input_image.mem and input_preview.png ({SIZE}x{SIZE})")


def read_input():
    path = BASE / "input_image.mem"

    if not path.exists():
        raise FileNotFoundError(
            "Run 'prepare' before checking results."
        )

    pixels = [int(v, 16) for v in path.read_text().split()]

    if len(pixels) != SIZE * SIZE:
        raise ValueError("Incorrect input_image.mem size")

    return pixels


def reference(mode):
    pixels = read_input()
    weights = WEIGHTS_BLUR if mode == "blur" else WEIGHTS_EDGE
    output = []

    for row in range(SIZE - 2):
        for col in range(SIZE - 2):
            total = 0

            for k in range(9):
                pixel_row = row + k // 3
                pixel_col = col + k % 3

                total += (
                    pixels[pixel_row * SIZE + pixel_col]
                    * weights[k]
                )

            if mode == "blur":
                value = total // 16
            else:
                value = abs(total) // 4

            output.append(max(0, min(255, value)))

    return output


def show(check=False):
    output_size = SIZE - 2

    for mode in ("blur", "edge"):
        path = BASE / f"{mode}_output.mem"

        if not path.exists():
            print(f"Missing {path.name}. Run the Verilog simulation first.")
            continue

        nums = [int(v, 16) for v in path.read_text().split()]

        if len(nums) != output_size ** 2:
            raise ValueError(
                f"{path.name}: expected {output_size**2} pixels, "
                f"found {len(nums)}"
            )

        # Resize to 504x504 using nearest-neighbor scaling.
        scale = 4
        enlarged = []

        for row in range(output_size):
            expanded_row = []

            for value in nums[row*output_size:(row+1)*output_size]:
                expanded_row.extend([value] * scale)

            for _ in range(scale):
                enlarged.extend(expanded_row)

        save_png(
            BASE / f"{mode}_output.png",
            enlarged,
            output_size * scale,
            output_size * scale
        )

        print(f"Saved {mode}_output.png")

        if check:
            expected = reference(mode)
            mismatches = sum(a != b for a, b in zip(nums, expected))

            status = "PASS" if mismatches == 0 else "FAIL"

            print(
                f"{mode}: {mismatches} mismatched pixels "
                f"/ {output_size**2} {status}"
            )


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "prepare"

    if cmd == "prepare":
        prepare(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "show":
        show()
    elif cmd == "check":
        show(check=True)
    else:
        raise SystemExit("Usage: prepare [image], show, or check")
