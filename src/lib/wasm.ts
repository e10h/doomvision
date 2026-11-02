export interface DecodeResult {
  validL0: boolean;
  validL1: boolean;
  sequence: number;
  status: number;
  sfxMask: number;
  musicPhase: number;
  pitch: number;
  pan: number;
  volume: number;
  threshold: number;
  confidence: number;
}

export interface DetectedRoi {
  barX: number;
  barY: number;
  barW: number;
  barH: number;
  screenX: number;
  screenY: number;
  screenW: number;
  screenH: number;
  locked: boolean;
}

export class WasmOpticalDecoder {
  private instance: WebAssembly.Instance | null = null;
  private memory: WebAssembly.Memory | null = null;
  private imgBufferPtr: number = 0;
  private imgBufferSize: number = 0;
  private resultPtr: number = 0;
  private roiInPtr: number = 0;
  private roiOutPtr: number = 0;

  async init(): Promise<boolean> {
    try {
      const response = await fetch('/optical_decoder.wasm');
      if (!response.ok) throw new Error(`Decoder HTTP ${response.status}`);
      const wasmBytes = await response.arrayBuffer();
      const wasmModule = await WebAssembly.instantiate(wasmBytes, {});
      this.instance = wasmModule.instance;
      this.memory = this.instance.exports.memory as WebAssembly.Memory;

      const allocFn = this.instance.exports.wasm_alloc as (size: number) => number;
      this.resultPtr = allocFn(32);
      this.roiInPtr = allocFn(40);
      this.roiOutPtr = allocFn(40);
      return true;
    } catch (err) {
      console.error('Failed to load optical_decoder.wasm:', err);
      return false;
    }
  }

  private ensureBuffer(neededSize: number): void {
    if (!this.instance) return;
    const allocFn = this.instance.exports.wasm_alloc as (size: number) => number;
    const deallocFn = this.instance.exports.wasm_dealloc as (ptr: number, size: number) => void;

    if (this.imgBufferSize < neededSize) {
      if (this.imgBufferPtr !== 0) {
        deallocFn(this.imgBufferPtr, this.imgBufferSize);
      }
      this.imgBufferPtr = allocFn(neededSize);
      this.imgBufferSize = neededSize;
    }
  }

  private parseResult(ptr: number): DecodeResult {
    const view = new DataView(this.memory!.buffer, ptr, 32);
    return {
      validL0: view.getUint8(0) === 1,
      validL1: view.getUint8(1) === 1,
      sequence: view.getUint8(2),
      status: view.getUint8(3),
      sfxMask: view.getUint16(4, true),
      musicPhase: view.getUint8(6),
      pitch: view.getUint8(7),
      pan: view.getUint8(8),
      volume: view.getUint8(9),
      threshold: view.getUint8(10),
      confidence: view.getUint8(11),
    };
  }

  private parseRoi(ptr: number): DetectedRoi {
    const view = new DataView(this.memory!.buffer, ptr, 40);
    return {
      barX: view.getFloat32(0, true),
      barY: view.getFloat32(4, true),
      barW: view.getFloat32(8, true),
      barH: view.getFloat32(12, true),
      screenX: view.getFloat32(16, true),
      screenY: view.getFloat32(20, true),
      screenW: view.getFloat32(24, true),
      screenH: view.getFloat32(28, true),
      locked: view.getUint8(32) === 1,
    };
  }

  private writeRoi(ptr: number, roi: DetectedRoi | null): void {
    const view = new DataView(this.memory!.buffer, ptr, 40);
    if (!roi) {
      for (let i = 0; i < 40; i++) view.setUint8(i, 0);
      return;
    }
    view.setFloat32(0, roi.barX, true);
    view.setFloat32(4, roi.barY, true);
    view.setFloat32(8, roi.barW, true);
    view.setFloat32(12, roi.barH, true);
    view.setFloat32(16, roi.screenX, true);
    view.setFloat32(20, roi.screenY, true);
    view.setFloat32(24, roi.screenW, true);
    view.setFloat32(28, roi.screenH, true);
    view.setUint8(32, roi.locked ? 1 : 0);
  }

  /**
   * AI Auto-Lock: Automatically discovers 4:3 screen bounds and locks onto the top optical barcode!
   */
  aiAutoLock(
    rgbaData: Uint8ClampedArray,
    imgWidth: number,
    imgHeight: number,
    lastRoi: DetectedRoi | null
  ): { result: DecodeResult; roi: DetectedRoi } | null {
    if (!this.instance || !this.memory) return null;

    this.ensureBuffer(rgbaData.length);
    new Uint8Array(this.memory.buffer).set(rgbaData, this.imgBufferPtr);
    this.writeRoi(this.roiInPtr, lastRoi);

    const autoLockFn = this.instance.exports.ai_auto_lock_screen as (
      rgbaPtr: number,
      imgW: number,
      imgH: number,
      lastRoiPtr: number,
      outRoiPtr: number,
      outResultPtr: number
    ) => number;

    autoLockFn(
      this.imgBufferPtr,
      imgWidth,
      imgHeight,
      this.roiInPtr,
      this.roiOutPtr,
      this.resultPtr
    );

    const roi = this.parseRoi(this.roiOutPtr);
    const result = this.parseResult(this.resultPtr);

    return { result, roi };
  }

  decodeManualRoi(
    rgbaData: Uint8ClampedArray,
    imgWidth: number,
    imgHeight: number,
    roi: { x: number; y: number; w: number; h: number }
  ): DecodeResult | null {
    if (!this.instance || !this.memory) return null;

    this.ensureBuffer(rgbaData.length);
    new Uint8Array(this.memory.buffer).set(rgbaData, this.imgBufferPtr);

    const decodeRoiFn = this.instance.exports.decode_optical_roi as (
      rgbaPtr: number,
      imgW: number,
      imgH: number,
      roiX: number,
      roiY: number,
      roiW: number,
      roiH: number,
      outResultPtr: number
    ) => number;

    decodeRoiFn(
      this.imgBufferPtr,
      imgWidth,
      imgHeight,
      Math.floor(roi.x),
      Math.floor(roi.y),
      Math.floor(roi.w),
      Math.floor(roi.h),
      this.resultPtr
    );

    return this.parseResult(this.resultPtr);
  }
}
