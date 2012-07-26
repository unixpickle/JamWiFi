//
//  packets.h
//  pcapTest
//
//  Created by Alex Nichol on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef pcapTest_packets_h
#define pcapTest_packets_h

#include <sys/types.h>

typedef struct {
    struct {
        unsigned int vers:2;
        unsigned int type:2;
        unsigned int subtype:4;
        unsigned int to_ds:1;
        unsigned int from_ds:1;
        unsigned int more_frag:1;
        unsigned int retry:1;
        unsigned int pw_mg:1;
        unsigned int more_data:1;
        unsigned int encrypted:1;
        unsigned int order:1;
    } __attribute__((__packed__)) frame_control;
    uint16_t durationID;
    unsigned char mac1[6];
    unsigned char mac2[6];
    unsigned char mac3[6];
    uint16_t seqControl;
    // unsigned char mac4[6];
} __attribute__((__packed__)) MACHeader;

#endif
