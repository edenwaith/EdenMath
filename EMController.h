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
	IBOutlet NSButton	 *binaryLogButton;
	IBOutlet NSButton	 *logButton;
	
	BOOL displayAlternates;
	
    NSUndoManager			*undoManager;		// the undo manager
}

// prototypes for EMController class methods

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
- (IBAction) digitButton: (id) sender;
- (IBAction) period:(id)sender;
- (IBAction) pi2:(id)sender;
- (IBAction) pi3_2:(id)sender;
- (IBAction) pi:(id)sender;
- (IBAction) pi_2:(id)sender;
- (IBAction) pi_3:(id)sender;
- (IBAction) pi_4:(id)sender;
- (IBAction) pi_6:(id)sender; 
- (IBAction) e:(id)sender;

// Standard 4-function calc methods
- (IBAction) enter:(id)sender;
- (IBAction) add:(id)sender;
- (IBAction) subtract:(id)sender;
- (IBAction) multiply:(id)sender;
- (IBAction) divide:(id)sender;
- (IBAction) reverseSign:(id)sender;
- (IBAction) percentage:(id)sender;
- (IBAction) mod:(id)sender;
- (IBAction) EE:(id)sender;

// Algebraic functions
- (IBAction) squared:(id)sender;
- (IBAction) cubed:(id)sender;
- (IBAction) exponent:(id)sender;
- (IBAction) squareRoot:(id)sender;
- (IBAction) cubedRoot:(id)sender;
- (IBAction) xRoot:(id)sender;
- (IBAction) ln:(id)sender;
- (IBAction) binaryLogarithm: (id) sender;
- (IBAction) logarithm:(id)sender;
- (IBAction) factorial:(id)sender;
- (IBAction) powerE:(id)sender;
- (IBAction) power2: (id) sender;
- (IBAction) power10:(id)sender;
- (IBAction) inverse:(id)sender;

// Trigonometric functions
- (IBAction) setAngleType: (id) sender;
- (IBAction) setDegree:(id)sender;
- (IBAction) setRadian:(id)sender;
- (IBAction) setGradient:(id)sender;
- (IBAction) sine:(id)sender;
- (IBAction) cosine:(id)sender;
- (IBAction) tangent:(id)sender;
- (IBAction) arcsine:(id)sender;
- (IBAction) arccosine:(id)sender;
- (IBAction) arctangent:(id)sender;

// Probability functions
- (IBAction) permutation:(id)sender;
- (IBAction) combination:(id)sender;
- (IBAction) randomNum:(id)sender;

// Toggle alternate functions
- (IBAction) toggleAlernates:(id)sender;
- (void) showAlternates;
- (void) hideAlternates;

@end
