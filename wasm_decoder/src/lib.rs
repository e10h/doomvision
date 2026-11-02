//! High-Performance Rust + WebAssembly Screen Rectangle & Optical Audio Engine for Doom84
//! Locks onto the 4:3 screen rectangle boundary and decodes dual-layer optical audio from the top scanlines.

use std::alloc::{alloc, dealloc, Layout};

const NUM_CELLS: usize = 40;
const SYNC0_BYTE: u8 = 0xA5;
const SYNC1_BYTE: u8 = 0x5A;

#[repr(C)]
#[derive(Debug, Default, Clone, Copy)]
pub struct DecodeResult {
    pub valid_l0: u8,       // 0
    pub valid_l1: u8,       // 1
    pub sequence: u8,       // 2
    pub status: u8,         // 3
    pub sfx_mask: u16,      // 4..5
    pub music_phase: u8,    // 6
    pub pitch: u8,          // 7
    pub pan: u8,            // 8
    pub volume: u8,         // 9
    pub threshold: u8,      // 10
    pub confidence: u8,     // 11
}

#[repr(C)]
#[derive(Debug, Default, Clone, Copy)]
pub struct DetectedRoi {
    pub bar_x: f32,         // 0
    pub bar_y: f32,         // 4
    pub bar_w: f32,         // 8
    pub bar_h: f32,         // 12
    pub screen_x: f32,      // 16
    pub screen_y: f32,      // 20
    pub screen_w: f32,      // 24
    pub screen_h: f32,      // 28
    pub locked: u8,         // 32
}

#[no_mangle]
pub extern "C" fn wasm_alloc(size: usize) -> *mut u8 {
    let layout = Layout::from_size_align(size, 8).unwrap();
    unsafe { alloc(layout) }
}

#[no_mangle]
pub extern "C" fn wasm_dealloc(ptr: *mut u8, size: usize) {
    if ptr.is_null() {
        return;
    }
    let layout = Layout::from_size_align(size, 8).unwrap();
    unsafe { dealloc(ptr, layout) }
}

#[inline(always)]
fn get_luma(rgba: &[u8], idx: usize) -> u8 {
    let r = rgba[idx] as u32;
    let g = rgba[idx + 1] as u32;
    let b = rgba[idx + 2] as u32;
    ((r * 77 + g * 150 + b * 29) >> 8) as u8
}

/// Adaptive binarizer: Computes local min/max along the strip to handle room lighting gradients
fn sample_cells_and_binarize(profile: &[u8], global_thresh: u8) -> [u8; NUM_CELLS] {
    let mut bits = [0u8; NUM_CELLS];
    let len = profile.len() as f32;
    let cell_w = len / (NUM_CELLS as f32);

    for (c, bit) in bits.iter_mut().enumerate() {
        let center_x = ((c as f32 + 0.5) * cell_w) as usize;
        let radius = (cell_w * 0.2) as usize;
        let x0 = center_x.saturating_sub(radius);
        let x1 = (center_x + radius + 1).min(profile.len());

        let sum: u32 = profile[x0..x1].iter().map(|&v| v as u32).sum();
        let avg = (sum / (x1 - x0).max(1) as u32) as u8;

        // Local window for lighting gradient adaptation
        let win_x0 = center_x.saturating_sub((cell_w * 3.0) as usize);
        let win_x1 = (center_x + (cell_w * 3.0) as usize).min(profile.len());
        let mut loc_min = 255u8;
        let mut loc_max = 0u8;
        for &v in &profile[win_x0..win_x1] {
            loc_min = loc_min.min(v);
            loc_max = loc_max.max(v);
        }

        let thresh = if loc_max.saturating_sub(loc_min) > 20 {
            loc_min + (loc_max - loc_min) / 2
        } else {
            global_thresh
        };

        *bit = if avg >= thresh { 1 } else { 0 };
    }
    bits
}

fn validate_layer_0(bits: &[u8; NUM_CELLS]) -> Option<(u8, u8, u8)> {
    if bits[0] != 1 || bits[1] != 0 || bits[2] != 1 || bits[3] != 0 {
        return None;
    }
    if bits[36] != 0 || bits[37] != 1 || bits[38] != 0 || bits[39] != 1 {
        return None;
    }
    let mut sync0 = 0u8;
    for i in 0..8 {
        if bits[4 + i] != 0 { sync0 |= 1 << (7 - i); }
    }
    if sync0 != SYNC0_BYTE {
        return None;
    }
    let mut seq = 0u8;
    for i in 0..8 {
        if bits[12 + i] != 0 { seq |= 1 << (7 - i); }
    }
    let mut sfx_low = 0u8;
    for i in 0..8 {
        if bits[20 + i] != 0 { sfx_low |= 1 << i; }
    }
    let status = bits[28] | (bits[29] << 1) | (bits[30] << 2);
    let c0 = sync0 ^ seq ^ sfx_low ^ status;
    let c0_4 = (c0 & 0x0F) ^ ((c0 >> 4) & 0x0F);
    let mut exp_c0 = 0u8;
    for i in 0..4 {
        if bits[32 + i] != 0 { exp_c0 |= 1 << (3 - i); }
    }
    if c0_4 != exp_c0 {
        return None;
    }

    Some((seq, sfx_low, status))
}

