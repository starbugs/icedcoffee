//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
//  http://icedcoffee-framework.org
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
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

#import "ICHostViewController.h"
#import "icDefaults.h"

@class ICScene;
@class ICUIScene;
@class ICLabel;
@class ICTestButtonPanel;

/**
 @brief Host view controller for icedcoffee test applications
 
 The ICTestHostViewController class defines a host view controller for icedcoffee test applications
 for both iOS and Mac OS X. It provides a user interface for running a sequence of multiple test
 scenes along with the required methods and properties to manage these scenes. An icedcoffee test
 application should subclass ICTestHostViewController and override ICHostViewController::setUpScene
 in order to set up test scenes. Test scenes are finally added to the controller using the
 ICTestHostViewController::addTestScene: method.
 */
@interface ICTestHostViewController : IC_HOSTVIEWCONTROLLER {
@protected
    NSMutableArray *_testScenes;
    NSMutableDictionary *_hints;
    ICScene *_currentTestScene;
    ICUIScene *_testHostScene;
    ICTestButtonPanel *_buttonPanel;
    ICLabel *_fpsLabel;
}

/**
 @brief The receiver's test scenes
 */
@property (nonatomic, readonly) NSArray *testScenes;

/**
 @brief The test scene currently presented by the receiver
 */
@property (nonatomic, retain, setter=setCurrentTestScene:) ICScene *currentTestScene;

/**
 @brief The receiver's host scene providing an interface for the user to cycle through tests
 */
@property (nonatomic, readonly) ICUIScene *testHostScene;

/**
 @brief Adds the given test scene to the receiver
 */
- (void)addTestScene:(ICScene *)scene withHint:(NSString *)hint;

/**
 @brief Removes the given test scene from the receiver
 */
- (void)removeTestScene:(ICScene *)scene;

@end
