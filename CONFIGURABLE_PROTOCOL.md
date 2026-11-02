# DVA5 configurable bitrate and dot grid

The live `/optical` experiment now prepares the entire supplied **I’ll Follow
the Sun** recording, with no 30-second trim. Its duration is approximately
108.853 seconds. The sender downloads the supplied original MP3 and decodes it
locally with OfflineAudioContext. The receiving phone never downloads it.

## What “128K” means here

The supplied MP3 is approximately 128 kbps. The optical audio path uses IMA
ADPCM, not MP3 frames: selecting 128 kbps means **32 kHz mono × 4 bits/sample**.
It preserves the full song but is not a byte-perfect transfer of the MP3,
not stereo, and not the same psychoacoustic codec or quality guarantee.
The original MP3 can be previewed explicitly on the sender with native audio
controls; that preview is separate from optical reception.

Available audio rates: 1, 2, 4, 8, 12, 16, 24, 32, 48, 64, 96, 128 kbps
(250 Hz–32 kHz mono).
Available optical frame rates: 4, 8, 16 fps. Frame duration is 1/fps.
Final audio is padded with zeros to a full frame; the 128 kbps / 8 fps profile
uses 871 frames, 108.875 seconds, about 22 ms longer than the source.

## How many colored cells?

For selected kbps K and frame rate F:

1. Sample rate R = K × 250; samples/frame = R/F.
2. Maximum samples/frame = ceil(R/F); audio bytes/frame A = ceil(max samples / 2).
3. Application RS lanes L = ceil((A + 30) / 223).
4. Data bytes/lane D = A+30 for L=1 (shortened RS), otherwise 223.
   Application packet bytes P = L × D.
5. Protected envelope bytes E = round_up_to_4(L × (D+32) + 30).
6. Data color cells required = E/4 × 13.
7. For C columns and H rows, usable cells = (C − 6) × H. Six cells per row
   calibrate red, green, blue, yellow, white, and black.

Each four bytes become thirteen base-six symbols, least significant first.
Reed–Solomon protects each application lane with 32 parity bytes. Shortened
lanes omit known leading zeros while retaining the same correction strength.
Three protected 10-byte identities occupy the envelope top/middle/bottom.
The four square alignment markers are outside the counted data grid.

Auto-fit balances total cell count with cell aspect ratio on the fixed panel:

| 128 kbps frame rate | Auto-fit grid | Colored cells/frame | Audio bytes/frame |
| --- | --- | --- | --- |
| 4 fps | 240 × 68 | 16,320 | 4,000 |
| 8 fps | 168 × 52 | 8,736 | 2,000 |
| 16 fps | 128 × 35 | 4,480 | 1,000 |

At 8 fps, ten RS lanes give 2,230 application bytes and a 2,580-byte envelope.
The grid requires 8,385 data cells, plus its calibration cells and unused
remainder. An ideal six-state entropy calculation alone would understate the
actual cell requirement. These are capacity numbers, not a guarantee of
camera throughput: higher density shrinks cells, and higher frame rate gives
fewer camera observations per optical frame.

## Settings and receiver link

The sender and receiver both expose audio bitrate, frame rate, columns, rows,
Auto-fit grid, and Set 128 kbps. Too-small grids are blocked before starting.
Changing settings stops the current session and re-encodes the already-loaded
source. The receiver link includes `kbps`, `fps`, `cols`, `rows`, `receive=1`.
Share that link from the hosted HTTPS site; localhost on one device is not the
other device. Both endpoints must use matching settings.

Panel geometry remains 384 × 160, with the data grid at (32,32), size 320 × 96.
The number of cells within that rectangle changes; markers stay fixed.
Perspective rectification uses at least 4 output pixels/cell and at least
640 × 192 pixels. Optional ±1-pixel sampling-phase trials correct dense-grid
screen-scaling offsets. Trials run for unreadable protected identities as well as damaged packet
bodies. A sampling error must not prevent attempting to recover the identity.
Trials use temporary state, do not count as separate
camera captures, and must pass full protected-ID, RS, and CRC verification.
They never introduce cross-phase votes into the temporal combiner.

## Packet and envelope

Application packet length is L × 223. Header offsets follow DVA4, except:

