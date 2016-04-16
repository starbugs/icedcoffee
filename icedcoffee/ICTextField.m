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

#import "ICTextField.h"
#import "ICTextFrame.h"
#import "ICTextLine.h"
#import "ICHostViewController.h"
#import "ICGLView.h"
#import "icUtils.h"

#ifdef __IC_PLATFORM_MAC

@interface ICLabel ()
@property (nonatomic, retain) ICTextFrame *textFrame;
@end

@interface ICTextField ()
@property (nonatomic, retain) ICLabel *textLabel;
- (void)updateTextLabelWithTextViewHelperStorage;
- (void)interpretKeyEvent:(ICKeyEvent *)keyEvent;
@end

@implementation ICTextField

@synthesize textLabel = _textLabel;

- (id)initWithSize:(kmVec3)size
{
    if ((self = [super initWithSize:size])) {
        self.textLabel = [ICLabel labelWithSize:size];
        self.textLabel.userInteractionEnabled = NO;
        [self addChild:self.textLabel];
        
        _caretIndex = 0;
        _caret = [[ICCaret alloc] init];
        [self addChild:_caret];
    }
    return self;
}

- (void)dealloc
{
    [_caret release];
    self.textLabel = nil;
    [super dealloc];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.textLabel.attributedText = attributedText;
}

