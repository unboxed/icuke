#import <Foundation/Foundation.h>

@interface Recorder : NSObject {
	NSMutableArray* eventList;
}

+(Recorder *)sharedRecorder;
-(void)record;
-(void)saveToFile:(NSString*)path;
-(void)load:(NSArray*)events;
-(void)loadFromFile:(NSString*)path;
-(void)play;
-(void)stop;

@end
