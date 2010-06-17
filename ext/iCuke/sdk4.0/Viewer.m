#import <UIKit/UIKit.h>

#import "Viewer.h"

static Viewer *sharedViewer = nil;

@interface NSObject (UIAccessibilityViewer)

-(void)appendToXml:(NSMutableString*)xml;
-(void)appendTraitsToXml:(NSMutableString*)xml;
-(void)appendFrameToXml:(NSMutableString*)xml;
-(void)appendOpenToXml:(NSMutableString*)xml;
-(void)appendCloseToXml:(NSMutableString*)xml;
-(void)appendChildrenToXml:(NSMutableString*)xml;

@end

@implementation NSObject (UIAccessibilityViewer)

-(void)appendOpenToXml:(NSMutableString*)xml {
	[xml appendFormat: @"<%@", NSStringFromClass([self class])];
	if ([self isAccessibilityElement]) {
		[self appendTraitsToXml: xml];
		if ([[self accessibilityLabel] length] > 0) {
			NSString *escaped_label = [self accessibilityLabel];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @"'" withString: @"&apos;"];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @"\\" withString: @"&#39;"];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
			escaped_label = [escaped_label stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
			[xml appendFormat: @"label=\"%@\" ", escaped_label];
		}
		if ([[self accessibilityHint] length] > 0) {
			[xml appendFormat: @"hint=\"%@\" ", [self accessibilityHint]];
		}
		if ([[self accessibilityValue] length] > 0) {
			NSString *escaped_value = [self accessibilityValue];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @"'" withString: @"&apos;"];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @"\\" withString: @"&#39;"];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
			escaped_value = [escaped_value stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
			[xml appendFormat: @"value=\"%@\" ", escaped_value];
		}
	}
	[xml appendString: @">"];
}

-(void)appendTraitsToXml:(NSMutableString *)xml {
	[xml appendString: @" traits=\""];
	if ([self accessibilityTraits] & UIAccessibilityTraitButton) {
		[xml appendString: @"button "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitLink) {
		[xml appendString: @"link "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitSearchField) {
		[xml appendString: @"search_field "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitImage) {
		[xml appendString: @"image "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitSelected) {
		[xml appendString: @"selected "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitPlaysSound) {
		[xml appendString: @"plays_sound "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitKeyboardKey) {
		[xml appendString: @"keyboard_key "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitStaticText) {
		[xml appendString: @"static_text "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitSummaryElement) {
		[xml appendString: @"summary_element "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitNotEnabled) {
		[xml appendString: @"not_enabled "];
	}
	if ([self accessibilityTraits] & UIAccessibilityTraitUpdatesFrequently) {
		[xml appendString: @"updates_frequently "];
	}
	[xml appendString: @"\" "];
}

-(void)appendFrameToXml:(NSMutableString *)xml {
	CGRect frame = [self accessibilityFrame];
	[xml appendFormat: @"<frame x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\"/>",
		frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
}

-(void)appendCloseToXml:(NSMutableString *)xml {
	[xml appendFormat: @"</%@>", NSStringFromClass([self class])];
}

-(void)appendChildrenToXml:(NSMutableString *)xml {
	// Bug that accessibilityElementCount is returning 2147483647 rather than 0?
	if ([self accessibilityElementCount] != 2147483647) {
		for (int i = 0; i < [self accessibilityElementCount]; i++) {
			id accessibilityElement = [self accessibilityElementAtIndex: i];
			[accessibilityElement appendToXml: xml];
		}
	}
}

-(void)appendToXml:(NSMutableString *)xml {
	[self appendOpenToXml: xml];
	[self appendFrameToXml: xml];
	[self appendChildrenToXml: xml];
	[self appendCloseToXml: xml];
}

@end

@implementation UITableView (AccessibilityVisibilityFix)

-(void)appendChildrenToXml:(NSMutableString *)xml {
	// Ignore the accessibility interface here because it doesn't allow us a way to tell if a cell is visible.
	for (UIView *view in [self visibleCells]) {
		[view appendToXml: xml];
	}
}

@end

@interface UIView (Viewer)

-(void)appendToXml:(NSMutableString *)xml;

@end

@implementation UIView (Viewer)

-(void)appendToXml:(NSMutableString *)xml {
	[self appendOpenToXml: xml];

	if ([self isAccessibilityElement]) {
		[self appendFrameToXml: xml];
	}

	for (UIView *view in self.subviews) {
		[view appendToXml: xml];
	}

	[self appendChildrenToXml: xml];
	[self appendCloseToXml: xml];
}

@end

@implementation Viewer

+(Viewer *)sharedViewer {
	if (sharedViewer == nil) {
		sharedViewer = [[super allocWithZone:NULL] init];
	}
	return sharedViewer;
}

-(NSString *)screen {
	NSMutableString *xml = [NSMutableString stringWithString: @"<screen>"];
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	[xml appendFormat: @"<frame x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\"/>",
		frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];

	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		[window appendToXml: xml];
	}

	[xml appendString: @"</screen>"];

	return xml;
}

@end
