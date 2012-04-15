//  
//  Copyright (C) 2012 Tobias Lensing
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
#import "ICRenderTexture.h"

/**
 @brief Defines a rectangular view backed by a render texture
 
 @attention This is preliminary documentation of a work-in-progress part of the framework.
 
 <h3>Overview</h3>
 
 The ICView class defines a rectangular view backed by a render texture target and a sub scene
 for drawing the view's contents. ICView essentially is a subclass of ICRenderTexture, adding
 a further level of abstraction for managing view hierarchies as is common in today's user
 interface frameworks.
 
 The most important difference between a view and a regular node is that a view's contents are
 drawn to a distinct view frame buffer, which is then presented on the parent frame buffer using
 a sprite. It is important to note that while the sprite is a direct child of the view in terms
 of the scene graph hierarchy, the contents of the view are part of a distinct sub scene. For
 further details on this mechanism, please see the ICRenderTexture super class documentation.
 
 By default, the contents of a view are updated only when needed, that is, when setNeedsDisplay
 was called or when the view's contents have not been rendered yet. You may change this behavior
 by setting the underlying render texture display mode to kICRenderTextureDisplayMode_Always
 using the setDisplayMode: method. This makes the view update its content whenever its parent
 frame buffer is updated.
 
 You may add nodes to a view by explicitly addressing the view's sub scene, that is, by sending an
 addChild: message to subScene. Do not add children directly to the view. You may add or remove
 sub views conveniently using the addSubView: and removeSubView: methods. Note that
 <code>[view.subScene addSubView:subView]</code> is identical to
 <code>[view.subScene addChild:subView]</code>.
 
 <h3>Drawing the View's Contents</h3>
 
 There are three different ways of drawing the view's contents:
 <ol>
    <li><b>Adding nodes to subScene</b>: as discussed above you can add arbitrary ICNode objects to
    the view's subScene like this: <code>[view.subScene addChild:myNode]</code>. When the view's
    contents are drawn, the scene graph of the sub scene will be drawn to the view's buffer.</li>
    <li><b>Adding sub views</b>: technically this is the same as adding nodes to subScene, however,
    sub views have their own sub scenes and their frame buffers may be drawn conditionally, so
    their contents are only updated if necessary.</li>
    <li><b>Drawing to the view's frame buffer manually</b>: you may manually draw to the
    view's frame buffer using the OpenGL ES 2 API. You must override drawWithVisitor: to
    implement custom drawing code. See the Subclassing section for further details.</li>
 </ol>
 
 <h3>Subclassing</h3>
 
 You should subclass ICView to implement custom views. Custom views may implement special view
 logic such as custom initialization and management of sub views. If you subclass ICView to
 set up a custom sub view hierarchy, make sure to override its designed initializer,
 initWithWidth:height:pixelFormat:. [FIXME: change designated initializer for depth buffer support]
 
 You may also subclass ICView to implement custom drawing code. In this case, override
 the drawWithVisitor: method. [TODO: add detailed documentation about special drawing
 logic of render textures]
 */
@interface ICView : ICRenderTexture

- (id)initWithWidth:(int)w height:(int)h;

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format;

/**
 @brief Adds the specified sub view to the view hierarchy
 */
- (void)addSubView:(ICView *)subView;

/**
 @brief Removes the specified sub view from the view hierarchy
 */
- (void)removeSubView:(ICView *)subView;

/**
 @brief The sub views
 */
- (NSArray *)subViews;

@end
