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

/*
 * Idea of subclassing NSOpenGLView was taken from  "TextureUpload" Apple's sample
 */

#import "icMacros.h"


#ifdef __IC_PLATFORM_MAC

#import "ICGLView.h"
#import "ICHostViewController.h"
#import "ICTextViewHelper.h"
#import "ICNode.h"
#import "ICUserInterfaceValidations.h"

// NSLog(@"event: %@", [event description]); \

#define DISPATCH_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        [self.hostViewController performSelector:@selector(eventMethod:) \
                                        onThread:self.hostViewController.thread \
                                      withObject:event \
                                   waitUntilDone:NO \
                                           modes:@[NSDefaultRunLoopMode]]; \
    }


@implementation ICGLView

@synthesize hostViewController = _hostViewController;
@synthesize textViewHelper = _textViewHelper;

// Used to initialize the view when instantiated from nib
- (id)initWithFrame:(NSRect)frameRect
{
	return [self initWithFrame:frameRect shareContext:nil hostViewController:nil];
}

- (id)initWithFrame:(NSRect)frameRect
       shareContext:(NSOpenGLContext*)shareContext
 hostViewController:(ICHostViewController *)hostViewController
{    
    // FIXME: make this configurable?
    NSOpenGLPixelFormatAttribute attribs[] =
    {
		NSOpenGLPFAAccelerated,
		//NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAStencilSize, 8,
        // https://developer.apple.com/library/mac/qa/qa1734/_index.html
        // https://developer.apple.com/library/mac/technotes/tn2229/_index.html
        NSOpenGLPFAAllowOfflineRenderers, // needed for running on integrated GPU on Macs with multiple GPUs
		0
    };
    
	NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    
	if (!pixelFormat)
		NSLog(@"No OpenGL pixel format");
    
	if ((self = [super initWithFrame:frameRect pixelFormat:[pixelFormat autorelease]])) {
//        [self.hostViewController reshape:self.bounds.size];
        
        [self setAcceptsTouchEvents:YES];
        
        [self setWantsBestResolutionOpenGLSurface:hostViewController.retinaDisplaySupportEnabled];
        
		if (shareContext) {
            NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat
                                                                  shareContext:shareContext];
			[self setOpenGLContext:context];
            [context setView:self];
            [context release];
        }
        
		// Synchronize buffer swaps with vertical refresh rate (vsync)
		GLint swapInt = 1;
		[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
        
        // Set up pixel alignment
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        //glPixelStorei(GL_PACK_ALIGNMENT, 1);

        if (hostViewController)
            self.hostViewController = hostViewController;
        
        //		GLint order = -1;
        //		[[self openGLContext] setValues:&order forParameter:NSOpenGLCPSurfaceOrder];
        
        self.textViewHelper = [[[ICTextViewHelper alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
	}
    
	return self;
}

- (void)dealloc
{
    [_hostViewController release];
    
    [_textViewHelper release];
    
    [super dealloc];
}

- (void)setHostViewController:(ICHostViewController *)hostViewController
{
    _hostViewController = hostViewController;
    [_hostViewController setView:self];
    // Issue 3: Interface Builder integration
    // Call -viewDidLoad on the host view controller (old style view instantiation and wiring)
    [_hostViewController viewDidLoad];
}

- (void)reshape
{
    NSOpenGLContext *openGLContext = [self openGLContext];
    [[self openGLContext] update];
    
    NSAssert(openGLContext, @"openGLContext must not be nil");
    
    if (openGLContext) {
        // We draw on a secondary thread through the display link
        // When resizing the view, -reshape is called automatically on the main thread
        // Add a mutex around to avoid the threads accessing the context simultaneously when resizing
        CGLLockContext([openGLContext CGLContextObj]);
        
        // Add an autorelease pool to avoid concurrent deallocation of autoreleased objects
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [self.hostViewController reshape:self.bounds.size];
        
        // avoid flicker
        /*if (!self.hostViewController.willPerformDisplayUpdate) {
            //NSLog(@"Draw due to reshape");
            [self.hostViewController drawScene];
        }*/
        [self.hostViewController drawScene];
        //[self setNeedsDisplay:YES];
        
        [pool release];
                
        CGLUnlockContext([openGLContext CGLContextObj]);
    }
}


// Event handling

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [ICGLView instanceMethodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [[_hostViewController.currentFirstResponder class] methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_hostViewController.currentFirstResponder respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_hostViewController.currentFirstResponder];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    return [_hostViewController.currentFirstResponder respondsToSelector:aSelector];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    if ([_hostViewController.currentFirstResponder respondsToSelector:@selector(validateUserInterfaceItem:)]) {
        id <ICUserInterfaceValidations> firstResponder = (id <ICUserInterfaceValidations>)_hostViewController.currentFirstResponder;
        return [firstResponder validateUserInterfaceItem:(id <ICValidatedUserInterfaceItem>)anItem];
    }
    
    return YES;
}

DISPATCH_EVENT(mouseDown)
DISPATCH_EVENT(mouseUp)
DISPATCH_EVENT(mouseDragged)
DISPATCH_EVENT(mouseMoved)

DISPATCH_EVENT(rightMouseDown)
DISPATCH_EVENT(rightMouseUp)
DISPATCH_EVENT(rightMouseDragged)

DISPATCH_EVENT(otherMouseDown)
DISPATCH_EVENT(otherMouseUp)
DISPATCH_EVENT(otherMouseDragged)

DISPATCH_EVENT(scrollWheel)
DISPATCH_EVENT(touchesBeganWithEvent)
DISPATCH_EVENT(touchesMovedWithEvent)
DISPATCH_EVENT(touchesEndedWithEvent)
DISPATCH_EVENT(touchesCancelledWithEvent)

DISPATCH_EVENT(keyDown)
DISPATCH_EVENT(keyUp)

- (void)setCursor:(NSCursor *)cursor
{
    [self.window invalidateCursorRectsForView:self];
    [_cursor release];
    _cursor = [cursor retain];
}

- (void)resetCursorRects
{
    if (_cursor)
        [self addCursorRect:self.bounds cursor:_cursor];
}

@end

#endif // __IC_PLATFORM_MAC
