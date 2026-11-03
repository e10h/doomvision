#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include "../src/piano-keymap.h"
int main(void){const uint8_t white[10][3]={{0,3,12},{0,6,14},{2,7,16},{2,6,17},{2,5,19},{2,4,21},{2,3,23},{2,2,24},{2,1,26},{2,0,28}};const uint8_t black[7][3]={{0,2,13},{0,7,15},{3,6,18},{3,5,20},{3,4,22},{3,2,25},{3,1,27}};unsigned int seen=0,i,r,b,count=0;for(i=0;i<10;i++)assert(key_notes[white[i][0]][white[i][1]]==white[i][2]);for(i=0;i<7;i++)assert(key_notes[black[i][0]][black[i][1]]==black[i][2]);for(r=0;r<7;r++)for(b=0;b<8;b++){uint8_t n=key_notes[r][b];assert(!!(key_masks[r]&(1<<b))==(n!=255));if(n!=255){assert(n>=12&&n<=28);assert(!(seen&(1u<<(n-12))));seen|=1u<<(n-12);count++;}}assert(count==17&&seen==0x1ffff);assert(key_notes[0][4]==255);assert(key_notes[3][7]==255&&key_notes[3][3]==255&&key_notes[3][0]==255);puts("Piano keymap: Y= excluded, WINDOW C4, MODE D4, all 17 chromatic notes through E5, STAT/8/decimal silent");return 0;}
