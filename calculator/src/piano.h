#ifndef PIANO_H
#define PIANO_H
static int16_t pcm[1000];
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
 if(phase+rate*1000<64000UL*256){dv_mix1000(pcm,piano_s8+(phase>>8),rate,phase&255);phase+=rate*1000;}else
#endif
 for(i=0;i<1000;i++){if(phase>=64000UL*256){v->active=0;break;}pcm[i]+=piano_s8[phase>>8];phase+=rate;}v->phase=phase;}}
#ifdef __ez80__
 dv_scale(pcm,count<=1?7:count<=2?6:count<=4?5:4);
#else
 {const unsigned int scale=count<=1?384:count<=2?192:count<=4?96:48;for(i=0;i<1000;i++)pcm[i]*=scale;}
#endif
}
#endif
