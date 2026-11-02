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
