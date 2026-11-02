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

## Live six-color music

Open `/optical` on the Mac and iPhone. On the Mac, choose Send, load the
30-second live sample, and start transmission. On the phone, choose Receive +
play, tap Start camera + audio, then keep the entire white panel and all four
corner markers visible. Auto-lock locates and perspective-corrects the grid. Each valid packet immediately schedules 125 ms of audio.
Use Enable audio / test beep to verify the speaker separately.

The grid now uses 80 × 24 cells (320 × 96 pixels), with four corner finders
in a 384 × 160 white panel. It carries 6 kHz mono audio with same-frame capture
combining, interleaved Reed–Solomon correction, and CRC verification. Playback
uses a 500–1500 ms adaptive target buffer and faded short-loss concealment.
UI counters distinguish capture confidence, correction, and playback buffering.
See [LIVE_PROTOCOL.md](LIVE_PROTOCOL.md) for capacity and limitations.

Run `npm run test:robust`, `npm run test:robust-alignment`, and
`npm run test:playout`. `npm run test:live` and `npm run test:alignment` retain
coverage of the previous transport. Physical iPhone capture is not yet verified.

The earlier byte-perfect MP3 transfer is preserved at `/optical/file`; that
mode buffers the complete file before playback. See
[COLOR_PROTOCOL.md](COLOR_PROTOCOL.md) and `npm run test:color`.
