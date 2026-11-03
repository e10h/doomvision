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
static uint8_t widths[SONG_COLS];
#if SONG_COLORS == 6
static uint8_t triplets[256][3];
#endif
static void rect(uint8_t*v,int x,int y,int w,int h,uint8_t c){while(h--){memset(v+y*320+x,c,w);y++;}}
/* Square finders retain their shape while their centers span the full LCD. */
static void render_background(uint8_t*v){
 int i;const int xy[4][2]={{16,16},{368,16},{368,144},{16,144}},dy[4]={36,36,124,124};const uint8_t dots[4]={17,18,20,19};
 memset(v,23,320*240);
 for(i=0;i<=SONG_COLS;i++)xe[i]=px(32)+(i*(px(352)-px(32))+SONG_COLS/2)/SONG_COLS;
 for(i=0;i<SONG_COLS;i++)widths[i]=xe[i+1]-xe[i];
#if SONG_COLORS == 6
 for(i=0;i<256;i++){triplets[i][0]=i%6;triplets[i][1]=(i/6)%6;triplets[i][2]=i/36;}
#endif
 for(i=0;i<=SONG_ROWS;i++)ye[i]=py(32)+(i*(py(128)-py(32))+SONG_ROWS/2)/SONG_ROWS;
 for(i=0;i<4;i++){int x=px(xy[i][0]),y=py(xy[i][1]);rect(v,x-12,y-12,24,24,16);rect(v,x-8,y-8,16,16,23);rect(v,x-5,y-5,10,10,16);rect(v,x-3,py(dy[i])-3,6,6,dots[i]);}
}
static void render(uint8_t*v,const uint8_t*frame){
 unsigned int r,c,n=0,y;uint8_t line[267];
#if SONG_COLORS == 6
 const uint8_t *packed=frame,*triple=triplets[0];uint8_t digit=3;
#endif
 for(r=0;r<SONG_ROWS;r++){
 uint8_t *dst=line;
 for(c=0;c<SONG_COLS;c++){uint8_t s;
 if(c<SONG_PILOTS)s=SONG_COLORS==6?c:16+c;else{
#if SONG_COLORS == 6
 if(digit==3){triple=triplets[n<SONG_SYMBOLS?*packed++:0];digit=0;}
 s=triple[digit++];
#else
 s=n<SONG_FRAME_BYTES*2?(frame[n/2]>>((n%2)*4))&15:0;
#endif
 n++;
 }
 /* Cell widths are 2–4 pixels: direct stores avoid thousands of tiny memset calls. */
 switch(widths[c]){case 4:*dst++=s; /* fall through */
 case 3:*dst++=s; /* fall through */
 case 2:*dst++=s; /* fall through */
 case 1:*dst++=s;break;default:memset(dst,s,widths[c]);dst+=widths[c];}
 }
 {uint8_t *row=v+ye[r]*320+xe[0];const unsigned int w=xe[SONG_COLS]-xe[0];
 for(y=ye[r];y<ye[r+1];y++){memcpy(row,line,w);row+=320;}}
 }
}
#endif
