/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

//
// Common layer for NS (Next-Step) stuff
//

#import <Availability.h>

#import <Foundation/Foundation.h> //	for NSObject

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#define ICRectFromString(__r__)		CGRectFromString(__r__)
#define ICPointFromString(__p__)	CGPointFromString(__p__)
#define ICSizeFromString(__s__)		CGSizeFromString(__s__)
#define ICNSSizeToCGSize
#define ICNSRectToCGRect
#define ICNSPointToCGPoint
#define ICTextAlignment				UITextAlignment
#define ICTextAlignmentCenter		UITextAlignmentCenter
#define ICTextAlignmentLeft			UITextAlignmentLeft
#define ICTextAlignmentRight		UITextAlignmentRight
#define ICEvent                     UIEvent


#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#define ICRectFromString(__r__)		NSRectToCGRect( NSRectFromString(__r__) )
#define ICPointFromString(__p__)	NSPointToCGPoint( NSPointFromString(__p__) )
#define ICSizeFromString(__s__)		NSSizeToCGSize( NSSizeFromString(__s__) )
#define ICNSSizeToCGSize			NSSizeToCGSize
#define ICNSRectToCGRect			NSRectToCGRect
#define ICNSPointToCGPoint			NSPointToCGPoint
#define ICTextAlignment				NSTextAlignment
#define ICTextAlignmentCenter		NSCenterTextAlignment
#define ICTextAlignmentLeft			NSLeftTextAlignment
#define ICTextAlignmentRight		NSRightTextAlignment
#define ICEvent                     NSEvent

#endif


