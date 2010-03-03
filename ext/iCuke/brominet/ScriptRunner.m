//
//  ScriptRunner.m
//  SelfTesting
//
//  Created by Matt Gallagher on 9/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//

#import "ScriptRunner.h"
#import "XMLDescription.h"
#import "TouchSynthesis.h"
#import "NSObject+ClassName.h"

@implementation ScriptRunner

//
// outputView
//
// The current view hierarchy as XML, starting with the keyWindow.
//
- (NSString*) outputView  {
  return [[UIApplication sharedApplication] xmlDescription];
}

//
// simulateTouch:
//
// Synthesize a touch begin/end in the center of the specified view. Since there
// is no API to do this, it's a dirty hack of a job.
//
- (void)simulateTouch:(UIView *)view hitTest:(BOOL)hitTest
{
  UITouch *touch = [[UITouch alloc] initInView:view hitTest:hitTest];
  UIEvent *event = [[UIEvent alloc] initWithTouch:touch];
  NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
  BOOL animations_enabled = [UIView areAnimationsEnabled];

  NSLog(@"Touch: %@", view);

  [touch.view touchesBegan:touches withEvent:event];

  [touch setPhase:UITouchPhaseEnded];

  [touch.view touchesEnded:touches withEvent:event];

  [event release];
  [touches release];
  [touch release];
}

//
// simulateSwipe:
//
// Synthesize a short rightward drag in the center of the specified view. Since there
// is no API to do this, it's a dirty hack of a job.
//
- (void)simulateSwipe:(UIView *)view
{
  UITouch *touch = [[UITouch alloc] initInView:view];
  UIEvent *event = [[UIEvent alloc] initWithTouch:touch];
  NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
  BOOL animations_enabled = [UIView areAnimationsEnabled];

  [touch.view touchesBegan:touches withEvent:event];

  [touch setPhase:UITouchPhaseMoved];
  [touch moveLocationInWindow];
  [event moveLocation];
  [touch.view touchesMoved:touches withEvent:event];

  [touch setPhase:UITouchPhaseEnded];
  [touch.view touchesEnded:touches withEvent:event];

  [event release];
  [touches release];
  [touch release];
}

@end
