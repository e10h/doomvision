#include <stdint.h>
#include <string.h>
#define PIANO_SAMPLES 128
#include "media.h"
#include "piano.h"
#include "clip.h"
#ifdef __ez80__
__attribute__((noinline)) void bench_usb_init(void){cur_block=cur_pos=0;*(unsigned int*)0xd17000=(unsigned int)pcm;}
__attribute__((noinline)) void bench_usb_decode(void){clip_block();}
volatile unsigned int which;
int main(void){if(which)bench_usb_decode();else bench_usb_init();return 0;}
#else
#include <stdio.h>
int main(void){for(unsigned int i=0;i<RICK_BLOCKS*1000/128+2;i++){clip_block();if(fwrite(pcm,2,128,stdout)!=128)return 1;}return 0;}
#endif
