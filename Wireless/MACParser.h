//
//  MACParser.h
//  JamWiFi
//
//  Created by Alex Nichol on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * MACToString(const unsigned char * mac);
BOOL copyMAC(const char * macString, unsigned char * mac);
