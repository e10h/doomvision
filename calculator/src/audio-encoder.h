#ifndef AUDIO_ENCODER_H
#define AUDIO_ENCODER_H
#include <stdint.h>
#include <string.h>
#include "base6-table.h"
#ifdef __ez80__
extern void dv_adpcm(const int16_t*,uint8_t*);
extern void dv_rs_lane(uint8_t*,const uint8_t*);
extern void dv_symbols(const uint8_t*,uint8_t*,const uint8_t*);
#endif
/* Same DVA5 / RS(255,223) / six-color transport as the Rust encoder. */
static uint8_t gf_exp[512],gf_log[256],rs_mul[256][32],crc_table[256][4];
static uint8_t packet[669],envelope[796],rs_work[255];
 #ifndef __ez80__
static const int16_t ima_steps[89]={7,8,9,10,11,12,13,14,16,17,19,21,23,25,28,31,34,37,41,45,50,55,60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,371,408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552,1707,1878,2066,2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,15289,16818,18500,20350,22385,24623,27086,29794,32767};
static const int8_t ima_adjust[8]={-1,-1,-1,-1,2,4,6,8};
 #endif
static uint32_t audio_crc(const uint8_t*p,unsigned int n){uint8_t a=255,b=255,c=255,d=255;while(n--){const uint8_t*t=crc_table[(uint8_t)(a^*p++)];a=b^t[0];b=c^t[1];c=d^t[2];d=t[3];}return ~((uint32_t)a|((uint32_t)b<<8)|((uint32_t)c<<16)|((uint32_t)d<<24));}
static void put32(uint8_t*p,uint32_t x){uint8_t i;for(i=0;i<4;i++){p[i]=(uint8_t)x;x>>=8;}}
static uint8_t gf_product(uint8_t a,uint8_t b){return a&&b?gf_exp[(unsigned int)gf_log[a]+gf_log[b]]:0;}
static void audio_encoder_init(void){unsigned int i,j,x=1;uint8_t gen[33]={1},next[33];for(i=0;i<255;i++){gf_exp[i]=x;gf_log[x]=i;x<<=1;if(x&256)x^=0x11d;}for(i=255;i<512;i++)gf_exp[i]=gf_exp[i-255];for(i=0;i<32;i++){memset(next,0,33);for(j=0;j<=i;j++){next[j]^=gen[j];next[j+1]^=gf_product(gen[j],gf_exp[i]);}memcpy(gen,next,33);}for(i=0;i<32;i++)for(j=0;j<256;j++)rs_mul[j][i]=gf_product(j,gen[i+1]);for(i=0;i<256;i++){uint32_t crc=i;for(j=0;j<8;j++)crc=(crc>>1)^((crc&1)?0xedb88320UL:0);for(j=0;j<4;j++){crc_table[i][j]=(uint8_t)crc;crc>>=8;}}}
static void audio_header(uint32_t id,unsigned int index,unsigned int total){memset(packet,0,669);memcpy(packet,"DVA5",4);put32(packet+4,id);put32(packet+8,index);put32(packet+12,total);put32(packet+16,8000);packet[20]=232;packet[21]=3;packet[24]=32;packet[25]=8;}
 #ifndef __ez80__
static uint8_t ima_encode_one(int sample,int*predictor,int*index){int pred=*predictor,diff=sample-pred,step=ima_steps[*index],delta=step>>3,s;uint8_t code=0;if(diff<0){code=8;diff=-diff;}if(diff>=step){code|=4;diff-=step;delta+=step;}s=step>>1;if(diff>=s){code|=2;diff-=s;delta+=s;}s=step>>2;if(diff>=s){code|=1;delta+=s;}pred+=(code&8)?-delta:delta;if(pred>32767)pred=32767;if(pred< -32768)pred=-32768;*predictor=pred;*index+=ima_adjust[code&7];if(*index<0)*index=0;if(*index>88)*index=88;return code;}
 #endif
static void audio_pcm(const int16_t *pcm){
#ifdef __ez80__
 packet[22]=(uint8_t)pcm[0];packet[23]=(uint8_t)(pcm[0]>>8);dv_adpcm(pcm,packet+26);
#else
int pred=pcm[0],index=32;unsigned int i;uint8_t*out=packet+26;packet[22]=(uint8_t)pred;packet[23]=(uint8_t)(pred>>8);for(i=0;i<500;i++){uint8_t lo=ima_encode_one(*pcm++,&pred,&index),hi=ima_encode_one(*pcm++,&pred,&index);*out++=lo|(hi<<4);}
#endif
}

static void audio_integrity(void){uint8_t identity[10];
 put32(packet+665,audio_crc(packet,665));memset(envelope,0,796);memcpy(identity,packet+4,4);identity[4]=packet[8];identity[5]=packet[9];put32(identity+6,audio_crc(identity,6));memcpy(envelope,identity,10);memcpy(envelope+393,identity,10);memcpy(envelope+786,identity,10);

}
static void audio_rs(void){unsigned int i,lane,pos;
#ifndef __ez80__
 unsigned int j;uint8_t b;
#endif
 for(lane=0;lane<3;lane++){
 memcpy(rs_work,packet+lane*223,223);memset(rs_work+223,0,32);
#ifdef __ez80__
 dv_rs_lane(rs_work,&rs_mul[0][0]);
#else
 for(i=0;i<223;i++){b=rs_work[i];if(b){uint8_t*w=rs_work+i+1;const uint8_t*t=rs_mul[b];
for(j=0;j<32;j++)*w++^=*t++;
}}
#endif

 memcpy(rs_work,packet+lane*223,223);pos=10+lane;
 for(i=0;i<255;i++){if(pos>=393&&pos<403)pos+=10;envelope[pos]=rs_work[i];pos+=3;}
 }

}
static void audio_symbols(uint8_t*out){
#ifdef __ez80__
 memset(out,0,SONG_FRAME_BYTES);dv_symbols(envelope,out,&base6_parts[0][0][0]);
#else
 unsigned int i,j;uint8_t digit=0,*dst=out;
 static const uint8_t sums[25]={0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,32};
 memset(out,0,SONG_FRAME_BYTES);
 for(i=0;i<796;i+=4){const uint8_t*a=base6_parts[0][envelope[i]],*b=base6_parts[1][envelope[i+1]],*c=base6_parts[2][envelope[i+2]],*d=base6_parts[3][envelope[i+3]];uint8_t carry=0;
 for(j=0;j<13;j++){uint8_t sum=sums[*a+++*b+++*c+++*d+++carry],color=sum&7;carry=sum>>3;
 if(digit==0)*dst=color;else if(digit==1)*dst+=color*6;else{*dst+=color*36;dst++;}if(++digit==3)digit=0;
 }
 }

#endif

}
static void audio_transport(uint8_t*out){audio_integrity();audio_rs();audio_symbols(out);}
#endif
