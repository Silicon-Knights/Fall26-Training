# Lecture 8: Mini Convolution Accelerator

Build a simple image-processing hardware accelerator in Verilog!

We'll use a Multiply-and-Accumulate (MAC) unit and a Finite State Machine (FSM) to apply two 3x3 image filters:

- **Gaussian Blur:** Smooths an image.
- **Sobel Edge Detection:** Highlights vertical edges.

No FPGA board is required. We'll simulate our hardware using Icarus Verilog.

## Project Files

| File | Purpose |
|---|---|
| `mac.v` | Multiplies pixel values by weights and accumulates results |
| `conv_controller.v` | FSM controlling the nine MAC operations |
| `conv3x3.v` | Connects the MAC and controller |
| `blur_tb.v` | Gaussian blur testbench |
| `edge_tb.v` | Sobel edge detection testbench |
| `image_tools.py` | Converts images into memory files and displays results |
| `sample_image.png` | Sample image for testing |

## 1. Setup

### Windows (WSL) / Ubuntu Linux

```bash
sudo apt update
sudo apt install -y iverilog python3 python3-pil
```

### macOS

```bash
brew install icarus-verilog python
python3 -m pip install pillow
```

Check your installation:

```bash
iverilog -V
python3 --version
```

## 2. Download the Workshop

```bash
git clone https://github.com/Silicon-Knights/Fall26-Training.git
cd Fall26-Training/lectures/lec8
```

## 3. Prepare an Image

Use the provided image:

```bash
python3 image_tools.py prepare sample_image.png
```

Or place your own PNG/JPG/JPEG image in this folder:

```bash
python3 image_tools.py prepare my_image.jpg
```

The script converts the image to 128x128 grayscale pixels and creates `input_image.mem`.

## 4. Gaussian Blur

Compile:

```bash
iverilog -g2012 -s blur_tb -o blur_sim \
    mac.v conv_controller.v conv3x3.v blur_tb.v
```

Simulate:

```bash
vvp blur_sim
```

## 5. Sobel Edge Detection

Compile:

```bash
iverilog -g2012 -s edge_tb -o edge_sim \
    mac.v conv_controller.v conv3x3.v edge_tb.v
```

Simulate:

```bash
vvp edge_sim
```

## 6. View and Verify Results

```bash
python3 image_tools.py check
```

This generates:

- `input_preview.png` - Grayscale input
- `blur_output.png` - Blurred image
- `edge_output.png` - Edge-detected image

A successful simulation should report:

```text
blur: 0 mismatched pixels / 15876 PASS
edge: 0 mismatched pixels / 15876 PASS
```

The output images are 126x126 because the 3x3 filter uses no padding.

### Open Images in WSL

```bash
explorer.exe .
```

## 7. How It Works

**MAC:** Performs multiplication and accumulation:

    total = total + pixel * weight

**FSM:** Controls the nine operations:

- IDLE: Wait for a new window
- RUN: Process pixels 0 through 8
- DONE: Output is ready

**Convolution Module:** Connects the MAC and FSM and selects the filter weights.

**Testbench:** Slides a 3x3 window across the input image and records each output pixel.

## 8. Connection to ML

Convolution is a fundamental operation used in Convolutional Neural Networks (CNNs).

Real AI accelerators use many MAC units operating in parallel. Our accelerator uses one MAC over nine clock cycles to calculate each output pixel.

