//
//  iCukeAppDelegate.h
//  iCuke
//
//  Created by Rob Holland on 02/03/2010.
//  Copyright The IT Refinery 2010. All rights reserved.
//

@class MainViewController;

@interface iCukeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end

