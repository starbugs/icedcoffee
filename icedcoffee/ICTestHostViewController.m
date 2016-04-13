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

#import "ICTestHostViewController.h"
#import "ICUIScene.h"
#import "ICButton.h"
#import "ICTestButtonPanel.h"

#ifdef __IC_PLATFORM_MAC
#define BUTTON_CONTROL_EVENT ICControlEventLeftMouseUpInside
#elif defined(__IC_PLATFORM_IOS)
#define BUTTON_CONTROL_EVENT ICControlEventTouchUpInside
#endif

@implementation ICTestHostViewController

@synthesize testScenes = _testScenes;
@synthesize currentTestScene = _currentTestScene;
@synthesize testHostScene = _testHostScene;

- (void)addTestScene:(ICScene *)scene withHint:(NSString *)hint
{
    [_testScenes addObject:scene];
    if ([_testScenes count] == 1)
        self.currentTestScene = scene;
    if (hint)
        [_hints setObject:hint forKey:[NSValue valueWithPointer:scene]];
    [self updateStatusLabel];
}

- (void)removeTestScene:(ICScene *)scene
{
    [_testScenes removeObject:scene];
    if ([_testScenes count] == 0)
        self.currentTestScene = nil;
    [self updateStatusLabel];
}

- (id)init
{
    if ((self = [super init])) {
        _testScenes = [[NSMutableArray alloc] initWithCapacity:1];
        _hints = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"fps"];
    
    [_buttonPanel release];
    [_testScenes release];
    [_hints release];
    
    [super dealloc];
}

- (void)updateStatusLabel
{
    NSUInteger sceneIndex = [_testScenes indexOfObject:_currentTestScene] + 1;
    NSUInteger sceneCount = [_testScenes count];
    NSString *name = _currentTestScene.name ? _currentTestScene.name : @"Untitled";
    _buttonPanel.statusLabel.text = [NSString stringWithFormat:@"Test %ld/%ld: %@",
                                     sceneIndex, sceneCount, name];
    NSString *hint = [_hints objectForKey:[NSValue valueWithPointer:_currentTestScene]];
    if (hint)
        _buttonPanel.hintLabel.text = hint;
    else
        _buttonPanel.hintLabel.text = @"Author did not provide hints";
}

- (void)setCurrentTestScene:(ICScene *)currentTestScene
{
    [self.testHostScene.contentView removeChild:_currentTestScene];
    [_currentTestScene release];
    _currentTestScene = [currentTestScene retain];
    [self.testHostScene.contentView addChild:_currentTestScene];
    [_currentTestScene orderBack];

    [self updateStatusLabel];
}

- (void)showNextScene
{
    if ([_testScenes count]) {
        int currentSceneIndex = (int)[_testScenes indexOfObject:_currentTestScene];
        if (currentSceneIndex + 1 < [_testScenes count])
            self.currentTestScene = [_testScenes objectAtIndex:currentSceneIndex+1];
        else
            self.currentTestScene = [_testScenes objectAtIndex:0];
    }
}

- (void)showPreviousScene
{
    if ([_testScenes count]) {
        int currentSceneIndex = (int)[_testScenes indexOfObject:_currentTestScene];
        if (currentSceneIndex - 1 < 0)
            self.currentTestScene = [_testScenes lastObject];
        else
            self.currentTestScene = [_testScenes objectAtIndex:currentSceneIndex-1];
    }
}

- (void)setUpScene
{
    _testHostScene = [ICUIScene scene];
    
    // This is required to automatically resize the scene to the host view's size
    self.scene = _testHostScene;
    self.scene.hostViewController = self;
    
    _fpsLabel = [[ICLabel alloc] initWithText:@"FPS: --.--"];
    _fpsLabel.autoresizesToTextSize = YES;
    _fpsLabel.position = kmVec3Make(10, 10, 0);
    [_testHostScene.contentView addChild:_fpsLabel];
    [self addObserver:self forKeyPath:@"fps" options:NSKeyValueObservingOptionNew context:nil];
    
    _buttonPanel = [[ICTestButtonPanel alloc] initWithSize:kmVec3Make(_testHostScene.size.width, 50, 0)];
    _buttonPanel.autoresizingMask = ICAutoResizingMaskWidthSizable | ICAutoResizingMaskTopMarginFlexible;
    [_buttonPanel setPositionY:_testHostScene.size.height - _buttonPanel.size.height];
    [_testHostScene.contentView addChild:_buttonPanel];

    [_buttonPanel.previousSceneButton addTarget:self
                                         action:@selector(showPreviousScene)
                               forControlEvents:BUTTON_CONTROL_EVENT];
    [_buttonPanel.nextSceneButton addTarget:self
                                     action:@selector(showNextScene)
                           forControlEvents:BUTTON_CONTROL_EVENT];

    [self runWithScene:_testHostScene]; // retained by super in self.scene
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"fps"]) {
        _fpsLabel.text = [NSString stringWithFormat:@"FPS: %0.02f", self.fps];
    }
}

@end
