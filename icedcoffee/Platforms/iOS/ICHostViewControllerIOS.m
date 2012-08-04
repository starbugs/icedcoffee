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

#import "../../icMacros.h"

#ifdef __IC_PLATFORM_IOS

#import <QuartzCore/QuartzCore.h>

#import "ICHostViewControllerIOS.h"
#import "ICTouchEventDispatcher.h"
#import "ICScene.h"
#import "icGL.h"
#import "ICESRenderer.h"
#import "ICScheduler.h"

@interface ICHostViewControllerIOS (Private)
- (void)threadMainLoop;
- (void)mainLoop:(id)sender;
@end

@implementation ICHostViewControllerIOS

- (id)init
{
    if ((self = [super init])) {
        _touchEventDispatcher = [[ICTouchEventDispatcher alloc] initWithHostViewController:self];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _touchEventDispatcher = [[ICTouchEventDispatcher alloc] initWithHostViewController:self];
    }
    return self;
}

- (void)dealloc
{
    [_touchEventDispatcher release];
    [super dealloc];
}

- (void)viewDidLayoutSubviews
{
    _openGLReady = YES;
    [self reshape:self.view.bounds.size];
    [self startAnimation];
}

- (void)startAnimation
{
    if (_openGLReady && !self.isRunning) {
        _isRunning = YES;
    
        ICLog(@"IcedCoffee: animation started");
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];

        self.thread = [[[NSThread alloc] initWithTarget:self
                                               selector:@selector(threadMainLoop)
                                                 object:nil] autorelease];
        [self.thread start];
    }
}

- (void)stopAnimation
{
    if (self.isRunning) {
        _isRunning = NO;
        
        ICLog(@"IcedCoffee: animation stopped");
        
        [self.thread cancel];
        self.thread = nil;
        
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)threadMainLoop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
	// start the run loop
	[[NSRunLoop currentRunLoop] run];
    
	[pool release];
}

- (void)mainLoop:(id)sender
{
	[self drawScene];
}

- (void)drawScene
{
    [super drawScene];
    
    if (_frameUpdateMode == ICFrameUpdateModeOnDemand && !_needsDisplay) {
        return; // nothing to draw
    }
    
    [self calculateDeltaTime];

	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
    
	ICGLView *openGLview = (ICGLView*)self.view;
/*    if (openGLview.depthFormat && ![openGLview.renderer depthBuffer]) {
        // FIXME: this may lead to issues, e.g. blank screen when we switch from continuous to
        // on demand rendering of the screen FBO!
        return; // depth buffer not ready
    }*/
    
	[EAGLContext setCurrentContext:[openGLview context]];

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE) {
        [[self scheduler] update:_deltaTime];

        glViewport(0, 0,
                   openGLview.bounds.size.width * self.contentScaleFactor,
                   openGLview.bounds.size.height * self.contentScaleFactor);

        // Render final scene
        [self.scene visit];
        
        [openGLview swapBuffers];
    }
}

// point is in UIView's coordinate system
- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback
{
    NSArray *resultNodeStack;
    
	ICGLView *openGLview = (ICGLView*)self.view;
	[EAGLContext setCurrentContext: [openGLview context]];

    resultNodeStack = [self.scene hitTest:point deferredReadback:deferredReadback];
    
    return resultNodeStack;
}

- (void)setContentScaleFactor:(float)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeCurrentHostViewController];
    [_touchEventDispatcher touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeCurrentHostViewController];
    [_touchEventDispatcher touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeCurrentHostViewController];
    [_touchEventDispatcher touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeCurrentHostViewController];
    [_touchEventDispatcher touchesMoved:touches withEvent:event];
}

@end

#endif // __IC_PLATFORM_IOS
