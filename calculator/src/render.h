#ifndef RENDER_H
#define RENDER_H
#include "song.h"
/* Canonical website coordinates, scaled to the CE's 320-pixel LCD. */
static int px(int x){return (x*5+3)/6;}
static void rect(uint8_t *v,int x,int y,int w,int h,uint8_t color){int a,b;for(b=y;b<y+h;b++)for(a=x;a<x+w;a++)v[b*320+a]=color;}
static void box(uint8_t*v,int x,int y,int w,int h,uint8_t c){rect(v,px(x),40+px(y),px(x+w)-px(x),px(y+h)-px(y),c);}
static void render(uint8_t*v,const uint8_t*frame){
 int i,r,c,n=0;const int xy[4][2]={{16,16},{368,16},{368,144},{16,144}};const int dy[4]={36,36,124,124};const uint8_t dots[4]={17,18,20,19};
 rect(v,0,40,320,134,23);
 for(i=0;i<4;i++){int x=xy[i][0],y=xy[i][1];box(v,x-14,y-14,28,28,16);box(v,x-10,y-10,20,20,23);box(v,x-6,y-6,12,12,16);box(v,x-3,dy[i]-3,6,6,dots[i]);}
 for(r=0;r<SONG_ROWS;r++)for(c=0;c<SONG_COLS;c++){
 uint8_t s;if(c<SONG_PILOTS)s=16+c;else{ s=n<SONG_FRAME_BYTES*2?(frame[n/2]>>((n%2)*4))&15:0;n++;}
 {int x=px(32)+(c*800+120)/240,y=40+px(32)+(r*240+36)/72;int x2=px(32)+((c+1)*800+120)/240,y2=40+px(32)+((r+1)*240+36)/72;rect(v,x,y,x2-x,y2-y,s);}
 }
}
#endif
