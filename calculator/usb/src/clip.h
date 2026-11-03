#ifndef USB_CLIP_H
#define USB_CLIP_H
static unsigned int cur_block,cur_pos;
static uint8_t clip_state[3];
#ifdef __ez80__
extern void dv_decode(const uint8_t*,int16_t*,unsigned int,uint8_t*);
#else
static const int16_t steps[89]={7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,371,408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552,1707,1878,2066,2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,27086,29794,32767};
static const int8_t adjust[8]={-1,-1,-1,-1,2,4,6,8};
#endif
static void clip_block(void){unsigned int done=0;while(done<PIANO_SAMPLES){const uint8_t*b=rick_adpcm+cur_block*502;unsigned int n=1000-cur_pos;
#ifndef __ez80__
unsigned int j;
#endif
if(n>PIANO_SAMPLES-done)n=PIANO_SAMPLES-done;if(!cur_pos){clip_state[0]=b[0];clip_state[1]=b[1];clip_state[2]=32;}
#ifdef __ez80__
 dv_decode(b+2+cur_pos/2,pcm+done,n,clip_state);
#else
 {int pred=(int16_t)((unsigned int)clip_state[0]|((unsigned int)clip_state[1]<<8)),idx=clip_state[2];for(j=0;j<n;j++){unsigned int pos=cur_pos+j;uint8_t c=(b[2+pos/2]>>((pos&1)*4))&15;int st=steps[idx],delta=(st>>3)+((c&4)?st:0)+((c&2)?st>>1:0)+((c&1)?st>>2:0);pred+=(c&8)?-delta:delta;if(pred>32767)pred=32767;if(pred< -32768)pred=-32768;idx+=adjust[c&7];if(idx<0)idx=0;if(idx>88)idx=88;pcm[done+j]=pred;}clip_state[0]=pred;clip_state[1]=pred>>8;clip_state[2]=idx;}
#endif
 done+=n;cur_pos+=n;if(cur_pos==1000){cur_pos=0;if(++cur_block==RICK_BLOCKS)cur_block=0;}}}
#endif
