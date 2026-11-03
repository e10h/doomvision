# TI-84 Plus CE optical song sender — 32 kbps

Full supplied “I'll Follow the Sun” recording, 108.85 seconds. Actual audio bytes travel through the optical grid: mono 8 kHz IMA ADPCM, 4 bits/sample = 32 kbps, plus packet headers and Reed–Solomon protection. It loops automatically.

## Single-file 8-second clip

Download `public/downloads/DVSUN8.8xp` and run `DVSUN8`. This embeds the first 8 seconds at 32 kbps, 8 fps, **96 columns × 29 rows, 6 colors** and needs no song AppVars. The standard CE C libraries and a compatible native launcher are still required. Press 2nd to play/pause; Enter restarts; Clear exits. It loops every 8 seconds. The panel fills the LCD; a small top-edge counter measures actual displayed frames per second over roughly one second (0.0 while paused). Alignment markers remain square and the grid is taller. Only the grid and FPS readout are redrawn during playback. Six-color unpacking uses a RAM lookup table and direct cell stores, avoiding per-cell division/modulo and tiny memset calls. All 64 optimized frames match the previous renderer pixel for pixel. Every payload passes RS/CRC with an exact grid crop; automatic alignment misses 19 of the 64 synthetic frames, so manual receiver crop may be necessary. Actual device FPS must be measured on hardware. Rebuild with `node tools/build-clip.mjs`; verify with `CE_COLORS=6 CE_OUTPUT=clip-build node tools/verify.mjs` after compiling a copy of `tools/render-test.c` under `clip-build/tools/` so it uses the generated clip header. The single-file clip defaults to six colors; the full-song package below remains sixteen colors.

## Full-song transfer and play

1. Extract `doomvision-ce32.zip`. Transfer **DVSUN32.8xp and all 12 DVS32xx.8xv files** with TI Connect CE. Keep all data AppVars in **Archive** (about 694 KB total).
2. Run `DVSUN32` using your existing CE native-program launcher. This is a CE C program; it requires the standard CE C libraries (graphx, fileioc, keypadc) and a launcher compatible with your calculator OS. A `.tns` file is for a different calculator family.
3. On the iPhone receiver choose **32 kbps, 8 fps, 80 columns, 24 rows, 16 colors**. Start scanning and enable audio with the receiver's user-gesture control. Leave “Unchecked playback” off initially.
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
