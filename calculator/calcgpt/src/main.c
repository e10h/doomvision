#include <usbdrvce.h>
#include <graphx.h>
#include <keypadc.h>
#include <tice.h>
#include <ti/getcsc.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include "wire.h"
#include "font8x8.h"

/* USB Descriptors */
static const uint8_t configuration_bytes[32] = {
    9, USB_CONFIGURATION_DESCRIPTOR, 32, 0, 1, 1, 0,
    0x80 | USB_BUS_POWERED | USB_NO_REMOTE_WAKEUP, 50,
    9, USB_INTERFACE_DESCRIPTOR, 0, 0, 2,
    USB_VENDOR_SPECIFIC_CLASS, 0x44, 2, 0,
    /* Endpoint 1: Bulk IN (0x81) */
    7, USB_ENDPOINT_DESCRIPTOR, 0x81, USB_BULK_TRANSFER, 64, 0, 0,
    /* Endpoint 2: Bulk OUT (0x02) */
    7, USB_ENDPOINT_DESCRIPTOR, 0x02, USB_BULK_TRANSFER, 64, 0, 0
};

static usb_device_descriptor_t device = {
    18, USB_DEVICE_DESCRIPTOR, 0x0200, 0, 0, 0, 64,
    0x0451, 0xe008, 0x0100, 0, 1, 0, 1
};
_Static_assert(sizeof(device) == 18, "USB device descriptor packing");

static const usb_configuration_descriptor_t *configs[] = {
    (const usb_configuration_descriptor_t *)configuration_bytes
};
static const usb_string_descriptor_t product = {
    .bLength = 30,
    .bDescriptorType = USB_STRING_DESCRIPTOR,
    .bString = L"CalcGPT Gemini"
};
static const usb_string_descriptor_t lang = {
    .bLength = 4,
    .bDescriptorType = USB_STRING_DESCRIPTOR,
    .bString = { 0x0409 }
};
static const usb_string_descriptor_t *strings[] = { &product };
static const usb_standard_descriptors_t descriptors = {
    &device, configs, &lang, 1, strings
};

static usb_endpoint_t ep_in = NULL;
static usb_endpoint_t ep_out = NULL;
static bool usb_configured = false;

/* USB Buffers */
static cgpt_packet_t tx_pkt;
static cgpt_packet_t rx_pkt;
static volatile bool rx_pending = false;
static volatile bool tx_busy = false;

/*
 * Rotated Display Metrics (Sideways: 90 degrees CCW)
 * Logical Width:  240 (0..239)
 * Logical Height: 320 (0..319)
 * 8x8 font gives 29 columns and 35 lines of chat!
 */
#define LOGICAL_WIDTH  240
#define LOGICAL_HEIGHT 320
#define MAX_LINES      35
#define LINE_COLS      29
#define MAX_INPUT      128

typedef struct {
    char text[LINE_COLS + 1];
    uint8_t color; /* 1=Cyan (user), 2=Green (AI), 3=Red (err), 4=Gray */
} ChatLine;

static ChatLine chat[MAX_LINES];
static int chat_count = 0;
static char input_buf[MAX_INPUT + 1];
static int input_len = 0;

static bool shift_mode = false; /* false = lowercase [a], true = uppercase [A] */
static const char *status_str = "Waiting for USB link…";

/* Forward declarations */
static void queue_rx(void);
static void append_newline(uint8_t color);
static void append_chat_char(char c, uint8_t color);
static void append_chat_string(const char *str, uint8_t color);

/* Rotated Drawing Primitives (Sideways: 90 degrees Clockwise) */
static void fill_rect_rot(int lx, int ly, int lw, int lh, uint8_t color) {
    int px = ly;
    int py = 239 - (lx + lw - 1);
    int pw = lh;
    int ph = lw;
    if (px < 0) { pw += px; px = 0; }
    if (py < 0) { ph += py; py = 0; }
    if (px + pw > 320) pw = 320 - px;
    if (py + ph > 240) ph = 240 - py;
    if (pw > 0 && ph > 0) {
        gfx_SetColor(color);
        gfx_FillRectangle(px, py, pw, ph);
    }
}

static void draw_char_rot(int lx, int ly, char c, uint8_t fg, uint8_t bg) {
    uint8_t uc = (uint8_t)c;
    if (uc > 127) uc = '?';
    const uint8_t *glyph = font8x8_basic[uc];
    int r, col;
    for (r = 0; r < 8; r++) {
        uint8_t b = glyph[r];
        int px = ly + r;
        if (px < 0 || px >= 320) continue;
        for (col = 0; col < 8; col++) {
            int py = 239 - (lx + col);
            if (py < 0 || py >= 240) continue;
            gfx_vbuffer[py][px] = (b & (1 << col)) ? fg : bg;
        }
    }
}

