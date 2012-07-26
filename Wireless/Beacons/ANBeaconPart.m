//
//  ANBeaconPart.m
//  GroupDeauth
//
//  Created by Alex Nichol on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANBeaconPart.h"

@implementation ANBeaconPart

@synthesize data;
@synthesize typeID;

- (id)initWithType:(UInt8)aTypeID data:(NSData *)theData {
    if ((self = [super init])) {
        data = theData;
        typeID = aTypeID;
    }
    return self;
}

@end
