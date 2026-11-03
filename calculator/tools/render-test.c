#include <stdio.h>
#include <stdlib.h>
#include "../src/render.h"
int main(int argc,char**argv){uint8_t frame[SONG_FRAME_BYTES],v[320*240];FILE*f=fopen(argv[1],"rb");int i;unsigned n=argc>2?atoi(argv[2]):0;fseek(f,n*SONG_FRAME_BYTES,SEEK_SET);if(fread(frame,1,sizeof frame,f)!=sizeof frame)return 1;fclose(f);for(i=0;i<320*240;i++)v[i]=23;render_background(v);render(v,frame);printf("P6\n320 240\n255\n");for(i=0;i<320*240;i++)fwrite(song_rgb[v[i]],1,3,stdout);return 0;}
