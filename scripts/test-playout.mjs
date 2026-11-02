import assert from 'node:assert/strict';import{readFileSync}from'node:fs';import ts from'typescript';
const source=ts.transpileModule(readFileSync(new URL('../src/lib/live.ts',import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;
const{LivePlayer}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
let context;const starts=[],buffers=[];
class Context{
 currentTime=0;state='suspended';destination={};constructor(){context=Object.assign(this,{});}async resume(){this.state='running';}
 createAnalyser(){return{connect(){},getByteTimeDomainData(a){a.fill(128);}};}
 createBuffer(channels,length,rate){assert.equal(rate,16000);const samples=new Float32Array(length);buffers.push(samples);return{getChannelData(){return samples;}};}
 createBufferSource(){return{connect(){},disconnect(){},start(t){starts.push(t);},stop(){}};}
 async close(){this.state='closed';}
}
Object.defineProperty(globalThis,'navigator',{configurable:true,value:{audioSession:{type:'auto'}}});globalThis.AudioContext=Context;
const interval=globalThis.setInterval,clear=globalThis.clearInterval;globalThis.setInterval=()=>17;globalThis.clearInterval=()=>{};
const p=new LivePlayer();await p.enable();assert.equal(navigator.audioSession.type,'playback');
const block=(index,value=.8)=>({samples:new Float32Array(750).fill(value),sampleRate:6000,id:7,index,total:240});
assert.equal(p.push(block(0)),true);assert.equal(starts.length,0,'waits for jitter buffer');assert.equal(p.push(block(0)),false,'duplicate ignored');
context.currentTime=.125;p.push(block(1));context.currentTime=.25;p.push(block(3,-.8));
for(const t of [.36,.49,.62,.74]){context.currentTime=t;p.pump();}
assert.deepEqual(starts,[.5,.625,.75,.875]);assert.equal(p.played,3);assert.equal(p.concealed,1,'missing block concealed');
assert.ok(buffers[2][1999]<buffers[2][100],'concealment fades');assert.ok(Math.abs(buffers[3][0]-buffers[2][1999])<.05,'recovery crossfade avoids a step');
assert.equal(p.push(block(2)),false);assert.equal(p.late,1);
p.reset();context.currentTime=0;starts.length=0;buffers.length=0;p.push(block(10));context.currentTime=.1;p.push(block(12));context.currentTime=.2;p.push(block(11));
for(const t of [.36,.49,.62]){context.currentTime=t;p.pump();}assert.equal(p.played,3);assert.equal(p.concealed,0,'reordered repairs arrive within buffer');
p.reset();context.currentTime=0;p.push(block(0));for(const t of [.36,.49,.62,.74,.86]){context.currentTime=t;p.pump();}assert.equal(p.concealed,3);assert.equal(p.rebuffers,1);assert.ok(p.latencySeconds>.5);
context.currentTime=1;p.push(block(9));context.currentTime=1.49;p.pump();assert.equal(p.played,2,'resumes after starvation with a larger buffer');
p.reset();context.currentTime=0;starts.length=0;p.push(block(239));p.push(block(0));context.currentTime=.36;p.pump();context.currentTime=.49;p.pump();assert.equal(p.played,2);assert.deepEqual(starts,[.5,.625],'loop boundary preserves queued tail');
context.state='interrupted';await p.enable();assert.equal(p.state,'running');assert.equal(p.playing,false,'interrupted schedule reset');p.dispose();globalThis.setInterval=interval;globalThis.clearInterval=clear;
console.log('Playout: startup buffer, duplicates, reordered blocks, faded loss concealment, seam crossfade, late drop, adaptive rebuffer, loop continuity, and iOS resume passed.');
