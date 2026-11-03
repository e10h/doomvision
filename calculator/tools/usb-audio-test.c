#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#define PIANO_SAMPLES 128
#include "../src/media.h"
#include "../src/piano.h"
#include "../src/wire.h"
int main(int argc,char**argv){uint8_t bytes[AUDIO_PACKET_BYTES];unsigned int frames=argc>1?atoi(argv[1]):250;if(argc>2){char*p=strtok(argv[2],",");while(p){note_on(atoi(p));p=strtok(NULL,",");}}else{note_on(12);note_on(16);note_on(19);}for(unsigned int i=0;i<frames;i++){piano_block();usb_audio_packet(bytes,i,1,pcm);if(fwrite(bytes,1,AUDIO_PACKET_BYTES,stdout)!=AUDIO_PACKET_BYTES)return 1;}return 0;}
