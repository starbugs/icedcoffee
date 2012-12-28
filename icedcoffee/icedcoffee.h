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
//  NOTE: Parts of this project have been inspired by or may contain merged and
//  possibly modified code from the cocos2d-iphone.org project and the cocos3d
//  (see http://brenwill.com/cocos3d/). The concerned files include the original
//  copyright notice as required by the respective project license.
//
//  ===================
//
//  Import this file in modules using icedcoffee

#import "icMacros.h"
#import "ICCamera.h"
#import "ICUICamera.h"
#import "ICConfiguration.h"
#import "icDefaults.h"
#import "ICHostViewController.h"
#import "ICTestHostViewController.h"
#import "ICNode.h"
#import "ICNodeVisitorDrawing.h"
#import "ICButton.h"
#import "ICLabel.h"
#import "ICScene.h"
#import "ICUIScene.h"
#import "ICShaderCache.h"
#import "ICShaderProgram.h"
#import "ICAnimatedShaderProgram.h"
#import "ICShaderValue.h"
#import "ICSprite.h"
#import "ICScale9Sprite.h"
#import "ICRectangle.h"
#import "ICLine2D.h"
#import "ICRenderTexture.h"
#import "ICScheduler.h"
#import "ICTableView.h"
#import "ICTableViewCell.h"
#import "ICTexture2D.h"
#import "ICMutableTexture2D.h"
#import "ICTextureCache.h"
#import "ICTextureLoader.h"
#import "ICView.h"
#import "ICScrollView.h"
#import "icTypes.h"
#import "ICBasicAnimation.h"
#import "ICCombinedVertexIndexBuffer.h"

// Font rendering
#import "ICFont.h"
#import "ICGlyphCache.h"
#import "ICGlyphTextureAtlas.h"
#import "ICTextureGlyph.h"
#import "ICGlyphRun.h"
#import "ICTextLine.h"
#import "ICTextFrame.h"

#ifdef __IC_PLATFORM_MAC
#import "Platforms/Mac/ICGLView.h"
#import "Platforms/Mac/ICHostViewControllerMac.h"
#import "ICMouseEvent.h"
#elif defined(__IC_PLATFORM_IOS)
#import "Platforms/iOS/ICHostViewControllerIOS.h"
#import "Platforms/iOS/ICGLView.h"
#import "ICTouchEvent.h"
#import "ICTouch.h"
#endif

// Extensions

#if defined(__IC_PLATFORM_IOS) && IC_ENABLE_GPUIMAGE_EXTENSIONS
#import "../extensions/GPUImage/ICGPUImageTexture2D.h"
#endif

