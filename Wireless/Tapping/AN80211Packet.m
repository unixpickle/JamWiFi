//
//  AN80211Packet.m
//  wifimsg
//
//  Created by Alex Nichol on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AN80211Packet.h"

@implementation AN80211Packet

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        if ([data length] < 24) return nil;
        packetData = (unsigned char *)malloc([data length]);
        memcpy(packetData, [data bytes], [data length]);
        macHeader = (MACHeader *)packetData;
        bodyData = packetData + sizeof(MACHeader);
        packetLength = (int)[data length];
        bodyLength = packetLength - sizeof(MACHeader);
    }
    return self;
}

- (const MACHeader *)macHeader {
    return macHeader;
}

- (const unsigned char *)packetData {
    return packetData;
}

- (const unsigned char *)bodyData {
    return bodyData;
}

- (int)packetLength {
    return packetLength;
}

- (int)bodyLength {
    return bodyLength;
}

- (void)dealloc {
    free(packetData);
}

- (uint32_t)dataFCS {
    if (bodyLength < 4) return 0;
    return *(uint32_t *)(&bodyData[bodyLength - 4]);
}

- (uint32_t)calculateFCS {
    return ~crc32((const char *)packetData, packetLength - 4);
}

@end
