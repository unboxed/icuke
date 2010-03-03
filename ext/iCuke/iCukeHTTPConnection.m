//
//  iCukeHTTPConnection.m
//  iCuke
//
//  Created by Rob Holland on 01/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTTPResponse.h"
#import "ScriptRunner.h"
#import "iCukeHTTPConnection.h"

@implementation iCukeHTTPConnection

- (UIView *)findView:(NSString *)address
{
  UIView *view = (UIView *)[address integerValue];

  if ([view isKindOfClass:[UIView class]]) {
    return view;
  } else {
    return nil;
  }
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
  ScriptRunner *runner = [[ScriptRunner alloc] init];

  NSLog(@"Request: %@", path);

  if ([path isEqualToString:@"/view"])
  {
    NSString *result = [runner outputView];
    [runner release];

    NSData *browseData = [result dataUsingEncoding:NSUTF8StringEncoding];
    return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
  }
  else if ([path hasPrefix:@"/touch/"]) {
    NSString *address = [path lastPathComponent];
    if ([address length] > 0) {
      UIView *view = [self findView:address];
      if (!view) {
        NSLog(@"Unknown address requested: %d", address);
        return nil;
      }

      [runner simulateTouch:view hitTest: YES];

      NSString *result = [runner outputView];
      [runner release];

      NSData *response = [result dataUsingEncoding:NSUTF8StringEncoding];
      return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
    }
  }

  return nil;
}

- (NSData *)preprocessResponse:(CFHTTPMessageRef)response
{
  CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Type"), CFSTR("text/xml"));

  return [super preprocessResponse:response];
}

@end
