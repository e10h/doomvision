/* ROM-free isolated eZ80 timing, using the CEmu CPU core. */
#include "emu.h"
#include "asic.h"
#include "cpu.h"
#include "mem.h"
#include "control.h"
#include "flash.h"
#include "symbols.h"
#include "src/song.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
void gui_console_clear(void){}
void gui_console_printf(const char *f,...){(void)f;}
void gui_console_err_printf(const char *f,...){(void)f;}
asic_rev_t gui_handle_reset(const boot_ver_t*v,asic_rev_t l,asic_rev_t d,emu_device_t dev,bool*python){(void)v;(void)l;(void)d;(void)dev;*python=false;return ASIC_REV_I;}
static unsigned run(unsigned pc){cpu_clear_signals();cpu.halted=false;cpu.ADL=cpu.MADL=cpu.L=cpu.IL=true;cpu.IEF1=cpu.IEF2=false;cpu.registers.SPL=0xd17f00;mem_poke_word(0xd17f00,0xd18020,true);cpu_flush(pc,true);unsigned start=cpu.cycles;for(unsigned i=0;i<1000000;i++){sched.event.next_cycle=cpu.cycles+1000;cpu_execute();if(cpu.halted)return cpu.cycles-start;}fprintf(stderr,"Timeout PC=%06x IX=%06x SP=%06x counter=%06x\n",cpu.registers.PC,cpu.registers.IX,cpu.registers.SPL,mem_peek_word(cpu.registers.IX-19,true));exit(1);}
int main(int argc,char**argv){if(argc<2)return 1;asic_init();mem.flash.size=0x400000;mem.flash.block=calloc(mem.flash.size,1);asic_reset();set_cpu_clock(48000000);control.stackLimit=0;control.protectedStart=0;control.protectedEnd=0;FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long n=ftell(f);rewind(f);if(fread(phys_mem_ptr(0xd1a87f,n),1,n,f)!=(size_t)n)return 1;fclose(f);mem_poke_byte(0xd18020,0x76);
#define TIME(name) do{unsigned c=run(SYM_##name);printf("%s: %u cycles, %.3f ms\n",#name,c,c/48000.);}while(0)
mem_poke_byte(0xd17010,argc>2?atoi(argv[2]):8);TIME(bench_init);TIME(bench_prepare);run(SYM_bench_dump);if(argc>3&&strcmp(argv[3],"-")){FILE*in=fopen(argv[3],"rb");if(!in||fread(phys_mem_ptr(mem_peek_word(0xd17000,true),2000),1,2000,in)!=2000)return 1;fclose(in);}else{TIME(bench_mix);}TIME(bench_pcm);TIME(bench_crc);TIME(bench_rs);TIME(bench_symbols);TIME(bench_transport);TIME(bench_render);run(SYM_bench_dump);
char path[1024];const char*prefix=argc>4?argv[4]:"/private/tmp/ez80";snprintf(path,sizeof path,"%s-pcm.bin",prefix);FILE*o=fopen(path,"wb");fwrite(phys_mem_ptr(mem_peek_word(0xd17000,true),2000),1,2000,o);fclose(o);
snprintf(path,sizeof path,"%s-packet.bin",prefix);o=fopen(path,"wb");fwrite(phys_mem_ptr(mem_peek_word(0xd17003,true),669),1,669,o);fclose(o);
snprintf(path,sizeof path,"%s-frame.ppm",prefix);o=fopen(path,"wb");fprintf(o,"P6\n320 240\n255\n");for(unsigned i=0;i<320*240;i++){unsigned c=mem_peek_byte(0xd40000+i);if(c>=27){fprintf(stderr,"Invalid palette index %u\n",c);return 1;}fwrite(song_rgb[c],1,3,o);}fclose(o);return 0;}
