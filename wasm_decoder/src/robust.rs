//! DVA4: protected identity, interleaved RS, confidence-weighted same-frame votes.
use crate::{color::crc32, rs};
const COLS: usize = 80;
const ROWS: usize = 24;
const N: usize = 544;
const COPIES: [usize; 3] = [0, 267, 534];
fn body_pos(i: usize) -> usize {
    if i < 255 {
        10 + i
    } else {
        277 + i - 255
    }
}
fn identity(e: &[u8]) -> Result<(u32, u16), i32> {
    let mut valid = Vec::new();
    for start in COPIES {
        let h = &e[start..start + 10];
        if crc32(&h[..6]) == u32::from_le_bytes(h[6..10].try_into().unwrap()) {
            valid.push(h[..6].to_vec());
        }
    }
    if valid.windows(2).any(|v| v[0] != v[1]) {
        return Err(6);
    }
    let mut majority = [0u8; 10];
    for i in 0..10 {
        let (a, b, c) = (e[i], e[267 + i], e[534 + i]);
        majority[i] = (a & b) | (a & c) | (b & c);
    }
    if crc32(&majority[..6]) != u32::from_le_bytes(majority[6..].try_into().unwrap()) {
        return Err(2);
    }
    if valid.iter().any(|h| h != &majority[..6]) {
        return Err(6);
    }
    Ok((
        u32::from_le_bytes(majority[..4].try_into().unwrap()),
        u16::from_le_bytes(majority[4..6].try_into().unwrap()),
    ))
}
fn pack(p: &[u8]) -> Option<[u8; N]> {
    if &p[..4] != b"DVA4" || crc32(&p[..442]) != u32::from_le_bytes(p[442..].try_into().unwrap()) {
        return None;
    }
    let index = u32::from_le_bytes(p[8..12].try_into().unwrap());
    if index > 65535 {
        return None;
    }
    let mut e = [0u8; N];
    let mut h = [0u8; 10];
    h[..4].copy_from_slice(&p[4..8]);
    h[4..6].copy_from_slice(&(index as u16).to_le_bytes());
    let c = crc32(&h[..6]);
    h[6..].copy_from_slice(&c.to_le_bytes());
    for start in COPIES {
        e[start..start + 10].copy_from_slice(&h);
    }
    let a = rs::encode(&p[..223]);
    let b = rs::encode(&p[223..]);
    for i in 0..255 {
        e[body_pos(2 * i)] = a[i];
        e[body_pos(2 * i + 1)] = b[i];
    }
    Some(e)
}
fn repair(e: &[u8], out: &mut [u8]) -> Option<usize> {
    let (id, index) = identity(e).ok()?;
    let mut a = [0u8; 255];
    let mut b = [0u8; 255];
    for i in 0..255 {
        a[i] = e[body_pos(2 * i)];
        b[i] = e[body_pos(2 * i + 1)];
    }
    let count = rs::repair(&mut a)? + rs::repair(&mut b)?;
    out[..223].copy_from_slice(&a[..223]);
    out[223..446].copy_from_slice(&b[..223]);
    if &out[..4] != b"DVA4"
        || crc32(&out[..442]) != u32::from_le_bytes(out[442..446].try_into().unwrap())
        || u32::from_le_bytes(out[4..8].try_into().unwrap()) != id
        || u32::from_le_bytes(out[8..12].try_into().unwrap()) != index as u32
    {
        return None;
    }
    Some(count)
}
#[no_mangle]
pub unsafe extern "C" fn pack_robust_frame(packet: *const u8, out: *mut u8) -> i32 {
    if packet.is_null() || out.is_null() {
        return -1;
    }
    let Some(e) = pack(std::slice::from_raw_parts(packet, 446)) else {
        return 0;
    };
    std::ptr::copy_nonoverlapping(e.as_ptr(), out, N);
    1
}
#[no_mangle]
pub unsafe extern "C" fn repair_robust_frame(envelope: *const u8, out: *mut u8) -> i32 {
    if envelope.is_null() || out.is_null() {
        return -1;
    }
    repair(
        std::slice::from_raw_parts(envelope, N),
        std::slice::from_raw_parts_mut(out, 446),
    )
    .map_or(0, |n| n as i32 + 1)
}
#[no_mangle]
pub unsafe extern "C" fn encode_robust_frame(packet: *const u8, symbols: *mut u8) -> i32 {
    if packet.is_null() || symbols.is_null() {
        return -1;
    }
    let Some(e) = pack(std::slice::from_raw_parts(packet, 446)) else {
        return 0;
    };
    crate::color::encode_grid(e.as_ptr(), symbols, COLS, ROWS, N)
}
#[no_mangle]
pub unsafe extern "C" fn encode_robust_envelope(envelope: *const u8, symbols: *mut u8) -> i32 {
    if envelope.is_null() || symbols.is_null() {
        return -1;
    }
    crate::color::encode_grid(envelope, symbols, COLS, ROWS, N)
}
pub struct Combiner {
    id: Option<(u32, u16)>,
    votes: Vec<[f32; 6]>,
    captures: u32,
}
#[no_mangle]
pub extern "C" fn robust_new() -> *mut Combiner {
    Box::into_raw(Box::new(Combiner {
        id: None,
        votes: vec![[0.; 6]; COLS * ROWS],
        captures: 0,
    }))
}
#[no_mangle]
pub unsafe extern "C" fn robust_free(p: *mut Combiner) {
    if !p.is_null() {
        drop(Box::from_raw(p));
    }
}
fn envelope(votes: &[[f32; 6]]) -> [u8; N] {
    let symbols: Vec<u8> = votes
        .iter()
        .map(|v| {
            v.iter()
                .enumerate()
                .max_by(|a, b| a.1.total_cmp(b.1))
                .unwrap()
                .0 as u8
        })
        .collect();
    let mut out = [0; N];
    for group in 0..N / 4 {
        let mut v = 0u64;
        for d in (0..13).rev() {
            let pos = group * 13 + d;
            v = v * 6 + symbols[(pos / 74) * COLS + 6 + pos % 74] as u64;
        }
        out[group * 4..group * 4 + 4].copy_from_slice(&(v as u32).to_le_bytes());
    }
    out
}
#[no_mangle]
pub unsafe extern "C" fn receive_robust_roi(
    state: *mut Combiner,
    rgba: *const u8,
    iw: u32,
    ih: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
    out: *mut u8,
    metrics: *mut u32,
) -> i32 {
    if state.is_null() || rgba.is_null() || out.is_null() || metrics.is_null() {
        return -1;
    }
    let m = std::slice::from_raw_parts_mut(metrics, 5);
    m.fill(0);
    if w < 160
        || h < 24
        || x.checked_add(w).map_or(true, |v| v > iw)
        || y.checked_add(h).map_or(true, |v| v > ih)
    {
        return -1;
    }
    let data = std::slice::from_raw_parts(rgba, iw as usize * ih as usize * 4);
    let mut votes = vec![[0f32; 6]; COLS * ROWS];
    let mut confidence = 0.;
    for row in 0..ROWS {
        let mut colors = [[0f32; 3]; COLS];
        for col in 0..COLS {
            let cx = x + (((col as f32 + 0.5) * w as f32 / COLS as f32) as u32).min(w - 1);
            let cy = y + (((row as f32 + 0.5) * h as f32 / ROWS as f32) as u32).min(h - 1);
            let rx = w / 80 / 5;
            let ry = h / 24 / 5;
            let mut n = 0.;
            for py in cy.saturating_sub(ry).max(y)..=(cy + ry).min(y + h - 1) {
                for px in cx.saturating_sub(rx).max(x)..=(cx + rx).min(x + w - 1) {
                    let i = ((py * iw + px) * 4) as usize;
                    for c in 0..3 {
                        colors[col][c] += data[i + c] as f32;
                    }
                    n += 1.;
                }
            }
            for c in 0..3 {
                colors[col][c] /= n;
            }
        }
        let mut separation = f32::MAX;
        for a in 0..6 {
            for b in a + 1..6 {
                separation =
                    separation.min((0..3).map(|c| (colors[a][c] - colors[b][c]).powi(2)).sum());
            }
        }
        if separation < 900. {
            m[0] = 1;
            return 0;
        }
        for col in 6..COLS {
            let ds: [f32; 6] = std::array::from_fn(|k| {
                (0..3)
                    .map(|c| (colors[col][c] - colors[k][c]).powi(2))
                    .sum()
            });
            let mut sorted = ds;
            sorted.sort_by(f32::total_cmp);
            let reliability = ((sorted[1] - sorted[0]) / (sorted[1] + 100.)).clamp(0.02, 1.);
            confidence += reliability;
            for k in 0..6 {
                votes[row * COLS + col][k] =
                    reliability * (-(ds[k] - sorted[0]) / (separation * 0.25)).exp();
            }
        }
    }
    m[3] = (confidence / (ROWS * 74) as f32 * 100.) as u32;
    let raw = envelope(&votes);
    let id = match identity(&raw) {
        Ok(id) => id,
        Err(stage) => {
            m[0] = stage as u32;
            return 0;
        }
    };
    let state = &mut *state;
    if state.id != Some(id) {
        state.id = Some(id);
        state.votes.fill([0.; 6]);
        state.captures = 0;
    }
    let decay = if state.captures >= 4 { 0.75 } else { 1. };
    for i in 0..votes.len() {
        for k in 0..6 {
            state.votes[i][k] = state.votes[i][k] * decay + votes[i][k];
        }
    }
    state.captures += 1;
    m[1] = state.captures;
    let output = std::slice::from_raw_parts_mut(out, 446);
    if let Some(n) = repair(&raw, output) {
        m[0] = 4;
        m[2] = n as u32;
        return 1;
    }
    let combined = envelope(&state.votes);
    if identity(&combined).ok() == Some(id) {
        if let Some(n) = repair(&combined, output) {
            m[0] = 5;
            m[2] = n as u32;
            return 1;
        }
    }
    m[0] = 3;
    0
}
