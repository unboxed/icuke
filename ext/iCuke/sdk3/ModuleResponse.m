#import "ModuleResponse.h"
#import "iCukeHTTPServer.h"
#include <dlfcn.h>

@implementation ModuleResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	return [requestURL.path isEqualToString:@"/module"];
}

- (void)startResponse
{
	NSString *module = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	if (!dlopen([module UTF8String], 0)) {
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
					@"Unable to load module: %@, %s", module, dlerror()]
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
