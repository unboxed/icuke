//
//  SniffingView.m
//  iCuke
//
//  Created by Rob Holland on 08/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import "SniffingView.h"

@interface UIEvent (Observing)
-(void *)_gsEvent;
@end

typedef void * GSEventRef;

typedef struct {
	unsigned char index;
	unsigned char index2;
	unsigned char type;
	unsigned char flags;
	float sizeX;
	float sizeY;
	float x;
	float y;
	int x24;
} gs_path_info_t;

typedef struct {
	int type;
	short deltaX;
	short deltaY;
	float x3;
	float x4;
	float pinch1;
	float pinch2;
	float averageX;
	float averageY;
	unsigned char x9_1;
	unsigned char pathCount;
} gs_hand_info_t;

id GSEventCreatePlistRepresentation(GSEventRef event);
extern CGFloat GSEventGetDeltaX(GSEventRef event);
extern CGFloat GSEventGetDeltaY(GSEventRef event);
extern int GSEventGetType(GSEventRef event);
extern int GSEventGetSubType(GSEventRef event);
extern int GSEventIsChordingHandEvent(GSEventRef event);
extern CGPoint GSEventGetInnerMostPathPosition(GSEventRef event);
extern CGPoint GSEventGetOuterMostPathPosition(GSEventRef event);
extern CGPoint GSEventGetLocationInWindow(GSEventRef event);
extern gs_hand_info_t GSEventGetHandInfo(GSEventRef event);
extern gs_path_info_t GSEventGetPathInfoAtIndex(GSEventRef event, CFIndex index);

@implementation SniffingView

-(void)eventStats:(UIEvent *)event {
	void *gs_event = [event _gsEvent];
	NSMutableDictionary *plist = GSEventCreatePlistRepresentation(gs_event);

	NSLog(@"Raw event: %@", event);

	NSLog(@"Plist data: %@", [plist objectForKey: @"Data"]);

	NSMutableData *data = [NSMutableData dataWithCapacity: 60];

	gs_hand_info_t gs_hand = GSEventGetHandInfo(gs_event);

	[data appendBytes: &gs_hand length: sizeof(gs_hand)];

	switch(gs_hand.type) {
		case 1:
		case 2:
		case 6:
		break;
		default:
		NSLog(@"Unexpected hand event type: %i", gs_hand.type);
	}

	if (gs_hand.deltaX != 1.0 && gs_hand.deltaX != 2.0) {
		NSLog(@"Unknown hand event deltaX: %f", gs_hand.deltaX);
	}

	if (gs_hand.deltaY != 1.0 && gs_hand.deltaY != 2.0) {
		NSLog(@"Unknown hand event deltaY: %f", gs_hand.deltaY);
	}

	if (gs_hand.x3 != 0.0) {
		NSLog(@"Non-zero hand event x3: %f", gs_hand.x3);
	}

	if (gs_hand.x4 != 0.0) {
		NSLog(@"Non-zero hand event x4: %f", gs_hand.x4);
	}

	if (gs_hand.pinch1 != 0) {
		NSLog(@"Non-zero hand event pinch1: %f", gs_hand.pinch1);
	}

	if (gs_hand.pinch2 != 0) {
		NSLog(@"Non-zero hand event pinch2: %f", gs_hand.pinch2);
	}

	if (gs_hand.x9_1 != 0) {
		NSLog(@"Non-zero hand event x9_1: %i", gs_hand.x9_1);
	}

	if (gs_hand.pathCount != 1 && gs_hand.pathCount != 2) {
		NSLog(@"Unexpected path count: %i", gs_hand.pathCount);
	}

	if (gs_hand.pathCount != gs_hand.deltaX || gs_hand.pathCount != gs_hand.deltaY) {
		NSLog(@"Path count does not match deltas: %i vs %f/%f", gs_hand.pathCount, gs_hand.deltaX, gs_hand.deltaY);
	}

	float averageX = 0;
	float averageY = 0;
	
	for (int i = 0; i < gs_hand.pathCount; i++) {
		gs_path_info_t gs_path = GSEventGetPathInfoAtIndex(gs_event, i);

		[data appendBytes: &gs_path length: sizeof(gs_path)];

		if (gs_path.index > (gs_hand.pathCount + 1)) {
			NSLog(@"Unexpected path event index: %i", gs_path.index);
		}
		
		if (gs_path.index != gs_path.index2) {
			NSLog(@"Unexpected path event index mismatch: %i vs %i", gs_path.index, gs_path.index2);
		}

		if (gs_path.type != (gs_hand.type == 6 ? 1 : 2)) {
			NSLog(@"Unexpected path event type: %i", gs_path.type);
		}

		if (gs_hand.type == 1) {
			if (gs_path.flags != 191) {
				NSLog(@"Unexpected path event flags: %i", gs_path.flags);
			}			
		} else if (gs_hand.type == 2) {
			if (gs_path.flags != 0 && gs_path.flags != 255) {
				NSLog(@"Unexpected path event flags: %i", gs_path.flags);
			}						
		} else {
			if (gs_path.flags != 255) {
				NSLog(@"Unexpected path event flags: %i", gs_path.flags);
			}			
		}

		if (gs_path.sizeX != 1.0 || gs_path.sizeY != 1.0) {
			NSLog(@"Unexpeced path event size: %f/%f", gs_path.sizeX, gs_path.sizeY);
		}

		averageX += gs_path.x;
		averageY += gs_path.y;
	}
	
	averageX = averageX / gs_hand.pathCount;
	averageY = averageY / gs_hand.pathCount;
	
	float x = [[[plist objectForKey:@"WindowLocation"] objectForKey:@"X"] floatValue];
	if (averageX != x) {
		NSLog(@"Average X value doesn't match WindowLocation X: %f vs %f", averageX, x);
	}

	float y = [[[plist objectForKey:@"WindowLocation"] objectForKey:@"Y"] floatValue];
	if (averageY != y) {
		NSLog(@"Average Y value doesn't match WindowLocation Y: %f vs %f", averageY, y);
	}
	
	NSLog(@"*****");
	
	return;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self eventStats: event];
	[super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self eventStats: event];
	[super touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self eventStats: event];
	[super touchesEnded: touches withEvent:event];
}

@end
