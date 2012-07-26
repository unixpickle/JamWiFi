//
//  MACParser.m
//  JamWiFi
//
//  Created by Alex Nichol on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MACParser.h"

NSString * MACToString(const unsigned char * mac) {
    return [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
            (unsigned char)mac[0], (unsigned char)mac[1], (unsigned char)mac[2],
            (unsigned char)mac[3], (unsigned char)mac[4], (unsigned char)mac[5]];
}

BOOL copyMAC(const char * macString, unsigned char * mac) {
    NSString * macStr = [NSString stringWithUTF8String:macString];
    NSArray * components = [macStr componentsSeparatedByString:@":"];
    for (int i = 0; i < [components count]; i++) {
        if (i >= 6) break;
        unsigned result = 0;
        NSScanner * scanner = [NSScanner scannerWithString:[components objectAtIndex:i]];
        [scanner scanHexInt:&result];
        mac[i] = result;
    }
    return YES;
}
