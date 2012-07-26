//
//  ANInterface.m
//  wifimsg
//
//  Created by Alex Nichol on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANInterface.h"

@implementation ANInterface

@synthesize interface;

- (id)initWithInterface:(NSString *)name {
    if ((self = [super init])) {
        interface = [[CWInterface alloc] initWithInterfaceName:name];
        if (!interface) return nil;
        pcapHandle = pcap_open_live([name UTF8String], 65536, 1, 1, pcapError);
        if (!pcapHandle) return nil;
        pcap_set_datalink(pcapHandle, DLT_IEEE802_11_RADIO);
    }
    return self;
}

- (AN80211Packet *)nextPacket:(BOOL)blocking {
    do {
        struct pcap_pkthdr * header;
        const u_char * buffer;
        int ret = pcap_next_ex(pcapHandle, &header, &buffer);
        if (ret < 0) {
            const char * error = pcap_geterr(pcapHandle);
            @throw [NSException exceptionWithName:@"libpcap"
                                           reason:[NSString stringWithUTF8String:error]
                                         userInfo:nil];
        }
        if (ret == 1) {
            uint16_t * words = (uint16_t *)buffer;
            if (words[1] >= header->caplen) continue;
            
            const u_char * dataBuffer = buffer + words[1];
            uint32_t len = header->caplen - words[1];
            NSData * data = [NSData dataWithBytes:dataBuffer length:len];
            return [[AN80211Packet alloc] initWithData:data];
        }
        usleep(10000);
    } while (blocking);
    return nil;
}

- (BOOL)writePacket:(AN80211Packet *)packet {
    uint16_t radioLen = 8;
    unsigned char * radioData = (unsigned char *)malloc([packet packetLength] + radioLen);
    memcpy(&radioData[2], &radioLen, 2);
    memcpy(&radioData[radioLen], [packet packetData], [packet packetLength]);
    int len = pcap_inject(pcapHandle, radioData, radioLen + [packet packetLength]);
    free(radioData);
    return (len == [packet packetLength] + radioLen);
}

- (BOOL)setChannel:(NSInteger)channel {
    [interface disassociate];
    NSSet * channels = [interface supportedWLANChannels];
    for (CWChannel * channelObj in channels) {
        if ([channelObj channelNumber] == channel) {
            return [interface setWLANChannel:channelObj error:nil];
        }
    }
    return NO;
}

- (void)closeInterface {
    if (pcapHandle) {
        pcap_close(pcapHandle);
        pcapHandle = NULL;
    }
    interface = nil;
}

- (void)dealloc {
    [self closeInterface];
}

@end
