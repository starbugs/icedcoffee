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

#import "ICTextureLoader.h"
#import "ICTexture2D.h"
#import "icMacros.h"

@implementation ICTextureLoader

+ (ICTexture2D *)loadTextureFromFile:(NSString *)filename
{
    return [[self class] loadTextureFromFile:filename resolutionType:ICResolutionTypeUnknown];
}

+ (ICTexture2D *)loadTextureFromFile:(NSString *)filename
                      resolutionType:(ICResolutionType)resolutionType
{
    return [[self class] loadTextureFromURL:[NSURL fileURLWithPath:filename]
                             resolutionType:resolutionType];
}

+ (ICTexture2D *)loadTextureFromURL:(NSURL *)url
{
    return [[self class] loadTextureFromURL:url resolutionType:ICResolutionTypeUnknown];
}

+ (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType
{
    ICTexture2D *texture = nil;
    
#ifdef __IC_PLATFORM_MAC
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
    texture = [[[ICTexture2D alloc] initWithCGImage:[image CGImage]] autorelease];
    
    [data release];
    [image release];
    
#elif __IC_PLATFORM_IOS
    
    UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    texture = [[[ICTexture2D alloc] initWithCGImage:image.CGImage resolutionType:resolutionType] autorelease];
    [image release];
    
#endif
    
    return texture;
}

@end
