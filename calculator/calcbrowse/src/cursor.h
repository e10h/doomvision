#ifndef CALCBROWSE_CURSOR_H
#define CALCBROWSE_CURSOR_H

#include <stdint.h>
#include <graphx.h>

#define CURSOR_W 9
#define CURSOR_H 12

/* 0 = Transparent, 1 = Black outline, 2 = White interior */
static const uint8_t cursor_sprite[CURSOR_H][CURSOR_W] = {
    { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 1, 0, 0, 0, 0, 0, 0, 0 },
    { 1, 2, 1, 0, 0, 0, 0, 0, 0 },
    { 1, 2, 2, 1, 0, 0, 0, 0, 0 },
    { 1, 2, 2, 2, 1, 0, 0, 0, 0 },
    { 1, 2, 2, 2, 2, 1, 0, 0, 0 },
    { 1, 2, 2, 2, 2, 2, 1, 0, 0 },
    { 1, 2, 2, 2, 1, 1, 1, 1, 0 },
    { 1, 2, 1, 2, 1, 0, 0, 0, 0 },
    { 1, 1, 0, 1, 2, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 2, 1, 0, 0 },
    { 0, 0, 0, 0, 0, 1, 1, 0, 0 },
};

static inline void draw_cursor(int x, int y, uint8_t black_color, uint8_t white_color) {
    int r, c;
    for (r = 0; r < CURSOR_H; r++) {
        int py = y + r;
        if (py < 0 || py >= 240) continue;
        for (c = 0; c < CURSOR_W; c++) {
            int px = x + c;
            if (px < 0 || px >= 320) continue;
            uint8_t pixel = cursor_sprite[r][c];
            if (pixel == 1) {
                gfx_vbuffer[py][px] = black_color;
            } else if (pixel == 2) {
                gfx_vbuffer[py][px] = white_color;
            }
        }
    }
}

#endif
