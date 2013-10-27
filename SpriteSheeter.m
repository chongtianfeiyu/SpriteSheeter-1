//
//  SpriteSheeter.m
//  
//
//  Created by Mark Morrill on 2011/11/15.
//  Copyright 2011 Cetuscript Systems. All rights reserved.
//

#import "SpriteSheeter.h"
#import "ChipBody.h"
#import "ChipShape.h"

static NSString* const SpriteSheeter_ImageKey           = @"image";
static NSString* const SpriteSheeter_SpritesKey         = @"sprites";
static NSString* const SpriteSheeterObject_BoundsKey    = @"bounds";
static NSString* const SpriteSheeterObject_FrameKey     = @"frame";
static NSString* const SpriteSheeterObject_MassKey      = @"mass";
static NSString* const SpriteSheeterObject_DensityKey   = @"density";
static NSString* const SpriteSheeterObject_ElasticityKey= @"elasticity";
static NSString* const SpriteSheeterObject_FrictionKey  = @"friction";
static NSString* const SpriteSheeterObject_OffsetKey    = @"offset";
static NSString* const SpriteSheeterObject_TypeKey      = @"type";
static NSString* const SpriteSheeterObject_VerticesKey  = @"vertices";
static NSString* const SpriteSheeterObject_InnerRadiusKey   = @"inner_radius";

static NSString* const SpriteSheeterType_Box            = @"box";
static NSString* const SpriteSheeterType_Circle         = @"circle";
static NSString* const SpriteSheeterType_Polygon        = @"polygon";

enum
{
    tat_Box,
    tat_Circle,
    tat_Polygon
};

@implementation SpriteSheeter

- (NSDictionary*) sprites
{
    return [_atlas objectForKey:SpriteSheeter_SpritesKey]; 
}

- (id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
    if( nil != (self = [super initWithFile:fileImage capacity:capacity] ) )
    {
        _screenScaleFactor = 1.0 / CC_CONTENT_SCALE_FACTOR();
    }
    return self;
}

+ (SpriteSheeter *)spriteSheeterWith:(NSString *)atlasName capacity:(NSUInteger)capacity
{
    NSString*       path            = [[NSBundle mainBundle] pathForResource:atlasName ofType:@"plist"];
    NSDictionary*   atlas           = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString*       imageFile       = [atlas objectForKey:SpriteSheeter_ImageKey];

    SpriteSheeter*  spriteSheeter   = [[SpriteSheeter alloc] initWithFile:imageFile
                                                                  capacity:capacity];
    
    if( nil != spriteSheeter )
        spriteSheeter.atlas = atlas;
    
    return spriteSheeter;
}

- (NSArray*) arrayOfSpriteKeys
{
    NSDictionary*   sprites = [self sprites];
    return [sprites allKeys];
}

- (SpriteSheeterObject*) spriteForKey:(NSString*)key objectScaleFactor:(CGFloat)objectScaleFactor
{
    return [SpriteSheeterObject spriteSheeterObjectWith:[[self sprites] objectForKey:key]
                                               forSheet:self
                                      objectScaleFactor:objectScaleFactor];
}

- (CCSprite*) ccSpriteForKey:(NSString*)key objectScaleFactor:(CGFloat)objectScaleFactor
{
    SpriteSheeterObject*    object = [self spriteForKey:key objectScaleFactor:objectScaleFactor];
    if( nil == object )
        return nil;
    
    CGRect      bounds  = object.bounds;
    CCSprite*   sprite  = [CCSprite spriteWithTexture:self.texture rect:bounds];
	//[sprite setBatchNode:self];
    [sprite setScale:objectScaleFactor];
	return sprite;
}


@end

@implementation SpriteSheeterObject
@synthesize dictionary = _dictionary;
@synthesize bounds, frame, offset, mass, typeStr, vertices, moment, vertCount;
@synthesize type = _type;
@synthesize verts = _verts;
@synthesize sheet = _sheet;

- (id) initWithDictionary:(NSDictionary*)dictionary
                 forSheet:(SpriteSheeter *)sheet
        objectScaleFactor:(CGFloat)objectScaleFactor
{
    NSParameterAssert(!fequalzero(objectScaleFactor));
    
    if( nil != (self = [super init] ) )
    {
        _sheet              = sheet;
        _dictionary         = dictionary;
        _verts              = NULL;
        _type               = -1;
        _objectScaleFactor  = objectScaleFactor;

    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"--- SpriteSheeterObject dealloc ---");
    if( NULL != _verts )
        free( _verts );
}

