//
//  iCukeAppDelegate.m
//  iCuke
//
//  Created by Rob Holland on 02/03/2010.
//  Copyright The IT Refinery 2010. All rights reserved.
//

#import "iCukeAppDelegate.h"
#import "MainViewController.h"

@implementation iCukeAppDelegate


@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
