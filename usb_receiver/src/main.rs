mod audio;
mod protocol;
use anyhow::{bail, Context, Result};
use rusb::UsbContext;
use std::{
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    thread,
    time::{Duration, Instant},
};
const VID: u16 = 0x0451;
const PID: u16 = 0xe008;
fn find(context: &rusb::Context, list: bool) -> Result<Option<rusb::Device<rusb::Context>>> {
    let mut found = None;
    for dev in context.devices()?.iter() {
        let Ok(d) = dev.device_descriptor() else {
            continue;
        };
        if d.vendor_id() != VID {
            continue;
        }
        let mut ours = false;
        for i in 0..d.num_configurations() {
            if list {
                if let Err(e) = dev.config_descriptor(i) {
                    println!("  configuration {i} descriptor error: {e}");
                }
            }
            if let Ok(c) = dev.config_descriptor(i) {
                for iface in c.interfaces() {
                    for alt in iface.descriptors() {
                        if list {
                            println!(
                                "  interface {}: class {:02x}/{:02x}/{:02x}, {} endpoints",
                                alt.interface_number(),
                                alt.class_code(),
                                alt.sub_class_code(),
                                alt.protocol_code(),
                                alt.num_endpoints()
                            );
                        }
                        if alt.class_code() == 0xff
                            && alt.sub_class_code() == 0x44
                            && alt.protocol_code() == 1
                        {
                            ours = true;
                        }
                    }
                }
            }
        }
        if list {
            if let Ok(handle) = dev.open() {
                let mut b = [0u8; 64];
                match handle.read_control(0x80, 6, 0x0200, 0, &mut b, Duration::from_millis(500)) {
                    Ok(n) => println!("  config wire: {:02x?}", &b[..n]),
                    Err(e) => println!("  config read: {e}"),
                }
            }
            println!(
                "USB {:03}:{:03} {:04x}:{:04x} {}",
                dev.bus_number(),
                dev.address(),
                d.vendor_id(),
                d.product_id(),
                if ours {
                    "Doomvision PCM sender"
                } else {
                    "TI device; run DVUSB6 to stream"
                }
            );
        }
        if d.product_id() == PID && ours {
            // A live string request avoids claiming a stale cached interface
            // after the calculator exits to TI file-transfer mode.
            if let Ok(h) = dev.open() {
                if let Ok(product) = h.read_product_string_ascii(&d) {
                    if product == "Doomvision PCM5" || product == "Doomvision PCM6" {
                        found = Some(dev);
                    }
                }
            }
        }
    }
    Ok(found)
}
fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.iter().any(|x| x == "--list") {
        let context = rusb::Context::new().context("Initialize libusb")?;
        if find(&context, true)?.is_none() {
            println!("No DVUSB5 sender detected.");
        }
        return Ok(());
    }
    let running = Arc::new(AtomicBool::new(true));
    let flag = running.clone();
    ctrlc::set_handler(move || flag.store(false, Ordering::Relaxed))?;
    if args.iter().any(|x| x == "--self-test") {
        let (_stream, buffer) = audio::start()?;
        let tone: Vec<i16> = (0..4000)
            .map(|i| ((i as f32 * std::f32::consts::TAU * 440. / 8000.).sin() * 4000.) as i16)
            .collect();
        for part in tone.chunks(128) {
            buffer.lock().unwrap().push(part, 8000);
            thread::sleep(Duration::from_millis(16));
        }
        thread::sleep(Duration::from_millis(150));
        eprintln!("Mac audio self-test complete (does not test USB).");
        return Ok(());
    }
    if args.len() == 3 && args[1] == "--replay" {
        let bytes = std::fs::read(&args[2])?;
        let packets = protocol::Decoder::default().feed(&bytes);
        if packets.is_empty() {
            bail!("No valid DVU1 PCM packets in replay file");
        }
        let (_stream, buffer) = audio::start()?;
        eprintln!(
            "Replaying {} actual PCM packets (offline; does not test USB)",
            packets.len()
        );
        for p in packets {
            buffer.lock().unwrap().push(&p.pcm, p.rate);
            thread::sleep(Duration::from_secs_f64(p.pcm.len() as f64 / p.rate as f64));
        }
        thread::sleep(Duration::from_millis(100));
        return Ok(());
    }
    let context = rusb::Context::new().context("Initialize libusb")?;
    if args.len() > 1 {
        bail!("Usage: doomvision-usb [--list | --self-test | --replay FILE]");
    }
    eprintln!("Connect calculator, run DVUSB6 (starts in piano mode). Waiting for DVUSB5/6; older builds are not claimed…");
    while running.load(Ordering::Relaxed) {
        let Some(device) = find(&context, false)? else {
            thread::sleep(Duration::from_millis(300));
            continue;
        };
        eprintln!("Compatible USB audio sender found; opening bulk audio interface…");
        let handle = match device.open() {
            Ok(h) => h,
            Err(e) => {
                eprintln!(
                    "Open failed: {e}. Close other doomvision-usb instances or TI Connect CE."
                );
                thread::sleep(Duration::from_secs(1));
                continue;
            }
        };
        if handle.active_configuration()? != 1 {
            handle.set_active_configuration(1)?;
        }
        if let Err(e) = handle.claim_interface(0) {
            eprintln!("Claim failed: {e}. Close other doomvision-usb instances or TI Connect CE, then retry.");
            thread::sleep(Duration::from_secs(1));
            continue;
        }
        let (_stream, buffer) = audio::start()?;
        let mut decoder = protocol::Decoder::default();
        let mut bytes = [0u8; 4096];
        let mut last = None;
        let mut frames = 0u64;
        let mut report = Instant::now();
        let mut flags = 0u16;
        let mut peak = 0u16;
        eprintln!("USB connected → waiting for PCM audio packets");
        while running.load(Ordering::Relaxed) {
            match handle.read_bulk(0x81, &mut bytes, Duration::from_millis(500)) {
                Ok(n) => {
                    for p in decoder.feed(&bytes[..n]) {
                        if last == Some(p.sequence) {
                            continue;
                        }
                        if let Some(prev) = last {
                            if p.sequence != prev.wrapping_add(1) {
                                eprintln!("Audio sequence changed: {prev} → {}", p.sequence);
                            }
                        }
                        last = Some(p.sequence);
                        flags = p.flags;
                        for s in &p.pcm {
                            peak = peak.max(s.unsigned_abs());
                        }
                        buffer.lock().unwrap().push(&p.pcm, p.rate);
                        frames += 1;
                        if frames == 1 {
                            eprintln!("PCM16 received: {} Hz mono → buffering 64 ms", p.rate);
                        }
                        if frames == 4 {
                            eprintln!("Audio queued → Mac speaker playback");
                        }
                    }
                }
                Err(rusb::Error::Timeout) => {}
                Err(e) => {
                    eprintln!("USB disconnected/error: {e}");
                    break;
                }
            }
            if report.elapsed() >= Duration::from_secs(1) {
                let b = buffer.lock().unwrap();
                let rate_khz = (b.source_rate as f32) / 1000.0;
                eprintln!(
                    "{} chunks · {} ({:.0} kHz) · {:.0} ms queued · {} underruns · {} dropped samples · peak {:.0}%",
                    frames,
                    if flags & 1 != 0 {
                        "piano"
                    } else if flags & 2 != 0 {
                        "clip paused"
                    } else {
                        "Rick clip"
                    },
                    rate_khz,
                    b.queued() as f32 / rate_khz,
                    b.underruns,
                    b.dropped,peak as f32/327.68
                );
                peak = 0;
                report = Instant::now();
            }
        }
        let _ = handle.release_interface(0);
    }
    Ok(())
}
