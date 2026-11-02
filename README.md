# Doom84s optical audio receiver

A camera receiver for the 40-cell, two-row barcode in `doom84s/src/sound.h`.
Rust compiled to WebAssembly finds the finder/sync pattern and validates checksums;
Web Audio plays the local music and sound effects.

```sh
npm install
# When changing Rust (requires the wasm32-unknown-unknown Rust target):
npm run build:wasm
npm run test:decoder
npm run dev
```

Open localhost:3000, start the camera, and allow access. Camera access requires
localhost or HTTPS. Use Test speaker to verify audio separately. The status strip
shows decoder loading, camera, barcode lock, checksum, and playback readiness;
startup failures appear inline.

Keep the calculator level, its full screen visible, and its top two pixel rows
sharp. Auto detection searches all rows and derives width from the barcode
prefix. Manual mode lets you drag tightly around both rows. The cyan screen
outline is a 4:3 estimate inferred from a valid barcode, not independent screen
boundary detection. Perspective correction and recovery of unresolved/blurred
pixel rows are not supported. Playback stops after 750 ms without a valid packet.

`npm run test:decoder` exercises the actual shipped WASM with protocol packets at
four scales/positions, checks both layers and payloads, and rejects invalid crops.
Physical camera focus, permissions, and speaker output still need a hardware test.

## Full-track configurable optical audio

Open `/optical` on the Mac and phone. The sender can load the full **I’ll
Follow the Sun** recording (about 1 minute 49 seconds). Choose audio bitrate (1–128 kbps),
optical fps, columns and rows, then Auto-fit grid. Load / encode the full track
and start transmission. Use Copy matching receiver link to configure the phone.
On the phone, choose Receive + play, start camera/audio, and keep the whole
white panel and four square markers visible.

The default is 128 kbps mono ADPCM (32 kHz), 8 fps, 168 × 52 = 8,736 colored
cells/frame. This is a different codec from the original 128 kbps MP3. The Set 1 kbps preset
uses 250 Hz mono and, at 8 fps, only 40 × 11 = 440 color cells; expect bass/rhythm
rather than full-band music. At 16 fps,
auto-fit uses 4,480 cells/frame. Grid capacity does not guarantee reliable camera
capture; use lower bitrate if cells are unresolved. Native source preview on
the sender is separate from optical reception.

See [CONFIGURABLE_PROTOCOL.md](CONFIGURABLE_PROTOCOL.md) for exact capacity math,
wire format, controls, limitations, and verification. Run `npm run test:flex`,
`npm run test:track`, and `npm run test:playout`. Earlier DVA4 and DVC2 tests and
assets remain for regression coverage; [LIVE_PROTOCOL.md](LIVE_PROTOCOL.md)
documents the previous fixed-rate transport.

The byte-perfect MP3 file-transfer experiment remains at `/optical/file`; it
buffers the complete file before playback. See [COLOR_PROTOCOL.md](COLOR_PROTOCOL.md).