+ (SpriteSheeterObject*) spriteSheeterObjectWith:(NSDictionary*) dictionary
                                        forSheet:(SpriteSheeter *)sheet
                               objectScaleFactor:(CGFloat)objectScaleFactor
{
    return [[SpriteSheeterObject alloc] initWithDictionary:dictionary
                                                  forSheet:sheet
                                         objectScaleFactor:objectScaleFactor];
}

- (CGFloat)screenScaleFactor
{
    return _sheet.screenScaleFactor;
}

- (CGRect)bounds
{
    NSArray*    box = [_dictionary objectForKey:SpriteSheeterObject_BoundsKey];
    CGRect      theBounds;
    CGFloat     screenScaleFactor = self.screenScaleFactor;
    
    theBounds.origin.x = [[box objectAtIndex:0] floatValue] * screenScaleFactor;
    theBounds.origin.y = [[box objectAtIndex:1] floatValue] * screenScaleFactor;
    theBounds.size.width = [[box objectAtIndex:2] floatValue] * screenScaleFactor;
    theBounds.size.height = [[box objectAtIndex:3] floatValue] * screenScaleFactor;
    
    return theBounds;
}

- (CGRect)frame
{
    NSArray*    box = [_dictionary objectForKey:SpriteSheeterObject_FrameKey];
    CGRect      theFrame;
    CGFloat     scaleFactor = self.screenScaleFactor * _objectScaleFactor;
    
    theFrame.origin.x = [[box objectAtIndex:0] floatValue] * scaleFactor;
    theFrame.origin.y = [[box objectAtIndex:1] floatValue] * scaleFactor;
    theFrame.size.width = [[box objectAtIndex:2] floatValue] * scaleFactor;
    theFrame.size.height = [[box objectAtIndex:3] floatValue] * scaleFactor;
    
    return theFrame;
}


- (CGPoint)offset
{
    NSArray*    array       = [_dictionary objectForKey:SpriteSheeterObject_OffsetKey];
    CGPoint     theOffset;
    CGFloat     scaleFactor = self.screenScaleFactor * _objectScaleFactor;
    
    theOffset.x = [[array objectAtIndex:0] floatValue] * scaleFactor;
    theOffset.y = [[array objectAtIndex:1] floatValue] * scaleFactor;
    
    //NSLog( @"self.offset = (%f,%f)", theOffset.x, theOffset.y );
    
    return theOffset;
}

- (CGFloat)mass
{
    return [[_dictionary objectForKey:SpriteSheeterObject_MassKey] floatValue];
}

- (CGFloat)density
{
    return [[_dictionary objectForKey:SpriteSheeterObject_DensityKey] floatValue];
}

- (CGFloat)elasticity
{
    return [[_dictionary objectForKey:SpriteSheeterObject_ElasticityKey] floatValue];
}

- (CGFloat)friction
{
    return [[_dictionary objectForKey:SpriteSheeterObject_FrictionKey] floatValue];
}

- (NSString *)typeStr
{
    return [_dictionary objectForKey:SpriteSheeterObject_TypeKey];
}

- (int)type
{
    if( _type < 0 )
    {
        NSString*   theType = self.typeStr;
        if( [theType isEqualToString:SpriteSheeterType_Box] )
            _type = tat_Box;
        else if( [theType isEqualToString:SpriteSheeterType_Circle] )
            _type = tat_Circle;
        else if( [theType isEqualToString:SpriteSheeterType_Polygon] )
            _type = tat_Polygon;
        NSAssert( _type >= 0, @"Invalid Shape Type" );
    }
    return _type;
}

- (NSArray *)vertices
{
    return [_dictionary objectForKey:SpriteSheeterObject_VerticesKey];
}

- (NSUInteger)vertCount
{
    return [self.vertices count] / 2;
}

