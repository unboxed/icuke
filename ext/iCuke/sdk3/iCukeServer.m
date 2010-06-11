//
//  iCukeServer.m
//  iCuke
//
//  Created by Rob Holland on 01/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import "iCukeServer.h"
#include <unistd.h>
#include <stdlib.h>

@implementation iCukeServer

+ (void)load
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[[iCukeHTTPServer sharediCukeHTTPServer] start];

	NSFileManager *fileManager= [[NSFileManager alloc] init];
	NSArray *paths;

	if (!getenv("ICUKE_KEEP_PREFERENCES")) {
		NSString *preferences = [NSHomeDirectory() stringByAppendingPathComponent: @"Library/Preferences"];

		paths = [fileManager contentsOfDirectoryAtPath: preferences error: NULL];
		for (NSString *path in paths) {
			NSLog(@"Found: %@", path);
			if (![path hasPrefix: @"."]) {
				NSLog(@"Removing: %@", path);
				unlink([[preferences stringByAppendingPathComponent: path] cStringUsingEncoding: [NSString defaultCStringEncoding]]);
			}
		}
	}

	// This is a hack, I can't find a nicer way. The iPhone Simulator's
	// preferences are hidden away from applications. None of the preference APIs
	// allow access to them.
	NSString *path = [NSString stringWithFormat: @"/Users/%@/Library/Application Support/iPhone Simulator/%@/Library/Preferences", NSUserName(), [[UIDevice currentDevice] systemVersion]];
	path = [path stringByAppendingPathComponent: @"com.apple.Accessibility.plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: path];
	if (!dict) {
		dict = [NSMutableDictionary dictionaryWithCapacity: 2];
	}
	NSNumber *enabled = [NSNumber numberWithBool: YES];
	[dict setObject: enabled forKey: @"AccessibilityEnabled"];
	[dict setObject: enabled forKey: @"ApplicationAccessibilityEnabled"];
	if (![dict writeToFile: path atomically: YES]) {
		NSLog(@"Failed to write %@ out to %@", dict, path);
	}

	NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	paths = [fileManager contentsOfDirectoryAtPath: documents error: NULL];
	for (NSString *path in paths) {
		if (![path hasPrefix: @"."]) {
			NSLog(@"Removing: %@", path);
			unlink([[documents stringByAppendingPathComponent: path] cStringUsingEncoding: [NSString defaultCStringEncoding]]);
		}
	}
	
	[pool release];
}

@end
