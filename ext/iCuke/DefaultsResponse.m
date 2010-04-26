#import "DefaultsResponse.h"
#import "iCukeHTTPServer.h"
#import "JSON.h"

@implementation DefaultsResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	return [requestURL.path isEqualToString:@"/defaults"];
}

- (void)startResponse
{
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	NSString *json = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSData *defaultsData = nil;

	if (!json) {
		NSDictionary *defaults = [user_defaults dictionaryRepresentation];

		defaultsData = [[defaults JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	} else {
		id parsed_json = [json JSONValue];

		NSEnumerator *enumerator = [parsed_json keyEnumerator];
		id key;
		while ((key = [enumerator nextObject])) {
			[user_defaults setObject: [parsed_json objectForKey: key] forKey: key];
		}
	}

	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"application/json");

	if (defaultsData)
		CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Length",
										(CFStringRef)[NSString stringWithFormat:@"%ld", [defaultsData length]]);

	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);

	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		if (defaultsData)
			[fileHandle writeData:defaultsData];
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
