#!/usr/bin/env python3
import subprocess, struct, os, sys

steps = [7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,371,408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552,1707,1878,2066,2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,27086,29794,32767]
adjust = [-1,-1,-1,-1,2,4,6,8]

def encode_block(samples):
    # Exactly 1000 samples
    # b[0..1]: initial pred
    pred = int(samples[0])
    ima_index = 32
    raw = bytearray(struct.pack('<h', pred))
    nibbles = []
    for s in samples:
        diff = int(s) - pred
        sign = 8 if diff < 0 else 0
        diff = abs(diff)
        step = steps[ima_index]
        code = 0
        delta = step >> 3
        if diff >= step:
            code |= 4
            diff -= step
            delta += step
        step >>= 1
        if diff >= step:
            code |= 2
            diff -= step
            delta += step
        step >>= 1
        if diff >= step:
            code |= 1
            delta += step
        pred += -delta if sign else delta
        if pred > 32767: pred = 32767
        if pred < -32768: pred = -32768
        ima_index += adjust[code]
        if ima_index < 0: ima_index = 0
        if ima_index > 88: ima_index = 88
        nibbles.append(code | sign)
    for j in range(0, 1000, 2):
        raw.append((nibbles[j] & 0xF) | ((nibbles[j+1] & 0xF) << 4))
    return raw

def main():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    wav_path = os.environ.get('CE_SOURCE', os.path.join(base, '../public/samples/never-gonna-give-you-up-30s.mp3'))
    out_dir = os.path.join(base, 'usb-build/src')
    os.makedirs(out_dir,exist_ok=True)
    
    # Six-second 16 kHz Rick excerpt: fits beside the full piano in one file.
    # Limit peaks without adding the previous clipping-prone EQ/boost.
    cmd = [
        'ffmpeg', '-y', '-v', 'error',
        '-i', wav_path,
        '-t', '6',
        '-ac', '1',
        '-ar', '16000',
        '-af', 'alimiter=limit=0.95:level=false',
        '-f', 's16le',
        '-'
    ]
    pcm_bytes = subprocess.check_output(cmd)
    samples = struct.unpack(f'<{len(pcm_bytes)//2}h', pcm_bytes)
    # Pad to 96,000 if needed (6.0s)
    if len(samples) < 96000:
        samples = list(samples) + [0] * (96000 - len(samples))
    elif len(samples) > 96000:
        samples = samples[:96000]
    
    with open(os.path.join(base,"usb-build/rick-source.pcm"),"wb") as f:f.write(struct.pack("<96000h",*samples))
    adpcm_data = bytearray()
    for block_idx in range(96):
        block_samples = samples[block_idx*1000 : (block_idx+1)*1000]
        adpcm_data.extend(encode_block(block_samples))
    
    print(f'Encoded 16kHz ADPCM: {len(adpcm_data)} bytes ({len(adpcm_data)//502} blocks = 6.0s)')
    
    # Decode the public source directly; never depend on a truncated generated
    # array from an earlier optical build.
    piano_source=os.path.join(base,'../public/samples/piano-c4.ogg')
    raw_piano=subprocess.check_output(['ffmpeg','-y','-v','error','-i',piano_source,'-af','apad,volume=2','-t','8','-ar','8000','-ac','1','-f','s8','-'])
    if len(raw_piano)!=64000:raise RuntimeError('Expected exactly 8 seconds of 8 kHz piano')
    piano_bytes=[str(x if x<128 else x-256) for x in raw_piano]
    # Keep the full 8-second allocation. Quiet late PCM8 tails are dominated
    # by 1-LSB quantization noise; softly fade/gate that noise, not the attack.
    clean=[]
    for i,raw in enumerate(piano_bytes):
        value=int(raw)
        if i>=12000:
            value=round(value*max(0.0,(64000-i)/52000))
            if abs(value)<=1:value=0
        clean.append(str(value))
    piano_bytes=clean
    piano_def = f'const int8_t piano_s8[{len(piano_bytes)}] = {{{",".join(piano_bytes)}}};\n'
    
    # Write embedded.c
    c_bytes = ','.join(str(b) for b in adpcm_data)
    with open(f'{out_dir}/embedded.c', 'w') as f:
        f.write('#include <stdint.h>\n')
        f.write(f'const uint8_t rick_adpcm[{len(adpcm_data)}] = {{{c_bytes}}};\n')
        f.write(piano_def)
    
    # Write media.h
    rates = ','.join(str(round(128 * 2**((48 + i - 60) / 12))) for i in range(48))
    with open(f'{out_dir}/media.h', 'w') as f:
        f.write('#ifndef DV_MEDIA_H\n#define DV_MEDIA_H\n#include <stdint.h>\n#define USB_AUDIO_RATE 16000\n#define USB_AUDIO_SAMPLES 128\n#define RICK_BLOCKS 96\n')
        f.write(f'#define PIANO_LENGTH {len(piano_bytes)}\n')
        f.write(f'extern const uint8_t rick_adpcm[{len(adpcm_data)}];\n')
        f.write(f'extern const int8_t piano_s8[{len(piano_bytes)}];\n')
        f.write(f'static const unsigned int note_rates[48] = {{{rates}}};\n#endif\n')
    
    print(f'Wrote embedded.c and media.h: Rick {len(adpcm_data)}B + Piano {len(piano_bytes)}B = {len(adpcm_data)+len(piano_bytes)}B total')

if __name__ == '__main__':
    main()
