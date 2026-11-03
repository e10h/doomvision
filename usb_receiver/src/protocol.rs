pub const RATE: u32 = 8000;
pub const SAMPLES: usize = 128;
pub const SIZE: usize = 16 + SAMPLES * 2;
#[derive(Debug)]
pub struct Packet {
    pub sequence: u32,
    pub rate: u32,
    pub flags: u16,
    pub pcm: Vec<i16>,
}
#[derive(Default)]
pub struct Decoder {
    buffer: Vec<u8>,
}
impl Decoder {
    pub fn feed(&mut self, bytes: &[u8]) -> Vec<Packet> {
        self.buffer.extend_from_slice(bytes);
        let mut out = Vec::new();
        loop {
            let Some(start) = self.buffer.windows(4).position(|x| x == b"DVU1") else {
                let keep = self.buffer.len().min(3);
                self.buffer.drain(..self.buffer.len() - keep);
                break;
            };
            self.buffer.drain(..start);
            if self.buffer.len() < 16 {
                break;
            }
            let h = &self.buffer[..16];
            let rate = u32::from_le_bytes(h[8..12].try_into().unwrap());
            let count = u16::from_le_bytes(h[12..14].try_into().unwrap()) as usize;
            let flags = u16::from_le_bytes(h[14..16].try_into().unwrap());
            let valid = (rate == RATE || rate == RATE * 2) && count == SAMPLES;
            if !valid || flags & !3 != 0 {
                self.buffer.remove(0);
                continue;
            }
            let size = SIZE;
            if self.buffer.len() < size {
                break;
            }
            let sequence = u32::from_le_bytes(self.buffer[4..8].try_into().unwrap());
            let pcm = self.buffer[16..size]
                .chunks_exact(2)
                .map(|b| i16::from_le_bytes([b[0], b[1]]))
                .collect();
            out.push(Packet {
                sequence,
                rate,
                flags,
                pcm,
            });
            self.buffer.drain(..size);
        }
        out
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    fn packet(seq: u32) -> Vec<u8> {
        let mut p = b"DVU1".to_vec();
        p.extend(seq.to_le_bytes());
        p.extend(RATE.to_le_bytes());
        p.extend((SAMPLES as u16).to_le_bytes());
        p.extend(1u16.to_le_bytes());
        for i in 0..SAMPLES {
            p.extend(((i as i16) * -100).to_le_bytes());
        }
        p
    }
    #[test]
    fn fragmented_and_joined() {
        let mut d = Decoder::default();
        let bytes = [b"noise".as_slice(), &packet(7), &packet(8)].concat();
        let mut got = Vec::new();
        for b in bytes {
            got.extend(d.feed(&[b]));
        }
        assert_eq!(got.len(), 2);
        assert_eq!(got[0].sequence, 7);
        assert_eq!(got[1].flags, 1);
        assert_eq!(got[0].pcm[127], -12700);
    }
    #[test]
    fn invalid_header_resync() {
        let mut d = Decoder::default();
        let mut bad = packet(0);
        bad[12] = 255;
        let bytes = [bad, packet(10)].concat();
        let p = d.feed(&bytes);
        assert_eq!(p.len(), 1);
        assert_eq!(p[0].sequence, 10);
        assert!(d.buffer.len() < SIZE);
    }
    #[test]
    fn joined_and_short_tail() {
        let mut d = Decoder::default();
        let bytes = [packet(0), packet(1), packet(2)].concat();
        assert_eq!(d.feed(&bytes[..bytes.len() - 1]).len(), 2);
        assert_eq!(d.feed(&bytes[bytes.len() - 1..]).len(), 1);
    }
}
