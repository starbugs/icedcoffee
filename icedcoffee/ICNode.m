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

#import "ICNode.h"

#import "icGL.h"
#import "icTypes.h"
#import "icUtils.h"
#import "kazmath/kazmath.h"

#import "ICScene.h"
#import "ICCamera.h"
#import "ICShaderCache.h"
#import "ICShaderValue.h"
#import "ICShaderUniform.h"
#import "ICShaderProgram.h"
#import "ICNodeVisitorPicking.h"
#import "ICHostViewController.h"
#import "ICRenderTexture.h"
#import "ICAnimation.h"
#import "ICScheduler.h"

#import "ICDrawAPI.h"


@interface ICNode (Private)
- (void)setParent:(ICNode *)parent;
- (void)setChildren:(NSMutableArray *)children;
- (void)setNeedsDisplayForNode:(ICNode *)node;
- (NSArray *)childrenSortedByZIndex;
@end


@implementation ICNode

#pragma mark - Lifecycle

- (id)init
{
    if ((self = [super init])) {
        self.children = nil; // lazy allocation
        self.computesTransform = YES;
        self.isVisible = YES;
        
        kmVec3 defaultPosition;
        kmVec3Fill(&defaultPosition, 0, 0, 0);
        [self setPosition:defaultPosition];
        
        // Anchor point is the same as default position initially
        [self setAnchorPoint:defaultPosition];
        // Content size is null also
        [self setSize:defaultPosition];
        
        kmVec3 defaultScale;
        kmVec3Fill(&defaultScale, 1, 1, 1);
        [self setScale:defaultScale];
        
        kmVec3 defaultAxis;
        kmVec3Fill(&defaultAxis, 0, 1, 0);
        [self setRotationAngle:0 axis:defaultAxis];
        
        kmMat4 identity;
        kmMat4Identity(&identity);
        self.transform = identity;
        
        // Auto center anchor point when content size is set
        self.autoCenterAnchorPoint = YES;
        
        // Enable user interaction by default
        self.userInteractionEnabled = YES;
        
        // Z Index is undefined by default
        self.zIndex = ICZIndexUndefined;
        
        _childrenSortedByZIndexDirty = YES;
#if defined(DEBUG) && IC_DEBUG_ICNODE_PARENTS
        _dbgParentInfo = nil;
#endif
    }
    return self;
}

- (void)dealloc
{
    for (ICNode *child in self.children) {
        child.parent = nil;
    }
    
    self.children = nil;
    [_childrenSortedByZIndex release];
    [self removeAllAnimations];
    
#if defined(DEBUG) && IC_DEBUG_ICNODE_PARENTS
    [_dbgParentInfo release];
#endif
    
    [super dealloc];
}


#pragma mark - Composition

@synthesize parent = _parent;
@synthesize children = _children;

- (void)addChild:(ICNode *)child
{
    [child setParent:self];
    
    if (!_children) {
        _children = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if (child.zIndex == ICZIndexUndefined)
        child.zIndex = [_children count];
    [(NSMutableArray *)_children addObject:child];
    _childrenSortedByZIndexDirty = YES;
}

- (void)insertChild:(ICNode *)child atIndex:(uint)index
{
    if (!_children) {
        _children = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if (self.zIndex == ICZIndexUndefined)
        self.zIndex = [_children count];
    [(NSMutableArray *)_children insertObject:child atIndex:index];
    _childrenSortedByZIndexDirty = YES;
}

- (void)removeChild:(ICNode *)child
{
    if (_children) {
        [child setParent:nil];
        [(NSMutableArray *)_children removeObject:child];
    }
    _childrenSortedByZIndexDirty = YES;
}

- (void)removeChildAtIndex:(uint)index
{
    if (_children) {
        [[_children objectAtIndex:index] setParent:nil];
        [(NSMutableArray *)_children removeObjectAtIndex:index];
    }
    _childrenSortedByZIndexDirty = YES;
}

- (void)removeAllChildren
{
    if (_children) {
        for (ICNode *child in _children) {
            [child setParent:nil];
        }
        [(NSMutableArray *)_children removeAllObjects];
    }
    _childrenSortedByZIndexDirty = YES;
}

- (BOOL)hasChildren
{
    return _children.count > 0;
}

- (ICNode *)childForTag:(uint)tag
{
    for (ICNode *child in _children) {
        if (child.tag == tag)
            return child;
    }
    return nil;
}

- (NSArray *)childrenOfType:(Class)classType
{
    NSMutableArray *children = [NSMutableArray array];
    for (ICNode *child in _children) {
        if ([child isKindOfClass:classType]) {
            [children addObject:child];
        }
    }
    return children;
}

- (NSArray *)childrenNotOfType:(Class)classType
{
    NSMutableArray *children = [NSMutableArray array];
    for (ICNode *child in _children) {
        if (![child isKindOfClass:classType]) {
            [children addObject:child];
        }
    }
    return children;
}

- (NSArray *)children
{
    return _children;
}

- (NSArray *)childrenSortedByZIndex
{
    if (_childrenSortedByZIndexDirty) {
        [_childrenSortedByZIndex release];
        _childrenSortedByZIndex = [[NSMutableArray alloc] initWithArray:_children];
        [_childrenSortedByZIndex sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ICNode *node1 = obj1, *node2 = obj2;
            if (node1.zIndex > node2.zIndex)
                return NSOrderedDescending;
            else if(node1.zIndex < node2.zIndex)
                return NSOrderedAscending;
            return NSOrderedSame;
        }];
        _childrenSortedByZIndexDirty = NO;
    }
    return _childrenSortedByZIndex;
}

- (NSArray *)drawingChildren
{
    return [self childrenSortedByZIndex];
}

- (NSArray *)pickingChildren
{
    return [self childrenSortedByZIndex];
}

- (NSArray *)ancestorsOfType:(Class)classType
{
    return [self ancestorsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return [node isKindOfClass:classType];
    }];
}

