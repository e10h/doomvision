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
#include "cursor.h"
#include "font8x8.h"

/* USB Descriptors */
static const uint8_t configuration_bytes[32] = {
    9, USB_CONFIGURATION_DESCRIPTOR, 32, 0, 1, 1, 0,
    0x80 | USB_BUS_POWERED | USB_NO_REMOTE_WAKEUP, 50,
    9, USB_INTERFACE_DESCRIPTOR, 0, 0, 2,
    USB_VENDOR_SPECIFIC_CLASS, 0x45, 2, 0, /* Subclass 0x45 for Browser */
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
    .bLength = 34,
    .bDescriptorType = USB_STRING_DESCRIPTOR,
    .bString = L"TI-84 Web Browser"
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
static brow_packet_t tx_pkt;
static brow_packet_t rx_pkt;
static volatile bool rx_pending = false;
static volatile bool tx_busy = false;

/* Screen Metrics */
#define SCREEN_W 320
#define SCREEN_H 240
#define TOTAL_PIXELS (SCREEN_W * SCREEN_H)

static size_t page_write_idx = 0;
static bool needs_blit = true;

/* Mouse Cursor with local background save/restore (108 bytes only!) */
static int cursor_x = 160;
static int cursor_y = 120;
static int saved_x = 160;
static int saved_y = 120;
static uint8_t cursor_saved[CURSOR_H][CURSOR_W];
static bool cursor_is_saved = false;
static int hold_duration = 0;
static int click_anim = 0;

/* Navigation & URL Bar */
static char current_url[64] = "https://wikipedia.org";
static char url_input[64] = "";
static int url_input_len = 0;
static bool url_bar_active = false;
static const char *status_msg = "Connect USB to Browse";

/* RGB332 Palette generation */
static void setup_rgb332_palette(void) {
    int i;
    for (i = 0; i < 256; i++) {
        uint8_t r = (i >> 5) & 7;
        uint8_t g = (i >> 2) & 7;
        uint8_t b = i & 3;
        uint16_t r5 = (r * 31) / 7;
        uint16_t g5 = (g * 31) / 7;
        uint16_t b5 = (b * 31) / 3;
        gfx_palette[i] = (r5 << 10) | (g5 << 5) | b5;
    }
}

/* 8x8 Text Rendering */
static void draw_char(int x, int y, char c, uint8_t fg, uint8_t bg, bool transparent_bg) {
    uint8_t uc = (uint8_t)c;
    if (uc > 127) uc = '?';
    const uint8_t *glyph = font8x8_basic[uc];
    int r, col;
    for (r = 0; r < 8; r++) {
        int py = y + r;
        if (py < 0 || py >= SCREEN_H) continue;
        uint8_t b = glyph[r];
        for (col = 0; col < 8; col++) {
            int px = x + col;
            if (px < 0 || px >= SCREEN_W) continue;
            if (b & (1 << col)) {
                gfx_vbuffer[py][px] = fg;
            } else if (!transparent_bg) {
                gfx_vbuffer[py][px] = bg;
            }
        }
    }
}

static void draw_string(int x, int y, const char *str, uint8_t fg, uint8_t bg, bool transparent_bg) {
    while (*str) {
        if (x + 8 > SCREEN_W) break;
        draw_char(x, y, *str++, fg, bg, transparent_bg);
        x += 8;
    }
}

static void restore_cursor_bg(void) {
    if (!cursor_is_saved) return;
    int r, c;
    for (r = 0; r < CURSOR_H; r++) {
        int py = saved_y + r;
        if (py < 0 || py >= SCREEN_H) continue;
        for (c = 0; c < CURSOR_W; c++) {
            int px = saved_x + c;
            if (px < 0 || px >= SCREEN_W) continue;
            gfx_vbuffer[py][px] = cursor_saved[r][c];
        }
    }
    cursor_is_saved = false;
}

static void save_and_draw_cursor(int x, int y) {
    int r, c;
    saved_x = x;
    saved_y = y;
    for (r = 0; r < CURSOR_H; r++) {
        int py = y + r;
        if (py < 0 || py >= SCREEN_H) continue;
        for (c = 0; c < CURSOR_W; c++) {
            int px = x + c;
            if (px < 0 || px >= SCREEN_W) continue;
            cursor_saved[r][c] = gfx_vbuffer[py][px];
            uint8_t pixel = cursor_sprite[r][c];
            if (pixel == 1) {
                gfx_vbuffer[py][px] = 0x00; /* Black */
            } else if (pixel == 2) {
                gfx_vbuffer[py][px] = 0xFF; /* White */
            }
        }
    }
    cursor_is_saved = true;
}

static void queue_rx(void);

static usb_error_t tx_complete(usb_endpoint_t ep, usb_transfer_status_t status, size_t n, void *arg) {
    (void)ep; (void)status; (void)n; (void)arg;
    tx_busy = false;
    return USB_SUCCESS;
}

static void send_cmd(uint8_t type, const void *data, uint16_t len) {
    if (!ep_in) return;
    tx_busy = true;
    brow_init_packet(&tx_pkt, type, 0, data, len);
    if (usb_ScheduleBulkTransfer(ep_in, &tx_pkt, USB_PACKET_SIZE, tx_complete, NULL) != USB_SUCCESS) {
        tx_busy = false;
    }
}

static usb_error_t rx_complete(usb_endpoint_t ep, usb_transfer_status_t status, size_t n, void *arg) {
    (void)ep; (void)arg;
    if (status == USB_TRANSFER_COMPLETED && n >= 8) {
        if (rx_pkt.magic[0] == BROW_MAGIC_0 &&
            rx_pkt.magic[1] == BROW_MAGIC_1 &&
            rx_pkt.magic[2] == BROW_MAGIC_2 &&
            rx_pkt.magic[3] == BROW_MAGIC_3) {

            uint8_t type = rx_pkt.type;
            uint16_t len = rx_pkt.length;
            if (len > USB_PAYLOAD_MAX) len = USB_PAYLOAD_MAX;

            if (type == PKT_FRAME_START) {
                restore_cursor_bg();
                page_write_idx = 0;
                status_msg = "Receiving page…";
                tx_busy = false;
            } else if (type == PKT_FRAME_DATA) {
                uint16_t i;
                for (i = 0; i + 1 < len; i += 2) {
                    uint8_t count = rx_pkt.payload[i];
                    uint8_t color = rx_pkt.payload[i + 1];
                    while (count > 0 && page_write_idx < TOTAL_PIXELS) {
                        int py = page_write_idx / SCREEN_W;
                        int px = page_write_idx % SCREEN_W;
                        gfx_vbuffer[py][px] = color;
                        page_write_idx++;
                        count--;
                    }
                }
            } else if (type == PKT_FRAME_END) {
                status_msg = "Ready";
                tx_busy = false;
                needs_blit = true;
            } else if (type == PKT_URL_UPDATE) {
                uint16_t copy_len = len < 63 ? len : 63;
                memcpy(current_url, rx_pkt.payload, copy_len);
                current_url[copy_len] = '\0';
                needs_blit = true;
            } else if (type == PKT_STATUS) {
                static char dynamic_status[40];
                uint16_t copy_len = len < 39 ? len : 39;
                memcpy(dynamic_status, rx_pkt.payload, copy_len);
                dynamic_status[copy_len] = '\0';
                status_msg = dynamic_status;
                needs_blit = true;
            } else if (type == PKT_PONG) {
                tx_busy = false;
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
        if (ep_in) usb_SetEndpointFlags(ep_in, USB_MANUAL_TERMINATE);
        if (ep_out) usb_SetEndpointFlags(ep_out, USB_MANUAL_TERMINATE);
        usb_configured = true;
        tx_busy = false;
        status_msg = "Connected · Loading…";
        queue_rx();
    } else if (e == USB_DEVICE_DISCONNECTED_EVENT || e == USB_DEVICE_DISABLED_EVENT) {
        ep_in = NULL;
        ep_out = NULL;
        usb_configured = false;
        rx_pending = false;
        tx_busy = false;
        status_msg = "Connect USB to Browse";
    }
    return USB_SUCCESS;
}

static void draw_chrome_bar(void) {
    gfx_SetColor(0x1B); /* Dark Slate / Navy Blue */
    gfx_FillRectangle(0, 0, SCREEN_W, 16);
    gfx_SetColor(0x36);
    gfx_HorizLine(0, 16, SCREEN_W);

    if (url_bar_active) {
        gfx_SetColor(0x00); /* Black box */
        gfx_FillRectangle(4, 2, SCREEN_W - 8, 12);
        gfx_SetColor(0x1F); /* Blue highlight */
        gfx_Rectangle(4, 2, SCREEN_W - 8, 12);
        draw_string(8, 4, "Go: ", 0xFC, 0x00, false);
        draw_string(36, 4, url_input, 0xFF, 0x00, false);
        if ((rtc_Seconds & 1) == 0) {
            int cx = 36 + url_input_len * 8;
            if (cx + 8 < SCREEN_W - 8) {
                draw_char(cx, 4, '_', 0xFC, 0x00, false);
            }
        }
    } else {
        draw_string(6, 4, current_url, 0xFF, 0x1B, false);
        draw_string(SCREEN_W - 100, 4, status_msg, 0x1F, 0x1B, false);
    }
}

int main(void) {
    usb_error_t err;

    /* Initialize Graphics */
    gfx_Begin();
    gfx_SetDrawBuffer();
    setup_rgb332_palette();

    /* Clear screen to clean white background */
    gfx_FillScreen(0xFF);
    draw_chrome_bar();
    draw_string(40, 80, "TI-84 Graphical Web Browser", 0x1B, 0xFF, false);
    draw_string(40, 100, "1. Connect USB cable to laptop", 0x49, 0xFF, false);
    draw_string(40, 116, "2. Open doomvision /browser", 0x49, 0xFF, false);
    draw_string(40, 140, "Controls:", 0x1B, 0xFF, false);
    draw_string(40, 156, "[Arrows] Move Mouse   [ENTER] Click", 0x00, 0xFF, false);
    draw_string(40, 172, "[+] / [-] Scroll Page  [WINDOW] URL", 0x00, 0xFF, false);
    draw_string(40, 188, "[GRAPH] Back           [Y=] Quit", 0x00, 0xFF, false);

    save_and_draw_cursor(cursor_x, cursor_y);
    gfx_BlitBuffer();

    /* Initialize USB in device mode */
    err = usb_Init(usb_event, NULL, &descriptors, USB_DEFAULT_INIT_FLAGS);
    if (err != USB_SUCCESS) {
        gfx_FillScreen(0);
        gfx_SetTextFGColor(0xE0);
        gfx_PrintStringXY("USB Init Failed!", 12, 12);
        gfx_BlitBuffer();
        while (!os_GetCSC());
        gfx_End();
        return 1;
    }

    while (1) {
        kb_key_t g1, g6, g7;
        uint8_t csc;
        bool cursor_moved = false;

        usb_HandleEvents();
        kb_Scan();

        g1 = kb_Data[1];
        g6 = kb_Data[6];
        g7 = kb_Data[7];
        csc = os_GetCSC();

        /* Exit program */
        if (g1 & kb_Yequ || csc == sk_Yequ) {
            break;
        }

        /* URL Bar Toggle: [WINDOW] */
        if (csc == sk_Window) {
            url_bar_active = !url_bar_active;
            if (url_bar_active) {
                strncpy(url_input, current_url, sizeof(url_input) - 1);
                url_input_len = strlen(url_input);
            }
            needs_blit = true;
        }

        if (url_bar_active) {
            if (csc == sk_Enter || (g6 & kb_Enter)) {
                if (url_input_len > 0) {
                    strncpy(current_url, url_input, sizeof(current_url) - 1);
                    send_cmd(PKT_NAV_URL, url_input, url_input_len);
                    status_msg = "Navigating…";
                }
                url_bar_active = false;
                needs_blit = true;
            } else if (csc == sk_Clear) {
                url_input_len = 0;
                url_input[0] = '\0';
                needs_blit = true;
            } else if (csc == sk_Del || csc == sk_Sub || csc == sk_Zoom) {
                if (url_input_len > 0) {
                    url_input[--url_input_len] = '\0';
                    needs_blit = true;
                }
            }
        } else {
            /* Mouse Movement with Acceleration */
            int speed = 2;
            if (hold_duration > 10) speed = 5;
            if (hold_duration > 25) speed = 9;

            int prev_x = cursor_x;
            int prev_y = cursor_y;

            if (g7 & kb_Up) {
                cursor_y -= speed;
                if (cursor_y < 16) cursor_y = 16;
            }
            if (g7 & kb_Down) {
                cursor_y += speed;
                if (cursor_y >= SCREEN_H - 1) cursor_y = SCREEN_H - 1;
            }
            if (g7 & kb_Left) {
                cursor_x -= speed;
                if (cursor_x < 0) cursor_x = 0;
            }
            if (g7 & kb_Right) {
                cursor_x += speed;
                if (cursor_x >= SCREEN_W - 1) cursor_x = SCREEN_W - 1;
            }

            if (cursor_x != prev_x || cursor_y != prev_y) {
                cursor_moved = true;
                hold_duration++;
            } else {
                hold_duration = 0;
            }

            /* Left Click: [ENTER] or [2nd] */
            if (csc == sk_Enter || csc == sk_2nd) {
                struct {
                    uint16_t x;
                    uint16_t y;
                    uint8_t button;
                } __attribute__((packed)) click_data;

                click_data.x = (uint16_t)cursor_x;
                click_data.y = (uint16_t)cursor_y;
                click_data.button = 1;

                send_cmd(PKT_CLICK, &click_data, sizeof(click_data));
                click_anim = 4;
                status_msg = "Clicked";
                needs_blit = true;
            }

            /* Scroll: [+] down, [-] up */
            if (csc == sk_Add) {
                int16_t delta = 150;
                send_cmd(PKT_SCROLL, &delta, sizeof(delta));
                status_msg = "Scrolling…";
                needs_blit = true;
            } else if (csc == sk_Sub) {
                int16_t delta = -150;
                send_cmd(PKT_SCROLL, &delta, sizeof(delta));
                status_msg = "Scrolling…";
                needs_blit = true;
            }

            /* Navigation: [GRAPH] = Back, [TRACE] = Forward, [ZOOM] = Reload */
            if (csc == sk_Graph) {
                send_cmd(PKT_NAV_BACK, NULL, 0);
                status_msg = "Going Back…";
                needs_blit = true;
            } else if (csc == sk_Trace) {
                send_cmd(PKT_NAV_FORWARD, NULL, 0);
                status_msg = "Going Forward…";
                needs_blit = true;
            } else if (csc == sk_Zoom) {
                send_cmd(PKT_NAV_RELOAD, NULL, 0);
                status_msg = "Reloading…";
                needs_blit = true;
            }
        }

        /* Render Cursor and Update Display */
        if (cursor_moved || needs_blit || click_anim > 0 || url_bar_active) {
            restore_cursor_bg();
            draw_chrome_bar();
            if (click_anim > 0) {
                gfx_SetColor(0xE0);
                gfx_Circle(cursor_x, cursor_y, (5 - click_anim) * 2);
                click_anim--;
            }
            save_and_draw_cursor(cursor_x, cursor_y);
            gfx_BlitBuffer();
            needs_blit = false;
        }
    }

    usb_Cleanup();
    gfx_End();
    return 0;
}
