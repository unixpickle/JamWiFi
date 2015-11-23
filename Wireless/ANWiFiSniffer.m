//
//  ANWiFiSniffer.m
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANWiFiSniffer.h"

@interface ANWiFiSniffer (Private)

- (void)backgroundThread;
- (void)informDelegateOpenFailed;
- (void)informDelegateError:(NSError *)error;
- (void)informDelegatePacket:(AN80211Packet *)packet;
- (void)finishBackgroundThread;

@end

@implementation ANWiFiSniffer

@synthesize delegate;

- (id)initWithInterfaceName:(NSString *)name {
    if ((self = [super init])) {
        interfaceName = name;
        writeBuffer = [[NSMutableArray alloc] init];
        channelLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)start {
    if (backgroundThread) return;
    @synchronized (writeBuffer) {
        [writeBuffer removeAllObjects];
    }
    backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundThread) object:nil];
    [backgroundThread start];
}

- (void)stop {
    if (!backgroundThread) return;
    [backgroundThread cancel];
    backgroundThread = nil;
}

- (BOOL)writePacket:(AN80211Packet *)packet {
    if (!backgroundThread) return NO;
    @synchronized (writeBuffer) {
        [writeBuffer addObject:packet];
    }
    return YES;
}

- (void)setChannel:(CWChannel *)channel {
    [channelLock lock];
    hopChannel = channel;
    [channelLock unlock];
}

#pragma mark - Background -

- (void)backgroundThread {
    @autoreleasepool {
        interface = [[ANInterface alloc] initWithInterface:interfaceName];
        if (!interface) {
            [self informDelegateOpenFailed];
            return;
        }
        AN80211Packet * packet = nil;
        while (true) {
            @autoreleasepool {
                if ([[NSThread currentThread] isCancelled]) {
                    [interface closeInterface];
                    interface = nil;
                    return;
                }
                [channelLock lock];
                if (hopChannel) {
                    [interface setChannel:hopChannel.channelNumber];
                    hopChannel = nil;
                }
                [channelLock unlock];
                @try {
                    packet = [interface nextPacket:NO];
                } @catch (NSException * exception) {
                    [self informDelegateError:[NSError errorWithDomain:@"pcap_next_ex" code:1 userInfo:nil]];
                    [interface closeInterface];
                    interface = nil;
                    return;
                }
                if ([[NSThread currentThread] isCancelled]) {
                    [interface closeInterface];
                    interface = nil;
                    return;
                }
                if (packet) [self informDelegatePacket:packet];
                AN80211Packet * wPacket = nil;
                @synchronized (writeBuffer) {
                    if ([writeBuffer count] > 0) {
                        wPacket = [writeBuffer objectAtIndex:0];
                        [writeBuffer removeObjectAtIndex:0];
                    }
                }
                if (wPacket) {
                    if (![interface writePacket:wPacket]) {
                        [self informDelegateError:[NSError errorWithDomain:@"pcap_inject" code:1 userInfo:nil]];
                        interface = nil;
                        return;
                    }
                }
                if (!packet && !wPacket) {
                    usleep(5000); // sleep for 5 milliseconds
                }
            }
        }
    }
}

- (void)informDelegateOpenFailed {
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(informDelegateOpenFailed) withObject:nil waitUntilDone:NO];
        return;
    }
    backgroundThread = nil;
    if ([delegate respondsToSelector:@selector(wifiSnifferFailedToOpenInterface:)]) {
        [delegate wifiSnifferFailedToOpenInterface:self];
    }
}

- (void)informDelegateError:(NSError *)error {
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(informDelegateError:) withObject:error waitUntilDone:NO];
        return;
    }
    backgroundThread = nil;
    if ([delegate respondsToSelector:@selector(wifiSniffer:failedWithError:)]) {
        [delegate wifiSniffer:self failedWithError:error];
    }
}

- (void)informDelegatePacket:(AN80211Packet *)packet {
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(informDelegatePacket:) withObject:packet waitUntilDone:NO];
        return;
    }
    if ([delegate respondsToSelector:@selector(wifiSniffer:gotPacket:)]) {
        [delegate wifiSniffer:self gotPacket:packet];
    }
}

@end