- (NSArray *)ancestorsNotOfType:(Class)classType
{
    return [self ancestorsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return ![node isKindOfClass:classType];
    }];    
}

- (NSArray *)ancestorsConformingToProtocol:(Protocol *)protocol
{
    return [self ancestorsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return [node conformsToProtocol:protocol];
    }];    
}

- (ICNode *)firstAncestorConformingToProtocol:(Protocol *)protocol
{
    NSArray *ancestors = [self ancestorsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        BOOL result = [node conformsToProtocol:protocol];
        if (result)
            *stop = YES;
        return result;
    }];
    if ([ancestors count]) {
        return [ancestors objectAtIndex:0];
    }
    return nil;
}

- (ICNode *)firstAncestorOfType:(Class)classType
{
    NSArray *ancestors = [self ancestorsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        BOOL passes = [node isKindOfClass:classType];
        if (passes)
            *stop = YES;
        return passes;
    }];
    if ([ancestors count])
        return [ancestors objectAtIndex:0];
    return nil;
}

- (NSArray *)ancestorsFilteredUsingBlock:(ICNodeFilterBlockType)filterBlock
{
    if (!filterBlock) {
        filterBlock = ^BOOL(ICNode *node, BOOL *stop) {
            return YES;
        };
    }
    
    BOOL stopFlag = NO;
    ICNode *node = self;
    NSMutableArray* ancestors = [[[NSMutableArray alloc] init] autorelease];
    while((node = [node parent])) {
        if (filterBlock(node, &stopFlag)) {
            [ancestors addObject:node];
        }
        if (stopFlag)
            break;
    }
    
    return ancestors;
}

- (NSArray *)ancestors
{
    return [self ancestorsFilteredUsingBlock:nil];
}

- (NSArray *)descendantsNotOfType:(Class)classType
{
    return [self descendantsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return ![node isKindOfClass:classType];
    }];
}

- (NSArray *)descendantsOfType:(Class)classType
{
    return [self descendantsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return [node isKindOfClass:classType];
    }];
}

- (NSArray *)descendantsConformingToProtocol:(Protocol *)protocol
{
    return [self descendantsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        return [node conformsToProtocol:protocol];
    }];
}

- (ICNode *)firstDescendantOfType:(Class)classType
{
    NSArray *descendants = [self descendantsFilteredUsingBlock:^BOOL(ICNode *node, BOOL *stop) {
        BOOL passes = [node isKindOfClass:classType];
        if (passes)
            *stop = YES;
        return passes;
    }];
    if ([descendants count]) {
        return [descendants objectAtIndex:0];
    }
    return nil;
}

