#ifndef CALCGPT_WIRE_H
#define CALCGPT_WIRE_H

#include <stdint.h>
#include <string.h>

#define CGPT_MAGIC_0 'C'
#define CGPT_MAGIC_1 'G'
#define CGPT_MAGIC_2 'P'
#define CGPT_MAGIC_3 'T'

#define PKT_PROMPT_START 0x01
#define PKT_PROMPT_DATA  0x02
#define PKT_CANCEL       0x03
#define PKT_PING         0x04

#define PKT_REPLY_START  0x10
#define PKT_REPLY_CHUNK  0x11
#define PKT_REPLY_END    0x12
#define PKT_ERROR        0x13
#define PKT_PONG         0x14

#define USB_PACKET_SIZE 64
#define USB_PAYLOAD_MAX 56

typedef struct {
    uint8_t magic[4];
    uint8_t type;
    uint8_t seq;
    uint16_t length;
    uint8_t payload[USB_PAYLOAD_MAX];
} __attribute__((packed)) cgpt_packet_t;

_Static_assert(sizeof(cgpt_packet_t) == USB_PACKET_SIZE, "CalcGPT packet size must be 64 bytes");

static inline void cgpt_init_packet(cgpt_packet_t *pkt, uint8_t type, uint8_t seq, const void *data, uint16_t len) {
    pkt->magic[0] = CGPT_MAGIC_0;
    pkt->magic[1] = CGPT_MAGIC_1;
    pkt->magic[2] = CGPT_MAGIC_2;
    pkt->magic[3] = CGPT_MAGIC_3;
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

