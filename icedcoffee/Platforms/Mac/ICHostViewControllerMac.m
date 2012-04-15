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

#import "ICHostViewControllerMac.h"
#import "ICScene.h"
#import "ICRenderTexture.h"
#import "icGL.h"


#define DISPATCH_MOUSE_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event { \
        [_mouseEventDispatcher eventMethod:event]; \
    }


@interface ICHostViewControllerMac (Private)
- (void)setIsRunning:(BOOL)isRunning;
- (void)setViewSize:(CGSize)viewSize;
@end


@implementation ICHostViewControllerMac

@synthesize view = _view;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Lifecycle
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

- (id)init
{
    if ((self = [super init])) {
        _mouseEventDispatcher = [[ICMouseEventDispatcher alloc] initWithHostViewController:self];
    }
    return self;
}

- (void)dealloc
{
    [self stopAnimation];
    [_mouseEventDispatcher release];

    [super dealloc];
}


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Animation and Drawing
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
	if (!_thread)
		_thread = [NSThread currentThread];
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self drawScene];
    
	// Process timers and other events
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
    
	[pool release];
        
    return kCVReturnSuccess;
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,
                                      const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn,
                                      CVOptionFlags* flagsOut,
                                      void* displayLinkContext)
{
    CVReturn result = [(ICHostViewControllerMac *)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void)startAnimation
{
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, self);
    
    // Set the display link for the current renderer
    ICGLView *openGLview = (ICGLView*) self.view;
    CGLContextObj cglContext = [[openGLview openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[openGLview pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);    
}

- (void)stopAnimation
{
    if (_displayLink) {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
        _displayLink = NULL;
    }
}

- (void)drawScene
{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
    
	ICGLView *openGLview = (ICGLView*)self.view;
	CGLLockContext([[openGLview openGLContext] CGLContextObj]);
	[[openGLview openGLContext] makeCurrentContext];
    
	glViewport(0, 0,
               openGLview.bounds.size.width * self.contentScaleFactor,
               openGLview.bounds.size.height * self.contentScaleFactor);
    
    // Render final scene
    [self.scene visit];
	[[openGLview openGLContext] flushBuffer];

    if ([NSThread currentThread] == self.thread) {
        // Let mouse event dispatcher update state for mouseEntered/mouseExited events
        [_mouseEventDispatcher updateMouseOverState];
    }
    
	CGLUnlockContext([[openGLview openGLContext] CGLContextObj]);    
}

- (NSArray *)hitTest:(CGPoint)point
{
    NSArray *resultNodeStack;
    
	ICGLView *openGLview = (ICGLView*)self.view;
	CGLLockContext([[openGLview openGLContext] CGLContextObj]);
	[[openGLview openGLContext] makeCurrentContext];

	glViewport(0, 0,
               openGLview.bounds.size.width * self.contentScaleFactor,
               openGLview.bounds.size.height * self.contentScaleFactor);
    
    resultNodeStack = [self.scene hitTest:point];
    
	CGLUnlockContext([[openGLview openGLContext] CGLContextObj]);
    
    return resultNodeStack;
}

- (void)setAcceptsMouseMovedEvents:(BOOL)acceptsMouseMovedEvents
{
    _mouseEventDispatcher.acceptsMouseMovedEvents = acceptsMouseMovedEvents;
}

- (BOOL)acceptsMouseMovedEvents
{
    return _mouseEventDispatcher.acceptsMouseMovedEvents;
}

- (void)setView:(ICGLView *)view
{
    [_view release];
    _view = [view retain];
    
    [super setView:view];
}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// ICMouseResponder Protocol Implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

DISPATCH_MOUSE_EVENT(mouseDown)
DISPATCH_MOUSE_EVENT(mouseDragged)
DISPATCH_MOUSE_EVENT(mouseEntered)
DISPATCH_MOUSE_EVENT(mouseExited)
DISPATCH_MOUSE_EVENT(mouseMoved)
DISPATCH_MOUSE_EVENT(mouseUp)

DISPATCH_MOUSE_EVENT(rightMouseDown)
DISPATCH_MOUSE_EVENT(rightMouseDragged)
DISPATCH_MOUSE_EVENT(rightMouseUp)

DISPATCH_MOUSE_EVENT(otherMouseDown)
DISPATCH_MOUSE_EVENT(otherMouseDragged)
DISPATCH_MOUSE_EVENT(otherMouseUp)

DISPATCH_MOUSE_EVENT(scrollWheel)

@end
