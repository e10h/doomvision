import{readFileSync,writeFileSync,mkdirSync,copyFileSync,rmSync}from'node:fs';
import{execFileSync}from'node:child_process';import{fileURLToPath}from'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),out=root+'clip-build/';mkdirSync(out+'src/',{recursive:true});
execFileSync('ffmpeg',['-y','-v','error','-i',process.env.CE_SOURCE??root+'../public/samples/never-gonna-give-you-up-30s.mp3','-t','8','-f','s16le','-ac','1','-ar','8000',out+'clip.pcm']);
execFileSync(process.execPath,[root+'tools/build-song.mjs',out+'clip.pcm'],{env:{...process.env,CE_OUTPUT:out,CE_COLORS:'6'},stdio:'inherit'});
execFileSync('ffmpeg',['-y','-v','error','-i',root+'../public/samples/piano-c4.ogg','-af','apad,volume=2','-t','8','-f','s8','-ac','1','-ar','8000',out+'piano.s8']);
for(const name of ['render.h','audio-encoder.h','piano.h','piano-keymap.h','base6-table.h','fast.S'])copyFileSync(root+'src/'+name,out+'src/'+name);
copyFileSync(root+'templates/clip-main.c',out+'src/main.c');
// Store ADPCM source blocks, not pre-expanded optical frames. Both sounds are
// encoded into complete normal audio packets on the calculator itself.
const packets=readFileSync(out+'assets/song-packets.bin'),rick=new Uint8Array(64*502),piano=readFileSync(out+'piano.s8');
for(let i=0;i<64;i++){rick.set(packets.subarray(i*669+22,i*669+24),i*502);rick.set(packets.subarray(i*669+26,i*669+526),i*502+2);}
const rates=Array.from({length:48},(_,i)=>Math.round(256*2**((48+i-60)/12)));
writeFileSync(out+'src/media.h',`#include <stdint.h>\n#define RICK_ID ${packets.readUInt32LE(4)}UL\nextern const uint8_t rick_adpcm[32128];\nextern const int8_t piano_s8[64000];\nstatic const unsigned int note_rates[48]={${rates.join(',')}};\n`);
writeFileSync(out+'src/embedded.c',`#include <stdint.h>\nconst uint8_t rick_adpcm[32128]={${[...rick].join(',')}};\nconst int8_t piano_s8[64000]={${[...piano].map(v=>v>127?v-256:v).join(',')}};\n`);
writeFileSync(out+'makefile',readFileSync(root+'makefile','utf8').replace('NAME = DVSUN32','NAME = DVSUN8').replace('optical song','Rick + sampled piano audio'));
rmSync(out+'obj',{recursive:true,force:true});rmSync(out+'bin',{recursive:true,force:true});execFileSync('make',['-C',out],{stdio:'inherit'});if(readFileSync(out+'bin/DVSUN8.8xp').length<1000)throw new Error('Build split into additional files');copyFileSync(out+'bin/DVSUN8.8xp',root+'../public/downloads/DVSUN8.8xp');console.log('Single-file Rick clip + actual sampled piano audio ready.');
