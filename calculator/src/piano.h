#ifndef PIANO_H
#define PIANO_H
#ifndef PIANO_SAMPLES
#define PIANO_SAMPLES 1000
#endif
#ifndef PIANO_LENGTH
#define PIANO_LENGTH 64000
#endif
_Static_assert(sizeof(piano_s8)==PIANO_LENGTH,"Piano storage/playback length mismatch");
_Static_assert(PIANO_LENGTH<=65535,"Piano phase exceeds native 24-bit range");
_Static_assert(PIANO_SAMPLES%8==0,"Assembly mixer needs groups of eight");
static int16_t pcm[PIANO_SAMPLES];
#include "piano-keymap.h"
typedef struct {unsigned int phase,rate;uint8_t active;} Voice;
static Voice voices[8];static uint8_t next_voice;
static void note_on(uint8_t note){Voice*v=&voices[next_voice];v->phase=0;v->rate=note_rates[note];v->active=1;next_voice=(next_voice+1)&7;}
#ifdef __ez80__
extern void dv_mix1000(int16_t*,const int8_t*,unsigned int,unsigned int);
extern void dv_scale(int16_t*,unsigned int);
#endif
static void piano_block(void){unsigned int i,j,count=0;memset(pcm,0,sizeof pcm);for(j=0;j<8;j++){Voice*v=&voices[j];if(v->active){unsigned int phase=v->phase,rate=v->rate;count++;
#ifdef __ez80__
 if(phase+rate*PIANO_SAMPLES<(unsigned long)PIANO_LENGTH*256){dv_mix1000(pcm,piano_s8+(phase>>8),rate,phase&255);phase+=rate*PIANO_SAMPLES;}else
#endif
 for(i=0;i<PIANO_SAMPLES;i++){if(phase>=(unsigned long)PIANO_LENGTH*256){v->active=0;break;}pcm[i]+=piano_s8[phase>>8];phase+=rate;}v->phase=phase;}}
#ifdef __ez80__
 dv_scale(pcm,count<=1?7:count<=2?6:count<=4?5:4);
#else
 {const unsigned int scale=count<=1?384:count<=2?192:count<=4?96:48;for(i=0;i<PIANO_SAMPLES;i++)pcm[i]*=scale;}
#endif
}
#endif
