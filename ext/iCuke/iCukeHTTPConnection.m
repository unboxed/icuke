//
//  iCukeHTTPConnection.m
//  iCuke
//
//  Created by Rob Holland on 01/03/2010.
//  Copyright 2010 The IT Refinery. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTTPResponse.h"
#import "iCukeHTTPConnection.h"
#import "Viewer.h"
#import "Recorder.h"
#import "JSON.h"

typedef struct {
	unsigned char index;
	unsigned char index2;
	unsigned char type;
	unsigned char flags;
	float sizeX;
	float sizeY;
	float x;
	float y;
	int x6;
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
	unsigned char x9_3;
	unsigned char x9_4;
} gs_hand_info_t;

@implementation iCukeHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	NSLog(@"Request: %@", path);

	if ([path hasPrefix:@"/quit"]) {
		exit(EXIT_SUCCESS);
	} else if ([path hasPrefix:@"/view"]) {
		NSData *browseData = [[[Viewer sharedViewer] screen] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/defaults"]) {
		NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
		id json = [[self parseRequestQuery] objectForKey:@"json"];

		if (!json) {
			NSDictionary *defaults = [user_defaults dictionaryRepresentation];

			NSData *browseData = [[defaults JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
			return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
		} else {
			id parsed_json = [json JSONValue];

			NSEnumerator *enumerator = [parsed_json keyEnumerator];
			id key;
			while ((key = [enumerator nextObject])) {
				[user_defaults setObject: [parsed_json objectForKey: key] forKey: key];
			}
		}
	} else if ([path hasPrefix:@"/record"]) {
		[[Recorder sharedRecorder] record];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/save"]) {
		NSDictionary *parameters = [self parseRequestQuery];
		
		[[Recorder sharedRecorder] saveToFile: [parameters objectForKey: @"file"]];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/load"]) {
		NSDictionary *parameters = [self parseRequestQuery];

		[[Recorder sharedRecorder] loadFromFile: [parameters objectForKey: @"file"]];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/play"]) {
		[[Recorder sharedRecorder] play];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/stop"]) {
		[[Recorder sharedRecorder] stop];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	} else if ([path hasPrefix:@"/event"]) {
		NSDictionary *parameters = [self parseRequestQuery];
		id parsed_json = [[parameters objectForKey: @"json"] JSONValue];
		NSArray *events;

		if ([parsed_json isKindOfClass:[NSDictionary class]]) {
			events = [NSArray arrayWithObject: parsed_json];
		} else {
			events = parsed_json;
		}

		for (NSMutableDictionary *event in events) {
			gs_hand_info_t hand_info;

			bzero(&hand_info, sizeof(hand_info));

			NSMutableDictionary *data = [event objectForKey: @"Data"];

			hand_info.type = [[data objectForKey: @"Type"] integerValue];
			NSDictionary *delta = [data objectForKey: @"Delta"];
			hand_info.deltaX = [[delta objectForKey: @"X"] shortValue];
			hand_info.deltaY = [[delta objectForKey: @"Y"] shortValue];
			hand_info.averageX = [[[delta objectForKey: @"WindowLocation"] objectForKey: @"X"] floatValue];
			hand_info.averageY = [[[delta objectForKey: @"WindowLocation"] objectForKey: @"Y"] floatValue];

			NSArray *points = [data objectForKey: @"Paths"];

			hand_info.pathCount = (unsigned char)[points count];

			NSMutableData *raw_data = [NSMutableData dataWithBytes: &hand_info length: sizeof(hand_info)];

			int index = hand_info.pathCount == 1 ? 2 : 1;

			for (NSDictionary *point in points) {
				gs_path_info_t path_info;

				bzero(&path_info, sizeof(path_info));

				path_info.index = path_info.index2 = index++;
				path_info.type = hand_info.type == 6 ? 1 : 2;
				path_info.sizeX = [[[point objectForKey: @"Size"] objectForKey: @"X"] floatValue];
				path_info.sizeY = [[[point objectForKey: @"Size"] objectForKey: @"Y"] floatValue];
				path_info.x = [[[point objectForKey: @"Location"] objectForKey: @"X"] floatValue];
				path_info.y = [[[point objectForKey: @"Location"] objectForKey: @"Y"] floatValue];

				[raw_data appendBytes: &path_info length: sizeof(path_info)];
			}

			[event setObject: raw_data forKey: @"Data"];

			NSLog(@"Built event data:    %@", [event objectForKey: @"Data"]);
		}

		[[Recorder sharedRecorder] load: events];
		[[Recorder sharedRecorder] play];

		NSData *browseData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		return [[[HTTPDataResponse alloc] initWithData:browseData] autorelease];
	}

	return nil;
}

- (NSData *)preprocessResponse:(CFHTTPMessageRef)response
{
	CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Type"), CFSTR("text/xml"));

	return [super preprocessResponse:response];
}

@end
