# DVC2 six-color optical file transport

The `/optical` experiment transfers the actual MP3 bytes, rather than an ID
that selects a recording on the receiver. It is separate from the original
Doom84s binary event protocol. The calculator sender has not been changed.

## Display

Canonical geometry: 320 × 24 pixels, 40 columns × 6 lanes, each cell 8 × 4
pixels. The web sender renders at 3× resolution and scales with the page.

Symbol values: 0=red, 1=green, 2=blue, 3=yellow, 4=white, 5=black.
Each lane begins with symbols 0,1,2,3,4,5 as calibration pilots. The remaining
34 cells in each lane contain data, read left to right, then top to bottom.
The receiver averages cell centers, learns RGB references from each lane's
pilots, rejects indistinguishable references and ambiguous colors, then checks
packet CRC. Cropping is manual; rotation and perspective are not corrected.

## Byte packing

Every 4 bytes interpreted as a little-endian unsigned 32-bit integer become
13 base-six digits, least significant digit first. Fifteen groups occupy
195 data cells and encode 60 bytes. The last 9 available cells are black
padding. Base-six values outside the uint32 range are rejected.

## Packet (60 bytes)

| Offset | Length | Meaning |
| --- | --- | --- |
| 0 | 4 | ASCII DVC2 |
| 4 | 4 | File ID: CRC-32 of entire file, little endian |
| 8 | 4 | Byte offset, little endian, multiple of 40 |
| 12 | 4 | Total file byte length, little endian |
| 16 | 40 | Arbitrary payload; zero-pad final packet |
| 56 | 4 | CRC-32 over bytes 0–55, little endian |

CRC uses reflected IEEE polynomial 0xedb88320, initial state 0xffffffff,
final XOR 0xffffffff. CRC detects accidental corruption, not malicious input.

Receiver accepts packets in any order, discards duplicate offsets, and checks
file size and identity. It verifies the complete file CRC before creating a
local Blob for native audio playback. It never fetches the sample. Audio is
played by an explicit tap on native media controls, including on iPhone.

The sender repeats the entire file; missing packets can arrive on later passes.
There is no forward error correction or optical acknowledgement yet. This is
buffered file transfer, not real-time audio streaming.

## Sample and capacity

The first 30 seconds of the supplied MP3 were transcoded to mono MP3 at 16 kHz,
16 kbps. This intentionally reduces fidelity. The 60,417-byte result requires
1,511 packets. At 8 packets/second a perfect first pass takes 188.875 seconds
(3 minutes 9 seconds); losses need additional passes. At 2 packets/second it
takes 12 minutes 36 seconds. Raising speed reduces capture reliability.

`npm run test:color` passes the entire sample through the compiled Rust encoder,
synthetic RGB pixels, the compiled Rust color decoder, and the same TypeScript
assembler as the receiver. It verifies byte-for-byte equality and SHA-256.
It also tests all 256 byte values, three scales, color tint, corruption, invalid
ROIs, duplicates, and shuffled order. Synthetic tests do not verify camera
focus, LCD refresh, rolling shutter, or iPhone speaker output.

The actual MP3 decoder yields 480,000 mono samples at 16 kHz: exactly 30 seconds.
MP3 container duration may include encoder delay/padding.
