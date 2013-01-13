//
//  DraggableControl.m
//  icedcoffee-tests-ios
//
//  Created by Tobias Lensing on 9/10/12.
//  Copyright (C) 2013 Tobias Lensing. All rights reserved.
//

#import "DraggableControl.h"

@implementation DraggableControl

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        ICRectangle *rectangle = [ICRectangle viewWithSize:size];
        [self addChild:rectangle];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event
{
    ICTouch *touch = [touches anyObject];
    _locationInNode = [touch locationInNode:self];
}

- (void)touchesMoved:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event
{
    ICTouch *touch = [touches anyObject];
    CGPoint locationInHostView = [touch locationInHostView];
    [self setPosition:kmVec3Make(locationInHostView.x - _locationInNode.x,
                                 locationInHostView.y - _locationInNode.y, 0.0f)];
}

@end
