//
//  TDAnimSpriteElement.h
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TDAnimTransformation.h"

@interface TDAnimSpriteElement : CCSprite {
    
    NSString                *name;
    NSMutableDictionary    *animationTable;
    CGPoint                 originalLoc;
    float                   amplitude;
}

@property (nonatomic, retain) NSMutableDictionary   *animationTable;
@property (nonatomic, retain) NSString              *name;


-(void) setAnchorPointPixels:(CGPoint)_anchorPoint;

-(void) __processFrames;

-(void) __playFrame:(int)_frame forAnimation:(NSString *)_anim;

-(void) __dumpAnimations;

-(void) __setAmplitude:(float)_amp;

-(void) applyLocAtAxis:(NSString *)_axis value:(float)_val;
-(void) applyRotAtAxis:(NSString *)_axis value:(float)_val;
-(void) applySclAtAxis:(NSString *)_axis value:(float)_val;


-(TDAnimTransformation *) __getTransformationType:(NSString *)_type fromFrameTransformation:(NSArray *)_translist;
-(TDAnimTransformation *) __getNextTransformationType:(NSString *)_type fromFrameNumber:(int)_f onAnimation:(NSString *)_anStr;

@end
