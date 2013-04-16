//
//  AppDelegate.h
//  MacBitCoin
//
//  Created by Myles Grant on 4/7/13.
//  Copyright (c) 2013 Myles Grant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCDAsyncSocket;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
	// Outgoing
	GCDAsyncSocket *asyncSocket;
	dispatch_queue_t socketQueueOut;
	
	// Incoming
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
	dispatch_queue_t socketQueueIn;
}

@property (assign) IBOutlet NSWindow *window;

@end