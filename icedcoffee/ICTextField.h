//
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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

#import "ICControl.h"
#import "ICLabel.h"
#import "ICCaret.h"

// Work in progress - Mac only currently

#ifdef __IC_PLATFORM_MAC

@interface ICTextField : ICControl {
@protected
    ICLabel *_textLabel;
    ICCaret *_caret;
    NSInteger _caretIndex;
}

@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, retain) ICFont *font;

@property (nonatomic, assign) icColor4B color;

@property (nonatomic, assign) float gamma;

- (void)keyDown:(ICKeyEvent *)keyEvent;

- (void)keyUp:(ICKeyEvent *)keyEvent;

@end

#endif

