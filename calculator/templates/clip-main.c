#include <graphx.h>
#include <keypadc.h>
#include <time.h>
#include <string.h>
#include "render.h"
#include "audio-encoder.h"
#include "media.h"
static uint8_t frame_data[SONG_FRAME_BYTES];
#include "piano.h"
int main(void){
 unsigned int i,frame=0,last=SONG_FRAMES,shown=0,fps10=0,piano_index=0;clock_t origin=0,elapsed=0,fps_start=0,last_tick=0;
 int paused=1,synth=0,oldmode=0,oldsecond=0,oldenter=0;uint8_t previous[7]={0};
 gfx_Begin();for(i=0;i<27;i++)gfx_palette[i]=gfx_RGBTo1555(song_rgb[i][0],song_rgb[i][1],song_rgb[i][2]);gfx_SetDrawBuffer();render_background(gfx_vbuffer[0]);gfx_SwapDraw();render_background(gfx_vbuffer[0]);audio_encoder_init();fps_start=clock();
 while(1){int mode,second,enter,draw=0;clock_t now;kb_Scan();now=clock();mode=!!(kb_Data[1]&kb_Yequ);second=!!(kb_Data[1]&kb_2nd);enter=!!(kb_Data[6]&kb_Enter);
 if(mode&&!oldmode){if(!synth){if(!paused)elapsed=now-origin;piano_index=0;memset(voices,0,sizeof voices);last_tick=now-CLOCKS_PER_SEC/8;}else origin=now-elapsed;synth=!synth;last=SONG_FRAMES;shown=0;fps10=0;fps_start=now;}
 if(synth){uint8_t row,bit;for(row=0;row<7;row++){uint8_t keys=kb_Data[row+1]&key_masks[row],fresh=keys&~previous[row];for(bit=0;bit<8;bit++)if(key_masks[row]&(1<<bit)){if(fresh&(1<<bit))note_on(key_notes[row][bit]);}previous[row]=keys;}if(now-last_tick>=CLOCKS_PER_SEC/8){last_tick=now;audio_header(0x50494e31UL,piano_index,65535);piano_block();audio_pcm(pcm);piano_index++;if(piano_index==65535)piano_index=0;draw=1;}}
 else{
 if(kb_Data[6]&kb_Clear)break;
 if(second&&!oldsecond){if(paused){origin=now-elapsed;paused=0;}else{elapsed=now-origin;paused=1;}last=SONG_FRAMES;shown=0;fps10=0;fps_start=now;}
 if(enter&&!oldenter){elapsed=0;origin=now;last=SONG_FRAMES;}
 if(!paused)elapsed=now-origin;frame=(elapsed/(CLOCKS_PER_SEC/SONG_FPS))%SONG_FRAMES;
 if(frame!=last){const uint8_t*b=rick_adpcm+frame*502;audio_header(RICK_ID,frame,64);packet[22]=b[0];packet[23]=b[1];memcpy(packet+26,b+2,500);draw=1;}
 for(i=0;i<7;i++)previous[i]=kb_Data[i+1]&key_masks[i];
 }
 oldmode=mode;oldsecond=second;oldenter=enter;
 if(draw){audio_transport(frame_data);render(gfx_vbuffer[0],frame_data);now=clock();if(now-fps_start>=CLOCKS_PER_SEC){fps10=(shown*10UL*CLOCKS_PER_SEC)/(now-fps_start);shown=0;fps_start=now;}hud_clear(gfx_vbuffer[0]);gfx_SetTextFGColor(16);gfx_SetTextBGColor(23);if(synth)gfx_PrintStringXY("P",100,0);gfx_SetTextXY(128,0);gfx_PrintUInt(!synth&&paused?0:fps10/10,1);gfx_PrintString(".");gfx_PrintUInt(!synth&&paused?0:fps10%10,1);gfx_PrintString(" fps");gfx_SwapDraw();if(synth||!paused)shown++;last=frame;}
 }
 gfx_End();return 0;
}
