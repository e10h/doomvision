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

/* Chat Line Buffer */
#define MAX_LINES 23
#define LINE_COLS 39
#define MAX_INPUT 128

typedef struct {
    char text[LINE_COLS + 1];
    uint8_t color; /* 0=White, 1=Cyan (user), 2=Green (AI), 3=Red (err) */
} ChatLine;

static ChatLine chat[MAX_LINES];
static int chat_count = 0;
static char input_buf[MAX_INPUT + 1];
static int input_len = 0;

enum TypingMode {
    MODE_UPPER = 0,
    MODE_LOWER = 1,
    MODE_NUM = 2
};
static enum TypingMode typing_mode = MODE_UPPER;
static const char *status_str = "Waiting for USB link…";

/* Forward declaration */
static void queue_rx(void);

static usb_error_t tx_complete(usb_endpoint_t ep, usb_transfer_status_t status, size_t n, void *arg) {
    (void)ep; (void)status; (void)n; (void)arg;
    tx_busy = false;
    return USB_SUCCESS;
}

static void append_chat_char(char c, uint8_t color);
static void append_newline(uint8_t color);

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
    gfx_FillScreen(0); /* Black background */

    /* Top Header Bar */
    gfx_SetColor(1); /* Dark Teal */
    gfx_FillRectangle(0, 0, 320, 18);
    gfx_SetColor(2); /* Neon Green line */
    gfx_HorizLine(0, 18, 320);

    gfx_SetTextFGColor(3); /* Neon Green text */
    gfx_PrintStringXY("CalcGPT", 6, 4);

    gfx_SetTextFGColor(4); /* Light Gray */
    gfx_PrintStringXY("| ", 72, 4);
    gfx_PrintString(status_str);

    /* Chat Messages */
    for (i = 0; i < chat_count; i++) {
        uint8_t fg;
        switch (chat[i].color) {
            case 1: fg = 5; break; /* Cyan for user */
            case 2: fg = 3; break; /* Neon Green for AI */
            case 3: fg = 6; break; /* Red/Orange for errors */
            default: fg = 7; break; /* White */
        }
        gfx_SetTextFGColor(fg);
        gfx_PrintStringXY(chat[i].text, 6, 22 + i * 8);
    }

    /* Bottom Input Bar */
    gfx_SetColor(1);
    gfx_FillRectangle(0, 222, 320, 18);
    gfx_SetColor(2);
    gfx_HorizLine(0, 221, 320);

    /* Mode Badge */
    gfx_SetTextFGColor(3);
    if (typing_mode == MODE_UPPER) gfx_PrintStringXY("[A] > ", 6, 226);
    else if (typing_mode == MODE_LOWER) gfx_PrintStringXY("[a] > ", 6, 226);
    else gfx_PrintStringXY("[1] > ", 6, 226);

    gfx_SetTextFGColor(7);
    gfx_PrintString(input_buf);

    /* Blinking Cursor */
    if ((rtc_Seconds & 1) == 0) {
        gfx_PrintChar('_');
    }

    gfx_BlitBuffer();
}

static void send_prompt(void) {
    if (input_len == 0 || !ep_in || tx_busy) return;

    /* Display prompt in cyan with word wrapping, then drop to new line */
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

static char map_scancode(uint8_t key) {
    /* Standard Alpha mapping */
    if (typing_mode == MODE_UPPER || typing_mode == MODE_LOWER) {
        char ch = 0;
        switch (key) {
            case sk_Math: ch = 'A'; break;
            case sk_Apps: ch = 'B'; break;
            case sk_Prgm: ch = 'C'; break;
            case sk_Recip: ch = 'D'; break;
            case sk_Sin: ch = 'E'; break;
            case sk_Cos: ch = 'F'; break;
            case sk_Tan: ch = 'G'; break;
            case sk_Power: ch = 'H'; break;
            case sk_Square: ch = 'I'; break;
            case sk_Comma: ch = 'J'; break;
            case sk_LParen: ch = 'K'; break;
            case sk_RParen: ch = 'L'; break;
            case sk_Div: ch = 'M'; break;
            case sk_Log: ch = 'N'; break;
            case sk_7: ch = 'O'; break;
            case sk_8: ch = 'P'; break;
            case sk_9: ch = 'Q'; break;
            case sk_Mul: ch = 'R'; break;
            case sk_Ln: ch = 'S'; break;
            case sk_4: ch = 'T'; break;
            case sk_5: ch = 'U'; break;
            case sk_6: ch = 'V'; break;
            case sk_Sub: ch = 'W'; break;
            case sk_Store: ch = 'X'; break;
            case sk_1: ch = 'Y'; break;
            case sk_2: ch = 'Z'; break;
            case sk_0: ch = ' '; break;
            case sk_DecPnt: ch = '.'; break;
            case sk_Chs: ch = '?'; break;
            default: break;
        }
        if (ch && typing_mode == MODE_LOWER && ch >= 'A' && ch <= 'Z') {
            ch = ch + ('a' - 'A');
        }
        return ch;
    }

    /* Numeric mapping */
    switch (key) {
        case sk_0: return '0';
        case sk_1: return '1';
        case sk_2: return '2';
        case sk_3: return '3';
        case sk_4: return '4';
        case sk_5: return '5';
        case sk_6: return '6';
        case sk_7: return '7';
        case sk_8: return '8';
        case sk_9: return '9';
        case sk_Add: return '+';
        case sk_Sub: return '-';
        case sk_Mul: return '*';
        case sk_Div: return '/';
        case sk_DecPnt: return '.';
        case sk_LParen: return '(';
        case sk_RParen: return ')';
        case sk_Comma: return ',';
        default: return 0;
    }
}

int main(void) {
    usb_error_t err;

    /* Initialize Graphics (8-bit palette) */
    gfx_Begin();
    gfx_SetDrawBuffer();

    /* Setup Custom Color Palette */
    gfx_SetPalette(gfx_palette, 256, 0);
    gfx_palette[0] = gfx_RGBTo1555(12, 15, 20);   /* 0: Background dark */
    gfx_palette[1] = gfx_RGBTo1555(16, 28, 34);   /* 1: Dark Teal header/footer */
    gfx_palette[2] = gfx_RGBTo1555(0, 255, 136);  /* 2: Neon Green highlight */
    gfx_palette[3] = gfx_RGBTo1555(0, 255, 136);  /* 3: Neon Green text */
    gfx_palette[4] = gfx_RGBTo1555(130, 160, 150);/* 4: Gray text */
    gfx_palette[5] = gfx_RGBTo1555(0, 216, 255);  /* 5: Cyan user text */
    gfx_palette[6] = gfx_RGBTo1555(255, 80, 80);   /* 6: Red error text */
    gfx_palette[7] = gfx_RGBTo1555(240, 244, 248);/* 7: Pure White text */

    append_chat_string("CalcGPT Gemini v1.0", 3);
    append_newline(3);
    append_chat_string("Connect USB cable to host.", 4);
    append_newline(4);
    append_chat_string("ALPHA: toggle A/a/1 | ENTER: send", 4);
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
        if (key == sk_Mode) {
            break; /* Exit */
        } else if (key == sk_Alpha) {
            typing_mode = (typing_mode + 1) % 3;
        } else if (key == sk_Del) {
            if (input_len > 0) {
                input_len--;
                input_buf[input_len] = '\0';
            }
        } else if (key == sk_Clear) {
            input_len = 0;
            input_buf[0] = '\0';
        } else if (key == sk_Enter) {
            send_prompt();
        } else if (key != 0) {
            char ch = map_scancode(key);
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

