//
//  TestViewController_Phone.m
//  Universal
//
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "TestViewController_Phone.h"
#import "ModalViewController.h"

@implementation TestViewController_Phone

#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"iPhone";
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)test:(id)sender {
	ModalViewController *viewController = [[ModalViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	[self.navigationController presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

@end
