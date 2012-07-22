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

#import "ICTableViewCell.h"
#import "ICSprite.h"
#import "ICLabel.h"

@implementation ICTableViewCell

@synthesize identifier = _identifier;
@synthesize label = _label;
@synthesize selected = _selected;

+ (id)cellWithIdentifier:(NSString *)identifier
{
    return [[[[self class] alloc] initWithIdentifier:identifier] autorelease];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    if ((self = [self initWithSize:CGSizeMake(100, 30)])) {
        _identifier = [identifier copy];
    }
    return self;
}

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        // Set up label
        self.label = [ICLabel labelWithText:@"" fontName:@"Lucida Grande" fontSize:12];
        self.label.color = (icColor4B){0,0,0,255};
        [self addChild:self.label];
    }
    return self;
}

- (void)dealloc
{
    self.label = nil;
    self.background = nil;
    [_identifier release];
    [super dealloc];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
    
    [self.label centerNodeVertically];    
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        if (_selected) {
            self.background.color = (icColor4B){0,50,170,255};
            self.label.color = (icColor4B){255,255,255,255};
        } else {
            self.background.color = (icColor4B){255,255,0,255};
            self.label.color = (icColor4B){0,0,0,255};
        }
        [self setNeedsDisplay];
    }
}

@end