- Magic is ASCII DVA5.
- Offset 16 (uint32 LE) is configured sample rate.
- Offset 20 (uint16 LE) is samples/frame.
- Offset 25 is optical fps (4, 8, or 16).
- ADPCM nibbles start at 26, low nibble first.
- Unused bytes are zero; CRC-32 occupies the final four bytes of the packet.

The protected envelope is E bytes. Three 10-byte identity copies start at
0, floor((E−10)/2), E−10. Each contains stream ID uint32 LE, frame index
uint16 LE, CRC-32 over those six bytes. All valid copies must agree and bit
majority must validate. Remaining slots carry interleaved RS codeword bytes,
byte-position first then lane index; up to three remaining bytes are zero.
Each lane corrects up to 16 erroneous bytes. The frame index limit is 65535.

Sample preparation downmixes to mono and uses a 32-tap, 256-phase windowed-sinc
resampler to limit aliasing before Rust ADPCM encoding. Stream ID incorporates
the source CRC, sample rate, and fps. The player derives frame duration from
the fps metadata and retains 32 kHz output buffers for the 128 kbps path.
Capture combining, error correction, marker orientation fallback, adaptive
buffering, and short-loss concealment remain enabled.

## Verification

`npm run test:flex` round-trips all 36 bitrate/fps profiles through the real
Rust optical encoder, synthetic RGB capture, decoder, and audio decoder. It
checks the 128 kbps capacity math, settings URLs, and undersized-grid blocking.
An optional s16le 32 kHz PCM path checks every audio block of the full song.
`--screenshot path.rgba width height` validates the real browser-rendered first
128 kbps / 8 fps frame, including sampling-phase refinement and audio metadata.

Rust tests exercise variable RS lane counts 1, 2, 5, 10, 19, and 32 with
16 erroneous bytes per lane and excessive-damage rejection. Track tests check
anti-aliasing, duration, stereo downmix, and upper-band preservation. Playback
tests include 32 kHz audio and 16 fps timing. Previous protocol tests remain.

The whole-source 128 kbps encode/decode test measured 30.9 dB ADPCM SNR relative
to a 32 kHz resampling of the source. That is not an MP3 quality comparison.
Real iPhone capture at these densities remains unverified.

## Reception troubleshooting

Use the matching receiver link after changing settings. The **Larger cells:
24 kbps test** preset uses 80 × 24 cells at 8 fps, keeping the full track while
reducing the density for a reception test. No automatic downgrade is applied.
**Save diagnostic camera frame** downloads the last raw camera image before
tracking overlays. Its filename includes kbps, fps, columns, and rows, so it
can be replayed against exactly the same receiver profile when investigating
hardware-only failures.

## Extreme low-rate mode

Set 1 kbps or choose 1, 2, 4, 8, 12, or 16 kbps in the bitrate menu. The 1 kbps
profile is 250 samples/second mono ADPCM, retaining only frequencies below
roughly 125 Hz. It is useful for low-density optical experiments and bass/rhythm,
not a music-quality equivalent to a 1 kbps perceptual codec.

At 8 fps the audio alternates 31/32 samples per frame, preserving exactly 250
samples over one second. Each frame starts at floor(index × rate / fps), and
its actual sample count is encoded in the header and checked by Rust. The
player resamples each block onto its fixed frame-time slot, preventing clock
drift from integer rounding. Half-byte padding adds a small wire overhead.

Single-lane RS blocks are shortened to actual packet needs. The encoder prepends
known zeros up to 223 data bytes, applies RS(255,223), and transmits only actual
data plus 32 parity bytes. The decoder restores zeros before repair and verifies
they remain zero. Sixteen byte errors per shortened word remain correctable.

At 1 kbps, 8 fps: 46 application bytes → 78 RS bytes + 30 repeated-ID bytes =
108 protected bytes/frame. Auto-fit is 40 × 11 = 440 color cells. Optical wire
rate is 6.912 kbps before base-six representation and pilots; **1 kbps refers
to waveform data**, not the total protected optical link. The full source is
cascaded through half-rate anti-alias filters before the final 250 Hz resample.
This avoids folding the original high frequencies into the low-rate output.

Rust tests cover shortened data lengths 31, 38, 46, 62, 94, 155, 218, and 223,
16-error repair and excessive-error rejection. JS tests cover all sample counts
in a second at 1 kbps for every fps, stable playout timing, bass preservation,
and suppression of high-frequency aliasing. Source and full-track duration are
unchanged; only audio fidelity and packet/grid size change.
