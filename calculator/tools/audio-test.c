#include <stdio.h>
#include <stdlib.h>
#include "../src/render.h"
#include "../src/audio-encoder.h"
#include "../src/media.h"
#include "../src/piano.h"
int main(int argc,char**argv){uint8_t v[320*240],data[SONG_FRAME_BYTES];unsigned int index=atoi(argv[2]),i;FILE*f;if(argc<5)return 1;render_background(v);audio_encoder_init();if(argv[1][0]=='r'){const uint8_t*b=rick_adpcm+index*502;audio_header(RICK_ID,index,64);packet[22]=b[0];packet[23]=b[1];memcpy(packet+26,b+2,500);}else{if(argv[1][0]=='x'){f=fopen(argv[3],"rb");if(!f||fread(pcm,2,1000,f)!=1000)return 1;fclose(f);}else{char*note=strtok(argv[3],",");while(note){note_on(atoi(note));note=strtok(NULL,",");}for(i=0;i<=index;i++)piano_block();}audio_header(0x50494e31UL,index,65535);audio_pcm(pcm);}audio_transport(data);render(v,data);f=fopen(argv[4],"wb");fwrite(packet,1,669,f);fclose(f);if(argc>5){f=fopen(argv[5],"wb");fwrite(pcm,2,1000,f);fclose(f);}printf("P6\n320 240\n255\n");for(i=0;i<320*240;i++)fwrite(song_rgb[v[i]],1,3,stdout);return 0;}
