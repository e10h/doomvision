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

## Six-color music experiment

Open `/optical` on a sender screen and on the receiving phone. On the sender,
load the included first-30-second sample and start transfer. On the phone,
select Receive, start the rear camera, and drag a crop tightly around the full
six-row strip. The receiver reconstructs actual MP3 bytes and enables playback
only after full-file verification. A perfect 8-packet/second pass takes about
3 minutes 9 seconds, and repeats recover missed packets.

See [COLOR_PROTOCOL.md](COLOR_PROTOCOL.md) for the wire format, limitations,
and sample fidelity. Run `npm run test:color` for the complete simulated
encode → RGB image → Rust decode → file reconstruction test.
