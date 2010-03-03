//
//  iCukeServer.m
//  iCuke
//
//  Created by Rob Holland on 01/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import "iCukeServer.h"
#import "iCukeHTTPConnection.h"

@implementation iCukeServer

+ (void)start {
	HTTPServer *server = [HTTPServer new];
	[server setConnectionClass: [iCukeHTTPConnection class]];
	[server setPort:50000];

	NSError *error;
	if(![server start:&error]) {
		NSLog(@"Error starting HTTP Server: %@", error);
	}
}

@end

void start_server(void) __attribute__((constructor));
void start_server(void)
{
  [iCukeServer start];
}