- (void)accumulateDescendants:(NSMutableArray *)descendants
                     withNode:(ICNode *)node
                   usingBlock:(ICNodeFilterBlockType)filterBlock
{
    if ([node hasChildren]) {
        BOOL stopFlag = NO;
        for (ICNode *child in node.children) {
            if (filterBlock(child, &stopFlag)) {
                [descendants addObject:child];
            }
            if (stopFlag)
                break;
            [self accumulateDescendants:descendants withNode:child usingBlock:filterBlock];
        }
    }
}

- (NSArray *)descendantsFilteredUsingBlock:(ICNodeFilterBlockType)filterBlock
{
    NSMutableArray *descendants = [NSMutableArray array];
    [self accumulateDescendants:descendants withNode:self usingBlock:filterBlock];
    return descendants;
}

- (NSArray *)descendants
{
    return [self descendantsOfType:nil];
}

- (uint)level
{
    uint level = 0;
    ICNode *parent = _parent;
    do {
        if (parent)
            level++;
    } while ((parent = [parent parent]));
    
    return level;
}

- (ICNode *)root
{
    ICNode *parent = _parent;
    while (true) {
        if ([parent parent]) {
            parent = [parent parent];
        } else {
            break;
        }
    }
    return parent;
}

- (ICScene *)rootScene
{
    ICNode *potentialScene = [self root];
    if ([potentialScene isKindOfClass:[ICScene class]]) {
        return (ICScene *)potentialScene;
    }
    return nil;
}

- (ICScene *)parentScene
{
    NSArray *sceneAncestors = [self ancestorsOfType:[ICScene class]];
    if ([sceneAncestors count] > 0)
        return [sceneAncestors objectAtIndex:0];
    return nil;
}

- (ICScene *)scene
{
    if ([self isKindOfClass:[ICScene class]]) {
        return (ICScene *)self;
    }
    return [self parentScene];
}

- (ICNode<ICFramebufferProvider> *)framebufferProvider
{
    return (ICNode<ICFramebufferProvider> *)[self firstAncestorConformingToProtocol:
                                             @protocol(ICFramebufferProvider)];
}

- (ICHostViewController *)hostViewController
{
    return [[self rootScene] hostViewController];
}


#pragma mark - Transforms

@synthesize transform = _transform;

- (const kmMat4 *)transformPtr
{
    return &_transform;
}

- (kmMat4)nodeToParentTransform
{
    if (_computesTransform && _transformDirty) {
        [self computeTransform];
    }
    return _transform;
}

- (kmMat4)parentToNodeTransform
{
    if (_computesTransform && _transformDirty) {
        [self computeTransform];
    }
    kmMat4 inverseTransform;
    kmMat4Inverse(&inverseTransform, &_transform);
    return inverseTransform;
}

// This will stop at ICScene objects to ensure that a scene always represents
// word coordinates, even if scenes are nested
- (kmMat4)nodeToWorldTransform
{
    kmMat4 nodeToParentTransform = [self nodeToParentTransform];
    for (ICNode *parent = _parent; parent != nil; parent = parent.parent) {
        kmMat4 parentNodeToParentTransform = [parent nodeToParentTransform];
        kmMat4Multiply(&nodeToParentTransform, &parentNodeToParentTransform, &nodeToParentTransform);
        if ([parent isKindOfClass:[ICScene class]]) {
            break; // scene represents world coordinates
        }
    }
    return nodeToParentTransform;
}

- (kmMat4)worldToNodeTransform
{
    kmMat4 inverseTransform;
    kmMat4 nodeToWorldTransform = [self nodeToWorldTransform];
    kmMat4Inverse(&inverseTransform, &nodeToWorldTransform);
    return inverseTransform;
}

- (kmVec3)convertToNodeSpace:(kmVec3)worldVect
{
    kmVec3 result;
    kmMat4 transform = [self worldToNodeTransform];
    kmVec3Transform(&result, &worldVect, &transform);
    return result;
}

- (kmVec3)convertToWorldSpace:(kmVec3)nodeVect
{
    kmVec3 result;
    kmMat4 transform = [self nodeToWorldTransform];
    kmVec3Transform(&result, &nodeVect, &transform);
    return result;
}

- (void)setPosition:(kmVec3)position
{
    [self willChangeValueForKey:@"position"];
    _position = position;
    _transformDirty = YES;
    [self didChangeValueForKey:@"position"];
}

- (void)setPositionX:(float)positionX
{
    [self setPosition:kmVec3Make(positionX, _position.y, _position.z)];
}

