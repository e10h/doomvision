//! Configurable six-color transport. Geometry stays fixed; cells and RS lanes vary.
use crate::{color::crc32, rs};
#[derive(Clone, Copy)]
pub(crate) struct Profile {
    pub(crate) cols: usize,
    pub(crate) rows: usize,
    pub(crate) lanes: usize,
    pub(crate) lane_data: usize,
    pub(crate) packet: usize,
    pub(crate) n: usize,
}
impl Profile {
    fn new(cols: usize, rows: usize, lanes: usize) -> Option<Self> {
        Self::shortened(cols, rows, lanes, 223)
    }
    fn shortened(cols: usize, rows: usize, lanes: usize, lane_data: usize) -> Option<Self> {
        if !(32..=256).contains(&cols)
            || !(8..=128).contains(&rows)
            || !(1..=32).contains(&lanes)
            || !(31..=223).contains(&lane_data)
        {
            return None;
        }
        let n = (lanes * (lane_data + 32) + 30 + 3) / 4 * 4;
        if (cols - 6) * rows / 13 * 4 < n {
            return None;
        }
        Some(Self {
            cols,
            rows,
            lanes,
            lane_data,
            packet: lanes * lane_data,
            n,
        })
    }
    pub(crate) fn binary(cols:usize,rows:usize,lanes:usize,lane_data:usize,bits:usize)->Option<Self>{
        if !(32..=256).contains(&cols)||!(8..=128).contains(&rows)||!(1..=32).contains(&lanes)||!(31..=223).contains(&lane_data)||!(3..=10).contains(&bits){return None;}
        let n=(lanes*(lane_data+32)+33)/4*4;if(cols-11)*rows*bits/8<n{return None;}
        Some(Self{cols,rows,lanes,lane_data,packet:lanes*lane_data,n})
    }
    pub(crate) fn copies(self) -> [usize; 3] {
        [0, (self.n - 10) / 2, self.n - 10]
    }
    fn positions(self) -> Vec<usize> {
        (0..self.n)
            .filter(|i| !self.copies().iter().any(|s| *i >= *s && *i < *s + 10))
            .take(self.lanes * (self.lane_data + 32))
            .collect()
    }
}
pub(crate) fn identity(e: &[u8], p: Profile) -> Result<(u32, u16), u32> {
    let copies = p.copies();
    let mut valid = Vec::new();
    for start in copies {
        let h = &e[start..start + 10];
        if crc32(&h[..6]) == u32::from_le_bytes(h[6..].try_into().unwrap()) {
            valid.push(h[..6].to_vec());
        }
    }
    if valid.windows(2).any(|v| v[0] != v[1]) {
        return Err(6);
    }
    let mut h = [0u8; 10];
    for i in 0..10 {
        let (a, b, c) = (e[copies[0] + i], e[copies[1] + i], e[copies[2] + i]);
        h[i] = (a & b) | (a & c) | (b & c);
    }
    if crc32(&h[..6]) != u32::from_le_bytes(h[6..].try_into().unwrap()) {
        return Err(2);
    }
    if valid.iter().any(|v| v != &h[..6]) {
        return Err(6);
    }
    Ok((
        u32::from_le_bytes(h[..4].try_into().unwrap()),
        u16::from_le_bytes(h[4..6].try_into().unwrap()),
    ))
}
pub(crate) fn pack(data: &[u8], p: Profile) -> Option<Vec<u8>> {
    if &data[..4] != b"DVA5"
        || crc32(&data[..p.packet - 4])
            != u32::from_le_bytes(data[p.packet - 4..].try_into().unwrap())
    {
        return None;
    }
    let index = u32::from_le_bytes(data[8..12].try_into().unwrap());
    if index > 65535 {
        return None;
    }
    let mut e = vec![0; p.n];
    let mut h = [0; 10];
    h[..4].copy_from_slice(&data[4..8]);
    h[4..6].copy_from_slice(&(index as u16).to_le_bytes());
    let crc = crc32(&h[..6]);
    h[6..].copy_from_slice(&crc.to_le_bytes());
    for start in p.copies() {
        e[start..start + 10].copy_from_slice(&h);
    }
    let positions = p.positions();
    for lane in 0..p.lanes {
        let start = 223 - p.lane_data;
        let mut padded = [0u8; 223];
        padded[start..].copy_from_slice(&data[lane * p.lane_data..(lane + 1) * p.lane_data]);
        let code = rs::encode(&padded);
        for i in 0..p.lane_data + 32 {
            e[positions[i * p.lanes + lane]] = code[start + i];
        }
    }
    Some(e)
}
pub(crate) fn repair(e: &[u8], p: Profile, out: &mut [u8]) -> Option<usize> {
    let (id, index) = identity(e, p).ok()?;
    let positions = p.positions();
    let mut repaired = 0;
    for lane in 0..p.lanes {
        let mut code = [0; 255];
        let start = 223 - p.lane_data;
        for i in 0..p.lane_data + 32 {
            code[start + i] = e[positions[i * p.lanes + lane]];
        }
        repaired += rs::repair(&mut code)?;
        if code[..start].iter().any(|&b| b != 0) {
            return None;
        }
        out[lane * p.lane_data..(lane + 1) * p.lane_data].copy_from_slice(&code[start..223]);
    }
    if &out[..4] != b"DVA5"
        || crc32(&out[..p.packet - 4])
            != u32::from_le_bytes(out[p.packet - 4..].try_into().unwrap())
        || u32::from_le_bytes(out[4..8].try_into().unwrap()) != id
        || u32::from_le_bytes(out[8..12].try_into().unwrap()) != index as u32
    {
        return None;
    }
    Some(repaired)
}
pub struct Flex {
    p: Profile,
    id: Option<(u32, u16)>,
    votes: Vec<[f32; 6]>,
    captures: u32,
}
#[no_mangle]
pub extern "C" fn flex_new(cols: u32, rows: u32, lanes: u32) -> *mut Flex {
    let Some(p) = Profile::new(cols as usize, rows as usize, lanes as usize) else {
        return std::ptr::null_mut();
    };
    Box::into_raw(Box::new(Flex {
        p,
        id: None,
        votes: vec![[0.; 6]; p.cols * p.rows],
        captures: 0,
    }))
}
#[no_mangle]
pub extern "C" fn flex_new_profile(cols: u32, rows: u32, lanes: u32, lane_data: u32) -> *mut Flex {
    let Some(p) = Profile::shortened(
        cols as usize,
        rows as usize,
        lanes as usize,
        lane_data as usize,
    ) else {
        return std::ptr::null_mut();
    };
    Box::into_raw(Box::new(Flex {
        p,
        id: None,
        votes: vec![[0.; 6]; p.cols * p.rows],
        captures: 0,
    }))
}
fn frame_samples(rate: u32, fps: u32, index: u32) -> u32 {
    (((index as u64 + 1) * rate as u64 / fps as u64) - (index as u64 * rate as u64 / fps as u64))
        as u32
}
#[no_mangle]
pub unsafe extern "C" fn flex_free(state: *mut Flex) {
    if !state.is_null() {
        drop(Box::from_raw(state));
    }
}
#[no_mangle]
pub unsafe extern "C" fn flex_encode(
    state: *const Flex,
    packet: *const u8,
    symbols: *mut u8,
) -> i32 {
    if state.is_null() || packet.is_null() || symbols.is_null() {
        return -1;
    }
    let p = (*state).p;
    let Some(e) = pack(std::slice::from_raw_parts(packet, p.packet), p) else {
        return 0;
    };
    crate::color::encode_grid(e.as_ptr(), symbols, p.cols, p.rows, p.n)
}
fn envelope(votes: &[[f32; 6]], p: Profile) -> Vec<u8> {
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
    let mut out = vec![0; p.n];
    for group in 0..p.n / 4 {
        let mut v = 0u64;
        for d in (0..13).rev() {
            let pos = group * 13 + d;
            v = v * 6 + symbols[(pos / (p.cols - 6)) * p.cols + 6 + pos % (p.cols - 6)] as u64;
        }
        out[group * 4..group * 4 + 4].copy_from_slice(&(v as u32).to_le_bytes());
    }
    out
}
#[no_mangle]
pub unsafe extern "C" fn flex_receive(
    state: *mut Flex,
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
    state: *mut Flex,
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
    let state = &mut *state;
    let p = state.p;
    let m = std::slice::from_raw_parts_mut(metrics, 5);
    m.fill(0);
    if w < (p.cols * 2) as u32
        || h < p.rows as u32
        || x.checked_add(w).map_or(true, |v| v > iw)
        || y.checked_add(h).map_or(true, |v| v > ih)
    {
        return -1;
    }
    let data = std::slice::from_raw_parts(rgba, iw as usize * ih as usize * 4);
    let mut votes = vec![[0.; 6]; p.cols * p.rows];
    let mut confidence = 0.;
    for row in 0..p.rows {
        let mut colors = vec![[0f32; 3]; p.cols];
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
        for col in 6..p.cols {
            let ds: [f32; 6] = std::array::from_fn(|k| {
                (0..3)
                    .map(|c| (colors[col][c] - colors[k][c]).powi(2))
                    .sum()
            });
            let mut sorted = ds;
            sorted.sort_by(f32::total_cmp);
            let weight = ((sorted[1] - sorted[0]) / (sorted[1] + 100.)).clamp(0.02, 1.);
            confidence += weight;
            for k in 0..6 {
                votes[row * p.cols + col][k] =
                    weight * (-(ds[k] - sorted[0]) / (separation * 0.25)).exp();
            }
        }
    }
    m[3] = (confidence / (p.rows * (p.cols - 6)) as f32 * 100.) as u32;
    let raw = envelope(&votes, p);
    let id = match identity(&raw, p) {
        Ok(v) => v,
        Err(stage) => {
            m[0] = stage;
            return 0;
        }
    };
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
    let out = std::slice::from_raw_parts_mut(out, p.packet);
    if let Some(n) = repair(&raw, p, out) {
        m[0] = 4;
        m[2] = n as u32;
        return 1;
    }
    let combined = envelope(&state.votes, p);
    if identity(&combined, p).ok() == Some(id) {
        if let Some(n) = repair(&combined, p, out) {
            m[0] = 5;
            m[2] = n as u32;
            return 1;
        }
    }
    m[0] = 3;
    0
}
#[no_mangle]
pub unsafe extern "C" fn encode_audio_v5(
    pcm: *const i16,
    count: u32,
    id: u32,
    index: u32,
    total: u32,
    rate: u32,
    fps: u32,
    size: u32,
    out: *mut u8,
) -> i32 {
    if ![4, 8, 16].contains(&fps)
        || rate < 250
        || rate > 32000
        || count != frame_samples(rate, fps, index)
        || size < 30 + count.div_ceil(2)
        || size > 223 * 32
    {
        return -1;
    }
    let ok = crate::live::encode_audio(
        pcm,
        count,
        id,
        index,
        total,
        out,
        size as usize,
        rate,
        count,
        b"DVA5",
    );
    if ok != 1 {
        return ok;
    }
    let p = std::slice::from_raw_parts_mut(out, size as usize);
    p[25] = fps as u8;
    let crc = crc32(&p[..size as usize - 4]);
    p[size as usize - 4..].copy_from_slice(&crc.to_le_bytes());
    1
}
#[no_mangle]
pub unsafe extern "C" fn decode_audio_v5(packet: *const u8, size: u32, out: *mut i16) -> i32 {
    if packet.is_null() || out.is_null() || size < 31 || size > 223 * 32 {
        return -1;
    }
    let p = std::slice::from_raw_parts(packet, size as usize);
    let rate = u32::from_le_bytes(p[16..20].try_into().unwrap());
    let n = u16::from_le_bytes(p[20..22].try_into().unwrap()) as u32;
    let fps = p[25] as u32;
    if &p[..4] != b"DVA5"
        || crc32(&p[..p.len() - 4]) != u32::from_le_bytes(p[p.len() - 4..].try_into().unwrap())
        || ![4, 8, 16].contains(&fps)
        || rate < 250
        || rate > 32000
        || n != frame_samples(rate, fps, u32::from_le_bytes(p[8..12].try_into().unwrap()))
        || 26 + n.div_ceil(2) > size - 4
        || p[24] > 88
        || u32::from_le_bytes(p[8..12].try_into().unwrap())
            >= u32::from_le_bytes(p[12..16].try_into().unwrap())
    {
        return 0;
    }
    let (mut predictor, mut index) = (
        i16::from_le_bytes(p[22..24].try_into().unwrap()) as i32,
        p[24] as i32,
    );
    for (i, s) in std::slice::from_raw_parts_mut(out, n as usize)
        .iter_mut()
        .enumerate()
    {
        *s = crate::live::step(
            (p[26 + i / 2] >> ((i % 2) * 4)) & 15,
            &mut predictor,
            &mut index,
        );
    }
    n as i32
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn shortened_blocks_correct_errors() {
        for length in [31, 38, 46, 62, 94, 155, 218, 223] {
            let p = Profile::shortened(128, 64, 1, length).unwrap();
            let mut data: Vec<u8> = (0..length).map(|i| ((i * 73 + 19) % 256) as u8).collect();
            data[..4].copy_from_slice(b"DVA5");
            data[8..12].copy_from_slice(&42u32.to_le_bytes());
            let crc = crc32(&data[..length - 4]);
            data[length - 4..].copy_from_slice(&crc.to_le_bytes());
            let original = pack(&data, p).unwrap();
            let positions = p.positions();
            let mut e = original.clone();
            for i in 0..16 {
                e[positions[i]] ^= 0x93;
            }
            let mut out = vec![0; length];
            assert_eq!(repair(&e, p, &mut out), Some(16));
            assert_eq!(out, data);
            let mut e = original;
            for i in 0..17 {
                e[positions[i]] ^= 0x81;
            }
            assert!(repair(&e, p, &mut out).is_none());
        }
    }
    #[test]
    fn dynamic_interleaving_and_bounds() {
        assert!(Profile::new(80, 24, 10).is_none());
        for lanes in [1, 2, 5, 10, 19, 32] {
            let p = Profile::new(256, 128, lanes).unwrap();
            let mut data: Vec<u8> = (0..p.packet).map(|i| ((i * 73 + 19) % 256) as u8).collect();
            data[..4].copy_from_slice(b"DVA5");
            data[8..12].copy_from_slice(&42u32.to_le_bytes());
            let crc = crc32(&data[..p.packet - 4]);
            data[p.packet - 4..].copy_from_slice(&crc.to_le_bytes());
            let original = pack(&data, p).unwrap();
            let positions = p.positions();
            let mut e = original.clone();
            for i in 0..lanes * 16 {
                e[positions[i]] ^= 0x93;
            }
            let mut out = vec![0; p.packet];
            assert_eq!(repair(&e, p, &mut out), Some(lanes * 16));
            assert_eq!(out, data);
            let mut e = original;
            for i in 0..17 {
                e[positions[i * lanes]] ^= 0x81;
            }
            assert!(repair(&e, p, &mut out).is_none());
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn flex_trial(
    state: *const Flex,
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
    let p = (*state).p;
    let mut trial = Flex {
        p,
        id: None,
        votes: vec![[0.; 6]; p.cols * p.rows],
        captures: 0,
    };
    receive(&mut trial, rgba, iw, ih, x, y, w, h, out, metrics, dx, dy)
}
