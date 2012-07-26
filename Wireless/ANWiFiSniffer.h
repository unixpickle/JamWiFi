//
//  ANWiFiSniffer.h
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANInterface.h"

@class ANWiFiSniffer;

@protocol ANWiFiSnifferDelegate <NSObject>

- (void)wifiSnifferFailedToOpenInterface:(ANWiFiSniffer *)sniffer;
- (void)wifiSniffer:(ANWiFiSniffer *)sniffer failedWithError:(NSError *)error;
- (void)wifiSniffer:(ANWiFiSniffer *)sniffer gotPacket:(AN80211Packet *)packet;

@end

@interface ANWiFiSniffer : NSObject {
    ANInterface * interface;
    NSString * interfaceName;
    NSThread * backgroundThread;
    NSMutableArray * writeBuffer;
    __unsafe_unretained id<ANWiFiSnifferDelegate> delegate;
    NSLock * channelLock;
    CWChannel * hopChannel;
}

@property (nonatomic, assign) id<ANWiFiSnifferDelegate> delegate;

- (id)initWithInterfaceName:(NSString *)name;
- (void)start;
- (void)stop;
- (BOOL)writePacket:(AN80211Packet *)packet;
- (void)setChannel:(CWChannel *)channel;

@end