- (void)setPositionY:(float)positionY
{
    [self setPosition:kmVec3Make(_position.x, positionY, _position.z)];
}

- (void)setPositionZ:(float)positionZ
{
    [self setPosition:kmVec3Make(_position.x, _position.y, positionZ)];
}

- (kmVec3)localCenter
{
    return [self localCenterRounded:NO];
}

- (kmVec3)localCenterRounded:(BOOL)rounded
{
    kmAABB aabb = [self localAABB];
    kmVec3Subtract(&aabb.max, &aabb.max, &aabb.min);
    kmVec3Scale(&aabb.max, &aabb.max, 0.5f);
    kmVec3Add(&aabb.max, &aabb.min, &aabb.max);
    if (rounded)
        aabb.max = kmVec3Round(aabb.max);
    return aabb.max;
}

- (kmVec3)localOpticalCenter
{
    return [self localOpticalCenterRounded:NO];
}

- (kmVec3)localOpticalCenterRounded:(BOOL)rounded
{
    kmAABB aabb = [self localAABB];
    kmVec3Subtract(&aabb.max, &aabb.max, &aabb.min);
    aabb.max.x *= 0.5f;
    aabb.max.y *= 0.47f;
    aabb.max.z *= 0.5f;
    kmVec3Add(&aabb.max, &aabb.min, &aabb.max);
    if (rounded)
        aabb.max = kmVec3Round(aabb.max);
    return aabb.max;
}

- (kmVec3)center
{
    return [self centerRounded:NO];
}

- (kmVec3)centerRounded:(BOOL)rounded
{
    if ([self computesTransform]) {
        [self computeTransform];
    }
    kmVec3 center = [self localCenter];
    kmVec3Transform(&center, &center, &_transform);
    if (rounded)
        center = kmVec3Round(center);
    return center;
}

- (kmVec3)opticalCenter
{
    return [self opticalCenterRounded:NO];
}

- (kmVec3)opticalCenterRounded:(BOOL)rounded
{
    if ([self computesTransform]) {
        [self computeTransform];
    }
    kmVec3 center = [self localOpticalCenter];
    kmVec3Transform(&center, &center, &_transform);
    if (rounded)
        center = kmVec3Round(center);
    return center;
}

- (void)setCenter:(kmVec3)center
{
    [self setCenter:center rounded:NO];
}

- (void)setCenter:(kmVec3)center rounded:(BOOL)rounded
{
    kmVec3 localCenter = [self localCenter];
    kmVec3 position;
    kmVec3Subtract(&position, &center, &localCenter);
    if (rounded)
        position = kmVec3Round(position);
    self.position = position;
}

- (void)setCenterX:(float)centerX
{
    [self setCenterX:centerX rounded:NO];
}

- (void)setCenterX:(float)centerX rounded:(BOOL)rounded
{
    kmVec3 localCenter = [self localCenter];
    float positionX = centerX - localCenter.x;
    if (rounded)
        positionX = roundf(positionX);
    [self setPositionX:positionX];
}

- (void)setCenterY:(float)centerY
{
    [self setCenterY:centerY rounded:NO];
}

- (void)setCenterY:(float)centerY rounded:(BOOL)rounded
{
    kmVec3 localCenter = [self localCenter];
    float positionY = centerY - localCenter.y;
    if (rounded)
        positionY = roundf(positionY);
    [self setPositionY:positionY];
}

- (void)setCenterZ:(float)centerZ
{
    [self setCenterZ:centerZ rounded:NO];
}

- (void)setCenterZ:(float)centerZ rounded:(BOOL)rounded
{
    kmVec3 localCenter = [self localCenter];
    float positionZ = centerZ - localCenter.z;
    if (rounded)
        positionZ = roundf(positionZ);
    [self setPositionZ:positionZ];
}

- (void)centerNode
{
    [self centerNodeRounded:NO];
}

- (void)centerNodeRounded:(BOOL)rounded
{
    kmVec3 center = [self.parent localCenterRounded:rounded];
    [self setCenter:center rounded:rounded];
}

- (void)centerNodeOptically
{
    [self centerNodeOpticallyRounded:NO];
}

- (void)centerNodeOpticallyRounded:(BOOL)rounded
{
    kmVec3 center = [self.parent localOpticalCenterRounded:rounded];
    [self setCenter:center rounded:rounded];
}

- (void)centerNodeVertically
{
    [self centerNodeVerticallyRounded:NO];
}

