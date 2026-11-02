import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import ts from 'typescript';
const source = ts.transpileModule(readFileSync(new URL('../src/lib/audio.ts', import.meta.url), 'utf8'), {
  compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ES2022 },
}).outputText;
const { WebAudioEngine } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
let sessionType = 'auto', created = 0, context;
const session = { get type() { return sessionType; }, set type(v) { sessionType = v; } };
Object.defineProperty(globalThis, 'navigator', { configurable: true, value: { audioSession: session } });
class FakeContext {
  state = 'suspended';
  destination = {};
  currentTime = 0;
  constructor() { assert.equal(sessionType, 'playback'); created++; }
  createGain() { return { gain: { value: 0 }, connect() {} }; }
  createAnalyser() { return { connect() {} }; }
  async resume() { this.state = 'running'; }
  async decodeAudioData() { return {}; }
}
globalThis.window = { AudioContext: class extends FakeContext {
  constructor() { super(); context = Object.assign(this, {}); }
} };
globalThis.fetch = async () => ({ ok: true, arrayBuffer: async () => new ArrayBuffer(8) });
const engine = new WebAudioEngine();
assert.equal(await engine.init(), true);
assert.equal(engine.running, true);
context.state = 'interrupted'; sessionType = 'auto';
await engine.resumeContext();
assert.equal(sessionType, 'playback');
assert.equal(engine.running, true);
await engine.init(); assert.equal(created, 1, 'retry reuses audio context');
delete navigator.audioSession;
context.state = 'suspended'; await engine.resumeContext();
assert.equal(engine.running, true, 'older browsers work without AudioSession');
context.resume = async () => {}; context.state = 'interrupted';
await assert.rejects(() => engine.resumeContext(), /Audio is paused/);
console.log('Audio: playback session, interrupted resume, context reuse, API fallback, and blocked resume passed');
