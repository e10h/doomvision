# DVS3 live optical audio

`/optical` plays independently decoded audio blocks as camera packets arrive.
The previous MP3 file-transfer experiment remains at `/optical/file`.

The first 30 seconds of the user-supplied recording were resampled to 4 kHz
mono signed 16-bit PCM, then encoded by Rust into 240 independent IMA ADPCM
blocks. Each block contains 500 audio samples (125 ms). This is low-fidelity
actual waveform data, not an instruction to play a recording stored on the
receiver. The receiver fetches only its code/WASM, never the sample.

## Optical grid

Canonical strip: 320 × 64 pixels, 80 columns × 16 lanes, 4 × 4-pixel cells.
The data grid is surrounded by four alignment finders and colored orientation
dots in a 384 × 128 white panel; the browser renders it at 3× resolution,
1152 × 384 pixels. Each lane starts with
six calibration cells: red, green, blue, yellow, white, black (values 0–5).
The remaining 74 cells carry base-six digits, read across lanes. Every 4 bytes
become 13 base-six digits, least significant first, as in DVC2. 91 groups
encode 364 bytes; the final unused cell is black. The taller strip is needed
for live audio bandwidth. This has not yet been integrated into the calculator.

## Packet layout (364 bytes)

| Offset | Bytes | Meaning |
| --- | --- | --- |
| 0 | 4 | ASCII DVS3 |
| 4 | 4 | Stream identifier, little endian |
| 8 | 4 | Block index, little endian |
| 12 | 4 | Total block count, little endian |
| 16 | 4 | Sample rate: 4000 Hz, little endian |
| 20 | 2 | Sample count: 500, little endian |
| 22 | 2 | Initial signed 16-bit predictor, little endian |
| 24 | 1 | Initial IMA step index (0–88) |
| 25 | 1 | Reserved, zero |
| 26 | 250 | 500 ADPCM codes, low nibble first |
| 276 | 84 | Reserved, zero |
| 360 | 4 | IEEE CRC-32 over bytes 0–359, little endian |

Each block is independent. Rust verifies CRC and audio bounds before decoding.
The sender emits 8 packets/second, repeats every 30 seconds, and is silent.
A receiver may join anywhere in the stream. Playback uses a 250 ms initial
jitter allowance and schedules each block at its source timeline offset. It
never waits for all 240 blocks. Duplicates do not replay; missing or late
blocks become gaps. A large backwards index transition starts the next pass.

For Web Audio compatibility, decoded 4 kHz PCM is linearly resampled to a
16 kHz AudioBuffer. iOS requests a playback audio session and unlocks/resumes
AudioContext from the Start/Enable tap. A separate test beep checks speakers
without claiming to have received a packet.

## Validation and limitations

`npm run test:live` round-trips all 240 blocks through actual Rust color encode,
synthetic pixels, Rust color decode, and Rust audio decode. It tests two scales,
color shifts, CRC failure, crop bounds, timing, duplicates, missing/late blocks,
loop transitions, and interrupted audio recovery. `scripts/pack-live.mjs` can
regenerate the DVS file from 4 kHz PCM and reports compression SNR. The current
sample achieves 18.3 dB relative to its downsampled source; bandwidth above
2 kHz was removed during resampling.

## Alignment and auto-lock

Auto-lock is on by default. Each corner finder is a 7-module square: black
outer ring, white inner ring, and a black 3 × 3 center. Four finder centers
are at (16,16), (368,16), (368,112), and (16,112). Modules are 4 pixels.
Red, green, blue, and yellow orientation dots (6 × 6 pixels) are centered at
(16,36), (368,36), (368,92), and (16,92). The grid starts at (32,32).

Rust searches horizontal 1:1:3:1:1 runs and cross-checks them vertically,
clusters repeated observations, and tests four-finder combinations. Colored
dots determine orientation, including mirrored views. A projective transform
maps finder positions to the known layout. Rust resamples the data grid to
640 × 128 pixels with bilinear interpolation before color decoding. Geometry
is re-estimated on each processed camera frame; stale locks are not retained.
This is deterministic computer vision, not a neural model.

The UI distinguishes searching for markers, orientation ambiguity, geometry
lock, calibration/color ambiguity, symbol/header failures, and CRC failure.
Manual crop remains a fallback and must exclude the border and markers.
`npm run test:alignment` exercises actual WASM detection, rectification and
packet decoding with rotation, perspective, mirroring, color shifts, and mild
blur/noise, and verifies that an occluded marker or blank scene cannot lock.
The finder geometry follows the common QR-style finder proportions; this is
not a QR payload and uses its own detector and transport.

A physical LCD/camera/iPhone test remains necessary. All four markers must be
visible and in focus. Severe blur, extreme perspective, and lens distortion
can still prevent decoding. There is no forward error correction. Display/camera refresh interference, focus, packet
loss, or background timer throttling can produce silence or gaps. A desktop
screen sender is provided; the calculator sender remains unchanged.
