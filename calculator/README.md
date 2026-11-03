# TI-84 Plus CE optical song sender — 32 kbps

Full supplied “I'll Follow the Sun” recording, 108.85 seconds. Actual audio bytes travel through the optical grid: mono 8 kHz IMA ADPCM, 4 bits/sample = 32 kbps, plus packet headers and Reed–Solomon protection. It loops automatically.

## Transfer and play

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
