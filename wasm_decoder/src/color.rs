//! Six-color transport. Audio is opaque bytes, never sound trigger flags.
const COLS: usize = 40;
const ROWS: usize = 6;
const PACKET: usize = 60;

pub fn crc32(bytes: &[u8]) -> u32 {
    let mut crc = !0u32;
    for &b in bytes {
        crc ^= b as u32;
        for _ in 0..8 { crc = (crc >> 1) ^ (0xedb88320u32 & 0u32.wrapping_sub(crc & 1)); }
    }
    !crc
}

#[no_mangle]
pub unsafe extern "C" fn encode_color_packet(bytes: *const u8, symbols: *mut u8) -> i32 {
    if bytes.is_null() || symbols.is_null() { return -1; }
    encode_grid(bytes, symbols, COLS, ROWS, PACKET)
}

unsafe fn encode_grid(bytes: *const u8, symbols: *mut u8, cols: usize, rows: usize, packet: usize) -> i32 {
    let bytes = std::slice::from_raw_parts(bytes, packet);
    let out = std::slice::from_raw_parts_mut(symbols, cols * rows);
    out.fill(5);
    for row in 0..rows { for c in 0..6 { out[row * cols + c] = c as u8; } }
    for group in 0..packet/4 {
        let mut value = u32::from_le_bytes(bytes[group*4..group*4+4].try_into().unwrap()) as u64;
        for digit in 0..13 {
            let pos = group * 13 + digit;
            out[(pos / (cols-6)) * cols + 6 + pos % (cols-6)] = (value % 6) as u8;
            value /= 6;
        }
    }
    1
}

#[no_mangle]
pub unsafe extern "C" fn decode_color_roi(
    rgba: *const u8, width: u32, height: u32,
    x: u32, y: u32, w: u32, h: u32, out: *mut u8,
) -> i32 {
    decode_grid(rgba,width,height,x,y,w,h,out,COLS,ROWS,PACKET,b"DVC2")
}

unsafe fn decode_grid(rgba: *const u8, width:u32, height:u32,x:u32,y:u32,w:u32,h:u32,out:*mut u8,cols:usize,rows:usize,packet_size:usize,magic:&[u8;4]) -> i32 {
    if rgba.is_null() || out.is_null() || w < (cols*2) as u32 || h < rows as u32 ||
        x.checked_add(w).map_or(true, |end| end > width) ||
        y.checked_add(h).map_or(true, |end| end > height) { return -1; }
    let Some(len) = (width as usize).checked_mul(height as usize).and_then(|n| n.checked_mul(4)) else { return -1; };
    let pixels = std::slice::from_raw_parts(rgba, len);
    let mut symbols = vec![0u8; cols * rows];
    for row in 0..rows {
        let mut samples = vec![[0f32;3]; cols];
        for col in 0..cols {
            // Average only the center of each cell to avoid edge blending.
            let cx = x + (((col as f32 + 0.5) * w as f32 / cols as f32) as u32).min(w-1);
            let cy = y + (((row as f32 + 0.5) * h as f32 / rows as f32) as u32).min(h-1);
            let radius = (w / cols as u32 / 5).max(0);
            let mut count = 0f32;
            for sx in cx.saturating_sub(radius).max(x)..=(cx+radius).min(x+w-1) {
                let i = ((cy as usize * width as usize) + sx as usize) * 4;
                for c in 0..3 { samples[col][c] += pixels[i+c] as f32; }
                count += 1.0;
            }
            for c in 0..3 { samples[col][c] /= count; }
        }
        // Six known pilots per row calibrate screen colors and white balance.
        for a in 0..6 { for b in a+1..6 {
            let d: f32 = (0..3).map(|c| (samples[a][c]-samples[b][c]).powi(2)).sum();
            if d < 1600.0 { return 0; }
        }}
        for col in 6..cols {
            let mut distances: Vec<(usize,f32)> = (0..6).map(|k| (k, (0..3).map(|c| (samples[col][c]-samples[k][c]).powi(2)).sum())).collect();
            distances.sort_by(|a,b| a.1.total_cmp(&b.1));
            if distances[0].1 > 15000.0 || distances[0].1 * 1.8 + 100.0 > distances[1].1 { return 0; }
            symbols[row*cols+col] = distances[0].0 as u8;
        }
    }
    let mut packet = vec![0u8; packet_size];
    for group in 0..packet_size/4 {
        let mut value = 0u64;
        for digit in (0..13).rev() {
            let pos = group * 13 + digit;
            value = value * 6 + symbols[(pos/(cols-6))*cols+6+pos%(cols-6)] as u64;
        }
        if value > u32::MAX as u64 { return 0; }
        packet[group*4..group*4+4].copy_from_slice(&(value as u32).to_le_bytes());
    }
    if &packet[..4] != magic || crc32(&packet[..packet_size-4]) != u32::from_le_bytes(packet[packet_size-4..].try_into().unwrap()) { return 0; }
    std::ptr::copy_nonoverlapping(packet.as_ptr(), out, packet_size);
    1
}


#[no_mangle]
pub unsafe extern "C" fn encode_live_packet(bytes:*const u8,symbols:*mut u8)->i32 {
    if bytes.is_null() || symbols.is_null() { return -1; }
    encode_grid(bytes,symbols,80,16,364)
}
#[no_mangle]
pub unsafe extern "C" fn decode_live_roi(rgba:*const u8,width:u32,height:u32,x:u32,y:u32,w:u32,h:u32,out:*mut u8)->i32 {
    decode_grid(rgba,width,height,x,y,w,h,out,80,16,364,b"DVS3")
}
