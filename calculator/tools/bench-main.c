#include "render.h"
#include "audio-encoder.h"
#include "media.h"
#include "piano.h"
static uint8_t out[SONG_FRAME_BYTES];
__attribute__((noinline)) void bench_init(void){render_background((uint8_t*)0xd40000);audio_encoder_init();}
__attribute__((noinline)) void bench_prepare(void){unsigned int i;for(i=0;i<*(volatile uint8_t*)0xd17010;i++)note_on(12+i);audio_header(0x50494e31,0,65535);}
__attribute__((noinline)) void bench_mix(void){piano_block();}
__attribute__((noinline)) void bench_pcm(void){audio_pcm(pcm);}
__attribute__((noinline)) void bench_transport(void){audio_transport(out);}
__attribute__((noinline)) void bench_render(void){render((uint8_t*)0xd40000,out);}
__attribute__((noinline)) void bench_crc(void){audio_integrity();}
__attribute__((noinline)) void bench_rs(void){audio_rs();}
__attribute__((noinline)) void bench_symbols(void){audio_symbols(out);}
__attribute__((noinline)) void bench_dump(void){*(unsigned int*)0xd17000=(unsigned int)pcm;*(unsigned int*)0xd17003=(unsigned int)packet;}
volatile unsigned int which;
int main(void){switch(which){case 0:bench_init();break;case 1:bench_prepare();break;case 2:bench_mix();break;case 3:bench_pcm();break;case 4:bench_transport();break;case 5:bench_render();break;case 6:bench_crc();break;case 7:bench_rs();break;case 8:bench_symbols();break;case 9:bench_dump();break;}return 0;}
