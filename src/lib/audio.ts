export const SFX_NAMES: Record<number, string> = {
  1: 'PISTOL',
  2: 'PLDETH',
  3: 'PLPAIN',
  4: 'PODTH',
  5: 'POPAIN',
  6: 'DOROPN',
  7: 'SWTCHN',
  8: 'ITEMUP',
  9: 'BAREXP',
};

export const SFX_ICONS: Record<number, string> = {
  1: '🔫',
  2: '💀',
  3: '🩸',
  4: '🧟',
  5: '💥',
  6: '🚪',
  7: '🎚️',
  8: '📦',
  9: '💣',
};

export class WebAudioEngine {
  private ctx: AudioContext | null = null;
  private masterGain: GainNode | null = null;
  public analyser: AnalyserNode | null = null;
  private musicBuffer: AudioBuffer | null = null;
  private musicSource: AudioBufferSourceNode | null = null;
  private isMusicPlaying: boolean = false;
  private sfxBuffers: Map<number, AudioBuffer> = new Map();
  private lastMask: number = 0;

  async init(): Promise<boolean> {
    try {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      this.ctx = new AudioCtx({ sampleRate: 44100 });

      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.value = 0.9;

      this.analyser = this.ctx.createAnalyser();
      this.analyser.fftSize = 512;
      this.analyser.smoothingTimeConstant = 0.8;

      this.masterGain.connect(this.analyser);
      this.analyser.connect(this.ctx.destination);

      await this.ctx.resume();
      await this.preloadSounds();
      if (!this.musicBuffer || this.sfxBuffers.size !== 9) throw new Error("Audio files failed to load");
      return true;
    } catch (err) {
      console.error('Failed to init Web Audio:', err);
      return false;
    }
  }

  async resumeContext(): Promise<void> {
    if (this.ctx && this.ctx.state === 'suspended') {
      await this.ctx.resume();
    }
  }

  get running(): boolean { return this.ctx?.state === "running"; }

  reset(): void {
    this.syncMusic(false);
    this.lastMask = 0;
  }

  setVolume(vol: number): void {
    if (this.masterGain && this.ctx) {
      this.masterGain.gain.setValueAtTime(Math.max(0, Math.min(1, vol)), this.ctx.currentTime);
    }
  }

  private async fetchAudioBuffer(url: string): Promise<AudioBuffer | null> {
    if (!this.ctx) return null;
    try {
      const res = await fetch(url);
      if (!res.ok) return null;
      const arrayBuffer = await res.arrayBuffer();
      return await this.ctx.decodeAudioData(arrayBuffer);
    } catch (e) {
      console.warn(`Could not load audio from ${url}:`, e);
      return null;
    }
  }

  private async preloadSounds(): Promise<void> {
    // 1. Load E1M1 Roland SC-55 Music
    this.musicBuffer = await this.fetchAudioBuffer('/sounds/e1m1_44k.wav');
    if (!this.musicBuffer) {
      this.musicBuffer = await this.fetchAudioBuffer('/sounds/e1m1_mono8.wav');
    }

    // 2. Preload SFX
    const sfxFiles: Record<number, string> = {
      1: '/sounds/sfx_pistol_44k.wav',
      2: '/sounds/sfx_pldeth_44k.wav',
      3: '/sounds/sfx_plpain_44k.wav',
      4: '/sounds/sfx_podth_44k.wav',
      5: '/sounds/sfx_popain_44k.wav',
      6: '/sounds/sfx_doropn_44k.wav',
      7: '/sounds/sfx_swtchn_44k.wav',
      8: '/sounds/sfx_itemup_44k.wav',
      9: '/sounds/sfx_barexp_44k.wav',
    };

    for (const [idStr, path] of Object.entries(sfxFiles)) {
      const id = parseInt(idStr, 10);
      let buf = await this.fetchAudioBuffer(path);
      if (!buf) {
        // Fallback to 11 kHz WAV
        const fallbackPath = path.replace('_44k.wav', '.wav');
        buf = await this.fetchAudioBuffer(fallbackPath);
      }
      if (buf) {
        this.sfxBuffers.set(id, buf);
      }
    }
  }

  syncMusic(shouldPlay: boolean): void {
    if (!this.ctx || !this.musicBuffer) return;

    if (shouldPlay && !this.isMusicPlaying) {
      this.musicSource = this.ctx.createBufferSource();
      this.musicSource.buffer = this.musicBuffer;
      this.musicSource.loop = true;

      const musicGain = this.ctx.createGain();
      musicGain.gain.value = 0.85;

      this.musicSource.connect(musicGain);
      musicGain.connect(this.masterGain!);

      this.musicSource.start(0);
      this.isMusicPlaying = true;
    } else if (!shouldPlay && this.isMusicPlaying) {
      try {
        this.musicSource?.stop();
        this.musicSource?.disconnect();
      } catch {
        // ignore if already stopped
      }
      this.musicSource = null;
      this.isMusicPlaying = false;
    }
  }

  processOpticalEvents(
    sfxMask: number,
    status: number,
    panCode: number = 7,
    volCode: number = 15,
    pitchCode: number = 7
  ): number[] {
    const musicActive = (status & 2) !== 0;
    this.syncMusic(musicActive);

    // Rising-edge trigger detection
    const newlyTriggered = sfxMask & ~this.lastMask;
    this.lastMask = sfxMask;

    const triggeredList: number[] = [];

    if (newlyTriggered !== 0) {
      for (let sfxId = 1; sfxId <= 9; ++sfxId) {
        if ((newlyTriggered & (1 << (sfxId - 1))) !== 0) {
          this.playSfx(sfxId, panCode, volCode, pitchCode);
          triggeredList.push(sfxId);
        }
      }
    }

    return triggeredList;
  }

  playSfx(sfxId: number, panCode: number, volCode: number, pitchCode: number): void {
    if (!this.ctx || !this.masterGain) return;
    const buf = this.sfxBuffers.get(sfxId);
    if (!buf) return;

    const source = this.ctx.createBufferSource();
    source.buffer = buf;

    // Pistol is kept at authentic 1.0x pitch and center pan; monsters/environment use dynamic pan & pitch
    if (sfxId === 1) {
      source.playbackRate.value = 1.0;
    } else {
      source.playbackRate.value = Math.pow(2.0, (pitchCode - 7) / 24.0);
    }

    const gainNode = this.ctx.createGain();
    const vol = sfxId === 1 ? 1.0 : Math.max(0.2, volCode / 15.0);
    gainNode.gain.value = vol;

    // Stereo Panner (-1.0 left to +1.0 right)
    let panner: StereoPannerNode | null = null;
    if (this.ctx.createStereoPanner && sfxId !== 1) {
      panner = this.ctx.createStereoPanner();
      const panVal = Math.max(-1.0, Math.min(1.0, (panCode - 7) / 7.0));
      panner.pan.setValueAtTime(panVal, this.ctx.currentTime);
    }

    if (panner) {
      source.connect(gainNode);
      gainNode.connect(panner);
      panner.connect(this.masterGain);
    } else {
      source.connect(gainNode);
      gainNode.connect(this.masterGain);
    }

    source.start(0);
  }
}
