//
//  AN80211Packet.h
//  wifimsg
//
//  Created by Alex Nichol on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "packets.h"
#include "crc.h"

@interface AN80211Packet : NSObject {
    MACHeader * macHeader;
    unsigned char * packetData;
    unsigned char * bodyData;
    int packetLength;
    int bodyLength;
}

@property (readwrite) int rssi;

- (id)initWithData:(NSData *)data;
- (const MACHeader *)macHeader;
- (const unsigned char *)packetData;
- (const unsigned char *)bodyData;
- (int)packetLength;
- (int)bodyLength;

- (uint32_t)dataFCS;
- (uint32_t)calculateFCS;

@end
