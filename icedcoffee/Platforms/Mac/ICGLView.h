/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

// ICGLView for Mac

#import <Cocoa/Cocoa.h>
#import "../../icMacros.h"

#ifdef __IC_PLATFORM_MAC

@class ICHostViewController;
@class ICTextViewHelper;

/**
 @brief Implements an icedcoffee OpenGL view in AppKit
 */
@interface ICGLView : NSOpenGLView <NSUserInterfaceValidations>
{
@private
    ICHostViewController *_hostViewController;
    NSCursor *_cursor;
    ICTextViewHelper *_textViewHelper;
}


@property (nonatomic, retain) ICTextViewHelper *textViewHelper;


#pragma mark - Initializing a View
/** @name Initializing a View */

- (id)initWithFrame:(NSRect)frameRect
       shareContext:(NSOpenGLContext*)shareContext
 hostViewController:(ICHostViewController *)hostViewController;


#pragma mark - Working with the View
/** @name Working with the View */

@property (nonatomic, assign, getter=hostViewController, setter=setHostViewController:)
    IBOutlet ICHostViewController *hostViewController;

- (void)setCursor:(NSCursor *)cursor;

@end

#endif // __IC_PLATFORM_MAC
