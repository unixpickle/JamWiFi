//
//  ANBeaconFrame.h
//  GroupDeauth
//
//  Created by Alex Nichol on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AN80211Packet.h"
#import "ANBeaconPart.h"

@interface ANBeaconFrame : NSObject {
    AN80211Packet * packet;
    NSArray * beaconParts;
}

@property (readonly) AN80211Packet * packet;

- (id)initWithPacket:(AN80211Packet *)beacon;
- (ANBeaconPart *)beaconPartWithID:(UInt8)anID;

- (NSString *)essid;
- (NSUInteger)channel;

@end