static void draw_string_rot(int lx, int ly, const char *str, uint8_t fg, uint8_t bg) {
    while (*str) {
        if (lx + 8 > LOGICAL_WIDTH) break;
        draw_char_rot(lx, ly, *str++, fg, bg);
        lx += 8;
    }
}

static usb_error_t tx_complete(usb_endpoint_t ep, usb_transfer_status_t status, size_t n, void *arg) {
    (void)ep; (void)status; (void)n; (void)arg;
    tx_busy = false;
    return USB_SUCCESS;
}

static usb_error_t rx_complete(usb_endpoint_t ep, usb_transfer_status_t status, size_t n, void *arg) {
    (void)ep; (void)arg;
    if (status == USB_TRANSFER_COMPLETED && n >= 8) {
        if (rx_pkt.magic[0] == CGPT_MAGIC_0 &&
            rx_pkt.magic[1] == CGPT_MAGIC_1 &&
            rx_pkt.magic[2] == CGPT_MAGIC_2 &&
            rx_pkt.magic[3] == CGPT_MAGIC_3) {
            
            uint8_t type = rx_pkt.type;
            uint16_t len = rx_pkt.length;
            if (len > USB_PAYLOAD_MAX) len = USB_PAYLOAD_MAX;

            if (type == PKT_REPLY_START) {
                status_str = "Gemini typing…";
                if (chat_count > 0 && strlen(chat[chat_count - 1].text) > 0) {
                    append_newline(2);
                }
            } else if (type == PKT_REPLY_CHUNK) {
                uint16_t i;
                status_str = "Receiving stream…";
                for (i = 0; i < len; i++) {
                    append_chat_char((char)rx_pkt.payload[i], 2);
                }
            } else if (type == PKT_REPLY_END) {
                status_str = "Online (Ready)";
                if (chat_count > 0 && strlen(chat[chat_count - 1].text) > 0) {
                    append_newline(2);
                }
            } else if (type == PKT_ERROR) {
                uint16_t i;
                status_str = "Gemini Error";
                append_newline(3);
                for (i = 0; i < len; i++) {
                    append_chat_char((char)rx_pkt.payload[i], 3);
                }
                append_newline(3);
            } else if (type == PKT_PONG) {
                status_str = "Online (Ready)";
            }
        }
    }
    rx_pending = false;
    queue_rx();
    return USB_SUCCESS;
}

static void queue_rx(void) {
    if (ep_out && !rx_pending) {
        rx_pending = true;
        if (usb_ScheduleBulkTransfer(ep_out, &rx_pkt, USB_PACKET_SIZE, rx_complete, NULL) != USB_SUCCESS) {
            rx_pending = false;
        }
    }
}

static usb_error_t usb_event(usb_event_t e, void *data, void *arg) {
    (void)data; (void)arg;
    if (e == USB_HOST_CONFIGURE_EVENT) {
        usb_device_t host = usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);
        ep_in = usb_GetDeviceEndpoint(host, 0x81);
        ep_out = usb_GetDeviceEndpoint(host, 0x02);
        if (ep_in) usb_SetEndpointFlags(ep_in, USB_AUTO_TERMINATE);
        if (ep_out) usb_SetEndpointFlags(ep_out, USB_AUTO_TERMINATE);
        usb_configured = true;
        status_str = "Connected to host";
        queue_rx();
    } else if (e == USB_DEVICE_DISCONNECTED_EVENT || e == USB_DEVICE_DISABLED_EVENT) {
        ep_in = NULL;
        ep_out = NULL;
        usb_configured = false;
        rx_pending = false;
        status_str = "Waiting for USB link…";
    }
    return USB_SUCCESS;
}

static void scroll_chat(void) {
    int i;
    for (i = 0; i < MAX_LINES - 1; i++) {
        chat[i] = chat[i + 1];
    }
    memset(chat[MAX_LINES - 1].text, 0, sizeof(chat[MAX_LINES - 1].text));
    chat[MAX_LINES - 1].color = 0;
    if (chat_count > 0) chat_count--;
}

static void append_newline(uint8_t color) {
    int cur_idx;
    if (chat_count >= MAX_LINES) {
        scroll_chat();
        cur_idx = MAX_LINES - 1;
    } else {
        chat_count++;
        cur_idx = chat_count - 1;
    }
    memset(chat[cur_idx].text, 0, sizeof(chat[cur_idx].text));
    chat[cur_idx].color = color;
}

