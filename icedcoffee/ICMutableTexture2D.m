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

#define __ICTEXTURE2D_PRIVATE

#import "ICMutableTexture2D.h"
#import "ICTexture2D_Private.h"

@implementation ICMutableTexture2D

@synthesize data = _data;
@synthesize ownsData = _ownsData;

- (id)initWithData:(void *)data
       pixelFormat:(ICPixelFormat)pixelFormat
       textureSize:(CGSize)textureSizeInPixels
       contentSize:(CGSize)contentSizeInPixels
    resolutionType:(ICResolutionType)resolutionType
          keepData:(BOOL)keepData
 uploadImmediately:(BOOL)uploadImmediately
{
    if ((self = [super init])) {
		_contentSizeInPixels = contentSizeInPixels;
        _sizeInPixels = textureSizeInPixels;
		_format = pixelFormat;
		_maxS = contentSizeInPixels.width / textureSizeInPixels.width;
		_maxT = contentSizeInPixels.height / textureSizeInPixels.height;
        _resolutionType = resolutionType;
		_hasPremultipliedAlpha = NO;
        
        if (keepData) {
            self.data = data;
            self.ownsData = YES;
        }
        
        if (uploadImmediately)
            [self uploadData:data];
    }
    return self;
}

- (void)dealloc
{
    self.data = nil;
    [super dealloc];
}

- (void)setData:(void *)data
{
    if (_data && self.ownsData) {
        free(_data);
    }
    _data = data;
}

- (void)upload
{
    [self internalUploadData:self.data];
}

- (void)uploadData:(const void *)data
{
    [self internalUploadData:data];
}

- (void)uploadData:(const void *)data inRect:(CGRect)rect
{
    if (_name) {
        glBindTexture(GL_TEXTURE_2D, _name);
        glTexSubImage2D(GL_TEXTURE_2D, 0, (GLint)rect.origin.x, (GLint)rect.origin.y,
                        (GLsizei)rect.size.width, (GLsizei)rect.size.height, GL_RGBA,
                        GL_UNSIGNED_BYTE, data);
    } else {
        ICLog(@"ICMutableTextur2D: cannot update uninitialized texture");
    }
}

@end
