#ifndef RENDER_H
#define RENDER_H
#include <string.h>
#include "song.h"
#ifndef SONG_COLORS
#define SONG_COLORS 16
#endif
static int px(int x){return (x*5+3)/6;}
static int py(int y){return 14+((y-16)*210+64)/128;}
static unsigned int xe[SONG_COLS+1],ye[SONG_ROWS+1];
static void rect(uint8_t*v,int x,int y,int w,int h,uint8_t c){while(h--){memset(v+y*320+x,c,w);y++;}}
/* Square finders retain their shape while their centers span the full LCD. */
static void render_background(uint8_t*v){
 int i;const int xy[4][2]={{16,16},{368,16},{368,144},{16,144}},dy[4]={36,36,124,124};const uint8_t dots[4]={17,18,20,19};
 memset(v,23,320*240);
 for(i=0;i<=SONG_COLS;i++)xe[i]=px(32)+(i*(px(352)-px(32))+SONG_COLS/2)/SONG_COLS;
 for(i=0;i<=SONG_ROWS;i++)ye[i]=py(32)+(i*(py(128)-py(32))+SONG_ROWS/2)/SONG_ROWS;
 for(i=0;i<4;i++){int x=px(xy[i][0]),y=py(xy[i][1]);rect(v,x-12,y-12,24,24,16);rect(v,x-8,y-8,16,16,23);rect(v,x-5,y-5,10,10,16);rect(v,x-3,py(dy[i])-3,6,6,dots[i]);}
}
static void render(uint8_t*v,const uint8_t*frame){
 unsigned int r,c,n=0,y;uint8_t line[267];
 for(r=0;r<SONG_ROWS;r++){
 for(c=0;c<SONG_COLS;c++){uint8_t s;if(c<SONG_PILOTS)s=SONG_COLORS==6?c:16+c;else{
#if SONG_COLORS == 6
uint8_t b=n<SONG_SYMBOLS?frame[n/3]:0;s=(n%3==0?b:n%3==1?b/6:b/36)%6;
#else
s=n<SONG_FRAME_BYTES*2?(frame[n/2]>>((n%2)*4))&15:0;
#endif
n++;}memset(line+xe[c]-xe[0],s,xe[c+1]-xe[c]);}
 for(y=ye[r];y<ye[r+1];y++)memcpy(v+y*320+xe[0],line,xe[SONG_COLS]-xe[0]);
 }
}
#endif
