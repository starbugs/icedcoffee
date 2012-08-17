//  
//  Copyright (C) 2012 Tobias Lensing, Marcus Tillmanns
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

#import "ICView.h"
#import "icMacros.h"

#ifdef __IC_PLATFORM_MAC
@class ICOSXEvent;

enum {
    ICControlEventLeftMouseDown             = 1 << 0,
    ICControlEventLeftMouseDownRepeat       = 1 << 1,
    ICControlEventLeftMouseDragInside       = 1 << 2,
    ICControlEventLeftMouseDragOutside      = 1 << 3,
    ICControlEventLeftMouseDragEnter        = 1 << 4,
    ICControlEventLeftMouseDragExit         = 1 << 5,
    ICControlEventLeftMouseUpInside         = 1 << 6,
    ICControlEventLeftMouseUpOutside        = 1 << 7,

    ICControlEventRightMouseDown            = 1 << 8,
    ICControlEventRightMouseDownRepeat      = 1 << 9,
    ICControlEventRightMouseDragInside      = 1 << 10,
    ICControlEventRightMouseDragOutside     = 1 << 11,
    ICControlEventRightMouseDragEnter       = 1 << 12,
    ICControlEventRightMouseDragExit        = 1 << 13,
    ICControlEventRightMouseUpInside        = 1 << 14,
    ICControlEventRightMouseUpOutside       = 1 << 15,

    ICControlEventOtherMouseDown            = 1 << 16,
    ICControlEventOtherMouseDownRepeat      = 1 << 17,
    ICControlEventOtherMouseDragInside      = 1 << 18,
    ICControlEventOtherMouseDragOutside     = 1 << 19,
    ICControlEventOtherMouseDragEnter       = 1 << 20,
    ICControlEventOtherMouseDragExit        = 1 << 21,
    ICControlEventOtherMouseUpInside        = 1 << 22,
    ICControlEventOtherMouseUpOutside       = 1 << 23,

    ICControlEventValueChanged              = 1 << 24,
    
    ICControlEventEditingDidBegin           = 1 << 25,
    ICControlEventEditingChanged            = 1 << 26,
    ICControlEventEditingDidEnd             = 1 << 27,
    ICControlEventEditingDidEndOnExit       = 1 << 28,

    ICControlEventAllMouseEvents            = 0x00FFFFFF,
    ICControlEventAllEvents                 = 0xFFFFFFFF
};
#define ICControlEventAllMouseEvents            0x00FFFFFF
#endif

// FIXME: touch control events not implemented yet
#ifdef __IC_PLATFORM_IOS
@class ICTouchEvent;

enum {
    ICControlEventTouchDown                 = 1 << 0,
    ICControlEventTouchDownRepeat           = 1 << 1,
    ICControlEventTouchDragInside           = 1 << 2,
    ICControlEventTouchDragOutside          = 1 << 3,
    ICControlEventTouchDragEnter            = 1 << 4,
    ICControlEventTouchDragExit             = 1 << 5,
    ICControlEventTouchUpInside             = 1 << 6,
    ICControlEventTouchUpOutside            = 1 << 7,
    ICControlEventTouchCancel               = 1 << 8,

    ICControlEventValueChanged              = 1 << 24,

    ICControlEventEditingDidBegin           = 1 << 25,
    ICControlEventEditingChanged            = 1 << 26,
    ICControlEventEditingDidEnd             = 1 << 27,
    ICControlEventEditingDidEndOnExit       = 1 << 28,

    ICControlEventAllTouchEvents            = 0x00000FFF,
    ICControlEventAllEvents                 = 0xFFFFFFFF
};
#endif
    
typedef NSUInteger ICControlEvents;

enum {
    ICControlStateNormal            = 0,
    ICControlStatePressed           = 1 << 0,
    ICControlStateHighlighted       = 1 << 1,
    ICControlStateDisabled          = 1 << 2,
    ICControlStateSelected          = 1 << 3
};
typedef NSUInteger ICControlState;

#ifdef __IC_PLATFORM_MAC
enum {
    ICLeftMouseButton   = 1 << 0,
    ICRightMouseButton  = 1 << 1,
    ICOtherMouseButton  = 1 << 2
};
typedef NSUInteger ICMouseButton;

enum {
    ICAbstractControlEventMouseDown             = 1 << 0,
    ICAbstractControlEventMouseDownRepeat       = 1 << 1,
    ICAbstractControlEventMouseDragInside       = 1 << 2,
    ICAbstractControlEventMouseDragOutside      = 1 << 3,
    ICAbstractControlEventMouseDragEnter        = 1 << 4,
    ICAbstractControlEventMouseDragExit         = 1 << 5,
    ICAbstractControlEventMouseUpInside         = 1 << 6,
    ICAbstractControlEventMouseUpOutside        = 1 << 7,
};
typedef NSUInteger ICAbstractControlEvents;

/**
 @brief Converts from abstract to concrete mouse control event
 */
ICControlEvents ICConcreteControlEvent(ICMouseButton mouseButton,
                                       ICAbstractControlEvents abstractControlEvent);
#endif


@interface ICAction : NSObject {
@protected
    id  _target;
    SEL _action;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

- (id)initWithTarget:(id)target action:(SEL)action;

- (BOOL)isEqual:(id)object;

@end

/**
 @brief Base class for simple user interface controls (buttons, sliders, etc.)
 
 The ICControl class implements the target-action design pattern to connect user interface
 controls with application logic.
 */
@interface ICControl : ICView {
@protected
    NSMutableDictionary *_actions;
    ICControlState _state;
}

- (id)initWithSize:(CGSize)size;

#ifdef __IC_PLATFORM_MAC
- (void)sendAction:(SEL)action to:(id)target forEvent:(ICOSXEvent *)event;
#elif defined(__IC_PLATFORM_IOS)
// FIXME: control event dispatch for iOS is work in progress
- (void)sendAction:(SEL)action to:(id)target forEvent:(ICTouchEvent *)event;
#endif

#ifdef __IC_PLATFORM_MAC
- (void)sendActionsForControlEvent:(ICControlEvents)controlEvent forEvent:(ICOSXEvent *)event;
#elif defined(__IC_PLATFORM_IOS)
// FIXME: control event dispatch for iOS is work in progress
- (void)sendActionsForControlEvent:(ICControlEvents)controlEvent forEvent:(ICTouchEvent *)event;
#endif

- (void)sendActionsForControlEvents:(ICControlEvents)controlEvents;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(ICControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(ICControlEvents)controlEvents;
- (NSArray *)actionsForTarget:(id)target forControlEvent:(ICControlEvents)controlEvent;
- (ICControlEvents)allControlEvents;
- (NSArray *)allTargets;

@property (nonatomic, assign, getter=state, setter=setState:) ICControlState state;
@property (nonatomic, assign, getter=enabled, setter=setEnabled:) BOOL enabled;
@property (nonatomic, assign, getter=selected, setter=setSelected:) BOOL selected;
@property (nonatomic, assign, getter=highlighted, setter=setHighlighted:) BOOL highlighted;


@end