- (void)centerNodeVerticallyRounded:(BOOL)rounded
{
    float centerY = [self.parent localCenterRounded:rounded].y;
    [self setCenterY:centerY rounded:rounded];
}

- (void)centerNodeHorizontally
{
    [self centerNodeHorizontallyRounded:NO];
}

- (void)centerNodeHorizontallyRounded:(BOOL)rounded
{
    float centerX = [self.parent localCenterRounded:rounded].x;
    [self setCenterX:centerX rounded:rounded];
}

- (kmVec3)position
{
    return _position;
}

- (void)setAnchorPoint:(kmVec3)anchorPoint
{
    [self willChangeValueForKey:@"anchorPoint"];
    _anchorPoint = anchorPoint;
    _transformDirty = YES;
    [self didChangeValueForKey:@"anchorPoint"];
}

- (void)centerAnchorPoint
{
    [self setAnchorPoint:[self localCenter]];
}

- (kmVec3)anchorPoint
{
    return _anchorPoint;
}

@synthesize origin = _origin;

- (void)setSize:(kmVec3)size
{
    [self willChangeValueForKey:@"size"];
    _size = size;
    [self didChangeValueForKey:@"size"];
    
    if (_autoCenterAnchorPoint) {
        [self centerAnchorPoint];
    }
}

- (kmVec3)size
{
    return _size;
}

- (void)setWidth:(float)width
{
    [self setSize:kmVec3Make(width, _size.height, _size.depth)];
}

- (void)setHeight:(float)height
{
    [self setSize:kmVec3Make(_size.width, height, _size.depth)];
}

- (void)setDepth:(float)depth
{
    [self setSize:kmVec3Make(_size.width, _size.height, depth)];
}

- (void)setScale:(kmVec3)scale
{
    [self willChangeValueForKey:@"scale"];
    _scale = scale;
    _transformDirty = YES;
    [self didChangeValueForKey:@"scale"];
}

- (void)setScaleX:(float)scaleX
{
    _scale.x = scaleX;
    _transformDirty = YES;
}

- (void)setScaleY:(float)scaleY
{
    _scale.y = scaleY;
    _transformDirty = YES;    
}

- (void)setScaleXY:(float)scaleXY
{
    _scale.x = _scale.y = scaleXY;
    _transformDirty = YES;
}

- (void)setScaleZ:(float)scaleZ
{
    _scale.z = scaleZ;
    _transformDirty = YES;    
}

- (kmVec3)scale
{
    return _scale;
}

@synthesize rotationAngle = _rotationAngle;
@synthesize rotationAxis = _rotationAxis;

- (void)setRotationAngle:(float)angle
{
    _rotationAngle = angle;
    _transformDirty = YES;
}

- (void)setRotationAxis:(kmVec3)axis
{
    [self willChangeValueForKey:@"rotationAxis"];
    _rotationAxis = axis;
    _transformDirty = YES;
    [self didChangeValueForKey:@"rotationAxis"];
}

- (void)setRotationAngle:(float)angle axis:(kmVec3)axis
{
    self.rotationAxis = axis;
    self.rotationAngle = angle;
    _transformDirty = YES;
}

- (void)getRotationAngle:(float *)angle axis:(kmVec3 *)axis
{
    *angle = _rotationAngle;
    *axis = _rotationAxis;
}

// respected by visitor
@synthesize computesTransform = _computesTransform;

- (void)computeTransform
{
    if (_transformDirty) {
        kmMat4 translate, anchorPoint, reAnchorPoint, scale, rotate;
                
        kmMat4Translation(&translate, _position.x, _position.y, _position.z);
        kmMat4Translation(&anchorPoint, -_anchorPoint.x, -_anchorPoint.y, -_anchorPoint.z);
        kmMat4Translation(&reAnchorPoint, _anchorPoint.x, _anchorPoint.y, _anchorPoint.z);
        kmMat4Scaling(&scale, _scale.x, _scale.y, _scale.z);
        kmMat4RotationAxisAngle(&rotate, &_rotationAxis, _rotationAngle);
        
        kmMat4Identity(&_transform);
        kmMat4Multiply(&_transform, &_transform, &anchorPoint);
        kmMat4Multiply(&_transform, &scale, &_transform);
        kmMat4Multiply(&_transform, &rotate, &_transform);
        kmMat4Multiply(&_transform, &reAnchorPoint, &_transform);
        kmMat4Multiply(&_transform, &translate, &_transform);
        
        _transformDirty = NO;
    }
}

