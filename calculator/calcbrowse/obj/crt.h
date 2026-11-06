/* generated from: obj/BROWSER.o */
#define HAS_INIT_ARRAY 0
#define HAS_FINI_ARRAY 0
#define HAS_CLOCK 0
#define HAS_ABORT 0
#define HAS_EXIT 0
#define HAS_C99__EXIT 0
#define HAS_RUN_PRGM 0
#define HAS_MAIN_ARGC_ARGV 0
#define HAS_ATEXIT 0
#ifdef __ASSEMBLER__
.macro LIBLOAD_LIBS
	.global __libload_library_GRAPHX
	.type __libload_library_GRAPHX, @object
__libload_library_GRAPHX:
	.db 0xC0, "GRAPHX", 0, 14
	.global _gfx_Begin
	.type _gfx_Begin, @function
_gfx_Begin:
	jp 0
	.global _gfx_End
	.type _gfx_End, @function
_gfx_End:
	jp 3
	.global _gfx_SetColor
	.type _gfx_SetColor, @function
_gfx_SetColor:
	jp 6
	.global _gfx_FillScreen
	.type _gfx_FillScreen, @function
_gfx_FillScreen:
	jp 15
	.global _gfx_SetDraw
	.type _gfx_SetDraw, @function
_gfx_SetDraw:
	jp 27
	.global _gfx_Blit
	.type _gfx_Blit, @function
_gfx_Blit:
	jp 33
	.global _gfx_PrintStringXY
	.type _gfx_PrintStringXY, @function
_gfx_PrintStringXY:
	jp 54
	.global _gfx_SetTextFGColor
	.type _gfx_SetTextFGColor, @function
_gfx_SetTextFGColor:
	jp 63
	.global _gfx_HorizLine
	.type _gfx_HorizLine, @function
_gfx_HorizLine:
	jp 93
	.global _gfx_Circle
	.type _gfx_Circle, @function
_gfx_Circle:
	jp 99
	.global _gfx_Rectangle
	.type _gfx_Rectangle, @function
_gfx_Rectangle:
	jp 105
	.global _gfx_FillRectangle
	.type _gfx_FillRectangle, @function
_gfx_FillRectangle:
	jp 108
	.global __libload_library_KEYPADC
	.type __libload_library_KEYPADC, @object
__libload_library_KEYPADC:
	.db 0xC0, "KEYPADC", 0, 2
	.global _kb_Scan
	.type _kb_Scan, @function
_kb_Scan:
	jp 0
	.global __libload_library_USBDRVCE
	.type __libload_library_USBDRVCE, @object
__libload_library_USBDRVCE:
	.db 0xC0, "USBDRVCE", 0, 0
	.global _usb_Init
	.type _usb_Init, @function
_usb_Init:
	jp 0
	.global _usb_Cleanup
	.type _usb_Cleanup, @function
_usb_Cleanup:
	jp 3
	.global _usb_HandleEvents
	.type _usb_HandleEvents, @function
_usb_HandleEvents:
	jp 9
	.global _usb_FindDevice
	.type _usb_FindDevice, @function
_usb_FindDevice:
	jp 36
	.global _usb_GetDeviceEndpoint
	.type _usb_GetDeviceEndpoint, @function
_usb_GetDeviceEndpoint:
	jp 84
	.global _usb_SetEndpointFlags
	.type _usb_SetEndpointFlags, @function
_usb_SetEndpointFlags:
	jp 108
	.global _usb_ScheduleTransfer
	.type _usb_ScheduleTransfer, @function
_usb_ScheduleTransfer:
	jp 129
.endm
#endif
#define HAS_LIBLOAD 1
