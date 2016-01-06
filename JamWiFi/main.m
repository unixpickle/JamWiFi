//
//  main.m
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>
#import <CoreWLAN/CoreWLAN.h>

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        if (geteuid()) {
            OSStatus myStatus;
            AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
            AuthorizationRef myAuthorizationRef;
            
            myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);
            if (myStatus != errAuthorizationSuccess) return myStatus;
            
            AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
            AuthorizationRights myRights = {1, &myItems};
            myFlags = kAuthorizationFlagDefaults |
            kAuthorizationFlagInteractionAllowed |
            kAuthorizationFlagPreAuthorize |
            kAuthorizationFlagExtendRights;
            myStatus = AuthorizationCopyRights(myAuthorizationRef, &myRights, NULL, myFlags, NULL );
            
            
            if (myStatus != errAuthorizationSuccess) {
                NSRunAlertPanel(@"Cannot run without admin privileges", @"This program cannot tap into the wireless network stack without administrator access.", @"OK", nil, nil);
                return 1;
            }
            
            
            const char * myToolPath = [[[NSBundle mainBundle] executablePath] UTF8String];
            char * myArguments[] = {NULL};
            
            myFlags = kAuthorizationFlagDefaults;
            myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, myToolPath, myFlags, myArguments,
                                                          NULL);
            AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
            exit(0);
        }
        return NSApplicationMain(argc, (const char **)argv);
    }
}
