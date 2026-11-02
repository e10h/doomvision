//! Calibrated RGB constellations, Gray labeling, and Gaussian max-log bit evidence.
use crate::{
    color::crc32,
    flex::{identity, pack, repair, Profile},
};
const PILOTS: usize = 11;
const CAL: [[f32; 3]; 11] = [
    [0., 0., 0.],
    [255., 0., 0.],
    [0., 255., 0.],
    [255., 255., 0.],
    [0., 0., 255.],
    [255., 0., 255.],
    [0., 255., 255.],
    [255., 255., 255.],
    [64., 64., 64.],
    [128., 128., 128.],
    [192., 192., 192.],
];
fn gray_decode(mut g: usize) -> usize {
    let mut b = 0;
    while g != 0 {
        b ^= g;
        g >>= 1;
    }
    b
}
fn color(index: usize, bits: usize) -> [f32; 3] {
    let sizes = [(bits + 2) / 3, (bits + 1) / 3, bits / 3];
    let mut offset = 0;
    std::array::from_fn(|c| {
        let max = (1 << sizes[c]) - 1;
        let level = gray_decode((index >> offset) & max);
        offset += sizes[c];
        (level as f32 / max as f32 * 255.).round()
    })
}
fn predict(rgb: [f32; 3], refs: &[[f32; 3]], gamma: [f32; 3], output_gamma: [f32; 3]) -> [f32; 3] {
    let axes: [f32; 3] = std::array::from_fn(|c| (rgb[c] / 255.).powf(gamma[c]));
    let mut out = [0.; 3];
    for k in 0..8 {
        let weight = (0..3)
            .map(|c| {
                if k & (1 << c) != 0 {
                    axes[c]
                } else {
                    1. - axes[c]
                }
            })
            .product::<f32>();
        for c in 0..3 {
            out[c] += weight * refs[k][c];
        }
    }
    std::array::from_fn(|c| out[c].clamp(0., 1.).powf(1. / output_gamma[c]) * 255.)
}
pub struct Palette {
    p: Profile,
    bits: usize,
    colors: usize,
    id: Option<(u32, u16)>,
    llr: Vec<f32>,
    captures: u32,
}
#[no_mangle]
pub extern "C" fn palette_new(
    cols: u32,
    rows: u32,
    lanes: u32,
    lane_data: u32,
    colors: u32,
) -> *mut Palette {
    if ![8, 16, 32, 64, 128, 256, 512, 1024].contains(&colors) {
        return std::ptr::null_mut();
    }
    let bits = colors.ilog2() as usize;
    let Some(p) = Profile::binary(
        cols as usize,
        rows as usize,
        lanes as usize,
        lane_data as usize,
        bits,
    ) else {
        return std::ptr::null_mut();
    };
    Box::into_raw(Box::new(Palette {
        p,
        bits,
        colors: colors as usize,
        id: None,
        llr: vec![0.; p.n * 8],
        captures: 0,
    }))
}
#[no_mangle]
pub unsafe extern "C" fn palette_free(p: *mut Palette) {
    if !p.is_null() {
        drop(Box::from_raw(p));
    }
}
#[no_mangle]
pub unsafe extern "C" fn palette_encode(
    state: *const Palette,
    packet: *const u8,
    symbols: *mut u16,
) -> i32 {
    if state.is_null() || packet.is_null() || symbols.is_null() {
        return -1;
    }
    let s = &*state;
    let Some(e) = pack(std::slice::from_raw_parts(packet, s.p.packet), s.p) else {
        return 0;
    };
    let out = std::slice::from_raw_parts_mut(symbols, s.p.cols * s.p.rows);
    out.fill(0);
    for row in 0..s.p.rows {
        for col in 0..PILOTS {
            out[row * s.p.cols + col] = (s.colors + col) as u16;
        }
    }
    for symbol in 0..(e.len() * 8).div_ceil(s.bits) {
        let mut value = 0;
        for b in 0..s.bits {
            let i = symbol * s.bits + b;
            if i < e.len() * 8 {
                value |= (((e[i / 8] >> (i % 8)) & 1) as u16) << b;
            }
        }
        out[(symbol / (s.p.cols - PILOTS)) * s.p.cols + PILOTS + symbol % (s.p.cols - PILOTS)] =
            value;
    }
    1
}
fn hard(llr: &[f32]) -> Vec<u8> {
    let mut e = vec![0; llr.len() / 8];
    for (i, &v) in llr.iter().enumerate() {
        if v > 0. {
            e[i / 8] |= 1 << (i % 8);
        }
    }
    e
}
fn soft_identity(e: &mut [u8], llr: &[f32], p: Profile) -> Result<(u32, u16), u32> {
    match identity(e, p) {
        Ok(id) => return Ok(id),
        Err(6) => return Err(6),
        _ => {}
    }
    let mut header = [0u8; 10];
    let copies = p.copies();
    for bit in 0..80 {
        let evidence = copies.iter().map(|start| llr[start * 8 + bit]).sum::<f32>();
        if evidence > 0. {
            header[bit / 8] |= 1 << (bit % 8);
        }
    }
    if crc32(&header[..6]) != u32::from_le_bytes(header[6..].try_into().unwrap()) {
        return Err(2);
    }
    for start in copies {
        let h = &e[start..start + 10];
        if crc32(&h[..6]) == u32::from_le_bytes(h[6..].try_into().unwrap()) && h[..6] != header[..6]
        {
            return Err(6);
        }
    }
    for start in copies {
        e[start..start + 10].copy_from_slice(&header);
    }
    identity(e, p)
}
#[no_mangle]
pub unsafe extern "C" fn palette_receive(
    state: *mut Palette,
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
    receive(state, rgba, iw, ih, x, y, w, h, out, metrics, 0., 0.)
}
unsafe fn receive(
    state: *mut Palette,
    rgba: *const u8,
    iw: u32,
    ih: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
    out: *mut u8,
    metrics: *mut u32,
    dx: f32,
    dy: f32,
) -> i32 {
    if state.is_null() || rgba.is_null() || out.is_null() || metrics.is_null() {
        return -1;
    }
    let s = &mut *state;
    let p = s.p;
    let m = std::slice::from_raw_parts_mut(metrics, 5);
    m.fill(0);
    if w < (p.cols * 2) as u32
        || h < p.rows as u32
        || x.checked_add(w).map_or(true, |v| v > iw)
        || y.checked_add(h).map_or(true, |v| v > ih)
    {
        return -1;
    }
    let pixels = std::slice::from_raw_parts(rgba, iw as usize * ih as usize * 4);
    let mut llr = vec![0.; p.n * 8];
    let mut confidence = 0.;
    let mut used = 0;
    for row in 0..p.rows {
        let mut samples = vec![[0f32; 3]; p.cols];
        let mut variances = vec![[0f32; 3]; p.cols];
        for col in 0..p.cols {
            let cx = x
                + (((col as f32 + 0.5) * w as f32 / p.cols as f32 + dx).max(0.) as u32).min(w - 1);
            let cy = y
                + (((row as f32 + 0.5) * h as f32 / p.rows as f32 + dy).max(0.) as u32).min(h - 1);
            let rx = w / p.cols as u32 / 5;
            let ry = h / p.rows as u32 / 5;
            let mut n = 0.;
            for py in cy.saturating_sub(ry).max(y)..=(cy + ry).min(y + h - 1) {
                for px in cx.saturating_sub(rx).max(x)..=(cx + rx).min(x + w - 1) {
                    let index = ((py * iw + px) * 4) as usize;
                    for c in 0..3 {
                        let v = pixels[index + c] as f32;
                        samples[col][c] += v;
                        variances[col][c] += v * v;
                    }
                    n += 1.;
                }
            }
            for c in 0..3 {
                samples[col][c] /= n;
                variances[col][c] = (variances[col][c] / n - samples[col][c].powi(2)).max(0.);
            }
        }
        if (0..3).any(|c| samples[7][c] - samples[0][c] < 35.) {
            m[0] = 1;
            return 0;
        }
        // Fit camera/output transfer from additive RGB-corner relationships,
        // then fit display/input transfer from grey patches. Interpolating
        // encoded RGB directly gives incorrect mixed-color predictions.
        let output_gamma: [f32; 3] = std::array::from_fn(|c| {
            let mut best = (f32::MAX, 1.);
            for step in 10..=70 {
                let g = step as f32 * 0.05;
                let v: Vec<f32> = (0..8).map(|k| (samples[k][c] / 255.).powf(g)).collect();
                let predictions = [
                    v[1] + v[2] - v[0],
                    v[1] + v[4] - v[0],
                    v[2] + v[4] - v[0],
                    v[1] + v[2] + v[4] - 2. * v[0],
                ];
                let score = predictions
                    .iter()
                    .zip([3, 5, 6, 7])
                    .map(|(pred, k)| (pred.clamp(0., 1.) - v[k]).powi(2))
                    .sum::<f32>()
                    + 0.00001 * (g - 1.).powi(2);
                if score < best.0 {
                    best = (score, g);
                }
            }
            best.1
        });
        let linear_refs: Vec<[f32; 3]> = (0..8)
            .map(|k| std::array::from_fn(|c| (samples[k][c] / 255.).powf(output_gamma[c])))
            .collect();
        let gamma = std::array::from_fn(|c| {
            let mut total = 0.;
            for k in 8..11 {
                let value = (((samples[k][c] / 255.).powf(output_gamma[c]) - linear_refs[0][c])
                    / (linear_refs[7][c] - linear_refs[0][c]))
                    .clamp(0.001, 0.999);
                total += value.ln() / (CAL[k][c] / 255.).ln();
            }
            (total / 3.).clamp(0.35, 4.)
        });
        let mut residual = [0.; 3];
        for k in 8..11 {
            let expected = predict(CAL[k], &linear_refs, gamma, output_gamma);
            for c in 0..3 {
                residual[c] += (samples[k][c] - expected[c]).powi(2) / 3.;
            }
        }
        let palette: Vec<[f32; 3]> = (0..s.colors)
            .map(|k| predict(color(k, s.bits), &linear_refs, gamma, output_gamma))
            .collect();
        for col in PILOTS..p.cols {
            let symbol = row * (p.cols - PILOTS) + col - PILOTS;
            if symbol * s.bits >= llr.len() {
                break;
            }
            let noise: [f32; 3] =
                std::array::from_fn(|c| (variances[col][c] + residual[c] + 16.).clamp(16., 2500.));
            let mut zero = [f32::MAX; 10];
            let mut one = [f32::MAX; 10];
            for (k, expected) in palette.iter().enumerate() {
                let distance = (0..3)
                    .map(|c| (samples[col][c] - expected[c]).powi(2) / noise[c])
                    .sum::<f32>();
                for b in 0..s.bits {
                    if k & (1 << b) == 0 {
                        zero[b] = zero[b].min(distance);
                    } else {
                        one[b] = one[b].min(distance);
                    }
                }
            }
            for b in 0..s.bits {
                let i = symbol * s.bits + b;
                if i >= llr.len() {
                    break;
                }
                let value = ((zero[b] - one[b]) * 0.5).clamp(-8., 8.);
                llr[i] = value;
                confidence += value.abs() / (value.abs() + 2.);
                used += 1;
            }
        }
    }
    m[3] = (confidence / used.max(1) as f32 * 100.) as u32;
    let mut raw = hard(&llr);
    let id = match soft_identity(&mut raw, &llr, p) {
        Ok(v) => v,
        Err(stage) => {
            m[0] = stage;
            return 0;
        }
    };
    if s.id != Some(id) {
        s.id = Some(id);
        s.llr.fill(0.);
        s.captures = 0;
    }
    let decay = if s.captures >= 4 { 0.75 } else { 1. };
    for i in 0..llr.len() {
        s.llr[i] = s.llr[i] * decay + llr[i];
    }
    s.captures += 1;
    m[1] = s.captures;
    let output = std::slice::from_raw_parts_mut(out, p.packet);
    if let Some(n) = repair(&raw, p, output) {
        m[0] = 4;
        m[2] = n as u32;
        return 1;
    }
    let mut combined = hard(&s.llr);
    if soft_identity(&mut combined, &s.llr, p).ok() == Some(id) {
        if let Some(n) = repair(&combined, p, output) {
            m[0] = 5;
            m[2] = n as u32;
            return 1;
        }
    }
    m[0] = 3;
    0
}
#[no_mangle]
pub unsafe extern "C" fn palette_trial(
    state: *const Palette,
    rgba: *const u8,
    iw: u32,
    ih: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
    out: *mut u8,
    metrics: *mut u32,
    dx: f32,
    dy: f32,
) -> i32 {
    if state.is_null() || dx.abs() > 1. || dy.abs() > 1. {
        return -1;
    }
    let s = &*state;
    let mut trial = Palette {
        p: s.p,
        bits: s.bits,
        colors: s.colors,
        id: None,
        llr: vec![0.; s.p.n * 8],
        captures: 0,
    };
    receive(&mut trial, rgba, iw, ih, x, y, w, h, out, metrics, dx, dy)
}
