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
    
    ICFont *arial = [ICFont fontWithName:@"Arial Bold" size:13];
    ICFont *georgia = [ICFont fontWithName:@"Georgia" size:12];
    ICFont *monaco = [ICFont fontWithName:@"Monaco" size:12];

    //ICGlyphCache *glyphCache = [ICGlyphCache currentGlyphCache];
    //[glyphCache cacheGlyphsWithString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" forFont:arial];
    //[glyphCache cacheGlyphsWithString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" forFont:georgia];

    /*ICGlyphRun *textRun = [[ICGlyphRun glyphRunWithString:@"1234 The quick brown fox jumps over the lazy dog" font:arial] precache];
    [textRun setPositionY:10];
    [scene.contentView addChild:textRun];
    
    ICGlyphRun *textRun2 = [[ICGlyphRun glyphRunWithString:@"1234 The quick brown fox jumps over the lazy dog" font:georgia] precache];
    [textRun2 setPositionY:100];
    [scene.contentView addChild:textRun2];*/

    /*ICGlyphTextureAtlas *textureAtlas = [[glyphCache textures] objectAtIndex:0];
    if (textureAtlas.dataDirty)
        [textureAtlas upload];
    ICSprite *sprite = [ICSprite spriteWithTexture:textureAtlas];
    [sprite setBlendFunc:(icBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
    [sprite setShaderProgram:[[ICShaderCache currentShaderCache] shaderProgramForKey:kICShader_PositionTextureA8Color]];
    [sprite setColor:(icColor4B){0,0,0,255}];
    [scene.contentView addChild:sprite];*/
    
    /*NSDictionary *attrs1 = [NSDictionary dictionaryWithObjectsAndKeys:arial, ICFontAttributeName, nil];
    NSDictionary *attrs2 = [NSDictionary dictionaryWithObjectsAndKeys:georgia, ICFontAttributeName, nil];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"The quick brown fox jumps over the lazy dog"
                                                                                   attributes:attrs1];
    [attrString addAttributes:attrs2 range:NSMakeRange(0, 10)];
    ICTextLine *line = [ICTextLine textLineWithAttributedString:attrString];
    [scene.contentView addChild:line];*/
    
    NSDictionary *frameAttrs = [NSDictionary dictionaryWithObjectsAndKeys:arial, ICFontAttributeName, nil];
    NSString *frameText = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,";
    NSMutableAttributedString *frameAttrString = [[NSMutableAttributedString alloc] initWithString:frameText
                                                                                        attributes:frameAttrs];
    [frameAttrString addAttribute:ICFontAttributeName value:georgia range:NSMakeRange(0, 99)];
    [frameAttrString addAttribute:ICFontAttributeName value:monaco range:NSMakeRange(202, [frameAttrString length]-202)];
    ICTextFrame *textFrame = [ICTextFrame textFrameWithSize:kmVec2Make(200, 200)
                                           attributedString:frameAttrString];
    textFrame.position = kmVec3Make(20, 20, 0);
    [scene.contentView addChild:textFrame];

    [self runWithScene:scene];
}

@end
