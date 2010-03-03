//
//  UIApplication+XMLDescription.m
//  iPhoneRiskManager
//
//  Created by Felipe Barreto on 03/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UIApplication+XMLDescription.h"
#import "UIView+XMLDescription.h"
#import "NSObject+ClassName.h"

@implementation UIApplication (XMLDescription)

- (NSString *) xmlDescription {
	NSMutableString *resultingXML = [NSMutableString stringWithFormat:@"\n<%@>", [self className]];
	
	if(self.windows.count > 0) {
		[resultingXML appendString:@"\n\t<windows>"];
		for (UIWindow *window in self.windows) {
			[resultingXML appendString:[window xmlDescriptionWithStringPadding:@"\t"]];
		}
		[resultingXML appendString:@"\n\t</windows>"];
	}
	else {
		[resultingXML appendString:@"\n\t<windows />"];
	}
	[resultingXML appendFormat:@"\n</%@>", [self className]];
	return resultingXML;
}


@end
