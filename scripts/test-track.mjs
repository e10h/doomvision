import assert from'node:assert/strict';import{readFileSync}from'node:fs';import ts from'typescript';
const code=ts.transpileModule(readFileSync(new URL('../src/lib/track.ts',import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;
const{monoPcm}=await import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);
function tone(hz){const samples=Float32Array.from({length:44100},(_,i)=>.8*Math.sin(2*Math.PI*hz*i/44100));return{length:44100,sampleRate:44100,numberOfChannels:2,duration:1,getChannelData:()=>samples};}
const rms=a=>Math.sqrt(a.slice(100,-100).reduce((s,n)=>s+(n/32768)**2,0)/(a.length-200));
const low=monoPcm(tone(1000),8000),aliased=monoPcm(tone(15000),8000),high=monoPcm(tone(10000),32000);
assert.equal(low.length,8000);assert.ok(rms(low)>.5);assert.ok(rms(aliased)<.03,'downsampling rejects aliasing');assert.equal(high.length,32000);assert.ok(rms(high)>.5,'128 kbps path preserves upper-band audio');
console.log('Sender resampler: duration, stereo downmix, low-frequency preservation, anti-aliasing, and 32 kHz upper band passed.');
