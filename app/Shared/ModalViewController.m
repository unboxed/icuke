//
//  ModalViewController.m
//  Universal
//
//  Created by Sam Soffes on 4/12/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "ModalViewController.h"

@implementation ModalViewController

NSString *lorem[] = {
	@"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
	@"Donec dictum vehicula suscipit.",
	@"Morbi eget mauris vel mauris pellentesque luctus ut sed nulla.",
	@"Aliquam blandit risus ut magna egestas ac commodo lacus sagittis.",
	@"Duis dui nunc, rutrum a tincidunt nec, commodo vitae ante.",
	@"Mauris fringilla est at nibh porta pulvinar.",
	@"Quisque mattis, odio sit amet ultrices elementum, dui libero scelerisque nisl, a bibendum ante orci ut metus.",
	@"Aliquam id lorem arcu.",
	@"Fusce luctus, nibh facilisis sagittis ornare, neque ligula accumsan ipsum, non dignissim sapien nulla et turpis.",
	@"Proin pretium erat nec ipsum fringilla pellentesque.",
	@"Fusce sem nisi, tincidunt in sodales ac, tincidunt non lorem."
};


#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Shared Modal";
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 300.0);
	} else {
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
		self.navigationItem.rightBarButtonItem = closeButton;
		[closeButton release];
	}
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

- (void)close:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sizeof(lorem) / sizeof(NSString *);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	cell.textLabel.text = lorem[indexPath.row];
	
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
