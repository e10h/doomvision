#ifndef PIANO_KEYMAP_H
#define PIANO_KEYMAP_H
/* Keypad matrix rows 1..7, bits 0..7. Values index C3-based samples;
 * 255 means silent. Y= switches modes and is never a note. */
static const uint8_t key_masks[7]={0xcc,0,0xff,0x76,0,0,0};
static const uint8_t key_notes[7][8]={
 {255,255,13,12,255,255,14,15},
 {255,255,255,255,255,255,255,255},
 {28,26,24,23,21,19,17,16},
 {255,27,25,255,22,20,18,255},
 {255,255,255,255,255,255,255,255},
 {255,255,255,255,255,255,255,255},
 {255,255,255,255,255,255,255,255}
};
#endif
