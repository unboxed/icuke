    //
//  AppDelegate_Shared.m
//  Universal
//
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "AppDelegate_Shared.h"

@implementation AppDelegate_Shared

@synthesize window;

#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[window release];
	[navigationController release];
	[super dealloc];
}

@end
