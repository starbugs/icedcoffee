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

#import "ICTargetActionDispatcher.h"
#import "ICControl.h"
#import "icMacros.h"

@implementation ICTargetActionDispatcher

- (void)dispatchActionWithActionDictionary:(NSDictionary *)actionDict
{
    id sender = [actionDict objectForKey:@"sender"];
    ICAction *action = [actionDict objectForKey:@"action"];
    
#ifdef __IC_PLATFORM_MAC
    ICOSXEvent *event;
#elif defined(__IC_PLATFORM_IOS)
    UIEvent *event;
#endif
    
    event = [actionDict objectForKey:@"event"];
    
    if (action.target && [action.target respondsToSelector:action.action]) {
        // Target responds to action selector, get signature of the selector implemented by target
        NSMethodSignature *signature = [action.target methodSignatureForSelector:action.action];
        if (signature) {
            // Valid action message signatures are:
            //  * (void)performAction;
            //  * (void)performAction:(id)sender;
            //  * (void)performAction:(id)sender forEvent:(ICOSXEvent *)event;
            NSUInteger numberOfArguments = [signature numberOfArguments];
            switch (numberOfArguments) {
                case 2:
                    [action.target performSelector:action.action];
                    break;
                case 3:
                    [action.target performSelector:action.action withObject:sender];
                    break;
                case 4:
                    [action.target performSelector:action.action withObject:sender withObject:event];
                    break;
            };
        } else {
            NSAssert(nil, @"Signature was nil, but target responds to action selector.");
        }
    }   
}

@end
