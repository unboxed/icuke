//
//  UIView+XMLDescription.m
//  SelfTesting
//
//  Created by Matt Gallagher on 9/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//

#import "UIView+XMLDescription.h"
#import "NSObject+ClassName.h"


@implementation UIView (XMLDescription)


- (NSMutableString *) xmlAttributesWithPadding:(NSString *)padding {
	NSMutableString *attributes;
	if ([self tag] != 0) {
		attributes = [NSMutableString stringWithFormat:@"\n%@\t<tag>%d</tag>", padding, [self tag]];
	} else {
		attributes = [NSMutableString new];
	}
	return attributes;
}

- (NSString *) xmlDescriptionWithStringPadding:(NSString *)padding {
	NSMutableString *resultingXML = [NSMutableString stringWithFormat:@"\n%@<%@ address=\"%d\">", padding, [self className], (NSInteger)self];
	[resultingXML appendString:[self xmlAttributesWithPadding:padding]];
	
	//TODO: delegate those to subclasses
	if ([self respondsToSelector:@selector(text)] && [self performSelector:@selector(text)])
	{
		[resultingXML appendFormat:@"\n%@\t<text><![CDATA[%@]]></text>", padding, [self performSelector:@selector(text)]];
	}
	if ([self respondsToSelector:@selector(title)])
	{
		[resultingXML appendFormat:@"\n%@\t<title><![CDATA[%@]]></title>", padding, [self performSelector:@selector(title)]];
	}
	if ([self isAccessibilityElement]) {
		if ([self accessibilityLabel]) {
			[resultingXML appendFormat:@"\n%@\t<accessibilityLabel><![CDATA[%@]]></accessibilityLabel>", padding, [self accessibilityLabel]];
		}
		if ([self accessibilityTraits] & UIAccessibilityTraitButton) {
			[resultingXML appendFormat:@"\n%@\t<accessibilityTrait trait=\"button\"/>", padding];
		}		
	}	
	if ([self respondsToSelector:@selector(currentTitle)] && [self performSelector:@selector(currentTitle)])
	{
		[resultingXML appendFormat:@"\n%@\t<currentTitle><![CDATA[%@]]></currentTitle>", padding, [self performSelector:@selector(currentTitle)]];
	}
	if ([self respondsToSelector:@selector(isKeyWindow)])
	{
		if([self performSelector:@selector(isKeyWindow)]) {
			[resultingXML appendFormat:@"\n%@\t<keyWindow>YES</keyWindow>", padding];			
		}
		else {
			[resultingXML appendFormat:@"\n%@\t<keyWindow>NO</keyWindow>", padding];			
		}
	}
	if ([self respondsToSelector:@selector(isOn)])
	{
		if(((UISwitch *)self).on) {
			[resultingXML appendFormat:@"\n%@\t<on>YES</on>", padding];			
		}
		else {
			[resultingXML appendFormat:@"\n%@\t<on>NO</on>", padding];
		}
	}
	
//	[resultingXML appendFormat:@"\n%@\t<frame>", padding];
//	[resultingXML appendFormat:@"\n%@\t\t<x>%f</x>", padding, self.frame.origin.x];
//	[resultingXML appendFormat:@"\n%@\t\t<y>%f</y>", padding, self.frame.origin.y];
//	[resultingXML appendFormat:@"\n%@\t\t<width>%f</width>", padding, self.frame.size.width];
//	[resultingXML appendFormat:@"\n%@\t\t<height>%f</height>", padding, self.frame.size.height];
//	[resultingXML appendFormat:@"\n%@\t</frame>", padding];
	if(self.subviews.count > 0) {
		[resultingXML appendFormat:@"\n%@\t<subviews>", padding];
		for (UIView *subview in [self subviews]) {
			[resultingXML appendString:[subview xmlDescriptionWithStringPadding:[NSString stringWithFormat:@"%@\t\t", padding]]];
		}
		[resultingXML appendFormat:@"\n%@\t</subviews>", padding];
	}
//	else {
//		[resultingXML appendFormat:@"\n%@\t<subviews />", padding];
//	}
	[resultingXML appendFormat:@"\n%@</%@>", padding, [self className]];
	return resultingXML;
}


@end

@implementation UITableViewCell (XMLDescription)

- (NSMutableString *) xmlAttributesWithPadding:(NSString *) padding {
	NSMutableString *attributes = [super xmlAttributesWithPadding:padding];
	[attributes appendFormat:@"\n%@\t<accessoryType>%d</accessoryType>", padding, [self accessoryType]];
	return attributes;
}

@end
