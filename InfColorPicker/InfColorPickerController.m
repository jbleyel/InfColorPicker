//==============================================================================
//
//  InfColorPickerController.m
//  InfColorPicker
//
//  Created by Troy Gaul on 7 Aug 2010.
//
//  Copyright (c) 2011-2013 InfinitApps LLC: http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import "InfColorPickerController.h"
#import "InfColorBarPicker.h"
#import "InfColorSquarePicker.h"
#import "InfHSBSupport.h"

//------------------------------------------------------------------------------

static void HSVFromUIColor(UIColor* color, float* h, float* s, float* v)
{
	CGColorRef colorRef = [color CGColor];
	
	const CGFloat* components = CGColorGetComponents(colorRef);
	size_t numComponents = CGColorGetNumberOfComponents(colorRef);
	
	CGFloat r, g, b;
	
	if (numComponents < 3) {
		r = g = b = components[0];
	}
	else {
		r = components[0];
		g = components[1];
		b = components[2];
	}
	
	RGBToHSV(r, g, b, h, s, v, YES);
}

//==============================================================================

@interface InfColorPickerController ()

@property (nonatomic) IBOutlet InfColorBarView* barView;
@property (nonatomic) IBOutlet InfColorSquareView* squareView;
@property (nonatomic) IBOutlet InfColorBarPicker* barPicker;
@property (nonatomic) IBOutlet InfColorSquarePicker* squarePicker;
@property (nonatomic) IBOutlet UIView* sourceColorView;
@property (nonatomic) IBOutlet UIView* resultColorView;
@property (nonatomic) IBOutlet UINavigationController* navController;

@property (nonatomic) IBOutlet InfColorBarPicker* alphabarPicker;
@property (nonatomic) IBOutlet InfColorBarView* alphabarView;

@property (nonatomic) IBOutlet UILabel* txtValue;


@end

//==============================================================================

@implementation InfColorPickerController {
	float _hue;
	float _saturation;
	float _brightness;
	float _alpha;
}

//------------------------------------------------------------------------------
#pragma mark	Class methods
//------------------------------------------------------------------------------

+ (InfColorPickerController*) colorPickerViewController
{
	return [[self alloc] initWithNibName: @"InfColorPickerView" bundle: nil];
}

//------------------------------------------------------------------------------

+ (CGSize) idealSizeForViewInPopover
{
	return CGSizeMake(256 + (1 + 20) * 2, 420);
}

//------------------------------------------------------------------------------
#pragma mark	Creation
//------------------------------------------------------------------------------

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	
	if (self) {
		self.navigationItem.title = @"Set Color";
	}
	
	return self;
}

//------------------------------------------------------------------------------

- (void) presentModallyOverViewController: (UIViewController*) controller
{
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: self];
	
	nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
																						   target: self
																						   action: @selector(done:)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																						   target: self
																						   action: @selector(cancel:)];

	[controller presentViewController: nav animated: YES completion: nil];
}

//------------------------------------------------------------------------------
#pragma mark	UIViewController methods
//------------------------------------------------------------------------------

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    
    _alphabarPicker.value = _alpha;
    _alphabarPicker.fill=false;
    
	_barPicker.value = _hue;
	_barPicker.fill = true;
	_squareView.hue = _hue;
	_squarePicker.hue = _hue;
	_squarePicker.value = CGPointMake(_saturation, _brightness);
	
	if (_sourceColor) {
		_sourceColorView.backgroundColor = _sourceColor;
	
        CGFloat r,g,b,a;
        [_sourceColor getRed:&r green:&g blue:&b alpha:&a];
        _alphabarPicker.value = a;
        _alphabarView.color = _sourceColor;
        _alpha = a;
    
        _txtValue.text = [self hexStringValue:_sourceColor];

    }
	if (_resultColor)
		_resultColorView.backgroundColor = _resultColor;
}

