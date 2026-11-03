# Browser USB receiver

Open `/usb` in Chrome or Edge on a Mac, using localhost or HTTPS. Run DVUSB6 on
the calculator, close TI Connect CE / native receivers, connect the USB cable,
then click Connect calculator and select Doomvision PCM6 in the browser picker.
No Mac helper or firmware changes are needed. Safari does not support WebUSB.

The page claims the existing FF/44/01 vendor interface, reads bulk endpoint 1,
and parses the same DVU1 PCM16 packets as the Rust receiver. An AudioWorklet
resamples 8/16 kHz audio into the output device clock, with a 64 ms priming buffer
and 200 ms queue cap. The analyser follows the actual worklet output. Audio stays
in the browser; the Next.js server serves the UI and worklet only.

Disconnect closes USB and the AudioContext. Physical disconnection is handled by
the pending USB read failing; reconnect requires clicking Connect again.

Run `node scripts/test-usb.mjs` from the receiver directory for packet framing,
invalid-header recovery, sustained 16 kHz playback, queue bounds and rate changes.
