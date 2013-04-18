//
//  AppDelegate.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ConnectionManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private	
	ConnectionManager *connectionManager;
}

@property (assign) IBOutlet NSWindow *window;

@end