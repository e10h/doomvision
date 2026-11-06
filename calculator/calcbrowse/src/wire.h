#ifndef CALCBROWSE_WIRE_H
#define CALCBROWSE_WIRE_H

#include <stdint.h>
#include <string.h>

#define BROW_MAGIC_0 'B'
#define BROW_MAGIC_1 'R'
#define BROW_MAGIC_2 'O'
#define BROW_MAGIC_3 'W'

/* Calculator -> Host */
#define PKT_CLICK        0x01
#define PKT_SCROLL       0x02
#define PKT_NAV_URL      0x03
#define PKT_NAV_BACK     0x04
#define PKT_NAV_FORWARD  0x05
#define PKT_NAV_RELOAD   0x06
#define PKT_PING         0x07

/* Host -> Calculator */
#define PKT_FRAME_START  0x10
#define PKT_FRAME_DATA   0x11
#define PKT_FRAME_END    0x12
#define PKT_URL_UPDATE   0x13
#define PKT_STATUS       0x14
#define PKT_PONG         0x15

#define USB_PACKET_SIZE  64
#define USB_PAYLOAD_MAX  56

typedef struct {
    uint8_t magic[4];
    uint8_t type;
    uint8_t seq;
    uint16_t length;
    uint8_t payload[USB_PAYLOAD_MAX];
} __attribute__((packed)) brow_packet_t;

_Static_assert(sizeof(brow_packet_t) == USB_PACKET_SIZE, "Browser packet size must be 64 bytes");

static inline void brow_init_packet(brow_packet_t *pkt, uint8_t type, uint8_t seq, const void *data, uint16_t len) {
    pkt->magic[0] = BROW_MAGIC_0;
    pkt->magic[1] = BROW_MAGIC_1;
    pkt->magic[2] = BROW_MAGIC_2;
    pkt->magic[3] = BROW_MAGIC_3;
    pkt->type = type;
    pkt->seq = seq;
    if (len > USB_PAYLOAD_MAX) len = USB_PAYLOAD_MAX;
    pkt->length = len;
    if (data && len > 0) {
        memcpy(pkt->payload, data, len);
    }
    if (len < USB_PAYLOAD_MAX) {
        memset(pkt->payload + len, 0, USB_PAYLOAD_MAX - len);
    }
}

#endif