fn validate_layer_1(bits: &[u8; NUM_CELLS]) -> Option<(u8, u8, u8, u8)> {
    if bits[0] != 0 || bits[1] != 1 || bits[2] != 0 || bits[3] != 1 {
        return None;
    }
    if bits[36] != 1 || bits[37] != 0 || bits[38] != 1 || bits[39] != 0 {
        return None;
    }
    let mut sync1 = 0u8;
    for i in 0..8 {
        if bits[4 + i] != 0 { sync1 |= 1 << (7 - i); }
    }
    if sync1 != SYNC1_BYTE {
        return None;
    }
    let mut phase = 0u8;
    for i in 0..8 {
        if bits[12 + i] != 0 { phase |= 1 << (7 - i); }
    }
    let mut pitch = 0u8;
    for i in 0..4 {
        if bits[20 + i] != 0 { pitch |= 1 << (3 - i); }
    }
    let mut pan = 0u8;
    for i in 0..4 {
        if bits[24 + i] != 0 { pan |= 1 << (3 - i); }
    }
    let mut vol = 0u8;
    for i in 0..4 {
        if bits[28 + i] != 0 { vol |= 1 << (3 - i); }
    }
    let c1 = sync1 ^ phase ^ ((pitch << 4) | pan) ^ vol;
    let c1_4 = (c1 & 0x0F) ^ ((c1 >> 4) & 0x0F);
    let mut exp_c1 = 0u8;
    for i in 0..4 {
        if bits[32 + i] != 0 { exp_c1 |= 1 << (3 - i); }
    }
    if c1_4 != exp_c1 {
        return None;
    }

    Some((phase, pitch, pan, vol))
}

/// Helper that samples a horizontal segment from x0 to x1 along scanlines y0 and y1.
fn test_strip_segment(
    rgba: &[u8],
    img_w: u32,
    img_h: u32,
    x0: u32,
    x1: u32,
    y0: u32,
    y1: u32,
    out_result: &mut DecodeResult,
) -> bool {
    if x1 <= x0.saturating_add(40) || x1 > img_w || y1 >= img_h || y0 >= img_h {
        return false;
    }
    let w = (x1 - x0) as usize;
    let mut prof0 = vec![0u8; w];
    let mut prof1 = vec![0u8; w];

    let mut min_l = 255u8;
    let mut max_l = 0u8;

    for i in 0..w {
        let px0 = ((y0 * img_w + x0 + i as u32) * 4) as usize;
        let px1 = ((y1 * img_w + x0 + i as u32) * 4) as usize;

        let v0 = get_luma(rgba, px0);
        let v1 = get_luma(rgba, px1);

        prof0[i] = v0;
        prof1[i] = v1;

        min_l = min_l.min(v0).min(v1);
        max_l = max_l.max(v0).max(v1);
    }

    if max_l.saturating_sub(min_l) < 20 {
        return false;
    }

    let thresh = min_l + (max_l - min_l) / 2;
    out_result.threshold = thresh;

    let bits0 = sample_cells_and_binarize(&prof0, thresh);
    let bits1 = sample_cells_and_binarize(&prof1, thresh);

    if let Some((seq, sfx_low, status)) = validate_layer_0(&bits0) {
        out_result.valid_l0 = 1;
        out_result.sequence = seq;
        out_result.status = status;
        let barexp_bit = (status & 1) as u16;
        out_result.sfx_mask = (sfx_low as u16) | (barexp_bit << 8);
        out_result.confidence = 96;

        if let Some((phase, pitch, pan, vol)) = validate_layer_1(&bits1) {
            out_result.valid_l1 = 1;
            out_result.music_phase = phase;
            out_result.pitch = pitch;
            out_result.pan = pan;
            out_result.volume = vol;
            out_result.confidence = 100;
        } else {
            out_result.pitch = 7;
            out_result.pan = 7;
            out_result.volume = 15;
        }
        return true;
    }

    false
}

#[no_mangle]
pub extern "C" fn decode_optical_roi(
    rgba_ptr: *const u8,
    img_width: u32,
    img_height: u32,
    roi_x: u32,
    roi_y: u32,
    roi_w: u32,
    roi_h: u32,
    out_result: *mut DecodeResult,
) -> i32 {
    if rgba_ptr.is_null() || out_result.is_null() { return -1; }
    let rgba = unsafe { std::slice::from_raw_parts(rgba_ptr, (img_width * img_height * 4) as usize) };
    let mut res = DecodeResult::default();

    let y0 = roi_y.saturating_add(roi_h / 4);
    let y1 = roi_y.saturating_add(roi_h.saturating_mul(3) / 4);
    let ok = test_strip_segment(rgba, img_width, img_height, roi_x, roi_x.saturating_add(roi_w), y0, y1, &mut res);

    unsafe { *out_result = res; }
    if ok { 1 } else { 0 }
}

