//
//  ANBeaconPart.h
//  GroupDeauth
//
//  Created by Alex Nichol on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANBeaconPart : NSObject {
    NSData * data;
    UInt8 typeID;
}

@property (readonly) NSData * data;
@property (readonly) UInt8 typeID;

- (id)initWithType:(UInt8)aTypeID data:(NSData *)theData;

@end