@synthesize autoCenterAnchorPoint = _autoCenterAnchorPoint;


#pragma mark - Order

- (NSUInteger)index
{
    return [self.parent.children indexOfObject:self];
}

@synthesize zIndex = _zIndex;

- (void)setZIndex:(NSInteger)zIndex
{
    if (zIndex != _zIndex) {
        _zIndex = zIndex;
        if (self.parent)
            self.parent->_childrenSortedByZIndexDirty = YES;
    }
}

- (void)orderBack
{
    NSArray *sortedChildren = [[self parent] childrenSortedByZIndex];
    if ([sortedChildren count] > 1) {
        NSInteger zIndex = 0;
        self.zIndex = zIndex++;
        for (ICNode *child in sortedChildren) {
            if (child != self) {
                child.zIndex = zIndex++;
            }
        }
    }
}

- (void)orderBackward
{
    NSArray *sortedChildren = [[self parent] childrenSortedByZIndex];
    if ([sortedChildren count] > 1) {
        NSUInteger index = [sortedChildren indexOfObject:self];
        if (index > 0) {
            NSInteger zIndex = self.zIndex;
            ICNode *reorderNode = [sortedChildren objectAtIndex:index - 1];
            self.zIndex = reorderNode.zIndex;
            reorderNode.zIndex = zIndex;
        }
    }
}

- (void)orderForward
{
    NSArray *sortedChildren = [[self parent] childrenSortedByZIndex];
    if ([sortedChildren count] > 1) {
        NSUInteger index = [sortedChildren indexOfObject:self];
        if (index < [sortedChildren count] - 1) {
            NSInteger zIndex = self.zIndex;
            ICNode *reorderNode = [sortedChildren objectAtIndex:index + 1];
            self.zIndex = reorderNode.zIndex;
            reorderNode.zIndex = zIndex;
        }
    }
}

- (void)orderFront
{
    NSArray *sortedChildren = [[self parent] childrenSortedByZIndex];
    if ([sortedChildren count] > 1) {
        NSInteger zIndex = 0;
        for (ICNode *child in sortedChildren) {
            if (child != self) {
                child.zIndex = zIndex++;
            }
        }
        self.zIndex = zIndex;
    }
}


#pragma mark - Bounds

- (kmAABB)localAABB
{
    return (kmAABB){
        _origin,
        kmVec3Make(_origin.x+_size.width,
                   _origin.y+_size.height,
                   _origin.z+_size.depth)
    };
}

- (kmAABB)aabb
{
    kmAABB aabb = [self localAABB];
    
    if (self.computesTransform) {
        [self computeTransform];
    }
    kmVec3Transform(&aabb.min, &aabb.min, &_transform);
    kmVec3Transform(&aabb.max, &aabb.max, &_transform);
    return icComputeAABBFromVertices((kmVec3*)&aabb, 2);
}

// FIXME
- (CGRect)frameRect
{
    kmVec3 world[8], view[8];
    
    world[0] = _position;
    world[1] = (kmVec3){_position.x + _size.width, _position.y, _position.z};
    world[2] = (kmVec3){_position.x + _size.width, _position.y + _size.height, _position.z};
    world[3] = (kmVec3){_position.x + _size.width, _position.y + _size.height, _position.z + _size.z};
    world[4] = (kmVec3){_position.x, _position.y + _size.height, _position.z};
    world[5] = (kmVec3){_position.x, _position.y + _size.height, _position.z + _size.z};
    world[6] = (kmVec3){_position.x, _position.y, _position.z + _size.z};
    world[7] = (kmVec3){_position.x + _size.width, _position.y, _position.z + _size.z};

    ICScene *scene = [self parentScene];
    if (!scene && [self isKindOfClass:[ICScene class]] && !_parent) {
        scene = (ICScene *)self;
    } else if (!scene) {
        NSAssert(nil, @"Could not get scene for frame rect calculation");
    }
    
    for (int i=0; i<8; i++) {
        kmVec3 w = world[i];
        if (_parent)
            w = [self convertToWorldSpace:world[i]];
        [scene.camera projectWorld:w toView:&view[i]];
        view[i].x = ICPixelsToPoints((int)view[i].x);
        view[i].y = ICPixelsToPoints((int)view[i].y);
    }
    
    kmAABB aabb = icComputeAABBFromVertices(view, 8);
    return CGRectMake(aabb.min.x, aabb.min.y, aabb.max.x - aabb.min.x,  aabb.max.y - aabb.min.y);
}


