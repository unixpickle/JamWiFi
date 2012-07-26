//
//  ANClientKiller.h
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANWiFiSniffer.h"
#import "ANClient.h"
#import "MACParser.h"

@interface ANClientKiller : NSView <ANWiFiSnifferDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    NSMutableArray * clients;
    NSArray * channels;
    NSDictionary * networksForChannel;
    int channelIndex;
    ANWiFiSniffer * sniffer;
    NSTimer * jamTimer;
    
    NSTableView * infoTable;
    NSScrollView * infoScrollView;
    NSButton * backButton;
    NSButton * doneButton;
    
    NSButton * newClientsCheck;
}

- (id)initWithFrame:(NSRect)frame sniffer:(ANWiFiSniffer *)theSniffer networks:(NSArray *)networks clients:(NSArray *)theClients;
- (void)configureUI;

- (void)backButton:(id)sender;
- (void)doneButton:(id)sender;

- (void)performNextRound;
- (AN80211Packet *)deauthPacketForBSSID:(const unsigned char *)bssid client:(const unsigned char *)client;
- (BOOL)includesBSSID:(const unsigned char *)bssid;

@end
