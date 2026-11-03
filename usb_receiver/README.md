# Doomvision USB audio — Mac prototype

Actual sampled audio travels from the TI-84 Plus CE over USB bulk IN (0x81).
The Mac plays PCM16 through CoreAudio via CPAL. No optical grid, browser synth,
key messages or browser camera is used for this transport.

## First connection

1. Transfer `DVUSB4.8xp` with TI Connect CE. It is separate from the optical
   `DVSUN8` program. If requested by the launcher, archive `USBDRVCE.8xv` too.
   The standard CE libraries/launcher used by the optical program are required.
2. Close TI Connect CE. Run DVUSB4. Unplug/replug its data cable once while
   DVUSB4 runs, allowing macOS to enumerate the custom audio interface.
3. Run `./doomvision-usb` on the Mac, or `cargo run --release` in this directory.
   The receiver waits for the sender and reconnects after disconnects.
4. The calculator starts in piano mode with the C4–E5 piano key layout.
   Y= switches to/from the 6-second 16 kHz Rick excerpt; 2nd plays/pauses Rick;
   ENTER restarts it; CLEAR exits. The calculator screen reports configuration,
   completed audio chunks and transfer errors.

The Mac reports: sender discovered → interface claimed → PCM received → audio
queued. A USB-configured calculator screen only confirms enumeration; completed
chunk counters and the Mac's PCM log confirm that the host is actually reading.
If claim/open fails, close TI Connect CE. To retry, CLEAR, run DVUSB4 again and
reconnect the cable. A charge-only cable cannot carry the stream.

## Tools and validation

`./doomvision-usb --list` lists TI devices and distinguishes the custom interface.
`./doomvision-usb --self-test` plays a quiet 0.5-second 440 Hz Mac speaker test;
it does not test the calculator or USB.
`./doomvision-usb --replay file.dvusb` plays recorded PCM packets, without USB.

Build with `cargo build --release`; test with `cargo test`. The vendored libusb
feature avoids a Homebrew runtime dependency. The provided Mac binary is for
Apple Silicon. Its dynamic dependencies are only macOS system libraries.

The CE sender builds with `node ../calculator/tools/build-usb.mjs` after the
optical clip's media has been generated. It uses the same piano PCM, notes and
assembly mixer, compiled for 128 samples per chunk instead of 1,000 samples.

Tests cover fragmented/coalesced USB reads, header validation/resynchronization,
bounded playback buffering and underruns. A two-second C-sampler piano-chord
packet recording has been played through the actual Mac receiver, separately
from physical USB testing. USB descriptors use explicit wire bytes to prevent
compiler padding from corrupting the configuration.

## Wire format

16,000 Hz mono, little-endian signed PCM16; 128 samples per chunk (8 ms).
272 bytes total: `DVU1` magic (4), sequence u32 (4), rate u32 (4), sample count
u16 (2), flags u16 (2), PCM (256). Flags: bit 0 piano, bit 1 paused clip.
The short final USB packet terminates each chunk. The USB layer supplies its
own CRC/retries. This is a vendor-specific bulk stream, not USB Audio Class.

Experimental USB identity matches the toolchain link-library example:
VID 0451, PID E008; interface 0 class FF, subclass 44, protocol 01. The receiver
checks the interface signature so it does not claim an ordinary TI file-transfer
interface just because its VID/PID matches. These IDs are not a product allocation.

usbdrvce documentation: https://ce-programming.github.io/toolchain/libraries/usbdrvce.html
Piano source/license: ../public/samples/piano-c4.txt (Meta Piano, CC0).

## 16 kHz repair

DVUSB4 is one calculator program. The Rick excerpt is 6 seconds at 16 kHz to fit
the one-file budget. The piano retains the full 64,000-sample / 8-second compact
8 kHz recording, plays it at the correct pitch into a 16 kHz output stream, and
softly fades/gates its quantization-dominated quiet tail. Outputting 16 kHz cannot
restore frequencies absent from that compact source.

The broken intermediate build stored only 12,000 piano samples while reading
64,000. Generated bounds, compile-time assertions and a 9.6-second sanitizer test
now guard that failure. Rick block count and USB rate/count metadata are explicit.
The keypad runs in continuous hardware mode; synchronous keyboard scans in every
audio-loop iteration had limited the 16 kHz stream to roughly 89 chunks/s rather
than the required 125. USB SOF deadlines advance without accumulating loop drift.
The Mac supports both 8/16 kHz, clears old samples on a rate change and uses a
64 ms jitter buffer without per-sample queue-driven pitch modulation.