#pragma mark - Drawing/Picking

@synthesize shaderProgram = _shaderProgram;
@synthesize isVisible = _isVisible;

- (void)applyStandardDrawSetupWithVisitor:(ICNodeVisitor *)visitor
{
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]]) { // drawing node visitor
        if (!self.shaderProgram)
            NSLog(@"Warning: no shader program set for node %@", [self description]);
        icGLUniformModelViewProjectionMatrix(self.shaderProgram);
        [self.shaderProgram use];
    } else {
        ICShaderProgram *p = [[ICShaderCache currentShaderCache] shaderProgramForKey:kICShader_Picking];
        icColor4B pickColor = [(ICNodeVisitorPicking *)visitor pickColor];        
        [p setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor4B(pickColor)]
               forUniform:@"u_pickColor"];
        icGLUniformModelViewProjectionMatrix(p);
        [p use];
    }    
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    // Implement custom drawing code in subclass
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    // Implement custom code to reset states after drawing children in subclass
}

// Private
- (void)setNeedsDisplayForNode:(ICNode *)node
{
    [[self parent] setNeedsDisplayForNode:node];
}

- (void)setNeedsDisplay
{
    [self setNeedsDisplayForNode:self];
}


#pragma mark - Ray-based Hit Testing

- (ICHitTestResult)localRayHitTest:(icRay3)ray
{
    // Override in subclass
    return ICHitTestUnsupported;
}


#pragma mark - User Interaction Support

@synthesize userInteractionEnabled = _userInteractionEnabled;


#pragma mark - Animations

- (void)addAnimation:(ICAnimation *)animation
{
    NSAssert(animation != nil, @"animation must not be nil");
    
    ICHostViewController *hvc = self.hostViewController;
    if (!hvc)
        hvc = [ICHostViewController currentHostViewController];
    [hvc.scheduler addAnimation:animation forNode:self];
}

- (void)removeAnimation:(ICAnimation *)animation
{
    NSAssert(animation != nil, @"animation must not be nil");
    
    ICHostViewController *hvc = self.hostViewController;
    if (!hvc)
        hvc = [ICHostViewController currentHostViewController];
    [hvc.scheduler removeAnimation:animation forNode:self];
}

- (void)removeAllAnimations
{
    ICHostViewController *hvc = self.hostViewController;
    if (!hvc)
        hvc = [ICHostViewController currentHostViewController];
    NSArray *animations = [hvc.scheduler animationsForNode:self];
    for (ICAnimation *animation in animations) {
        [hvc.scheduler removeAnimation:animation forNode:self];
    }
}


#pragma mark - Debugging

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | parent = %@ (%@)>",
            [self class], (uint)self, self.name, [_parent class], [_parent name]];
}

// private
- (void)debugLogBranchWithRoot:(ICNode *)root node:(ICNode *)node
{
    uint level = [node level] - [root level];
    NSMutableString *indent = [NSMutableString stringWithCapacity:level];
    for (uint i=0; i<level; i++) {
        [indent appendString:@" "];
    }
    NSLog(@"%@ - %@", indent, [node description]);
    for (ICNode *child in _children) {
        [child debugLogBranchWithRoot:root node:child];
    }
}

- (void)debugLogBranch
{
    [self debugLogBranchWithRoot:self node:self];
}

- (void)debugDrawBoundingBox
{
    icColor4B magentaColor = (icColor4B){255,0,255,255};
    kmVec4 boundingBox = kmVec4Make(self.origin.x, self.origin.y, self.size.width, self.size.height);
    [ICDrawAPI drawRect2D:boundingBox z:0 color:magentaColor lineWidth:1];
}


#pragma mark - ICResponder Overrides

- (BOOL)makeFirstResponder
{
    return [self.hostViewController makeFirstResponder:self];
}

#ifdef __IC_PLATFORM_DESKTOP
- (void)noResponderFor:(SEL)selector
{
    [self.hostViewController.view noResponderFor:selector];
}
#endif // __IC_PLATFORM_DESKTOP


#pragma mark - NSObject KVO/KVC Overrides

