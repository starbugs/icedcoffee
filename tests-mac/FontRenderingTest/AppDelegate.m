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

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize label = _label;

- (void)dealloc
{
    self.hostViewController = nil;
    
    [super dealloc];
}

- (void)buttonLeftMouseDown:(id)sender
{
    self.label.color = (icColor4B){255,0,255,255};
    ((ICButton *)sender).label.text = @"Mouse Down";
}

- (void)buttonLeftMouseUpInside:(id)sender
{
    self.label.color = (icColor4B){255,255,255,255};
    ((ICButton *)sender).label.text = @"Test Button";
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    [scene setClearColor:(icColor4B){0,0,0,255}];
    [scene setSize:(kmVec3){self.hostViewController.view.bounds.size.width,
                            self.hostViewController.view.bounds.size.height, 0}];
    
    self.label = [ICLabel labelWithText:@"The quick brown fox jumps over the lazy dog"
                               fontName:@"Lucida Grande"
                               fontSize:16];
    [self.label setColor:(icColor4B){255,255,255,255}];
    [scene addChild:self.label];
    
    //[self.label centerNodeOpticallyRounded:YES];
    kmVec3 center = [scene localCenterRounded:YES];
    [self.label setCenterY:center.y];
    
    kmVec3 startCenter = kmVec3Make(-self.label.size.width, 0, 0);
    ICBasicAnimation *animation = [ICBasicAnimation animation];
    animation.keyPath = @"center";
    animation.timingFunction = [ICAnimationTimingFunction easeOutTimingFunction];
    animation.fromValue = [NSValue valueWithBytes:&startCenter objCType:@encode(kmVec3)];
    animation.toValue = [NSValue valueWithBytes:&center objCType:@encode(kmVec3)];
    animation.duration = 2.0;
    [self.label addAnimation:animation];
    
    icColor4B startColor = (icColor4B){255,255,255,255};
    icColor4B endColor = (icColor4B){255,255,255,255};
    ICBasicAnimation *colorAnimation = [ICBasicAnimation animationWithKeyPath:@"color"];
    colorAnimation.fromValue = [NSValue valueWithBytes:&startColor objCType:@encode(icColor4B)];
    colorAnimation.toValue = [NSValue valueWithBytes:&endColor objCType:@encode(icColor4B)];
    colorAnimation.duration = 2.0;
    [self.label addAnimation:colorAnimation];
    
    ICBasicAnimation *rotationAnimation = [ICBasicAnimation animationWithKeyPath:@"rotationAngle"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:M_PI];
    rotationAnimation.toValue = [NSNumber numberWithFloat:0];
    rotationAnimation.duration = 2.0;
    rotationAnimation.timingFunction = [ICAnimationTimingFunction easeOutTimingFunction];
    [self.label addAnimation:rotationAnimation];
    
    kmVec3 startScale = kmVec3Make(20, 20, 1);
    kmVec3 endScale = kmVec3Make(1, 1, 1);
    ICBasicAnimation *scaleAnimation = [ICBasicAnimation animationWithKeyPath:@"scale"];
    scaleAnimation.fromValue = [NSValue valueWithBytes:&startScale objCType:@encode(kmVec3)];
    scaleAnimation.toValue = [NSValue valueWithBytes:&endScale objCType:@encode(kmVec3)];
    scaleAnimation.duration = 2.0;
    scaleAnimation.timingFunction = [ICAnimationTimingFunction easeOutTimingFunction];
    [self.label addAnimation:scaleAnimation];
    
    ICBasicAnimation *trackingAnimation = [ICBasicAnimation animationWithKeyPath:@"tracking"];
    trackingAnimation.fromValue = [NSNumber numberWithFloat:10];
    trackingAnimation.toValue = [NSNumber numberWithFloat:0];
    trackingAnimation.duration = 2.0;
    trackingAnimation.timingFunction = [ICAnimationTimingFunction easeOutTimingFunction];
    [self.label addAnimation:trackingAnimation];
   
    ICButton *button = [[[ICButton alloc] initWithSize:icSizeMake(160, 21)] autorelease];
    [button setPositionY:50];
    button.label.text = @"Test Button";
    [scene addChild:button];
    [button centerNodeHorizontallyRounded:YES];
    
    [button addTarget:self action:@selector(buttonLeftMouseDown:) forControlEvents:ICControlEventLeftMouseDown];
    [button addTarget:self action:@selector(buttonLeftMouseUpInside:) forControlEvents:ICControlEventLeftMouseUpInside];
    
    ICTextField *textField = [[[ICTextField alloc] initWithSize:icSizeMake(200, 200)] autorelease];
    [textField setFont:[ICFont fontWithName:@"Arial" size:13]];
    [textField setPositionY:300];
    [textField setText:@"Text field\nTest\nwith multiple lines"];
    [textField setColor:(icColor4B){255,255,255,255}];
    [scene addChild:textField];
    [textField centerNodeHorizontallyRounded:YES];

    /*ICTextField *textField2 = [[[ICTextField alloc] initWithSize:icSizeMake(200, 100)] autorelease];
    [textField2 setPositionY:330];
    [textField2 setText:@"Text field"];
    [textField2 setColor:(icColor4B){255,255,255,255}];
    [scene addChild:textField2];
    [textField2 centerNodeHorizontallyRounded:YES];*/

    [self.hostViewController runWithScene:scene];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    self.hostViewController.frameUpdateMode = ICFrameUpdateModeOnDemand;
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:YES];

    [self.hostViewController enableRetinaDisplaySupport:YES];

    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setUpScene];
}

@end
