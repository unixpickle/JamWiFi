//
//  CarbonAppProcess.m
//  AutoConvert
//
//  Created by Alex Nichol on 7/3/11.
//  Copyright 2011 Alex Nichol. All rights reserved.
//

#import "CarbonAppProcess.h"


@implementation CarbonAppProcess

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
	}
    return self;
}

- (id)initWithProcessSerial:(ProcessSerialNumber)num {
	if ((self = [super init])) {
		processSerial = num;
	}
	return self;
}

+ (CarbonAppProcess *)currentProcess {
	ProcessSerialNumber frontmost;
	GetCurrentProcess(&frontmost);
	return [[CarbonAppProcess alloc] initWithProcessSerial:frontmost];
}

+ (CarbonAppProcess *)frontmostProcess {
	ProcessSerialNumber frontmost;
	GetFrontProcess(&frontmost);
	return [[CarbonAppProcess alloc] initWithProcessSerial:frontmost];
}

+ (CarbonAppProcess *)nextProcess {
	ProcessSerialNumber next;
	if (GetNextProcess(&next) != noErr) {
		NSLog(@"No next process");
		return nil;
	}
	return [[CarbonAppProcess alloc] initWithProcessSerial:next];
}

- (void)makeFrontmost {
    SetFrontProcessWithOptions(&processSerial, kSetFrontProcessFrontWindowOnly);
}

- (void)setHidden:(BOOL)hide {
	ShowHideProcess(&processSerial, hide^1);
}

- (BOOL)isFrontmost {
    ProcessSerialNumber psn;
    GetFrontProcess(&psn);
    
    Boolean result = FALSE;
    SameProcess(&psn, &processSerial, &result);
    return (BOOL)result;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[CarbonAppProcess class]]) {
		ProcessSerialNumber mySerial = processSerial;
		ProcessSerialNumber theirSerial = (ProcessSerialNumber)([(CarbonAppProcess *)object serial]);
		if (mySerial.lowLongOfPSN == theirSerial.lowLongOfPSN) {
			if (mySerial.highLongOfPSN == theirSerial.highLongOfPSN) {
				return YES;
			}
		}
	}
	return NO;
}

- (ProcessSerialNumber)serial {
	return processSerial;
}

@end
