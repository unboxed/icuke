#import <Foundation/Foundation.h>

@interface Viewer : NSObject

+(Viewer*)sharedViewer;
-(NSString*)screen;

@end
