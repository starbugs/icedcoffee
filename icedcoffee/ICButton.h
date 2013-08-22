//  
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
//  http://icedcoffee-framework.org
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, disttribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "ICControl.h"
#import "ICLabel.h"

/**
 @brief Represents a button control

 <h3>Overview</h3>
 
 The ICButton class defines a flexible button control comprised of a background view and a title
 label. The class allows you to define different custom backgrounds for each control state (normal,
 pressed, disabled, highlighted, selected). By default, ICButton uses a built-in shader based
 rounded rectangle view to draw its background.
 
 <h3>Setup</h3>
 
 You initialize a new button using the ICButton::initWithSize: method. Alternatevily, you may use
 the ICButton::buttonWithSize: convenience method, which returns a new autoreleased button.
 After initializing a button, you will most likely want to set its title. The following example
 code illustrates how to create a button with a custom title:
 
 @code
 // Create a new autoreleased ICButtton object
 ICButton *myButton = [ICButton buttonWithSize:kmVec2Make(160,21,0)];
 // Set the title of the button to some custom string
 myButton.label.text = @"My Button Title";
 // Add the button to our scene (assuming that scene is a valid ICScene object)
 [scene addChild:myButton];
 @endcode
  */
@interface ICButton : ICControl {
@protected
    ICLabel *_label;

    NSMutableDictionary *_activeBackgrounds;
    NSMutableDictionary *_backgroundsByControlState;
    
    BOOL _mixesBackgroundStates;
    
@private
    BOOL _mouseButtonPressed;
}

#pragma mark - Creating a Button
/** @name Creating a Button */

+ (id)buttonWithSize:(kmVec3)size;


#pragma mark - Changing the Button's Label
/** @name Changing the Button's Label */

/**
 @brief Defines the button label
 */
@property (nonatomic, retain, setter=setLabel:) ICLabel *label;


#pragma mark - Changing the Button's Background
/** @name Changing the Button's Background */

/**
 @brief Sets a background view for the given control state
 */
- (void)setBackground:(ICView *)background forState:(ICControlState)state;

/**
 @brief Removes the background view for the given control state
 */
- (void)removeBackgroundForState:(ICControlState)state;

/**
 @brief Returns the background view for the specified state
 */
- (ICView *)backgroundForState:(ICControlState)state;

/**
 @brief A boolean flag indicating whether backgrounds for certain states should be mixed
 
 If set to <code>YES</code>, ICButton will draw highlighted and selected background views on top
 of normal, disabled or pressed backgrounds. Otherwise, background states are treated in a
 mutually exclusive manner, meaning that only one background will be drawn at a time.
 The default value for this property is <code>YES</code>.
 */
@property (nonatomic, assign) BOOL mixesBackgroundStates;

@end
