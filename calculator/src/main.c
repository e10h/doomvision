#include <graphx.h>
#include <fileioc.h>
#include <keypadc.h>
#include <time.h>
#include <stdio.h>
#include "render.h"
int main(void){
 const uint8_t *banks[SONG_BANKS];unsigned int i,frame=0,last=SONG_FRAMES;clock_t origin=0,elapsed=0;int paused=1,oldsecond=0,oldenter=0;clock_t fps_start=0;unsigned int shown=0,fps10=0;
 for(i=0;i<SONG_BANKS;i++){ti_var_t f=ti_Open(song_names[i],"r");if(!f){printf("Missing %s\nTransfer all 12 AppVars.",song_names[i]);return 1;}if(ti_GetSize(f)!=song_sizes[i]||!ti_IsArchived(f)){ti_Close(f);printf("Archive %s first.",song_names[i]);return 1;}banks[i]=ti_GetDataPtr(f);ti_Close(f);}
 gfx_Begin();for(i=0;i<27;i++)gfx_palette[i]=gfx_RGBTo1555(song_rgb[i][0],song_rgb[i][1],song_rgb[i][2]);gfx_SetDrawBuffer();render_background(gfx_vbuffer[0]);gfx_SwapDraw();render_background(gfx_vbuffer[0]);fps_start=clock();
 while(1){int second,enter;kb_Scan();if(kb_Data[6]&kb_Clear)break;second=!!(kb_Data[1]&kb_2nd);enter=!!(kb_Data[6]&kb_Enter);
 if(second&&!oldsecond){shown=0;fps10=0;fps_start=clock();if(paused){origin=clock()-elapsed;paused=0;}else{elapsed=clock()-origin;paused=1;}last=SONG_FRAMES;}
 if(enter&&!oldenter){elapsed=0;origin=clock();frame=0;last=SONG_FRAMES;}
 oldsecond=second;oldenter=enter;if(!paused)elapsed=clock()-origin;frame=(elapsed/(CLOCKS_PER_SEC/SONG_FPS))%SONG_FRAMES;
 if(frame!=last){
 clock_t now;render(gfx_vbuffer[0],banks[frame/SONG_BANK_FRAMES]+(frame%SONG_BANK_FRAMES)*SONG_FRAME_BYTES);
 now=clock();if(now-fps_start>=CLOCKS_PER_SEC){fps10=(shown*10UL*CLOCKS_PER_SEC)/(now-fps_start);shown=0;fps_start=now;}
 rect(gfx_vbuffer[0],125,0,80,8,23);gfx_SetTextFGColor(16);gfx_SetTextBGColor(23);gfx_SetTextXY(128,0);gfx_PrintUInt(paused?0:fps10/10,1);gfx_PrintString(".");gfx_PrintUInt(paused?0:fps10%10,1);gfx_PrintString(" fps");
 gfx_SwapDraw();if(!paused)shown++;last=frame;
 }
 }
 gfx_End();return 0;
}
