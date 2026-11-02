//! Independently decodable IMA ADPCM blocks: 500 samples, 4 kHz mono.
use crate::color::crc32;
const STEPS: [i32; 89] = [
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66,
    73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449,
    494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272,
    2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493,
    10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767,
];
const INDEX: [i32; 8] = [-1, -1, -1, -1, 2, 4, 6, 8];
fn step(code: u8, predictor: &mut i32, index: &mut i32) -> i16 {
    let s = STEPS[*index as usize];
    let mut delta = s >> 3;
    if code & 4 != 0 {
        delta += s;
    }
    if code & 2 != 0 {
        delta += s >> 1;
    }
    if code & 1 != 0 {
        delta += s >> 2;
    }
    *predictor = (*predictor + if code & 8 != 0 { -delta } else { delta }).clamp(-32768, 32767);
    *index = (*index + INDEX[(code & 7) as usize]).clamp(0, 88);
    *predictor as i16
}
#[no_mangle]
pub unsafe extern "C" fn encode_audio_block(
    pcm: *const i16,
    count: u32,
    id: u32,
    block: u32,
    total: u32,
    out: *mut u8,
) -> i32 {
    encode_audio(pcm, count, id, block, total, out, 364, 4000, 500, b"DVS3")
}
unsafe fn encode_audio(
    pcm: *const i16,
    count: u32,
    id: u32,
    block: u32,
    total: u32,
    out: *mut u8,
    size: usize,
    rate: u32,
    n: u32,
    magic: &[u8; 4],
) -> i32 {
    if pcm.is_null() || out.is_null() || count != n || total == 0 || block >= total {
        return -1;
    }
    let samples = std::slice::from_raw_parts(pcm, n as usize);
    let p = std::slice::from_raw_parts_mut(out, size);
    p.fill(0);
    p[..4].copy_from_slice(magic);
    p[4..8].copy_from_slice(&id.to_le_bytes());
    p[8..12].copy_from_slice(&block.to_le_bytes());
    p[12..16].copy_from_slice(&total.to_le_bytes());
    p[16..20].copy_from_slice(&rate.to_le_bytes());
    p[20..22].copy_from_slice(&(n as u16).to_le_bytes());
    p[22..24].copy_from_slice(&samples[0].to_le_bytes());
    p[24] = 32;
    let mut predictor = samples[0] as i32;
    let mut index = 32i32;
    for (i, &sample) in samples.iter().enumerate() {
        let mut diff = sample as i32 - predictor;
        let mut code = 0u8;
        if diff < 0 {
            code = 8;
            diff = -diff;
        }
        let mut s = STEPS[index as usize];
        for bit in [4, 2, 1] {
            if diff >= s {
                code |= bit;
                diff -= s;
            }
            s >>= 1;
        }
        step(code, &mut predictor, &mut index);
        p[26 + i / 2] |= code << ((i % 2) * 4);
    }
    let crc = crc32(&p[..size - 4]);
    p[size - 4..].copy_from_slice(&crc.to_le_bytes());
    1
}
#[no_mangle]
pub unsafe extern "C" fn decode_audio_block(packet: *const u8, out: *mut i16) -> i32 {
    if packet.is_null() || out.is_null() {
        return -1;
    }
    let p = std::slice::from_raw_parts(packet, 364);
    if &p[..4] != b"DVS3"
        || crc32(&p[..360]) != u32::from_le_bytes(p[360..].try_into().unwrap())
        || u32::from_le_bytes(p[16..20].try_into().unwrap()) != 4000
        || u16::from_le_bytes(p[20..22].try_into().unwrap()) != 500
        || p[24] > 88
        || u32::from_le_bytes(p[8..12].try_into().unwrap())
            >= u32::from_le_bytes(p[12..16].try_into().unwrap())
    {
        return 0;
    }
    let mut predictor = i16::from_le_bytes(p[22..24].try_into().unwrap()) as i32;
    let mut index = p[24] as i32;
    let samples = std::slice::from_raw_parts_mut(out, 500);
    for (i, sample) in samples.iter_mut().enumerate() {
        *sample = step(
            (p[26 + i / 2] >> ((i % 2) * 4)) & 15,
            &mut predictor,
            &mut index,
        );
    }
    500
}

#[no_mangle]
pub unsafe extern "C" fn encode_audio_v4(
    pcm: *const i16,
    count: u32,
    id: u32,
    block: u32,
    total: u32,
    out: *mut u8,
) -> i32 {
    encode_audio(pcm, count, id, block, total, out, 446, 6000, 750, b"DVA4")
}
#[no_mangle]
pub unsafe extern "C" fn decode_audio_v4(packet: *const u8, out: *mut i16) -> i32 {
    if packet.is_null() || out.is_null() {
        return -1;
    }
    let p = std::slice::from_raw_parts(packet, 446);
    if &p[..4] != b"DVA4"
        || crc32(&p[..442]) != u32::from_le_bytes(p[442..].try_into().unwrap())
        || u32::from_le_bytes(p[16..20].try_into().unwrap()) != 6000
        || u16::from_le_bytes(p[20..22].try_into().unwrap()) != 750
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
    for (i, s) in std::slice::from_raw_parts_mut(out, 750)
        .iter_mut()
        .enumerate()
    {
        *s = step(
            (p[26 + i / 2] >> ((i % 2) * 4)) & 15,
            &mut predictor,
            &mut index,
        );
    }
    750
}
