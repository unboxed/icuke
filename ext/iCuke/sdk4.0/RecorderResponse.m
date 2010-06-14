#import "RecorderResponse.h"
#import "iCukeHTTPServer.h"
#import "Recorder.h"

@implementation RecorderResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	if ([requestURL.path isEqualToString:@"/record"] ||
		[requestURL.path isEqualToString:@"/play"] ||
		[requestURL.path isEqualToString:@"/load"] ||
		[requestURL.path isEqualToString:@"/save"] ||
		[requestURL.path isEqualToString:@"/stop"])
		return YES;

	return NO;
}

- (void)startResponse
{
	if ([url.path isEqualToString:@"/record"]) {
		[[Recorder sharedRecorder] record];
		[self finishResponse];
	} else if ([url.path isEqualToString:@"/play"]) {
		[[Recorder sharedRecorder] playbackWithDelegate: self doneSelector: @selector(finishResponse)];
	} else if ([url.path isEqualToString:@"/load"]) {
		[[Recorder sharedRecorder] loadFromFile: [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[self finishResponse];
	} else if ([url.path isEqualToString:@"/save"]) {
		[[Recorder sharedRecorder] saveToFile: [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[self finishResponse];
	} else if ([url.path isEqualToString:@"/stop"]) {
		[[Recorder sharedRecorder] stop];
		[self finishResponse];
	}

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
