# TI-84 Plus CE optical song sender — 32 kbps

Full supplied “I'll Follow the Sun” recording, 108.85 seconds. Actual audio bytes travel through the optical grid: mono 8 kHz IMA ADPCM, 4 bits/sample = 32 kbps, plus packet headers and Reed–Solomon protection. It loops automatically.

## Single-file Rick clip + actual piano audio

Download `public/downloads/DVSUN8.8xp` and run `DVSUN8`. One calculator file contains the first **8 seconds of Never Gonna Give You Up** and an **8-second recorded piano sample**. Use the dedicated **`/ti84`** iPhone reader: 32 kbps, 8 fps, 96 × 29, six colors. The standard CE C libraries and a compatible native launcher remain required.

- **2nd**: play/pause Rick; **Enter**: restart Rick; **Clear**: exit from clip mode.
- **Y=**: toggle sampled piano / Rick. A tiny `P` marks piano mode.
- Piano layout spans C4–E5 with eight-voice sampled playback. White keys: WINDOW=C4, MODE=D4, X,T,θ,n=E4, APPS=F4, SIN=G4, comma=A4, 7=B4, 4=C5, 1=D5, 0=E5. Black keys: ZOOM=C♯4, DEL=D♯4, PRGM=F♯4, COS=G♯4, (=A♯4, 5=C♯5, 2=D♯5. STAT, 8 and decimal remain silent, preserving the E–F and B–C gaps. Y= is reserved for switching. Press Y=, then Clear to exit.

The calculator resamples and mixes the recording, creates 1,000 PCM samples per audio frame, and encodes actual IMA ADPCM audio locally. Both modes use the ordinary DVA5 audio packets, Reed–Solomon protection and CRC. **No key-state commands or browser synthesizer are used.** The reader plays the decoded audio with a 125 ms minimum buffer. The panel and measured FPS counter remain unchanged. The sampled mix, ADPCM encoder, Reed–Solomon loop, base-six conversion and grid renderer use eZ80 assembly kernels and lookup tables. Measured isolated CPU frame work at 48 MHz is **87.7 ms for one voice / 109.5 ms for eight voices**, below the 125 ms budget for 8 fps. Keyboard/UI, LCD DMA, OS and camera overhead are excluded; actual FPS and interactive latency still require a physical-device test.

Piano source: [Meta Piano C4, velocity 3](https://github.com/facebookincubator/Meta-open-sound/tree/main/systems/instruments/meta-piano), CC0 public domain. `piano-c4.ogg` is the source recording; the build trims/pads to eight seconds, converts it to 8 kHz signed PCM8 for storage, and outputs 32 kbps IMA audio. Notes resample this real recording; higher pitches have a shorter decay. The 8-bit storage is a sound-quality tradeoff that allows both recordings in one compressed program.

Rebuild from this directory with `node tools/build-clip.mjs` (CEdev, ffmpeg and installed receiver dependencies required). Set `CE_SOURCE` to the original Rick MP3 to use it instead of the bundled 30-second excerpt. The tool refuses a split-file build.

For native renderer/encoder verification:

```
mkdir -p clip-build/tools
cp tools/audio-test.c clip-build/tools/
cc -O2 clip-build/tools/audio-test.c clip-build/src/embedded.c -o /private/tmp/ce-audio-test
node tools/verify-audio.mjs
```

The C encoder matches the Rust encoder byte for byte. All 64 Rick blocks, 48 distinct piano pitches and three later decay blocks pass actual raster → automatic alignment → RS/CRC → exact audio tests (115 round trips). These are host tests of the actual C encoder and renderer, not hardware timing measurements. The automatic reader also recovers the original exact audio packet from the privately held real iPhone photo; that photo is not published.

## Full-song transfer and play

1. Extract `doomvision-ce32.zip`. Transfer **DVSUN32.8xp and all 12 DVS32xx.8xv files** with TI Connect CE. Keep all data AppVars in **Archive** (about 694 KB total).
2. Run `DVSUN32` using your existing CE native-program launcher. This is a CE C program; it requires the standard CE C libraries (graphx, fileioc, keypadc) and a launcher compatible with your calculator OS. A `.tns` file is for a different calculator family.
3. For the **full-song 16-color** package, on the standard `/optical` iPhone receiver choose **32 kbps, 8 fps, 80 columns, 24 rows, 16 colors**. Start scanning and enable audio with the receiver's user-gesture control. Leave “Unchecked playback” off initially.
4. The calculator starts paused. Frame the entire white panel, including all four square finders; hold the phone close enough to distinguish the small cells. Press **2nd** to play/pause, **Enter** to restart, **Clear** to exit.

Receiver settings path: `/optical?kbps=32&fps=8&cols=80&rows=24&colors=16&receive=1`

At this density cells are only 3–4 LCD pixels wide. Camera focus, glare and LCD response can cause losses. The bitrate is audio payload rate, not MP3 quality: the source is transcoded to 8 kHz mono. This is experimental hardware support. The native executable compiles, and the same C renderer's 320×240 output passes the real website marker/RS/CRC/audio decoder at six representative frames, including bank boundaries. Physical CE-to-iPhone performance has not been tested.

## Rebuild

Requires CEdev v15, Node with the receiver's dependencies, and ffmpeg. From this directory:

```
ffmpeg -i ../public/samples/ill-follow-the-sun.mp3 -f s16le -ac 1 -ar 8000 /private/tmp/doomvision-ce32.pcm
node tools/build-song.mjs /private/tmp/doomvision-ce32.pcm
make
for f in assets/DVS32*.bin; do
  name=$(basename "$f" .bin)
  "$HOME/CEdev/bin/convbin" -i "$f" -o "bin/$name.8xv" -j bin -k 8xv -n "$name" -r
done
cc -O2 tools/render-test.c -o /private/tmp/ce-render
node tools/verify.mjs
```

`build-song.mjs` uses the website's Rust/WASM encoder to generate every protected frame in advance. The CE renders packed nibbles and row calibration pilots using the same alignment geometry as the browser sender. Archived banks are read directly without loading the song into RAM. Only file reads occur after bank pointers are cached.

## ROM-free native performance verification

The previous C implementation spent about 989 ms on an eight-voice frame; the optimized native kernels take about 109.5 ms. `benchmarks/ez80-timing.json` records stage timings, CEmu revision and limitations. These are measured CPU cycles, not a physical-device FPS claim. Compile with `-fno-omit-frame-pointer`; omitting it exposed invalid frame-register reuse in the toolchain during native testing.

After building the clip, use a local CEmu checkout (no TI ROM is required):

```
python3 tools/bench-ez80.py --cemu /path/to/CEmu
node tools/verify-ez80.mjs
```

The benchmark executes the compiled eZ80 mixing, IMA ADPCM, RS, base-six and pixel routines. One/eight-voice piano, silence, alternating full-scale, ramp and deterministic random inputs must match portable C PCM/packets/pixels exactly. The Rust test then verifies each native audio packet and decodes its actual rendered barcode.
