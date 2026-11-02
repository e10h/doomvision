//! Systematic RS(255,223), GF(256), polynomial 0x11d, roots alpha^0..31.
const fn tables() -> ([u8; 512], [u8; 256]) {
    let mut e = [0; 512];
    let mut l = [0; 256];
    let mut x = 1u16;
    let mut i = 0;
    while i < 255 {
        e[i] = x as u8;
        l[x as usize] = i as u8;
        x <<= 1;
        if x & 256 != 0 {
            x ^= 0x11d;
        }
        i += 1;
    }
    while i < 512 {
        e[i] = e[i - 255];
        i += 1;
    }
    (e, l)
}
const T: ([u8; 512], [u8; 256]) = tables();
fn mul(a: u8, b: u8) -> u8 {
    if a == 0 || b == 0 {
        0
    } else {
        T.0[T.1[a as usize] as usize + T.1[b as usize] as usize]
    }
}
fn div(a: u8, b: u8) -> u8 {
    if a == 0 {
        0
    } else {
        T.0[(T.1[a as usize] as usize + 255 - T.1[b as usize] as usize) % 255]
    }
}
fn syndromes(c: &[u8; 255]) -> [u8; 32] {
    std::array::from_fn(|i| c.iter().fold(0, |s, &b| mul(s, T.0[i]) ^ b))
}
pub fn encode(data: &[u8]) -> [u8; 255] {
    assert_eq!(data.len(), 223);
    let mut generator = vec![1u8];
    for i in 0..32 {
        let mut next = vec![0; generator.len() + 1];
        for (j, &b) in generator.iter().enumerate() {
            next[j] ^= b;
            next[j + 1] ^= mul(b, T.0[i]);
        }
        generator = next;
    }
    let mut work = [0; 255];
    work[..223].copy_from_slice(data);
    for i in 0..223 {
        let b = work[i];
        if b != 0 {
            for j in 0..33 {
                work[i + j] ^= mul(b, generator[j]);
            }
        }
    }
    work[..223].copy_from_slice(data);
    work
}
pub fn repair(c: &mut [u8; 255]) -> Option<usize> {
    let s = syndromes(c);
    if s.iter().all(|&n| n == 0) {
        return Some(0);
    }
    let mut locator = [0u8; 33];
    let mut old = [0u8; 33];
    locator[0] = 1;
    old[0] = 1;
    let (mut degree, mut shift, mut previous) = (0usize, 1usize, 1u8);
    for n in 0..32 {
        let mut d = s[n];
        for i in 1..=degree {
            d ^= mul(locator[i], s[n - i]);
        }
        if d == 0 {
            shift += 1;
            continue;
        }
        let saved = locator;
        let scale = div(d, previous);
        for j in 0..33 - shift {
            locator[j + shift] ^= mul(scale, old[j]);
        }
        if 2 * degree <= n {
            degree = n + 1 - degree;
            old = saved;
            previous = d;
            shift = 1;
        } else {
            shift += 1;
        }
    }
    if degree == 0 || degree > 16 {
        return None;
    }
    let mut positions = Vec::new();
    let mut xs = Vec::new();
    for p in 0..255 {
        let power = 254 - p;
        let inv = T.0[(255 - power) % 255];
        let mut val = 0;
        for i in (0..=degree).rev() {
            val = mul(val, inv) ^ locator[i];
        }
        if val == 0 {
            positions.push(p);
            xs.push(T.0[power]);
        }
    }
    if positions.len() != degree {
        return None;
    }
    let mut a = vec![vec![0u8; degree + 1]; degree];
    for r in 0..degree {
        for col in 0..degree {
            let mut v = 1;
            for _ in 0..r {
                v = mul(v, xs[col]);
            }
            a[r][col] = v;
        }
        a[r][degree] = s[r];
    }
    for col in 0..degree {
        let pivot = (col..degree).find(|&r| a[r][col] != 0)?;
        a.swap(col, pivot);
        let d = a[col][col];
        for j in col..=degree {
            a[col][j] = div(a[col][j], d);
        }
        for r in 0..degree {
            if r != col {
                let f = a[r][col];
                for j in col..=degree {
                    a[r][j] ^= mul(f, a[col][j]);
                }
            }
        }
    }
    for i in 0..degree {
        c[positions[i]] ^= a[i][degree];
    }
    if syndromes(c).iter().all(|&n| n == 0) {
        Some(degree)
    } else {
        None
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn repairs_random_errors() {
        let mut seed = 17u32;
        for n in 0..=16 {
            for _ in 0..20 {
                let data: Vec<u8> = (0..223)
                    .map(|_| {
                        seed = seed.wrapping_mul(1664525).wrapping_add(1013904223);
                        (seed >> 24) as u8
                    })
                    .collect();
                let original = encode(&data);
                let mut c = original;
                let mut used = vec![];
                while used.len() < n {
                    seed = seed.wrapping_mul(1664525).wrapping_add(1013904223);
                    let p = (seed % 255) as usize;
                    if !used.contains(&p) {
                        used.push(p);
                        c[p] ^= ((seed >> 24) as u8) | 1;
                    }
                }
                assert_eq!(repair(&mut c), Some(n));
                assert_eq!(c, original);
            }
        }
    }
}
