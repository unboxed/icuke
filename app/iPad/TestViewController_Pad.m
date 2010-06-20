//
//  TestViewController_Pad.m
//  Universal
//
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "TestViewController_Pad.h"
#import "ModalViewController.h"

@implementation TestViewController_Pad

#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"iPad";
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)test:(id)sender {
	ModalViewController *viewController = [[ModalViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	
	Class popoverClass = NSClassFromString(@"UIPopoverController");
	if (popoverClass) {
		UIPopoverController *popover = [[popoverClass alloc] initWithContentViewController:navigationController];
		popover.delegate = self;
		[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	
	[navigationController release];
}


#pragma mark -
#pragma mark UIPopoverControllerDelegate
#pragma mark -

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[popoverController release];
}

@end
