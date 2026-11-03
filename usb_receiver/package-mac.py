#!/usr/bin/env python3
"""Build and package the native Rust Mac receiver (run on macOS)."""
from pathlib import Path
import plistlib
import shutil
import subprocess
import zipfile

root = Path(__file__).resolve().parent
out = root.parent / 'public' / 'downloads'
subprocess.run(['cargo', 'build', '--release', '--manifest-path', str(root / 'Cargo.toml')], check=True)
app = out / 'Doomvision.app'
(app / 'Contents' / 'MacOS').mkdir(parents=True, exist_ok=True)
binary = root / 'target' / 'release' / 'doomvision-usb'
shutil.copy2(binary, app / 'Contents' / 'MacOS' / 'doomvision-usb')
(app / 'Contents' / 'Info.plist').write_bytes(plistlib.dumps({
    'CFBundleExecutable': 'doomvision-usb', 'CFBundleIdentifier': 'app.doomvision.usb',
    'CFBundleName': 'Doomvision', 'CFBundleDisplayName': 'Doomvision',
    'CFBundlePackageType': 'APPL', 'CFBundleShortVersionString': '0.2.0',
    'CFBundleVersion': '2', 'NSHighResolutionCapable': True, 'LSMinimumSystemVersion': '11.0',
}))
subprocess.run(['codesign', '--force', '--sign', '-', str(app)], check=True)
shutil.copy2(binary, out / 'doomvision-usb')
with zipfile.ZipFile(out / 'doomvision-usb-mac.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for p in sorted(app.rglob('*')):
        if p.is_file(): z.write(p, p.relative_to(out))
    for name in ['DVUSB6.8xp', 'USBDRVCE.8xv', 'doomvision-usb', 'Start USB Audio.command']:
        z.write(out / name, name)
    z.write(root / 'README.md', 'README.md')
    z.write(root.parent / 'public' / 'samples' / 'piano-c4.txt', 'piano-source.txt')
print(out / 'doomvision-usb-mac.zip')
