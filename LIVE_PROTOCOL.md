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
The browser renders at 3× resolution, 960 × 192 pixels. Each lane starts with
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

A physical LCD/camera/iPhone test remains necessary. Manual cropping, sufficient
focus, and a level view are required. There is no perspective correction or
forward error correction. Display/camera refresh interference, focus, packet
loss, or background timer throttling can produce silence or gaps. A desktop
screen sender is provided; the calculator sender remains unchanged.
