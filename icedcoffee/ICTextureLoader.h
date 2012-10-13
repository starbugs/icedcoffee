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

#import <Foundation/Foundation.h>
#import "icTypes.h"

@class ICTexture2D;

#ifdef __IC_PLATFORM_IOS
/**
 @brief Provides methods for loading textures from image files
 
 This class provides methods for loading textures from image files based on image loading
 functionality implemented in the CoreGraphics framework.
 
 On iOS, the following file formats are supported:
 - Tagged Image File Format (``TIFF``)
 - Joint Photographic Experts Group (``JPEG``)
 - Graphic Interchange Format (``GIF``)
 - Portable Network Graphics (``PNG``)
 - Windows Bitmap Format (``BMP``, ``BMPF``)
 - Windows Icon Format (``ICO``)
 - Windows Cursor (``CUR``)
 - XWindow Bitmap (``XBM``)
 */
#elif defined(__IC_PLATFORM_MAC)
/**
 @brief Provides methods for loading textures from image files
 
 This class provides methods for loading textures from image files based on image loading
 functionality implemented in the CoreGraphics framework.
 
 On Mac OS X, all file formats supported by the ``NSBitmapImageRep`` class are also supported
 by ICTextureLoader.
 */
#endif
@interface ICTextureLoader : NSObject

#pragma mark - Loading Textures from Local Files
/** @name Loading Textures from Local Files */

+ (ICTexture2D *)loadTextureFromFile:(NSString *)filename;

+ (ICTexture2D *)loadTextureFromFile:(NSString *)filename
                      resolutionType:(ICResolutionType)resolutionType;

+ (ICTexture2D *)loadTextureFromFile:(NSString *)filename
                      resolutionType:(ICResolutionType)resolutionType
                               error:(NSError **)error;


#pragma mark - Loading Textures from URLs
/** @name Loading Textures from URLs */

+ (ICTexture2D *)loadTextureFromURL:(NSURL *)url;

+ (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType;

+ (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType
                              error:(NSError **)error;

@end
