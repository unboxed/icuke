#import "EventResponse.h"
#import "iCukeHTTPServer.h"
#import "JSON.h"
#import "Recorder.h"

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

@implementation EventResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	return [requestURL.path isEqualToString:@"/event"];
}

- (void)startResponse
{
	NSString *json = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	id event_data = [json JSONValue];
	NSArray *events;

	if ([event_data isKindOfClass:[NSDictionary class]]) {
		events = [NSArray arrayWithObject: event_data];
	} else {
		events = event_data;
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
		if (hand_info.type != 1) {
			hand_info.x9_3 = 0x7c;
			hand_info.x9_4 = 0x98;
		}

		NSMutableData *raw_data = [NSMutableData dataWithBytes: &hand_info length: sizeof(hand_info)];

		int index = hand_info.pathCount == 1 ? 2 : 1;

		for (NSDictionary *point in points) {
			gs_path_info_t path_info;

			bzero(&path_info, sizeof(path_info));

			path_info.index = path_info.index2 = index++;
			path_info.type = hand_info.type == 6 ? 1 : 2;
			path_info.flags = hand_info.type == 1 ? 0x43 : 0x3f;
			path_info.sizeX = [[[point objectForKey: @"Size"] objectForKey: @"X"] floatValue];
			path_info.sizeY = [[[point objectForKey: @"Size"] objectForKey: @"Y"] floatValue];
			path_info.x = [[[point objectForKey: @"Location"] objectForKey: @"X"] floatValue];
			path_info.y = [[[point objectForKey: @"Location"] objectForKey: @"Y"] floatValue];

			[raw_data appendBytes: &path_info length: sizeof(path_info)];
		}

		[event setObject: raw_data forKey: @"Data"];
	}

	[[Recorder sharedRecorder] load: events];
	[[Recorder sharedRecorder] playbackWithDelegate: self doneSelector: @selector(finishResponse)];
}

- (void)finishResponse
{
	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);

	@try
	{
		[fileHandle writeData:(NSData *)headerData];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		CFRelease(headerData);
		[server closeHandler:self];
	}
}
@end