- (NSString *) hexStringValue:(UIColor*)color
{
    NSString *result=@"";
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(_sourceColor.CGColor));

    if (kCGColorSpaceModelRGB == colorSpaceModel) {
        CGFloat r,g,b,a;
        if ( [color getRed:&r green:&g blue:&b alpha:&a]) {
            result = [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255),lroundf(a * 255)];
        }
    }
    else if(kCGColorSpaceModelMonochrome == colorSpaceModel)
    {
        CGFloat w;
        if ([color getWhite:&w alpha:NULL]) {
            result = [NSString stringWithFormat:@"#%02lX%02lX%02lX",lroundf(w * 255) , lroundf(w * 255), lroundf(w * 255)];
        }
    }
    return result;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return UIInterfaceOrientationMaskAll;
	else
		return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

//------------------------------------------------------------------------------

- (UIRectEdge) edgesForExtendedLayout
{
	return UIRectEdgeNone;
}

//------------------------------------------------------------------------------
#pragma mark	IB actions
//------------------------------------------------------------------------------

- (IBAction)takeAlphaValue:(InfColorBarPicker *)sender {
    
    _alpha = sender.value;
    
    [ self updateResultColor ];
    
}

- (IBAction) takeBarValue: (InfColorBarPicker*) sender
{
	_hue = sender.value;
	
	_squareView.hue = _hue;
	_squarePicker.hue = _hue;
	
	[self updateResultColor];
}

//------------------------------------------------------------------------------

- (IBAction) takeSquareValue: (InfColorSquarePicker*) sender
{
	_saturation = sender.value.x;
	_brightness = sender.value.y;
	
	[self updateResultColor];
}

//------------------------------------------------------------------------------

- (IBAction) takeBackgroundColor: (UIView*) sender
{
	self.resultColor = sender.backgroundColor;
}

//------------------------------------------------------------------------------

- (IBAction) done: (id) sender
{
    if (_resultBlock) {
        _resultBlock(self, true, self.resultColor);
    }
//	[self.delegate colorPickerControllerDidFinish: self];
}

- (IBAction) cancel: (id) sender
{
    self.resultColor = _sourceColor;
    if (_resultBlock) {
        _resultBlock(self, false, self.resultColor);
    }
//	[self.delegate colorPickerControllerDidFinish: self];
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) informDelegateDidChangeColor
{
	//if (self.delegate && [(id) self.delegate respondsToSelector: @selector(colorPickerControllerDidChangeColor:)])
	//	[self.delegate colorPickerControllerDidChangeColor: self];
}

//------------------------------------------------------------------------------

- (void) updateResultColor
{
	// This is used when code internally causes the update.  We do this so that
	// we don't cause push-back on the HSV values in case there are rounding
	// differences or anything.
	
	[self willChangeValueForKey: @"resultColor"];
	
	_resultColor = [UIColor colorWithHue: _hue
							  saturation: _saturation
							  brightness: _brightness
								   alpha: _alpha];
	
	[self didChangeValueForKey: @"resultColor"];
	
	_resultColorView.backgroundColor = _resultColor;
	
    _txtValue.text = [self hexStringValue:_resultColor];
    
    _alphabarView.color = _resultColor;

	[self informDelegateDidChangeColor];
}

//------------------------------------------------------------------------------

- (void) setResultColor: (UIColor*) newValue
{
	if (![_resultColor isEqual: newValue]) {
		_resultColor = newValue;
		
		float h = _hue;
		HSVFromUIColor(newValue, &h, &_saturation, &_brightness);
		
		if ((h == 0.0 && _hue == 1.0) || (h == 1.0 && _hue == 0.0)) {
			// these are equivalent, so do nothing
		}
		else if (h != _hue) {
			_hue = h;
			
			_barPicker.value = _hue;
			_squareView.hue = _hue;
			_squarePicker.hue = _hue;
		}
		
        CGFloat r,g,b,a;
        [newValue getRed:&r green:&g blue:&b alpha:&a];
        _alphabarPicker.value = a;
        _alphabarView.color = newValue;
        _alpha = a;
        
		_squarePicker.value = CGPointMake(_saturation, _brightness);
		
		_resultColorView.backgroundColor = _resultColor;
		
		[self informDelegateDidChangeColor];
	}
}

//------------------------------------------------------------------------------

- (void) setSourceColor: (UIColor*) newValue
{
	if (![_sourceColor isEqual: newValue]) {
		_sourceColor = newValue;
		
		_sourceColorView.backgroundColor = _sourceColor;
		
		self.resultColor = newValue;
	}
}

//------------------------------------------------------------------------------

@end

//==============================================================================