static void append_chat_char(char c, uint8_t color) {
    int cur_idx;
    int len;

    if (chat_count == 0) {
        append_newline(color);
    }

    if (c == '\n') {
        append_newline(color);
        return;
    }

    cur_idx = chat_count - 1;
    len = strlen(chat[cur_idx].text);

    if (len >= LINE_COLS) {
        append_newline(color);
        cur_idx = chat_count - 1;
        len = 0;
    }

    chat[cur_idx].text[len] = c;
    chat[cur_idx].text[len + 1] = '\0';
    chat[cur_idx].color = color;
}

static void append_chat_string(const char *str, uint8_t color) {
    while (*str) {
        append_chat_char(*str++, color);
    }
}

static void draw_ui(void) {
    int i;
    /* Clear full screen (Black = color 0) */
    gfx_FillScreen(0);

    /* Top Header Bar (ly=0..16) */
    fill_rect_rot(0, 0, LOGICAL_WIDTH, 16, 1); /* Dark Teal */
    fill_rect_rot(0, 16, LOGICAL_WIDTH, 1, 2);  /* Neon Green line */

    draw_string_rot(4, 4, "CalcGPT", 3, 1);
    draw_string_rot(68, 4, "|", 4, 1);
    draw_string_rot(80, 4, status_str, 4, 1);

    /* Chat Messages (ly=18..298, up to 35 lines) */
    for (i = 0; i < chat_count; i++) {
        uint8_t fg;
        switch (chat[i].color) {
            case 1: fg = 5; break; /* Cyan for user */
            case 2: fg = 3; break; /* Neon Green for AI */
            case 3: fg = 6; break; /* Red/Orange for errors */
            default: fg = 7; break; /* White */
        }
        draw_string_rot(4, 20 + i * 8, chat[i].text, fg, 0);
    }

    /* Bottom Input Bar (ly=300..320) */
    fill_rect_rot(0, 300, LOGICAL_WIDTH, 20, 1); /* Dark Teal */
    fill_rect_rot(0, 299, LOGICAL_WIDTH, 1, 2);   /* Neon Green line */

    /* Prompt indicator */
    if (shift_mode) {
        draw_string_rot(4, 306, "[A] >", 3, 1);
    } else {
        draw_string_rot(4, 306, "[a] >", 3, 1);
    }

    /* Input text (scrolls horizontally if longer than 22 chars) */
    int disp_offset = 0;
    if (input_len > 22) {
        disp_offset = input_len - 22;
    }
    draw_string_rot(52, 306, input_buf + disp_offset, 7, 1);

    /* Blinking Cursor */
    if ((rtc_Seconds & 1) == 0) {
        int cursor_x = 52 + (input_len - disp_offset) * 8;
        if (cursor_x + 8 <= LOGICAL_WIDTH) {
            draw_char_rot(cursor_x, 306, '_', 3, 1);
        }
    }

    gfx_BlitBuffer();
}

static void send_prompt(void) {
    if (input_len == 0 || !ep_in || tx_busy) return;

    /* Display prompt in cyan with word wrapping, then drop to next line */
    append_chat_string("> ", 1);
    append_chat_string(input_buf, 1);
    append_newline(2);

    status_str = "Sending prompt…";
    cgpt_init_packet(&tx_pkt, PKT_PROMPT_START, 0, input_buf, input_len);
    tx_busy = true;
    if (usb_ScheduleBulkTransfer(ep_in, &tx_pkt, USB_PACKET_SIZE, tx_complete, NULL) != USB_SUCCESS) {
        tx_busy = false;
        status_str = "USB Tx error";
    }

    input_len = 0;
    input_buf[0] = '\0';
}

/*
 * Sideways QWERTY Keypad Matrix Mapping:
 * Held 90 degrees CCW:
 * Top Row:    0 to window ==> Q to P
 * Middle Row: . to del    ==> A to L
 * Bottom Row: (-) to var  ==> Z to M
 * Control:
 *   [+]     ==> Shift toggle ([a] <-> [A])
 *   [^]     ==> Space
 *   [-]     ==> Backspace
 *   [CLEAR] ==> Clear line
 *   [ENTER] ==> Send message
 *   [*]     ==> '*'
 *   [/]     ==> '/'
 *   [MATH]  ==> '?'
 *   [x^-1]  ==> '.'
 *   [LOG]   ==> ','
 *   [LN]    ==> '\''
 */
