#include <usbdrvce.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdint.h>
#include <string.h>
#define PIANO_SAMPLES 128
#include "media.h"
#include "piano.h"
#include "wire.h"
/* Explicit USB wire bytes: C struct padding must not enter descriptors. */
static const uint8_t configuration_bytes[25]={9,USB_CONFIGURATION_DESCRIPTOR,25,0,1,1,0,0x80|USB_BUS_POWERED|USB_NO_REMOTE_WAKEUP,50,9,USB_INTERFACE_DESCRIPTOR,0,0,1,USB_VENDOR_SPECIFIC_CLASS,0x44,1,0,7,USB_ENDPOINT_DESCRIPTOR,0x81,USB_BULK_TRANSFER,64,0,0};
static usb_device_descriptor_t device={18,USB_DEVICE_DESCRIPTOR,0x0200,0,0,0,64,0x0451,0xe008,0x0106,0,1,0,1};
_Static_assert(sizeof(device)==18,"USB device descriptor packing");
static const usb_configuration_descriptor_t* configs[]={(const usb_configuration_descriptor_t*)configuration_bytes};
static const usb_string_descriptor_t product={.bLength=32,.bDescriptorType=USB_STRING_DESCRIPTOR,.bString=L"Doomvision PCM6"};
static const usb_string_descriptor_t lang={.bLength=4,.bDescriptorType=USB_STRING_DESCRIPTOR,.bString={0x0409}};
static const usb_string_descriptor_t* strings[]={&product};
static const usb_standard_descriptors_t descriptors={&device,configs,&lang,1,strings};
static usb_endpoint_t endpoint;static uint8_t clock_sync;
typedef struct{uint8_t data[AUDIO_PACKET_BYTES],busy;}Slot;static Slot slots[8];static uint32_t sequence;static unsigned int sent,errors;
static usb_error_t complete(usb_endpoint_t ep,usb_transfer_status_t status,size_t n,void*arg){Slot*s=arg;(void)ep;s->busy=0;if(status!=USB_TRANSFER_COMPLETED||n!=AUDIO_PACKET_BYTES)errors++;else sent++;return USB_SUCCESS;}
static usb_error_t event(usb_event_t e,void*data,void*arg){(void)data;(void)arg;if(e==USB_HOST_CONFIGURE_EVENT){usb_device_t host=usb_FindDevice(NULL,NULL,USB_SKIP_HUBS);endpoint=usb_GetDeviceEndpoint(host,0x81);clock_sync=1;if(endpoint)usb_SetEndpointFlags(endpoint,USB_AUTO_TERMINATE);}else if(e==USB_DEVICE_DISCONNECTED_EVENT||e==USB_DEVICE_DISABLED_EVENT){endpoint=NULL;}return USB_SUCCESS;}
#include "clip.h"

int main(void){uint8_t previous[7]={0},old_y=0,old_second=0,old_enter=0,synth=1,paused=0;unsigned int last=0,ui=0;usb_error_t error;
 gfx_Begin();gfx_FillScreen(255);gfx_SetTextFGColor(0);gfx_PrintStringXY("DVUSB6 - 16kHz audio",12,12);gfx_PrintStringXY("Y= piano/Rick  2nd play/pause",12,30);gfx_PrintStringXY("ENTER restart / CLEAR exit",12,46);
 error=usb_Init(event,NULL,&descriptors,USB_DEFAULT_INIT_FLAGS);if(error!=USB_SUCCESS){gfx_PrintStringXY("USB init failed",12,80);kb_AnyKey();usb_Cleanup();gfx_End();return 1;}
 __asm__ volatile("di");kb_EnableInt=0;kb_SetMode(MODE_3_CONTINUOUS);
 while(1){uint8_t y,second,enter,row,bit;unsigned int now;usb_HandleEvents();if(kb_Data[6]&kb_Clear)break;y=!!(kb_Data[1]&kb_Yequ);second=!!(kb_Data[1]&kb_2nd);enter=!!(kb_Data[6]&kb_Enter);if(y&&!old_y){synth=!synth;paused=0;memset(voices,0,sizeof voices);ui=0;}if(!synth&&second&&!old_second){paused=!paused;ui=0;}if(!synth&&enter&&!old_enter){cur_block=0;cur_pos=0;}old_y=y;old_second=second;old_enter=enter;
 for(row=0;row<7;row++){uint8_t keys=kb_Data[row+1]&key_masks[row],fresh=keys&~previous[row];if(synth)for(bit=0;bit<8;bit++)if(fresh&(1<<bit))note_on(key_notes[row][bit]);previous[row]=keys;}
 now=usb_GetFrameNumber()&0x3ff8;if(clock_sync){last=now;clock_sync=0;}if(endpoint&&((now-last)&0x3fff)>=64){uint8_t i;for(i=0;i<8;i++)if(!slots[i].busy)break;if(i<8){if(((now-last)&0x3fff)>512)last=now;else last=(last+64)&0x3fff;Slot*s=&slots[i];if(synth)piano_block();else if(paused)memset(pcm,0,sizeof pcm);else clip_block();usb_audio_packet(s->data,sequence++,synth?1:paused?2:0,pcm);s->busy=1;if(usb_ScheduleBulkTransfer(endpoint,s->data,AUDIO_PACKET_BYTES,complete,s)!=USB_SUCCESS){s->busy=0;errors++;last=now;}}}
 if(!ui||((now-ui)&0x3fff)>=2000){ui=now?now:1;gfx_SetColor(255);gfx_FillRectangle(12,80,300,64);gfx_PrintStringXY(endpoint?"USB configured (16 kHz)":"Waiting for Mac USB receiver",12,80);gfx_PrintStringXY(synth?"Piano":paused?"Rick Astley (Paused)":"Rick Astley (Playing)",12,98);gfx_SetTextXY(12,114);gfx_PrintUInt(sent,1);gfx_PrintString(" chunks / ");gfx_PrintUInt(errors,1);gfx_PrintString(" errors");}
 }
 usb_Cleanup();kb_SetMode(MODE_0_IDLE);kb_Reset();gfx_End();return 0;}
