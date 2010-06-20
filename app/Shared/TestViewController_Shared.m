//
//  TestViewController_Shared.m
//  Universal
//
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "TestViewController_Shared.h"

@implementation TestViewController_Shared

#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(20.0, 20.0, 280.0, 44.0);
	[button setTitle:@"Show Test Modal" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)test:(id)sender {
	// Must be overridden by subclass
}

@end
