//
//  CarbonAppProcess.h
//  AutoConvert
//
//  Created by Alex Nichol on 7/3/11.
//  Copyright 2011 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface CarbonAppProcess : NSObject {
    ProcessSerialNumber processSerial;
}

- (id)initWithProcessSerial:(ProcessSerialNumber)num;
+ (CarbonAppProcess *)currentProcess;
+ (CarbonAppProcess *)frontmostProcess;
+ (CarbonAppProcess *)nextProcess;
- (void)makeFrontmost;
- (void)setHidden:(BOOL)hide;
- (BOOL)isFrontmost;
- (ProcessSerialNumber)serial;

@end
