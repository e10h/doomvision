#ifndef PIANO_H
#define PIANO_H
static int16_t pcm[1000];
static const uint8_t key_masks[7]={0xbf,0xfe,0xff,0xff,0x7f,0x7f,0x0f};
typedef struct {unsigned int phase,rate;uint8_t active;} Voice;
static Voice voices[8];static uint8_t next_voice;
static void note_on(uint8_t note){Voice*v=&voices[next_voice];v->phase=0;v->rate=note_rates[note];v->active=1;next_voice=(next_voice+1)&7;}
static void piano_block(void){unsigned int i,j,count=0;static const unsigned int gain[9]={0,256,128,85,64,51,42,36,32};for(j=0;j<8;j++)if(voices[j].active)count++;for(i=0;i<1000;i++){int sum=0;for(j=0;j<8;j++){Voice*v=&voices[j];if(v->active){if(v->phase>=64000UL*256){v->active=0;continue;}sum+=(int)piano_s8[v->phase>>8];v->phase+=v->rate;}}pcm[i]=(int16_t)((sum*gain[count]*3)/2);}}
#endif
