#!/usr/bin/env python3
"""Run the actual eZ80 USB Rick decoder against the portable reference; no ROM."""
import argparse,shutil,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1];p=argparse.ArgumentParser(description=__doc__);p.add_argument('--cemu',type=Path,required=True);p.add_argument('--cedev',type=Path,default=Path.home()/'CEdev');args=p.parse_args();build=root/'decoder-bench';src=build/'src';shutil.rmtree(src,ignore_errors=True);src.mkdir(parents=True,exist_ok=True)
def run(cmd,**kw):return subprocess.run([str(x) for x in cmd],check=True,**kw)
for name in ['embedded.c','media.h','piano.h','piano-keymap.h','clip.h','fast.S']:shutil.copyfile(root/'usb-build/src'/name,src/name)
shutil.copyfile(root/'tools/usb-clip-bench.c',src/'main.c');shutil.copyfile(root/'makefile',build/'makefile')
run(['make','-C',build,'clean'],stdout=subprocess.DEVNULL);run(['make','-C',build],stdout=subprocess.DEVNULL)
bin=args.cedev/'binutils/bin';obj=build/'bin/DVSUN32.obj';symbols={}
for line in run([bin/'z80-none-elf-nm',obj],capture_output=True,text=True).stdout.splitlines():
 fields=line.split()
 if len(fields)==3 and fields[2].startswith('_bench_usb_'):symbols[fields[2][1:]]=int(fields[0],16)
(build/'symbols.h').write_text('\n'.join(f'#define SYM_{k} 0x{v:x}u' for k,v in symbols.items())+'\n')
run([bin/'z80-none-elf-objcopy','-O','binary',obj,build/'raw.bin']);core=args.cemu.resolve()/'core'
run(['make','-C',core,'-j4','CC=clang','CFLAGS=-O3 -std=gnu11 -fPIC'],stdout=subprocess.DEVNULL)
run(['clang','-O2','-I'+str(core),'-I'+str(build),root/'tools/usb-decode-cycles.c',core/'libcemucore.a','-o',build/'cycles','-framework','IOKit','-framework','CoreFoundation'])
result=run([build/'cycles',build/'raw.bin',build/'native.pcm'],capture_output=True,text=True).stdout;print(result,end='')
run(['cc','-O2','-I'+str(src),root/'tools/usb-clip-bench.c',src/'embedded.c','-o',build/'host'])
ref=run([build/'host'],capture_output=True).stdout;native=(build/'native.pcm').read_bytes();assert native==ref,'eZ80 decoder differs from C reference';assert native[:512]==native[-512:],'loop boundary differs';print('Entire clip + wrap: compiled eZ80 PCM is byte-identical to the portable reference');(build/'result.txt').write_text(result+'Full clip and loop boundary PCM parity passed.\n')
