#![allow(unexpected_cfgs)]
use std::sync::{
    atomic::{AtomicU32, AtomicUsize, Ordering},
    Arc,
};
const N: usize = 2048;
pub struct Scope {
    samples: [AtomicU32; N],
    cursor: AtomicUsize,
    pub connected: AtomicBool,
    pub rate: AtomicU32,
    pub flags: AtomicU32,
}
impl Scope {
    pub fn new() -> Self {
        Self {
            samples: std::array::from_fn(|_| AtomicU32::new(0)),
            cursor: AtomicUsize::new(0),
            connected: AtomicBool::new(false),
            rate: AtomicU32::new(16000),
            flags: AtomicU32::new(1),
        }
    }
    // Single audio-callback writer; the display reads without locking playback.
    pub fn record(&self, sample: f32) {
        let i = self.cursor.load(Ordering::Relaxed);
        self.samples[i % N].store(sample.to_bits(), Ordering::Relaxed);
        self.cursor.store(i.wrapping_add(1), Ordering::Release);
    }
    fn snapshot(&self) -> Vec<f32> {
        let end = self.cursor.load(Ordering::Acquire);
        (0..N)
            .map(|i| f32::from_bits(self.samples[end.wrapping_add(i) % N].load(Ordering::Relaxed)))
            .collect()
    }
}
static SCOPE: std::sync::OnceLock<Arc<Scope>> = std::sync::OnceLock::new();
use cocoa::{
    appkit::*,
    base::{id, nil, NO, YES},
    foundation::*,
};
use objc::{
    class,
    declare::ClassDecl,
    msg_send,
    runtime::{Object, Sel},
    sel, sel_impl,
};
use std::sync::atomic::AtomicBool;
extern "C" fn draw(view: &Object, _: Sel, _: NSRect) {
    unsafe {
        let bounds: NSRect = msg_send![view, bounds];
        let bg: id = msg_send![class!(NSColor), colorWithCalibratedRed:0.035f64 green:0.06f64 blue:0.08f64 alpha:1.0f64];
        let _: () = msg_send![bg, setFill];
        let backdrop: id = msg_send![class!(NSBezierPath), bezierPathWithRect:bounds];
        let _: () = msg_send![backdrop, fill];
        let Some(scope) = SCOPE.get() else { return };
        let samples = scope.snapshot();
        let color: id = msg_send![class!(NSColor), colorWithCalibratedRed:0.45f64 green:0.95f64 blue:0.7f64 alpha:1.0f64];
        let _: () = msg_send![color, setStroke];
        let path: id = msg_send![class!(NSBezierPath), bezierPath];
        let _: () = msg_send![path, setLineWidth:1.5f64];
        for (i, s) in samples.iter().enumerate() {
            let point = NSPoint::new(
                20. + i as f64 * (bounds.size.width - 40.) / (N - 1) as f64,
                bounds.size.height / 2. + *s as f64 * (bounds.size.height - 50.) / 2.,
            );
            if i == 0 {
                let _: () = msg_send![path, moveToPoint:point];
            } else {
                let _: () = msg_send![path, lineToPoint:point];
            }
        }
        let _: () = msg_send![path, stroke];
    }
}
pub fn run(scope: Arc<Scope>, running: Arc<AtomicBool>) {
    let _ = SCOPE.set(scope.clone());
    unsafe {
        let pool = NSAutoreleasePool::new(nil);
        let app = NSApp();
        app.setActivationPolicy_(NSApplicationActivationPolicyRegular);
        let mut cls = ClassDecl::new("DoomvisionWaveform", class!(NSView)).unwrap();
        cls.add_method(sel!(drawRect:), draw as extern "C" fn(&Object, Sel, NSRect));
        let cls = cls.register();
        let rect = NSRect::new(NSPoint::new(0., 0.), NSSize::new(760., 280.));
        let window = NSWindow::alloc(nil).initWithContentRect_styleMask_backing_defer_(
            rect,
            NSWindowStyleMask::NSTitledWindowMask
                | NSWindowStyleMask::NSClosableWindowMask
                | NSWindowStyleMask::NSMiniaturizableWindowMask
                | NSWindowStyleMask::NSResizableWindowMask,
            NSBackingStoreBuffered,
            NO,
        );
        let _: () = msg_send![window, setReleasedWhenClosed:NO];
        NSWindow::setTitle_(
            window,
            NSString::alloc(nil).init_str("Doomvision · USB audio waveform"),
        );
        let view: id = msg_send![cls, alloc];
        let view: id = msg_send![view, initWithFrame:rect];
        window.setContentView_(view);
        window.center();
        window.makeKeyAndOrderFront_(nil);
        app.finishLaunching();
        let _: () = msg_send![app, activateIgnoringOtherApps:YES];
        while running.load(Ordering::Relaxed) && window.isVisible() == YES {
            let frame_pool = NSAutoreleasePool::new(nil);
            let state = if scope.connected.load(Ordering::Relaxed) {
                if scope.flags.load(Ordering::Relaxed) & 1 != 0 {
                    "Piano"
                } else {
                    "Rick clip"
                }
            } else {
                "Waiting for calculator"
            };
            let title = format!(
                "Doomvision · {} · {} kHz",
                state,
                scope.rate.load(Ordering::Relaxed) / 1000
            );
            let title = NSString::alloc(nil).init_str(&title);
            NSWindow::setTitle_(window, title);
            let _: () = msg_send![title, release];
            loop {
                let event: id = msg_send![app, nextEventMatchingMask:usize::MAX untilDate:NSDate::distantPast(nil) inMode:NSDefaultRunLoopMode dequeue:YES];
                if event == nil {
                    break;
                }
                app.sendEvent_(event);
            }
            let _: () = msg_send![view, setNeedsDisplay:YES];
            let _: () = msg_send![app, updateWindows];
            frame_pool.drain();
            std::thread::sleep(std::time::Duration::from_millis(33));
        }
        window.close();
        let _: () = msg_send![view, release];
        let _: () = msg_send![window, release];
        pool.drain();
    }
}