// Automatic KVO broken for C unions, see http://stackoverflow.com/questions/14295505

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"position"] ||
        [key isEqualToString:@"size"] ||
        [key isEqualToString:@"origin"] ||
        [key isEqualToString:@"anchorPoint"] ||
        [key isEqualToString:@"scale"] ||
        [key isEqualToString:@"rotationAxis"]) {
        return NO;
    }
    return YES;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"positionX"]) {
        [self setPositionX:[(NSNumber *)value floatValue]];
    } else if ([keyPath isEqualToString:@"positionY"]) {
        [self setPositionY:[(NSNumber *)value floatValue]];
    } else if ([keyPath isEqualToString:@"positionZ"]) {
        [self setPositionZ:[(NSNumber *)value floatValue]];
    } else if([keyPath isEqualToString:@"position"]) {
        kmVec3 position;
        [(NSValue *)value getValue:&position];
        [self setPosition:position];
        
    } else if([keyPath isEqualToString:@"size"]) {
        kmVec3 size;
        [(NSValue *)value getValue:&size];
        [self setSize:size];

    } else if([keyPath isEqualToString:@"origin"]) {
        kmVec3 origin;
        [(NSValue *)value getValue:&origin];
        [self setScale:origin];
        
    } else if ([keyPath isEqualToString:@"centerX"]) {
        [self setCenterX:[(NSNumber *)value floatValue]];
    } else if ([keyPath isEqualToString:@"centerY"]) {
        [self setCenterY:[(NSNumber *)value floatValue]];
    } else if ([keyPath isEqualToString:@"centerZ"]) {
        [self setCenterZ:[(NSNumber *)value floatValue]];
    } else if ([keyPath isEqualToString:@"center"]) {
        kmVec3 center;
        [(NSValue *)value getValue:&center];
        [self setCenter:center rounded:NO];
    
    } else if ([keyPath isEqualToString:@"centerXRounded"]) {
        [self setCenterX:[(NSNumber *)value floatValue] rounded:YES];
    } else if ([keyPath isEqualToString:@"centerYRounded"]) {
        [self setCenterY:[(NSNumber *)value floatValue] rounded:YES];
    } else if ([keyPath isEqualToString:@"centerZRounded"]) {
        [self setCenterZ:[(NSNumber *)value floatValue] rounded:YES];
    } else if ([keyPath isEqualToString:@"centerRounded"]) {
        kmVec3 center;
        [(NSValue *)value getValue:&center];
        [self setCenter:center rounded:YES];

    } else if([keyPath isEqualToString:@"anchorPoint"]) {
        kmVec3 anchorPoint;
        [(NSValue *)value getValue:&anchorPoint];
        [self setScale:anchorPoint];
        
    } else if([keyPath isEqualToString:@"scale"]) {
        kmVec3 scale;
        [(NSValue *)value getValue:&scale];
        [self setScale:scale];
    
    } else {
        [super setValue:value forKey:keyPath];
    }
}

- (id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"position"]) {
        return [NSValue valueWithBytes:&_position objCType:@encode(kmVec3)];
    } else if ([key isEqualToString:@"size"]) {
        return [NSValue valueWithBytes:&_size objCType:@encode(kmVec3)];
    } else if ([key isEqualToString:@"origin"]) {
        return [NSValue valueWithBytes:&_origin objCType:@encode(kmVec3)];
    } else if ([key isEqualToString:@"anchorPoint"]) {
        return [NSValue valueWithBytes:&_anchorPoint objCType:@encode(kmVec3)];
    } else if ([key isEqualToString:@"scale"]) {
        return [NSValue valueWithBytes:&_scale objCType:@encode(kmVec3)];
    } else if ([key isEqualToString:@"rotationAxis"]) {
        return [NSValue valueWithBytes:&_rotationAxis objCType:@encode(kmVec3)];
    }
    return [super valueForKey:key];
}


#pragma mark - Private

- (void)setParent:(ICNode *)parent
{
    _parent = parent;
    self.nextResponder = parent;
    
#if defined(DEBUG) && IC_DEBUG_ICNODE_PARENTS
    // Debugging
    [_dbgParentInfo release];
    _dbgParentInfo = [[_parent description] copy];
#endif
}

- (void)setChildren:(NSMutableArray *)children
{
    [_children release];
    _children = [children retain];
}

#if defined(DEBUG) && IC_DEBUG_ICNODE_PARENTS
- (NSString *)dbgParentInfo
{
    return _dbgParentInfo;
}
#endif

@end