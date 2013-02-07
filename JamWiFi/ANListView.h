//
//  ANListView.h
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreWLAN/CoreWLAN.h>
#import "ANTrafficGatherer.h"

@interface ANListView : NSView <NSTableViewDelegate, NSTableViewDataSource> {
    NSString * interfaceName;
    NSArray * networks;
    
    NSButton * scanButton;
    NSButton * disassociateButton;
    NSButton * jamButton;
    NSProgressIndicator * progressIndicator;
    NSScrollView * networksScrollView;
    NSTableView * networksTable;
}

- (void)scanInBackground;
- (void)scanButton:(id)sender;
- (void)disassociateButton:(id)sender;
- (void)jamButton:(id)sender;

- (NSString *)securityTypeString:(CWNetwork *)network;

@end
