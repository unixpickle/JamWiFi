//
//  ANClient.h
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANClient : NSObject {
    unsigned char * macAddress;
    unsigned char * bssid;
    int packetCount;
    int deauthsSent;
    BOOL enabled;
}

@property (readwrite) int packetCount;
@property (readwrite) int deauthsSent;
@property (readonly) unsigned char * macAddress;
@property (readonly) unsigned char * bssid;
@property (readwrite) float rssi;
@property (readwrite) BOOL enabled;

- (id)initWithMac:(const unsigned char *)mac bssid:(const unsigned char *)aBSSID;

@end
