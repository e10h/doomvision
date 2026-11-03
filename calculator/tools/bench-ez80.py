#!/usr/bin/env python3
"""ROM-free eZ80 timing and native assembly parity. Requires CEmu core checkout."""
import argparse,json,random,shutil,struct,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--cemu',type=Path,required=True);p.add_argument('--cedev',type=Path,default=Path.home()/'CEdev');args=p.parse_args()
core=args.cemu.resolve()/'core';build=root/'bench-build';src=build/'src';src.mkdir(parents=True,exist_ok=True);(build/'tools').mkdir(exist_ok=True)
def run(cmd,**kw):return subprocess.run([str(x) for x in cmd],check=True,**kw)
for name in ['embedded.c','media.h','song.h']:shutil.copyfile(root/'clip-build/src'/name,src/name)
for name in ['render.h','audio-encoder.h','piano.h','base6-table.h','fast.S']:shutil.copyfile(root/'src'/name,src/name)
shutil.copyfile(root/'tools/bench-main.c',src/'main.c');shutil.copyfile(root/'makefile',build/'makefile')
run(['make','-C',core,'-j4','CC=clang','CFLAGS=-O3 -std=gnu11 -fPIC'],stdout=subprocess.DEVNULL)
run(['make','-C',build,'clean'],stdout=subprocess.DEVNULL);run(['make','-C',build],stdout=subprocess.DEVNULL)
binutils=args.cedev/'binutils/bin';symbols={};obj=build/'bin/DVSUN32.obj'
for line in run([binutils/'z80-none-elf-nm',obj],capture_output=True,text=True).stdout.splitlines():
 fields=line.split()
 if len(fields)==3 and fields[2].startswith('_bench_'):symbols[fields[2][1:]]=int(fields[0],16)
(build/'symbols.h').write_text('\n'.join(f'#define SYM_{k} 0x{v:x}u' for k,v in symbols.items())+'\n')
run([binutils/'z80-none-elf-objcopy','-O','binary',obj,build/'raw.bin'])
cmd=['clang','-O2','-I'+str(core),'-I'+str(build),root/'tools/cycle-test.c',core/'libcemucore.a','-o',build/'cycle-test']
if sys.platform=='darwin':cmd+=['-framework','IOKit','-framework','CoreFoundation']
run(cmd);shutil.copyfile(root/'tools/audio-test.c',build/'tools/audio-test.c');run(['cc','-O2',build/'tools/audio-test.c',src/'embedded.c','-o',build/'host-audio'])
checks=build/'checks';checks.mkdir(exist_ok=True);timings={};parity=0
for voices in [1,8]:
 prefix=checks/f'voices{voices}';output=run([build/'cycle-test',build/'raw.bin',voices,'-',prefix],capture_output=True,text=True).stdout;print(output,end='');stage={}
 for line in output.splitlines():
  key,rest=line.split(':',1);stage[key]=float(rest.split(',')[1].split()[0])
 timings[str(voices)]={'stages_ms':stage,'frame_ms':sum(stage[k] for k in ['bench_mix','bench_pcm','bench_transport','bench_render'])}
 notes=','.join(str(12+i) for i in range(voices));ref=checks/f'host{voices}'
 host=run([build/'host-audio','p',0,notes,str(ref)+'-packet.bin',str(ref)+'-pcm.bin'],capture_output=True).stdout
 assert host==Path(str(prefix)+'-frame.ppm').read_bytes(),'eZ80 pixels differ'
 for kind in ['packet.bin','pcm.bin']:assert Path(str(ref)+'-'+kind).read_bytes()==Path(str(prefix)+'-'+kind).read_bytes(),f'eZ80 {kind} differs'
 parity+=1
rng=random.Random(84);vectors={'silence':[0]*1000,'limits':[-32768,32767]*500,'ramp':[((i*1237)&65535)-32768 for i in range(1000)],'random':[rng.randrange(-32768,32768) for _ in range(1000)]}
for name,values in vectors.items():
 pcm=checks/(name+'.pcm');pcm.write_bytes(struct.pack('<1000h',*values));prefix=checks/name
 run([build/'cycle-test',build/'raw.bin',1,pcm,prefix],stdout=subprocess.DEVNULL)
 ref=checks/('ref-'+name);host=run([build/'host-audio','x',0,pcm,str(ref)+'-packet.bin',str(ref)+'-pcm.bin'],capture_output=True).stdout
 assert host==Path(str(prefix)+'-frame.ppm').read_bytes(),f'{name}: eZ80 pixels differ'
 assert Path(str(ref)+'-packet.bin').read_bytes()==Path(str(prefix)+'-packet.bin').read_bytes(),f'{name}: eZ80 audio differs'
 parity+=1
result={'cpu_hz':48000000,'asic':'I','timings':timings,'native_parity_cases':parity,'cemu_commit':run(['git','-C',args.cemu,'rev-parse','HEAD'],capture_output=True,text=True).stdout.strip(),'limits':'Isolated CPU kernels, no calculator OS, camera, keyboard/UI or LCD DMA overhead. Physical FPS is not measured.'}
(build/'timing.json').write_text(json.dumps(result,indent=2)+'\n');print(f'{parity} compiled-eZ80 PCM/packet/raster parity cases passed; timing.json written')
