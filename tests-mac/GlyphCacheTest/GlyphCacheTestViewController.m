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

#import "GlyphCacheTestViewController.h"

@implementation GlyphCacheTestViewController

- (void)setUpScene
{
    ICUIScene *scene = [ICUIScene scene];
    
    ICFont *arial = [[ICFont alloc] initWithName:@"Arial Bold" size:50];
    ICFont *monaco = [[ICFont alloc] initWithName:@"Monaco" size:50];

    ICGlyphCache *glyphCache = [ICGlyphCache currentGlyphCache];
    [glyphCache cacheGlyphsWithString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" forFont:arial];
    [glyphCache cacheGlyphsWithString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" forFont:monaco];

    ICGlyphRun *textRun = [[ICGlyphRun glyphRunWithString:@"1234 The quick brown fox jumps over the lazy dog" font:arial] precache];
    [textRun setPositionY:10];
    [scene addChild:textRun];
    
    ICGlyphRun *textRun2 = [[ICGlyphRun glyphRunWithString:@"1234 The quick brown fox jumps over the lazy dog" font:monaco] precache];
    [textRun2 setPositionY:100];
    [scene addChild:textRun2];

    /*ICGlyphTextureAtlas *textureAtlas = [[glyphCache textures] objectAtIndex:0];
    if (textureAtlas.dataDirty)
        [textureAtlas upload];
    ICSprite *sprite = [ICSprite spriteWithTexture:textureAtlas];
    [sprite setBlendFunc:(icBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
    [sprite setShaderProgram:[[ICShaderCache currentShaderCache] shaderProgramForKey:kICShader_PositionTextureA8Color]];
    [sprite setColor:(icColor4B){0,0,0,255}];
    [scene addChild:sprite];*/
    

    [self runWithScene:scene];
}

@end
