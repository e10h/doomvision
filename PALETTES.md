# Experimental multi-color optical transport

The live sender and receiver support **6, 8, 16, 32, 64, 128, 256, 512, 1024**
data colors. The Palette selector auto-fits the grid and preserves the selected
bitrate/fps. The matching receiver link includes `colors`. Both ends must agree.
Six colors remain the default and keep the existing base-six decoder.

## Capacity vs color spacing

At 128 kbps ADPCM and 8 optical frames/second, with the existing RS protection:

| Data colors | Data bits/cell | Auto-fit grid | Cells/frame |
| --- | --- | --- | --- |
| 6 | 2.46 (32 bits per 13 cells) | 168 × 52 | 8,736 |
| 8 | 3 | 160 × 47 | 7,520 |
| 16 | 4 | 144 × 39 | 5,616 |
| 32 | 5 | 120 × 38 | 4,560 |
| 64 | 6 | 120 × 32 | 3,840 |
| 128 | 7 | 104 × 32 | 3,328 |
| 256 | 8 | 104 × 28 | 2,912 |
| 512 | 9 | 96 × 27 | 2,592 |
| 1024 | 10 | 88 × 27 | 2,376 |

Counts include per-row references, not the external square finders. At very
low bitrate the minimum supported 32-column/8-row grid and calibration overhead
can dominate, so capacity gains eventually flatten.

For powers of two, usable data cells are `(columns−11) × rows` and capacity is
`floor(usable × log2(colors) / 8)` envelope bytes. Data bits are packed LSB-first
across cells and bytes; final unused bits are zero. The DVA5 application packet,
shortened/interleaved RS code, protected identities, and CRC are unchanged.

## Constellations and reference patches

RGB component bit depths for B total bits are ceil(B/3), floor((B+1)/3),
floor(B/3). Each component uses evenly spaced 8-bit display values. The level
index is Gray-coded, so adjacent levels differ in one transmitted bit.
For example, 64 colors are 4 × 4 × 4 levels; 1024 are 16 × 8 × 8 levels.

Each row begins with 11 known reference patches: black, red, green, yellow,
blue, magenta, cyan, white, and three greys at 64, 128, 192. These are calibration
patches, separate from the advertised data alphabet. Small palettes therefore
also display grey tones that are not payload symbols. No 1024-patch calibration
strip is needed.

Rust fits separate camera/output and display/input transfer functions. RGB
corner additivity estimates the output gamma; grey references then estimate
the input gamma in the resulting linear-light domain. Trilinear interpolation
of linearized RGB corners predicts colors before output re-encoding. This
avoids incorrectly interpolating gamma-encoded mixed colors directly. Cell-center pixel
variance and calibration residuals estimate diagonal RGB noise variance.
The model captures a limited class of gamma, lighting, and channel-mixing
changes; arbitrary camera/display nonlinearities are not guaranteed corrected.

## Soft decisions and temporal evidence

For each bit, the decoder finds the nearest predicted color among labels with
that bit zero and among labels with it one, using noise-normalized squared RGB
distance. Half their distance difference is a Gaussian **max-log approximation**
to a bit log-likelihood ratio. Evidence is clipped to ±8 to limit one capture's
influence. It is not a trained neural model or an exact calibrated probability.

Protected identity first uses the existing hard majority/CRC checks; if unreadable,
soft evidence across the three repeated records is summed. A recovered record
must pass CRC and agree with any individually valid identity copies. Different
valid identities remain a mixed-frame rejection.

Only observations with a verified matching stream/frame ID accumulate bit
log-likelihoods. After four observations, older evidence decays by 0.75. Direct
and combined hard bytes go through RS repair, packet CRC, and protected identity
matching before any audio is accepted. Sampling-phase trials are temporary
states and do not contaminate the capture combiner.

The confidence display derives from bit-evidence strength in these modes. It
is diagnostic evidence, not a promised probability of successful reception.

## Tests, measurements, limits

`npm run test:palettes` verifies every data palette has exactly its advertised
number of unique colors, checks all palettes with ideal captures and a controlled
gamma/channel-mixing/noise transform, and exercises 72 additional combinations
of palette, low/mid/high bitrate, and fps. It recovers three individually
uncorrectable captures by soft-bit fusion, and rejects mixed frame identities.

A controlled heavy-distortion test recovers an 8-color packet while rejecting
the 1024-color packet without bypassing CRC. This demonstrates the tradeoff,
not a universal camera noise threshold or ranking. Simulated mild-noise success
does not establish real iPhone support for a palette.

128–1024-color modes are explicitly experimental. More colors reduce symbol
spacing, making exposure, focus, gamut clipping, color processing, and camera
noise more important. Verified packets/audio delivered per second should decide
whether the smaller grid helps. Physical iPhone capture remains unverified.

Background: pilot/channel estimation followed by likelihood detection is used
in optical color communication; see the
[optical-camera communication overview](https://pmc.ncbi.nlm.nih.gov/articles/PMC7061997/)
and [512-color experimental research](https://arxiv.org/abs/2301.01599). Those
experiments use different hardware and methods and do not validate this app.

Browser-rendered validation at 24 kbps / 8 fps: a 16-color first-frame capture
passed with 11 repaired bytes; a 64-color capture passed with zero repaired
bytes. A 1024-color capture was rejected with an unreadable protected identity.
These are individual scaled browser screenshots, not camera trials or measured
bit-error rates. The high-order modes remain available for experimentation,
but successful simulated decoding must not be read as real-screen reliability.

## Unchecked playback experiment

The receiving page has an opt-in, default-off checkbox for palettes of 8+ colors.
It bypasses calibration-contrast rejection, protected-ID/CRC acceptance and
validated packet framing, and emits best-guess audio from the sampled bits.
It still attempts RS repair; if repair fails, it extracts the received systematic
data. No cross-frame soft accumulation is attempted without a trusted ID.

Audio uses the configured sample rate and fps, a local output clock, a clamped
ADPCM step index, and checked memory/payload bounds. Corrupt metadata cannot
select an arbitrary sample rate or write beyond the audio buffer. Source packet
IDs and CRCs are ignored. The UI clearly labels the output and counters as
unchecked. Alignment and matching palette/grid settings remain necessary.
This mode may produce noise and is not evidence of correct data recovery.
