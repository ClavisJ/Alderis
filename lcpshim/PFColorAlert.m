@import Alderis;
#import "libcolorpicker.h"

@interface PFColorAlert () <HBColorPickerDelegate>

@end

@implementation PFColorAlert {
	PFColorAlert *_strongSelf;
	HBColorPickerViewController *_viewController;
	UIColor *_color;
	PFColorAlertCompletion _completion;
}

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
	return [[self.class alloc] initWithStartColor:startColor showAlpha:showAlpha];
}

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
	self = [super init];
	if (self) {
		_color = startColor;
		if (showAlpha) {
			NSLog(@"Alderis: -[PFColorAlert initWithStartColor:showAlpha:]: showAlpha was requested, but alpha is not yet supported.");
		}
	}
	return self;
}

- (void)displayWithCompletion:(PFColorAlertCompletion)completion {
	_completion = [completion copy];
	_viewController = [[HBColorPickerViewController alloc] init];
	_viewController.delegate = self;
	_viewController.popoverPresentationController.sourceRect = [UIScreen mainScreen].bounds;
	_viewController.popoverPresentationController.permittedArrowDirections = 0;

	UIColor *color = _color ?: [UIColor colorWithWhite:0.6 alpha:1];
	HBColorPickerConfiguration *configuration = [[HBColorPickerConfiguration alloc] initWithColor:color];
	_viewController.configuration = configuration;

	UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	[rootViewController presentViewController:_viewController animated:YES completion:nil];

	// Keep a strong reference to ourself. The color picker delegate is weakly stored by
	// HBColorPickerViewController, but some users of PFColorAlert do not keep a strong reference to
	// the PFColorAlert instance after calling displayWithCompletion:, causing this class to get
	// deallocated and the delegate never called.
	_strongSelf = self;
}

- (void)close {
	_completion(_color);
	_strongSelf = nil;
}

- (void)colorPicker:(HBColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
	_color = [color copy];
	[self close];
}

- (void)colorPickerDidCancel:(HBColorPickerViewController *)colorPicker {
	[self close];
}

@end
