use anyhow::{bail, Context, Result};
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use std::{
    collections::VecDeque,
    sync::{Arc, Mutex},
};
pub struct Buffer {
    pub scope: Arc<crate::gui::Scope>,
    queue: VecDeque<i16>,
    pub source_rate: u32,
    p0: f32,
    p1: f32,
    p2: f32,
    p3: f32,
    phase: f64,
    primed: bool,
    pub underruns: u64,
    pub dropped: u64,
}
impl Default for Buffer {
    fn default() -> Self {
        Self {
            scope: Arc::new(crate::gui::Scope::new()),
            queue: VecDeque::new(),
            source_rate: 16000,
            p0: 0.,
            p1: 0.,
            p2: 0.,
            p3: 0.,
            phase: 0.,
            primed: false,
            underruns: 0,
            dropped: 0,
        }
    }
}
impl Buffer {
    pub fn push(&mut self, pcm: &[i16], rate: u32) {
        if rate != 0 && rate != self.source_rate {
            self.source_rate = rate;
            self.queue.clear();
            self.primed = false;
            self.phase = 0.;
            self.p0 = 0.;
            self.p1 = 0.;
            self.p2 = 0.;
            self.p3 = 0.;
        }
        self.queue.extend(pcm.iter().copied());
        let max_len = if self.source_rate == 16000 {
            3200
        } else {
            1600
        };
        while self.queue.len() > max_len {
            self.queue.pop_front();
            self.dropped += 1;
        }
    }
    fn next(&mut self, rate: u32) -> f32 {
        let min_prime = if self.source_rate == 16000 { 1024 } else { 512 };
        if !self.primed {
            if self.queue.len() < min_prime {
                return 0.;
            }
            self.p1 = self.queue.pop_front().unwrap() as f32 / 32768.;
            self.p2 = self.queue.pop_front().unwrap() as f32 / 32768.;
            self.p0 = self.p1;
            self.p3 = self.queue.pop_front().unwrap_or(0) as f32 / 32768.;
            self.phase = 0.;
            self.primed = true;
        }
        let t = self.phase as f32;
        let t2 = t * t;
        let t3 = t2 * t;
        let c0 = -0.5 * self.p0 + 1.5 * self.p1 - 1.5 * self.p2 + 0.5 * self.p3;
        let c1 = self.p0 - 2.5 * self.p1 + 2.0 * self.p2 - 0.5 * self.p3;
        let c2 = -0.5 * self.p0 + 0.5 * self.p2;
        let c3 = self.p1;
        let sample = (c0 * t3 + c1 * t2 + c2 * t + c3).clamp(-1.0, 1.0);
        // Sender is paced by USB SOF. Do not frequency-modulate every output
        // sample based on the sawtooth queue depth of 128-sample USB chunks.
        self.phase += self.source_rate as f64 / rate as f64;
        while self.phase >= 1. {
            self.phase -= 1.;
            if let Some(next) = self.queue.pop_front() {
                self.p0 = self.p1;
                self.p1 = self.p2;
                self.p2 = self.p3;
                self.p3 = next as f32 / 32768.;
            } else {
                self.primed = false;
                self.p0 = 0.;
                self.p1 = 0.;
                self.p2 = 0.;
                self.p3 = 0.;
                self.underruns += 1;
                break;
            }
        }
        sample
    }
    pub fn queued(&self) -> usize {
        self.queue.len()
    }
}
pub fn start() -> Result<(cpal::Stream, Arc<Mutex<Buffer>>)> {
    let host = cpal::default_host();
    let dev = host
        .default_output_device()
        .context("No Mac audio output device")?;
    let supported = dev.default_output_config()?;
    let format = supported.sample_format();
    let mut config: cpal::StreamConfig = supported.into();
    config.buffer_size = cpal::BufferSize::Fixed(256);
    let buffer = Arc::new(Mutex::new(Buffer::default()));
    eprintln!(
        "Audio: {} · {} Hz · {} channels",
        dev.name()?,
        config.sample_rate.0,
        config.channels
    );
    let stream = match format {
        cpal::SampleFormat::F32 => build::<f32>(&dev, &config, buffer.clone())?,
        cpal::SampleFormat::I16 => build::<i16>(&dev, &config, buffer.clone())?,
        cpal::SampleFormat::U16 => build::<u16>(&dev, &config, buffer.clone())?,
        other => bail!("Unsupported audio output format: {other:?}"),
    };
    stream.play()?;
    Ok((stream, buffer))
}
fn build<T: cpal::SizedSample + cpal::FromSample<f32>>(
    dev: &cpal::Device,
    config: &cpal::StreamConfig,
    buffer: Arc<Mutex<Buffer>>,
) -> Result<cpal::Stream> {
    let channels = config.channels as usize;
    let rate = config.sample_rate.0;
    Ok(dev.build_output_stream(
        config,
        move |out: &mut [T], _| {
            if let Ok(mut b) = buffer.try_lock() {
                for frame in out.chunks_mut(channels) {
                    let sample = b.next(rate);
                    b.scope.record(sample);
                    for v in frame {
                        *v = T::from_sample(sample);
                    }
                }
            } else {
                for v in out {
                    *v = T::from_sample(0.);
                }
            }
        },
        |e| eprintln!("Audio output error: {e}"),
        None,
    )?)
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn buffering_and_loss() {
        let mut b = Buffer::default();
        b.push(&[10000; 128], 8000);
        assert_eq!(b.next(48000), 0.);
        b.push(&[10000; 384], 8000);
        assert!(b.next(48000) > 0.);
        for _ in 0..6000 {
            b.next(48000);
        }
        assert!(b.underruns > 0);
        assert_eq!(b.next(48000), 0.);
        b.push(&[0; 10000], 8000);
        assert_eq!(b.queued(), 1600);
        assert!(b.dropped > 0);
    }
    #[test]
    fn sixteen_k_stream_stays_primed() {
        let mut b = Buffer::default();
        b.push(&[10000; 1024], 16000);
        for i in 0..480000 {
            if i % 384 == 0 {
                b.push(&[10000; 128], 16000);
            }
            let s = b.next(48000);
            assert!((s - 10000. / 32768.).abs() < 0.0001);
        }
        assert_eq!(b.underruns, 0);
        assert_eq!(b.dropped, 0);
    }
    #[test]
    fn rate_change_clears_old_audio() {
        let mut b = Buffer::default();
        b.push(&[10000; 512], 8000);
        assert!(b.next(48000) > 0.);
        b.push(&[0; 128], 16000);
        assert_eq!(b.queued(), 128);
        assert_eq!(b.next(48000), 0.);
    }
}
