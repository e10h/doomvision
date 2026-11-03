#ifndef USB_AUDIO_WIRE_H
#define USB_AUDIO_WIRE_H
#include <stdint.h>
#include <string.h>
#define AUDIO_RATE USB_AUDIO_RATE
#define AUDIO_SAMPLES USB_AUDIO_SAMPLES
#define AUDIO_PACKET_BYTES (16 + AUDIO_SAMPLES * 2)
static void usb_audio_packet(uint8_t*out,uint32_t sequence,uint8_t flags,const int16_t*pcm){unsigned int i;memcpy(out,"DVU1",4);for(i=0;i<4;i++){out[4+i]=(uint8_t)sequence;sequence>>=8;}out[8]=(uint8_t)AUDIO_RATE;out[9]=(uint8_t)(AUDIO_RATE>>8);out[10]=0;out[11]=0;out[12]=(uint8_t)AUDIO_SAMPLES;out[13]=(uint8_t)(AUDIO_SAMPLES>>8);out[14]=flags;out[15]=0;for(i=0;i<AUDIO_SAMPLES;i++){uint16_t s=(uint16_t)pcm[i];out[16+i*2]=(uint8_t)s;out[17+i*2]=(uint8_t)(s>>8);}}
#endif
