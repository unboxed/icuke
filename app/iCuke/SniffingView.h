//
//  SniffingView.h
//  iCuke
//
//  Created by Rob Holland on 08/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SniffingView : UIView {

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
