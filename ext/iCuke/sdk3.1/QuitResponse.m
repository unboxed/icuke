#import "QuitResponse.h"
#import "iCukeHTTPServer.h"
#import "JSON.h"

@implementation QuitResponse
+ (void)load
{
	[iCukeHTTPResponseHandler registerHandler:self];
}

+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
	method:(NSString *)requestMethod
	url:(NSURL *)requestURL
	headerFields:(NSDictionary *)requestHeaderFields
{
	return [requestURL.path isEqualToString:@"/quit"];
}

- (void)startResponse
{
	exit(0);
}
@end
