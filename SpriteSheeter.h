//
//  SpriteSheeter.h
//
//
//  Created by Mark Morrill on 2011/11/15.
//  Copyright 2011 Cetuscript Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

#define fequal(a,b)     (fabsf((a) - (b)) < FLT_EPSILON)
#define fequalzero(a)   (fabsf(a) < FLT_EPSILON)
#define fequalone(a)    (fabsf((a) - 1.0f) < FLT_EPSILON)

@class SpriteSheeterObject;
@class ChipBody;
@class ChipShape;

@interface SpriteSheeter : CCSpriteBatchNode 
{
    NSDictionary*   _atlas;
}
@property (nonatomic, strong) NSDictionary*     atlas;
@property (nonatomic, readonly) CGFloat         screenScaleFactor;  // this is for the device's screen

+ (SpriteSheeter*) spriteSheeterWith:(NSString*) atlasName capacity:(NSUInteger)capacity;   // without .plist extension

- (NSArray*) arrayOfSpriteKeys;
- (SpriteSheeterObject*) spriteForKey:(NSString*)key objectScaleFactor:(CGFloat)objectScaleFactor;

- (CCSprite*) ccSpriteForKey:(NSString*)key objectScaleFactor:(CGFloat)objectScaleFactor;

@end

@interface SpriteSheeterObject : NSObject
{
    NSDictionary*   _dictionary;
    int             _type;
    CGPoint*        _verts;
}
@property (nonatomic, retain)   NSDictionary*   dictionary;
@property (nonatomic, readonly) CGRect          frame;
@property (nonatomic, readonly) CGRect          bounds;
@property (nonatomic, readonly) CGPoint         offset;
@property (nonatomic, readonly) CGFloat         mass;
@property (nonatomic, readonly) CGFloat         density;
@property (nonatomic, readonly) CGFloat         elasticity;
@property (nonatomic, readonly) CGFloat         friction;
@property (nonatomic, readonly) int             type;
@property (nonatomic, readonly) NSString*       typeStr;
@property (nonatomic, readonly) NSArray*        vertices;
@property (nonatomic, readonly) CGFloat         moment;
@property (nonatomic, readonly) CGFloat         outerRadius;
@property (nonatomic, readonly) CGFloat         innerRadius;
@property (nonatomic, readonly) CGPoint*        verts;      // made from vertices
@property (nonatomic, readonly) NSUInteger      vertCount;
@property (nonatomic, readonly) CGFloat         objectScaleFactor;  // this is for the object...
@property (nonatomic, assign) SpriteSheeter*    sheet;

+ (SpriteSheeterObject*) spriteSheeterObjectWith:(NSDictionary*) dictionary
                                        forSheet:(SpriteSheeter*)sheet
                               objectScaleFactor:(CGFloat)objectScaleFactor;

//- (ChipBody*) newBody;
- (ChipShape*) newShapeForBody:(ChipBody*)body;
- (CCSprite*) newSprite;
- (CGFloat) screenScaleFactor;

@end