- (CGPoint *)verts
{
    NSAssert( tat_Polygon == self.type, @"verts are only for polygons" );
    
    if( NULL == _verts )
    {
        NSArray*    theVertArray    = self.vertices;
        NSUInteger  count           = [theVertArray count] / 2;
        if( count )
        {
            _verts  = malloc( sizeof(CGPoint) * count );
            if( NULL != _verts )
            {
                CGFloat     scaleFactor = self.screenScaleFactor * _objectScaleFactor;
                NSUInteger  i;
                for( i=0; i<count; ++i )
                {
                    _verts[i].x = [[theVertArray objectAtIndex:i*2] floatValue] * scaleFactor;
                    _verts[i].y = [[theVertArray objectAtIndex:(i*2) + 1] floatValue] * scaleFactor;
                }

                /*
                NSLog( @"examine the verts" );
                for( i=0; i<count; ++i )
                {
                    NSLog( @"vert(%0.0f, %0.0f)", _verts[i].x, _verts[i].y );
                }
                 */
                
                if( !cpPolyValidate( _verts, (int) count ) )  // how is the winding?
                {
                    //NSLog( @"---" );
                    //NSLog( @"winding is wrong" );
                    // I'm hoping we are not concave. let's reverse the winding
                    NSUInteger  j = count - 1;
                    CGPoint     temp;
                    for( i=0; i<j; ++i, --j )
                    {
                        temp = _verts[i];
                        _verts[i] = _verts[j];
                        _verts[j] = temp;
                    }
                    
                    /*
                    for( i=0; i<count; ++i )
                    {
                        NSLog( @"vert(%0.0f, %0.0f)", _verts[i].x, _verts[i].y );
                    }
                     */
                }
            }
        }
    }
    return _verts;
}

- (CGFloat)outerRadius
{
    CGRect  theFrame = self.frame;
    // height and width should be the same.... let's average them but they should be inputed as the same
    return (theFrame.size.width + theFrame.size.height) * 0.25;
}

- (CGFloat)innerRadius
{
    return [[_dictionary objectForKey:SpriteSheeterObject_InnerRadiusKey] floatValue] * _objectScaleFactor * _sheet.screenScaleFactor;
}

- (CGFloat)moment
{
    switch( self.type )
    {
        case tat_Box:
        {
            CGRect theFrame    = self.frame;
            return cpMomentForBox( self.mass, theFrame.size.width, theFrame.size.height );
        }
        case tat_Circle:
            return cpMomentForCircle( self.mass, self.innerRadius, self.outerRadius, self.offset );
        case tat_Polygon:
            return cpMomentForPoly( self.mass, (int) self.vertCount, self.verts, self.offset );
    }
    
    return 0.0f;
}

/*
- (ChipBody*) newBody
{
    return [ChipBody bodyWithMass:self.mass andMoment:self.moment];
}
*/

- (ChipShape*) makeNewBoxShapeForBody:(ChipBody*)body
{
    CGRect      theFrame   = self.frame;
    return [ChipPolyShape boxWithBody:body
                                width:theFrame.size.width
                               height:theFrame.size.height];
}


- (ChipShape*) makeNewPolyShapeForBody:(ChipBody*)body
{
    ChipShape*  shape   = [ChipPolyShape polyWithBody:body
                                                count:(int)self.vertCount
                                                verts:self.verts
                                               offset:self.offset];
    
    return shape;
}

- (ChipShape*) makeNewCircleShapeForBody:(ChipBody*)body
{
    return [ChipCircleShape circleWithBody:body
                                    radius:self.outerRadius
                                    offset:self.offset];
}

- (ChipShape*) newShapeForBody:(ChipBody*)body
{
    ChipShape*  shape = nil;
    switch( self.type )
    {
        case tat_Box:
            shape = [self makeNewBoxShapeForBody:body];
            break;
            
        case tat_Circle:
            shape = [self makeNewCircleShapeForBody:body];
            break;

        case tat_Polygon:
            shape = [self makeNewPolyShapeForBody:body];
            break;
    }
    
    if( shape )
    {
        shape.elasticity = self.elasticity;
        shape.friction = self.friction;
    }
    
    return shape;
}

- (CCSprite*) newSprite
{
	CCSprite*   sprite = [CCSprite spriteWithTexture:_sheet.texture rect:self.bounds];
	[sprite setBatchNode:_sheet];
    [sprite setScale:_objectScaleFactor];
	return sprite;
}


@end
