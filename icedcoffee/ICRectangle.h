//
//  ICRectangle.h
//  icedcoffee-mac
//
//  Created by Marcus Tillmanns on 6/16/12.
//

#import "ICView.h"

@class ICSprite;

@interface ICRectangle : ICView
{
@protected
    ICSprite* _sprite;
    float     _borderWidth;
    
}

@property (nonatomic, assign)float borderWidth;

@end
