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

@class ICTextureCache;
@class ICShaderCache;

/**
 @brief Represents a render context for binding arbitrary objects to an OpenGL context
 
 The ICRenderContext class provides strong references to objects that should be bound
 to an OpenGL context in order to make them globally retrievable based on the current
 OpenGL context. Render contexts are registered and retrieved using the ICContextManager
 class.
 */
@interface ICRenderContext : NSObject {
@protected
    ICTextureCache *_textureCache;
    ICShaderCache *_shaderCache;
    NSMutableDictionary *_customObjects;
}

/**
 @brief Returns the render context for the current OpenGL context
 */
+ (id)currentRenderContext;

/**
 @brief Initializes the receiver
 */
- (id)init;

/**
 @brief Initializes the receiver with the texture and shader caches from the given share context
 */
- (id)initWithShareContext:(ICRenderContext *)shareContext;

/**
 @brief The receiver's texture cache
 */
@property (nonatomic, retain) ICTextureCache *textureCache;

/**
 @brief The receiver's shader cache
 */
@property (nonatomic, retain) ICShaderCache *shaderCache;

/**
 @brief Sets a custom object for the given key
 */
- (void)setCustomObject:(id)object forKey:(id)key;

/**
 @brief Returns the custom object set for the given key
 */
- (id)customObjectForKey:(id)key;

/**
 @brief Removes the custom object set for the given key
 */
- (void)removeCustomObjectForKey:(id)key;

/**
 @brief Removes all custom objects from the receiver
 */
- (void)removeAllCustomObjects;

@end
