//
//  EMController.h
//  EdenMath
//
//  Created by admin on Thu Feb 21 2002.
//  Copyright (c) 2002-2013 Edenwaith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "EMResponder.h"
#import "EMWindow.h"

@interface EMController : NSObject
{
    EMResponder			 *em; 			// model responder to buttons
	
    IBOutlet NSTextField *displayField; // display field showing output
	IBOutlet EMWindow	 *window;
	
	IBOutlet NSButton	 *alternateButton; // '2nd' button
	IBOutlet NSButton	 *sineButton;
	IBOutlet NSButton	 *cosineButton;
	IBOutlet NSButton	 *tangentButton;
	IBOutlet NSButton	 *x3Button;
	IBOutlet NSButton	 *xyButton;
	IBOutlet NSButton	 *lnButton;
	IBOutlet NSButton	 *logButton;
	
	BOOL displayAlternates;
	
    NSUndoManager			*undoManager;		// the undo manager
}

// prototypes for EMController class methods
- (void)off:(id)sender;	// Not currently used

- (void)clear:(id)sender;
- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

- (void)updateDisplay;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;
- (void)saveState;
- (void)setState:(NSDictionary *)emState;
- (void)undoAction:(id)sender;
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

- (IBAction) goToProductPage : (id) sender;
- (IBAction) goToFeedbackPage: (id) sender;

// Arithmetic functions & constants
- (void) digitButton: (id) sender;
- (void)period:(id)sender;
- (void)pi2:(id)sender;
- (void)pi3_2:(id)sender;
- (void)pi:(id)sender;
- (void)pi_2:(id)sender;
- (void)pi_3:(id)sender;
- (void)pi_4:(id)sender;
- (void)pi_6:(id)sender; 
- (void)e:(id)sender;

// Standard 4-function calc methods
- (void)enter:(id)sender;
- (void)add:(id)sender;
- (void)subtract:(id)sender;
- (void)multiply:(id)sender;
- (void)divide:(id)sender;
- (void)reverse_sign:(id)sender;
- (void)percentage:(id)sender;
- (void)mod:(id)sender;
- (void)EE:(id)sender;

// Algebraic functions
- (void)squared:(id)sender;
- (void)cubed:(id)sender;
- (void)exponent:(id)sender;
- (void)square_root:(id)sender;
- (void)cubed_root:(id)sender;
- (void)xroot:(id)sender;
- (void)ln:(id)sender;
- (void)logarithm:(id)sender;
- (void)factorial:(id)sender;
- (void)powerE:(id)sender;
- (void)power10:(id)sender;
- (void)inverse:(id)sender;

// Trigonometric functions
- (IBAction) setAngleType: (id) sender;
- (void)setDegree:(id)sender;
- (void)setRadian:(id)sender;
- (void)setGradient:(id)sender;
- (void)sine:(id)sender;
- (void)cosine:(id)sender;
- (void)tangent:(id)sender;
- (void)arcsine:(id)sender;
- (void)arccosine:(id)sender;
- (void)arctangent:(id)sender;

// Probability functions
- (void)permutation:(id)sender;
- (void)combination:(id)sender;
- (void)random_num:(id)sender;

- (void)toggleAlernates:(id)sender;
- (void) showAlternates;
- (void) hideAlternates;

@end
