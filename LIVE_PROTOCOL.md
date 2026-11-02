# DVA4: combined captures, error correction, and buffered live audio

`/optical` transfers the actual first 30 seconds of the supplied recording.
Each frame carries 750 independent IMA ADPCM samples at 6 kHz mono, 125 ms.
There are 240 frames at 8 frames/second. The receiver never downloads music;
all sample data comes from camera captures and is decoded in Rust.

Compared with DVS3: data grid grows from 80 × 16 to 80 × 24 cells with unchanged
4 × 4-pixel cell size (320 × 96 canonical pixels). Application bytes per frame
grow from 364 to 446 (+22.5%); audio bytes grow from 250 to 375 (+50%). Higher
sample rate preserves frequencies up to 3 kHz instead of 2 kHz. Audio is still
lossy and low fidelity. This desktop-screen sender is not integrated into the
calculator.

## Geometry and symbols

White panel: 384 × 160, rendered at 3× in the browser. Grid origin (32,32),
size 320 × 96. Corner finder centers: (16,16), (368,16), (368,144), (16,144).
Each finder has a black outer 7 × 7 square, white 5 × 5 square, black 3 × 3
center; modules are 4 pixels. Orientation dots (6 × 6) are red, green, blue,
yellow at (16,36), (368,36), (368,124), (16,124).

Rust detects the finders, checks colored orientation, and projectively
resamples the grid to 640 × 192. Every lane starts with six pilots:
red, green, blue, yellow, white, black (values 0–5). Remaining 74 cells/lane
carry base-six digits. Each 4-byte little-endian integer becomes 13 digits,
least significant digit first. 136 groups carry a 544-byte envelope; 8 unused
cells are black.

## Protected identity and combining

The 544-byte envelope contains three 10-byte identity records starting at
byte offsets 0, 267, and 534, spread across the top, middle, and bottom.
Each contains stream ID (uint32 LE), frame index (uint16 LE), and CRC-32 over
those six bytes. Valid copies must agree; differing valid IDs indicate a
mixed rolling-shutter/frame-transition capture and are rejected. A bitwise
majority of the three copies must pass its CRC before capture combining.

For each cell, the receiver learns RGB references from the lane pilots and
calculates six soft scores from color distances, weighted by the nearest vs
second-nearest separation. Scores accumulate only for a matching protected
(stream ID, frame index). Changing identity clears the accumulation. After
four observations, old scores decay to bound their influence. Unreadable
identity/calibration captures are not added. A direct decode is attempted
first, then the combined decode; every result must pass the application CRC
and match the protected ID. No checksum is bypassed.

## Reed–Solomon

Two systematic RS(255,223) codewords protect the 446 application bytes.
GF(256) uses primitive polynomial 0x11d, generator 2, and generator roots
alpha^0 through alpha^31. Each codeword has 32 parity bytes and can correct
up to 16 erroneous bytes, including errors in parity. Codewords are byte
interleaved before optical packing: a contiguous 32-byte channel burst puts
16 errors in each word. More damage may be recoverable by capture combining,
but is not guaranteed. CRC-32 rejects unsuccessful/miscorrected results.

The 510 interleaved bytes occupy offsets 10–264 and 277–531 (255 per segment).
Offsets 265–266 and 532–533 are reserved zero. Identity records are separate.

## Application packet (446 bytes)

| Offset | Bytes | Meaning |
| --- | --- | --- |
| 0 | 4 | ASCII DVA4 |
| 4 | 4 | Stream identifier, LE |
| 8 | 4 | Frame index, LE, <=65535 |
| 12 | 4 | Total frames, LE |
| 16 | 4 | Sample rate: 6000 Hz, LE |
| 20 | 2 | Sample count: 750, LE |
| 22 | 2 | Initial signed predictor, LE |
| 24 | 1 | Initial IMA step index, 0–88 |
| 25 | 1 | Reserved |
| 26 | 375 | 750 ADPCM nibbles, low nibble first |
| 401 | 41 | Reserved |
| 442 | 4 | IEEE CRC-32 over bytes 0–441, LE |

CRC is reflected IEEE polynomial 0xedb88320, init/final XOR 0xffffffff.

## Smoother playout

A 500 ms initial buffer gives reordered or combined packets time to arrive.
A 25 ms scheduling pump commits only a 150 ms horizon; missing slots are not
filled immediately when a later frame is first observed. Duplicate frames do
not replay. Brief missing blocks repeat the most recent decoded block with
progressively reduced amplitude (three blocks maximum), and 3 ms seam fades
reduce clicks. Longer starvation rebuffers instead of repeating indefinitely.
The target buffer adapts from 500 to 1500 ms based on arrival jitter and
starvation, taking effect when starting or rebuffering. It does not reconstruct
missing musical content. Stream loops preserve the queued end of the last pass.

Decoded PCM is interpolated into 16 kHz Web Audio buffers. iOS playback session
selection and gesture-based audio unlocking are retained. The test beep is
independent of camera reception. UI shows confidence, combined capture count,
corrected bytes, target buffer, concealed blocks, and rebuffer events.

## Tests and limits

- `cargo test --manifest-path wasm_decoder/Cargo.toml`: randomized RS codewords
  with 0–16 byte errors across 340 cases.
- `npm run test:robust`: all 240 audio packets, 32-byte burst correction,
  excess-damage rejection, three individually uncorrectable captures combined
  into an exact packet, header majority repair, mixed IDs, and frame isolation.
- `npm run test:robust-alignment`: actual WASM detection, perspective correction,
  and FEC/CRC under rotation, perspective, mirroring, tint, blur/noise, display
  gamut variation, and occlusion. Optional RGBA screenshot arguments also
  validate the real browser-rendered first packet.
- `npm run test:playout`: buffering, duplicates, reordering, loss fades,
  crossfade continuity, late packets, starvation recovery, loops, iOS resume.
- Legacy DVS3/DVC2 tests and decoding APIs remain for regression coverage.

`pack-robust.mjs` generates the sample from 6 kHz s16le PCM. The generated
sample is 107,040 bytes and its ADPCM SNR is 19.2 dB relative to the downsampled
source. Encoder delay/resampling bandwidth losses are separate from this SNR.

Physical iPhone capture remains unverified. Error correction cannot fix severe
blur, missing markers, poor focus, or arbitrary damage. The taller panel must
remain entirely visible. Camera/display refresh interference can still reduce
the number of useful captures within each 125 ms display frame.