- (NSAttributedString *)attributedText
{
    return self.textLabel.attributedText;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

- (NSString *)text
{
    return self.textLabel.text;
}

- (void)setFont:(ICFont *)font
{
    self.textLabel.font = font;
}

- (ICFont *)font
{
    return self.textLabel.font;
}

- (void)setColor:(icColor4B)color
{
    self.textLabel.color = color;
}

- (icColor4B)color
{
    return self.textLabel.color;
}

- (void)setGamma:(float)gamma
{
    self.textLabel.gamma = gamma;
}

- (float)gamma
{
    return self.textLabel.gamma;
}

- (void)keyDown:(ICKeyEvent *)keyEvent
{
    unsigned char keyCode = [keyEvent keyCode];
    switch (keyCode) {
        case 36:    // Carriage return
        {
            [self insertAtCaret:@"\n"];
            break;
        }
        case 51:    // Backspace
        {
            [self deleteAtCaret];
            break;
        }
        case 123:   // Left cursor
        {
            if (_caretIndex > 0)
                _caretIndex--;
            break;
        }
        case 124:   // Right cursor
        {
            if (_caretIndex < [self.text length])
                _caretIndex++;
            break;
        }
        case 125:   // Down cursor
        {
            ICTextLine *line = nil, *nextLine = nil;
            [self.textLabel.textFrame offsetForStringIndex:_caretIndex line:&line];
            NSInteger lineIndex = [self.textLabel.textFrame.lines indexOfObject:line];
            NSUInteger linesCount = [self.textLabel.textFrame.lines count];
            if (linesCount > 1 && lineIndex < linesCount - 1) {
                // Cursor will move down within existing lines
                nextLine = [self.textLabel.textFrame.lines objectAtIndex:lineIndex+1];
                _caretIndex = [self.textLabel.textFrame stringIndexForHorizontalOffset:_caret.position.x inLine:nextLine];
                if (_caretIndex == nextLine.stringRange.location + nextLine.stringRange.length && [self.textLabel.textFrame lineEndsWithLineBreak:nextLine]) {
                    _caretIndex--;
                }
            } else {
                // Cursor will move down behind existing lines
                _caretIndex = [self.text length];
            }
            break;
        }
        case 126:   // Up cursor
        {
            ICTextLine *line = nil, *prevLine = nil;
            [self.textLabel.textFrame offsetForStringIndex:_caretIndex line:&line];
            if (line) {
                NSInteger lineIndex = [self.textLabel.textFrame.lines indexOfObject:line];
                if (lineIndex > 0 && [self.textLabel.textFrame.lines count] > 1) {
                    prevLine = [self.textLabel.textFrame.lines objectAtIndex:lineIndex-1];
                    _caretIndex = [self.textLabel.textFrame stringIndexForHorizontalOffset:_caret.position.x inLine:prevLine];
                    if (_caretIndex > prevLine.stringRange.location && [[prevLine.string substringFromIndex:_caretIndex-1-prevLine.stringRange.location] isEqualToString:@"\n"]) {
                        _caretIndex--;
                    }
                }
            } else {
                // Move up from past end of last line
                _caretIndex--;
            }
            break;
        }
        default:
        {
            [self interpretKeyEvent:keyEvent];
            break;
        }
    }
    
    ICTextLine *line = nil;
    kmVec2 offset = [self.textLabel.textFrame offsetForStringIndex:_caretIndex line:&line];
    _caret.position = kmVec3Make(offset.x, offset.y, 0);
    if (line) {
        _caret.size = kmVec3Make(0, line.ascent + line.descent, 0);
    }
}

- (void)keyUp:(ICKeyEvent *)keyEvent
{
    
}

- (BOOL)becomeFirstResponder
{
    NSTextView *textViewHelper = self.hostViewController.view.textViewHelper;
    [[textViewHelper textStorage] replaceCharactersInRange:NSMakeRange(0, [[textViewHelper textStorage] length]) withAttributedString:self.attributedText];
    return [super becomeFirstResponder];
}

- (void)mouseDown:(ICMouseEvent *)event
{
    ICTextLine *line = nil;
    kmVec3 location = [event locationInNode:self];
    _caretIndex = [self.textLabel.textFrame stringIndexForPosition:kmVec2Make(location.x, location.y)];
    kmVec2 offset = [self.textLabel.textFrame offsetForStringIndex:_caretIndex line:&line];
    _caret.position = kmVec3Make(offset.x, offset.y, 0);
    _caret.size = kmVec3Make(0, line.ascent + line.descent, 0);

    NSTextView *textViewHelper = self.hostViewController.view.textViewHelper;
    [textViewHelper setSelectedRange:NSMakeRange(_caretIndex, 0)];
}

- (void)updateTextLabelWithTextViewHelperStorage
{
    NSTextStorage *textStorage = [self.hostViewController.view.textViewHelper textStorage];
    NSLog(@"%@", [textStorage string]);
    self.textLabel.attributedText = textStorage;
}

- (void)interpretKeyEvent:(ICKeyEvent *)keyEvent
{
    // Looks as if Apple's text input construct wants to be run on the main thread only for some reason
    icRunOnMainQueueWithoutDeadlocking(^{
        [self.hostViewController.view.textViewHelper interpretKeyEvents:@[[keyEvent nativeEvent]]];
    });
    [self insertAtCaret:[keyEvent characters]];
}

- (void)insertAtCaret:(NSString *)characters
{
    NSString *before = [self.text substringWithRange:NSMakeRange(0, _caretIndex)];
    NSString *after = [self.text substringWithRange:NSMakeRange(_caretIndex, [self.text length] - _caretIndex)];
    self.text = [[before stringByAppendingString:characters] stringByAppendingString:after];
    _caretIndex += [characters length];
}

- (void)deleteAtCaret
{
    if (_caretIndex > 0) {
        NSString *before = [self.text substringWithRange:NSMakeRange(0, _caretIndex-1)];
        NSString *after = [self.text substringWithRange:NSMakeRange(_caretIndex, [self.text length] - _caretIndex)];
        self.text = [before stringByAppendingString:after];
        _caretIndex--;
    }
}

/*
- (void)keyDown:(ICKeyEvent *)keyEvent
{
    if ([[keyEvent characters] length]) {
        unichar character = [[keyEvent characters] characterAtIndex:0];
        switch (character) {
            case NSDeleteCharacter: {
                NSInteger newLength = [self.textLabel.text length] - 1;
                if (newLength >= 0)
                    self.textLabel.text = [self.textLabel.text substringWithRange:NSMakeRange(0, newLength)];
                break;
            }
            default: {
                self.textLabel.text = [self.textLabel.text stringByAppendingString:[keyEvent characters]];
                break;
            }
        }
    }
}

- (void)keyUp:(ICKeyEvent *)keyEvent
{
    
}*/

@end

#endif
