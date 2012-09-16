//  
// Copyright (C) 2012 Tobias Lensing
//  
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//  
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//  
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//  
/* BASED ON:
 *
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ICHostViewController.h"
#import "ICMouseResponder.h"
#import "ICMouseEventDispatcher.h"
#import "ICGLView.h"
#import "icMacros.h"
#import <QuartzCore/CVDisplayLink.h>

#ifdef __IC_PLATFORM_MAC

// See http://developer.apple.com/library/mac/#qa/qa1385/_index.html

/**
 @brief Host view controller for the Mac platform
 
 ICHostViewControllerMac specializes and extends ICHostViewController to implement view management
 for the Mac OS X platform. Each Cocoa view that should display an IcedCoffee scene in your
 application must have a distinct host view controller.
 
 When creating an IcedCoffee-based application or integrating an IcedCoffee-based OpenGL view
 into an existing Cocoa application on the Mac, it is recommended to subclass
 ICHostViewControllerMac in order to implement a specialized view controller for each
 application view that should display an IcedCoffee scene.
 */
@interface ICHostViewControllerMac : ICHostViewController <ICMouseResponder>
{
@protected
    CVDisplayLinkRef _displayLink;
    ICGLView *_view;
    ICMouseEventDispatcher *_mouseEventDispatcher;
    BOOL _usesDisplayLink;
    BOOL _drawsConcurrently;
    BOOL _isThreadOwner;
    NSTimer *_renderTimer;
    icTime _mouseOverStateDeltaTime;
}

@property (nonatomic, retain, getter=view, setter=setView:) IBOutlet ICGLView *view;

@property (nonatomic, assign) BOOL usesDisplayLink;

@property (nonatomic, assign) BOOL drawsConcurrently;

- (void)setAcceptsMouseMovedEvents:(BOOL)acceptsMouseMovedEvents;

- (BOOL)acceptsMouseMovedEvents;

- (void)setUpdatesMouseEnterExitEventsContinuously:(BOOL)updatesMouseEnterExitEventsContinuously;

- (BOOL)updatesMouseEnterExitEventsContinuously;

@end

#endif // __IC_PLATFORM_MAC
