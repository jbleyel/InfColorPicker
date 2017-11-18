//==============================================================================
//
//  InfColorPickerController.h
//  InfColorPicker
//
//  Created by Troy Gaul on 7 Aug 2010.
//
//  Copyright (c) 2011-2013 InfinitApps LLC: http://infinitapps.com
//	Some rights reserved: http://opensource.org/licenses/MIT
//
//==============================================================================

#import <UIKit/UIKit.h>

@class InfColorPickerController;

typedef void (^InfColorPickerControllerCompletionBlock) (InfColorPickerController* _Nonnull ctrl ,BOOL Success, UIColor * _Nullable color);

//@protocol InfColorPickerControllerDelegate;

//------------------------------------------------------------------------------

@interface InfColorPickerController : UIViewController

// Public API:

+ (InfColorPickerController*_Nonnull) colorPickerViewController;
+ (CGSize) idealSizeForViewInPopover;

- (void) presentModallyOverViewController: (UIViewController*_Nullable) controller;

//@property (strong, nonatomic) id <InfColorPickerControllerDelegate> delegate;

@property (nonatomic) InfColorPickerControllerCompletionBlock _Nonnull resultBlock;

@property (nonatomic) UIColor* _Nullable sourceColor;
@property (nonatomic) UIColor* _Nullable resultColor;


@end

//------------------------------------------------------------------------------
/*
@protocol InfColorPickerControllerDelegate

@optional

- (void) colorPickerControllerDidFinish: (InfColorPickerController*) controller;
	// This is only called when the color picker is presented modally.

- (void) colorPickerControllerDidChangeColor: (InfColorPickerController*) controller;

@end
*/
//------------------------------------------------------------------------------
