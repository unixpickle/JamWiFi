//
//  ANBeaconFrame.m
//  GroupDeauth
//
//  Created by Alex Nichol on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANBeaconFrame.h"

@implementation ANBeaconFrame

@synthesize packet;

- (id)initWithPacket:(AN80211Packet *)beacon {
    if ((self = [super init])) {
        packet = beacon;
        int bodyOffset = 0x0c;
        if (bodyOffset >= packet.bodyLength - 4) return nil;
        NSMutableArray * mParts = [NSMutableArray array];
        for (int i = bodyOffset; i < packet.bodyLength - 4; i += 2) {
            UInt8 typeID = packet.bodyData[i];
            UInt8 length = packet.bodyData[i + 1];
            // NSLog(@"Type: %d len: %d", typeID, length);
            if (length + i + 2 > packet.bodyLength) return nil;
            NSData * data = [NSData dataWithBytes:&packet.bodyData[i + 2] length:length];
            ANBeaconPart * part = [[ANBeaconPart alloc] initWithType:typeID data:data];
            [mParts addObject:part];
            i += length;
        }
        beaconParts = mParts;
    }
    return self;
}

- (ANBeaconPart *)beaconPartWithID:(UInt8)anID {
    for (ANBeaconPart * part in beaconParts) {
        if ([part typeID] == anID) return part;
    }
    return nil;
}

- (NSString *)essid {
    ANBeaconPart * part = [self beaconPartWithID:0];
    if (!part) return nil;
    return [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
}

- (NSUInteger)channel {
    ANBeaconPart * part = [self beaconPartWithID:3];
    if (!part) return 0;
    NSData * data = [part data];
    if ([data length] != 1) return 0;
    return *((const UInt8 *)[data bytes]);
}

@end