/// AI RECTANGLE SCREEN LOCK-ON ENGINE:
/// 1. Finds the prominent 4:3 rectangular LCD screen in the camera feed.
/// 2. Snaps to its top boundary and samples the top few scanlines where the optical barcode resides.
/// 3. Tracks smoothly across frames with sub-millisecond execution.
#[no_mangle]
pub extern "C" fn ai_auto_lock_screen(
    rgba_ptr: *const u8,
    img_width: u32,
    img_height: u32,
    last_roi: *const DetectedRoi,
    out_roi: *mut DetectedRoi,
    out_result: *mut DecodeResult,
) -> i32 {
    if rgba_ptr.is_null() || out_roi.is_null() || out_result.is_null() || img_width < 41 || img_height < 2 {
        return -1;
    }

    let rgba = unsafe { std::slice::from_raw_parts(rgba_ptr, (img_width * img_height * 4) as usize) };
    let last = if !last_roi.is_null() { unsafe { &*last_roi } } else { &DetectedRoi::default() };

    let mut res = DecodeResult::default();

    // 1. FAST PATH: Local tracking around previously locked screen rectangle
    if last.locked == 1 && last.screen_w > 40.0 {
        let bar_x = last.bar_x as u32;
        let bar_w = last.bar_w as u32;
        let screen_h = last.screen_h as f32;
        let py = (screen_h / 240.0).max(1.0);

        for dy in -10..=12 {
            let y0 = (last.bar_y as i32 + dy).max(0) as u32;
            let y1 = (y0 as f32 + py).min(img_height as f32 - 1.0) as u32;

            if test_strip_segment(rgba, img_width, img_height, bar_x, bar_x + bar_w, y0, y1, &mut res) {
                unsafe {
                    let mut r = *last;
                    r.bar_y = y0 as f32;
                    r.screen_y = r.bar_y;
                    r.locked = 1;
                    *out_roi = r;
                    *out_result = res;
                }
                return 1;
            }
        }
    }

    // Locate the known alternating finder + sync prefix on every row. Infer
    // cell spacing from six transitions rather than guessing screen sizes.
    for y in 0..img_height {
        let row: Vec<u8> = (0..img_width)
            .map(|x| get_luma(rgba, ((y * img_width + x) * 4) as usize))
            .collect();
        let lo = *row.iter().min().unwrap();
        let hi = *row.iter().max().unwrap();
        if hi.saturating_sub(lo) < 40 { continue; }
        let threshold = lo + (hi - lo) / 2;
        let mut edges = Vec::new();
        for x in 1..img_width as usize {
            if (row[x] >= threshold) != (row[x - 1] >= threshold) {
                edges.push(x);
            }
        }
        for e in edges.windows(6) {
            // First transition is the right edge of white cell zero.
            if row[e[0]] >= threshold { continue; }
            let cell = (e[5] - e[0]) as f32 / 5.0;
            if cell < 2.0 || e.windows(2).any(|v| ((v[1]-v[0]) as f32-cell).abs() > 1.5) { continue; }
            let start = e[0] as f32 - cell;
            if start < -1.0 { continue; }
            // Pixel rounding of individual transitions can shift the far end.
            for dw in -4..=4 {
                let x0 = start.max(0.0).round() as u32;
                let width = (cell * 40.0).round() as i32 + dw;
                if width < 41 || x0 + width as u32 > img_width { continue; }
                let py = (width as f32 / 320.0).max(1.0);
                let y1 = (y as f32 + py).round() as u32;
                if test_strip_segment(rgba, img_width, img_height, x0, x0 + width as u32, y, y1.min(img_height-1), &mut res) {
                    unsafe {
                        *out_roi = DetectedRoi {
                            bar_x: x0 as f32, bar_y: y as f32,
                            bar_w: width as f32, bar_h: py * 2.0,
                            screen_x: x0 as f32, screen_y: y as f32,
                            screen_w: width as f32, screen_h: width as f32 * 0.75,
                            locked: 1,
                        };
                        *out_result = res;
                    }
                    return 1;
                }
            }
        }
    }

    // 3. Not found: Return default center guide box without lock
    unsafe {
        let default_w = img_width as f32 * 0.70;
        let default_h = default_w * 0.75;
        let default_x = (img_width as f32 - default_w) / 2.0;
        let default_y = (img_height as f32 - default_h) / 3.0;

        *out_roi = DetectedRoi {
            bar_x: default_x,
            bar_y: default_y,
            bar_w: default_w,
            bar_h: default_h * 0.04,
            screen_x: default_x,
            screen_y: default_y,
            screen_w: default_w,
            screen_h: default_h,
            locked: 0,
        };
        *out_result = res;
    }
    0
}

mod color;