static char map_qwerty_key(uint8_t key) {
    char ch = 0;
    switch (key) {
        /* Row 1: 0 to window ==> Q to P */
        case sk_0:        ch = 'Q'; break;
        case sk_1:        ch = 'W'; break;
        case sk_4:        ch = 'E'; break;
        case sk_7:        ch = 'R'; break;
        case sk_Comma:    ch = 'T'; break;
        case sk_Sin:      ch = 'Y'; break;
        case sk_Apps:     ch = 'U'; break;
        case sk_GraphVar: ch = 'I'; break;
        case sk_Mode:     ch = 'O'; break;
        case sk_Window:   ch = 'P'; break;

        /* Row 2: . to del ==> A to L */
        case sk_DecPnt:   ch = 'A'; break;
        case sk_2:        ch = 'S'; break;
        case sk_5:        ch = 'D'; break;
        case sk_8:        ch = 'F'; break;
        case sk_LParen:   ch = 'G'; break;
        case sk_Cos:      ch = 'H'; break;
        case sk_Prgm:     ch = 'J'; break;
        case sk_Stat:     ch = 'K'; break;
        case sk_Del:      ch = 'L'; break;

        /* Row 3: (-) to var ==> Z to M */
        case sk_Chs:      ch = 'Z'; break;
        case sk_3:        ch = 'X'; break;
        case sk_6:        ch = 'C'; break;
        case sk_9:        ch = 'V'; break;
        case sk_RParen:   ch = 'B'; break;
        case sk_Tan:      ch = 'N'; break;
        case sk_Vars:     ch = 'M'; break;

        /* Punctuation & symbols */
        case sk_Math:     ch = '?'; break;
        case sk_Recip:    ch = '.'; break;
        case sk_Log:      ch = ','; break;
        case sk_Ln:       ch = '\''; break;
        case sk_Mul:      ch = '*'; break;
        case sk_Div:      ch = '/'; break;

        default: return 0;
    }

    if (!shift_mode && ch >= 'A' && ch <= 'Z') {
        ch = ch + ('a' - 'A');
    }
    return ch;
}

int main(void) {
    usb_error_t err;

    /* Initialize Graphics (8-bit palette) */
    gfx_Begin();
    gfx_SetDrawBuffer();

    /* Setup Custom Color Palette */
    gfx_SetPalette(gfx_palette, 256, 0);
    gfx_palette[0] = gfx_RGBTo1555(12, 15, 20);    /* 0: Background dark */
    gfx_palette[1] = gfx_RGBTo1555(16, 28, 34);    /* 1: Dark Teal header/footer */
    gfx_palette[2] = gfx_RGBTo1555(0, 255, 136);   /* 2: Neon Green highlight */
    gfx_palette[3] = gfx_RGBTo1555(0, 255, 136);   /* 3: Neon Green text */
    gfx_palette[4] = gfx_RGBTo1555(130, 160, 150); /* 4: Gray text */
    gfx_palette[5] = gfx_RGBTo1555(0, 216, 255);   /* 5: Cyan user text */
    gfx_palette[6] = gfx_RGBTo1555(255, 80, 80);   /* 6: Red error text */
    gfx_palette[7] = gfx_RGBTo1555(240, 244, 248); /* 7: Pure White text */

    append_chat_string("CalcGPT QWERTY v2.0", 3);
    append_newline(3);
    append_chat_string("Sideways layout: 240x320", 4);
    append_newline(4);
    append_chat_string("+:Shift ^:Space -:Backspace", 4);
    append_newline(4);
    append_chat_string("ENTER:Send CLEAR:Clear Y=:Exit", 4);
    append_newline(4);

    /* Initialize USB in device mode */
    err = usb_Init(usb_event, NULL, &descriptors, USB_DEFAULT_INIT_FLAGS);
    if (err != USB_SUCCESS) {
        gfx_FillScreen(0);
        gfx_SetTextFGColor(6);
        gfx_PrintStringXY("USB Init Failed!", 12, 12);
        gfx_BlitBuffer();
        while (!os_GetCSC());
        gfx_End();
        return 1;
    }

    while (1) {
        uint8_t key;
        usb_HandleEvents();

        key = os_GetCSC();
        if (key == sk_Yequ) {
            break; /* [Y=] quits to TI-OS */
        } else if (key == sk_Add) {
            shift_mode = !shift_mode; /* [+] toggles uppercase / lowercase */
        } else if (key == sk_Sub) {
            /* [-] is Backspace */
            if (input_len > 0) {
                input_len--;
                input_buf[input_len] = '\0';
            }
        } else if (key == sk_Power) {
            /* [^] is Space */
            if (input_len < MAX_INPUT) {
                input_buf[input_len++] = ' ';
                input_buf[input_len] = '\0';
            }
        } else if (key == sk_Clear) {
            /* [CLEAR] clears line */
            input_len = 0;
            input_buf[0] = '\0';
        } else if (key == sk_Enter) {
            /* [ENTER] sends message */
            send_prompt();
        } else if (key != 0) {
            char ch = map_qwerty_key(key);
            if (ch && input_len < MAX_INPUT) {
                input_buf[input_len++] = ch;
                input_buf[input_len] = '\0';
            }
        }

        draw_ui();
    }

    usb_Cleanup();
    gfx_End();
    return 0;
}
