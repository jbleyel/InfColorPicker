//==============================================================================
//
//  InfColorBarPicker.m
//  InfColorPicker
//
//  Created by Troy Gaul on 8/9/10.
//
//  Copyright (c) 2011-2013 InfinitApps LLC: http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import "InfColorBarPicker.h"

#import "InfColorIndicatorView.h"
#import "InfHSBSupport.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//------------------------------------------------------------------------------

#define kContentInsetX 20

//==============================================================================

@implementation InfColorBarView
@synthesize color;

//------------------------------------------------------------------------------

static CGImageRef createContentImage()
{
	float hsv[] = { 0.0f, 1.0f, 1.0f };
	return createHSVBarContentImage(InfComponentIndexHue, hsv);
}

//------------------------------------------------------------------------------

static CGImageRef createContentImage2()
{
	return createCheckerPatternImage();
}

- (void) drawRectA: (CGRect) rect
{
	CGImageRef image = createContentImage2();
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:image]];
    
    
	if( image ) {
		CGContextRef context = UIGraphicsGetCurrentContext();
        
        [patternColor setFill];
        
        CGContextFillRect(context, self.bounds);
        
		CGImageRelease( image );
        
        CGFloat r,g,b,a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        
        CGGradientRef myGradient;
        CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 0.95 };
        CGFloat components[8] = { r ,g ,b , 0.f,  // Start color
            r,g,b, 1.f }; // End color
        
        myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                          locations, num_locations);
        
        
        CGPoint myStartPoint, myEndPoint;
        myStartPoint.x = 0;
        myStartPoint.y = 0;
        myEndPoint.x = self.frame.size.width;
        myEndPoint.y = 0;
        
        CGContextDrawLinearGradient(context, myGradient, myStartPoint
                                    , myEndPoint,
                                    kCGGradientDrawsAfterEndLocation);
        
        
        CGColorSpaceRelease(myColorspace);
        CGGradientRelease(myGradient);
        
	}
}

- (void) drawRect: (CGRect) rect
{
    if (self.color) {
        [self drawRectA:rect];
        return;
    }
    
	CGImageRef image = createContentImage();
	
	if (image) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextDrawImage(context, [self bounds], image);
		
		CGImageRelease(image);
	}
}

- (void)setColor:(UIColor *)newColor
{
    color = newColor;
    
    [self setNeedsDisplay];
    
}

//------------------------------------------------------------------------------

@end

//==============================================================================

@implementation InfColorBarPicker {
	InfColorIndicatorView* indicator;
}

@synthesize fill;
//------------------------------------------------------------------------------
#pragma mark	Drawing
//------------------------------------------------------------------------------

- (void) layoutSubviews
{
	if (indicator == nil) {
		CGFloat kIndicatorSize = 24.0f;
		indicator = [[InfColorIndicatorView alloc] initWithFrame: CGRectMake(0, 0, kIndicatorSize, kIndicatorSize)];
        
        indicator.fill = fill;
		[self addSubview: indicator];
	}
	
	indicator.color = [UIColor colorWithHue: self.value
	                             saturation: 1.0f
	                             brightness: 1.0f
	                                  alpha: 1.0f];
	
	CGFloat indicatorLoc = kContentInsetX + (self.value * (self.bounds.size.width - 2 * kContentInsetX));
	indicator.center = CGPointMake(indicatorLoc, CGRectGetMidY(self.bounds));
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) setValue: (float) newValue
{
	if (newValue != _value) {
		_value = newValue;
		
		[self sendActionsForControlEvents: UIControlEventValueChanged];
		[self setNeedsLayout];
	}
}

//------------------------------------------------------------------------------
#pragma mark	Tracking
//------------------------------------------------------------------------------

- (void) trackIndicatorWithTouch: (UITouch*) touch
{
	float percent = ([touch locationInView: self].x - kContentInsetX)
				  / (self.bounds.size.width - 2 * kContentInsetX);
	
	self.value = pin(0.0f, percent, 1.0f);
}

//------------------------------------------------------------------------------

- (BOOL) beginTrackingWithTouch: (UITouch*) touch
                      withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch: touch];
	
	return YES;
}

//------------------------------------------------------------------------------

- (BOOL) continueTrackingWithTouch: (UITouch*) touch
                         withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch: touch];
	
	return YES;
}

//------------------------------------------------------------------------------
#pragma mark	Accessibility
//------------------------------------------------------------------------------

- (UIAccessibilityTraits) accessibilityTraits
{
	UIAccessibilityTraits t = super.accessibilityTraits;
	
	t |= UIAccessibilityTraitAdjustable;
	
	return t;
}

//------------------------------------------------------------------------------

- (void) accessibilityIncrement
{
	float newValue = self.value + 0.05;
	
	if (newValue > 1.0)
		newValue -= 1.0;
		
	self.value = newValue;
}

//------------------------------------------------------------------------------

- (void) accessibilityDecrement
{
	float newValue = self.value - 0.05;
	
	if (newValue < 0)
		newValue += 1.0;
	
	self.value = newValue;
}

//------------------------------------------------------------------------------

- (NSString*) accessibilityValue
{
	return [NSString stringWithFormat: @"%d degrees hue", (int) (self.value * 360.0)]; 
}

//------------------------------------------------------------------------------

@end

//==============================================================================
