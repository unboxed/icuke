#import "ViewResponse.h"
#import "iCukeHTTPServer.h"
#import "Viewer.h"

// AX API
extern Boolean AXAPIEnabled(void);

@implementation ViewResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	return [requestURL.path isEqualToString:@"/view"];
}

- (void)startResponse
{
	if (!AXAPIEnabled()) {
		CFHTTPMessageRef response =
			CFHTTPMessageCreateResponse(
				kCFAllocatorDefault, 500, NULL, kCFHTTPVersion1_1);
		CFHTTPMessageSetHeaderFieldValue(
			response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/plain");
		CFHTTPMessageSetHeaderFieldValue(
			response, (CFStringRef)@"Connection", (CFStringRef)@"close");
		CFHTTPMessageSetBody(
			response,
			(CFDataRef)[[NSString stringWithFormat:
					@"Accessiblity Inspector Disabled: "
					@"Please enable the accessibilty inspector in the simulator and retry"]
				dataUsingEncoding:NSUTF8StringEncoding]);
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
			CFRelease(response);
			[server closeHandler:self];
		}
		
		return;
	}
	
	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/xml");
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");

	NSData *viewData = [[[Viewer sharedViewer] screen] dataUsingEncoding:NSUTF8StringEncoding];

	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length",
									(CFStringRef)[NSString stringWithFormat:@"%ld", [viewData length]]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);

	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		[fileHandle writeData:viewData];
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
