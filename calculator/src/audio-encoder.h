#ifndef AUDIO_ENCODER_H
#define AUDIO_ENCODER_H
#include <stdint.h>
#include <string.h>
/* Same DVA5 / RS(255,223) / six-color transport as the Rust encoder. */
static uint8_t gf_exp[512],gf_log[256],rs_mul[32][256];
static uint8_t packet[669],envelope[796],rs_work[255];
static const int16_t ima_steps[89]={7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,371,408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552,1707,1878,2066,2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,27086,29794,32767};
static const int8_t ima_adjust[8]={-1,-1,-1,-1,2,4,6,8};
static uint32_t audio_crc(const uint8_t*p,unsigned int n){uint32_t crc=0xffffffffUL;uint8_t j;while(n--){crc^=*p++;for(j=0;j<8;j++)crc=(crc>>1)^((crc&1)?0xedb88320UL:0);}return ~crc;}
static void put32(uint8_t*p,uint32_t x){uint8_t i;for(i=0;i<4;i++){p[i]=(uint8_t)x;x>>=8;}}
static uint8_t gf_product(uint8_t a,uint8_t b){return a&&b?gf_exp[(unsigned int)gf_log[a]+gf_log[b]]:0;}
static void audio_encoder_init(void){unsigned int i,j,x=1;uint8_t gen[33]={1},next[33];for(i=0;i<255;i++){gf_exp[i]=x;gf_log[x]=i;x<<=1;if(x&256)x^=0x11d;}for(i=255;i<512;i++)gf_exp[i]=gf_exp[i-255];for(i=0;i<32;i++){memset(next,0,33);for(j=0;j<=i;j++){next[j]^=gen[j];next[j+1]^=gf_product(gen[j],gf_exp[i]);}memcpy(gen,next,33);}for(i=0;i<32;i++)for(j=0;j<256;j++)rs_mul[i][j]=gf_product(j,gen[i+1]);}
static void audio_header(uint32_t id,unsigned int index,unsigned int total){memset(packet,0,669);memcpy(packet,"DVA5",4);put32(packet+4,id);put32(packet+8,index);put32(packet+12,total);put32(packet+16,8000);packet[20]=232;packet[21]=3;packet[24]=32;packet[25]=8;}
static void audio_pcm(const int16_t *pcm){int32_t pred=pcm[0];int index=32;unsigned int i;packet[22]=(uint8_t)pred;packet[23]=(uint8_t)(pred>>8);for(i=0;i<1000;i++){int32_t diff=(int32_t)pcm[i]-pred;int step=ima_steps[index],s=step,delta=step>>3;uint8_t code=0,bit;if(diff<0){code=8;diff=-diff;}for(bit=4;bit;bit>>=1){if(diff>=s){code|=bit;diff-=s;delta+=s;}s>>=1;}pred+=(code&8)?-delta:delta;if(pred>32767)pred=32767;if(pred< -32768)pred=-32768;index+=ima_adjust[code&7];if(index<0)index=0;if(index>88)index=88;packet[26+i/2]|=code<<((i&1)*4);}}
static void audio_transport(uint8_t*out){
 unsigned int i,j,lane,pos;uint8_t identity[10],b,digit=0,*dst=out;uint32_t v,q;
 put32(packet+665,audio_crc(packet,665));memset(envelope,0,796);memcpy(identity,packet+4,4);identity[4]=packet[8];identity[5]=packet[9];put32(identity+6,audio_crc(identity,6));memcpy(envelope,identity,10);memcpy(envelope+393,identity,10);memcpy(envelope+786,identity,10);
 for(lane=0;lane<3;lane++){
 memcpy(rs_work,packet+lane*223,223);memset(rs_work+223,0,32);
 for(i=0;i<223;i++){b=rs_work[i];if(b){for(j=0;j<32;j++)rs_work[i+j+1]^=rs_mul[j][b];}}
 memcpy(rs_work,packet+lane*223,223);pos=10+lane;
 for(i=0;i<255;i++){if(pos>=393&&pos<403)pos+=10;envelope[pos]=rs_work[i];pos+=3;}
 }
 /* Four base-216 divisions yield twelve base-six digits, then a final
  * digit. Shared lookup tables avoid thirteen full-width divisions. */
 memset(out,0,SONG_FRAME_BYTES);
 for(i=0;i<796;i+=4){v=(uint32_t)envelope[i]|((uint32_t)envelope[i+1]<<8)|((uint32_t)envelope[i+2]<<16)|((uint32_t)envelope[i+3]<<24);
 for(j=0;j<13;j++){
 if(j%3==0&&j<12){q=v/216;b=(uint8_t)(v-q*216);v=q;}
 {uint8_t s=j==12?(uint8_t)v:triplets[b][j%3];if(digit==0)*dst=s;else if(digit==1)*dst+=s*6;else{*dst+=s*36;dst++;}if(++digit==3)digit=0;}
 }
 }
}
#endif
