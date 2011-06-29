//
//  TDAnimCharacter.h
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "TDAnimParser.h"
#import "TDAnimSpriteElement.h"
#import "TDAnimEvent.h"

@protocol TDAnimCharacter_Delegate;

@interface TDAnimCharacter : CCNode {

    id <TDAnimCharacter_Delegate> delegate;
    
    NSMutableDictionary     *childrenTable;
    TDAnimParser            *parser;
    
    NSMutableDictionary     *animationTable;
    NSMutableArray          *eventsTable;
    
    BOOL                    isRunning;
    BOOL                    currentAnimLoopable;
    
    int                     currentAnimLength;
    NSString                *currentAnimStr;
    
    NSString                *nextAnimStr;
    BOOL                    nextAnimLoopable;
    
    float                   FPS;
    float                   time;
    int                     currentFrame;
    int                     prevFrame;
    
    float                   amplitude;
}

@property (nonatomic, assign) id <TDAnimCharacter_Delegate> delegate;

@property (nonatomic, retain) NSMutableDictionary *childrenTable;


+(TDAnimCharacter *) character;
+(TDAnimCharacter *) characterFromConfigFile:(NSString *)_fileStr;
+(TDAnimCharacter *) characterFromConfigFile:(NSString *)_fileStr andAtlasInfoFile:(NSString *)_atlasInfo;

-(void) createCharacterWithXMLFile:(NSString *)_xmlStr andAtlasInfoFile:(NSString *)_atlasInfo;
-(void) createCharacterWithXMLFile:(NSString *)_xmlStr;


-(void) createCharacterAnimationsFromXML:(NSString *)_xmlStr;
// LOOP

-(void) tick:(ccTime)_timeDif;

-(void) debug;
-(void) drawRectangle:(CCSprite *)_sprite;

// ANIMATION MANAGEMENT


-(void) parseAnimations;
-(void) setAmplitude:(float)_amplitude;
-(void) playAnimation:(NSString *)_animStr loop:(BOOL)_loop wait:(BOOL)_wait;
-(void) stopAnimation;
-(void) setFPS:(float)_fps;


-(NSString *) getCurrentAnimation;

// EVENTS MANAGEMENT

-(void)             __parseEvents:(NSMutableDictionary *)_evtsList;
-(void)             executeEvent:(TDAnimEvent *)_evt;
-(TDAnimEvent *)    getEventForFrame:(int)_frame inAnimation:(NSString *)_animStr;




// CHILDREN MANAGEMENT

-(void)                     addElement:(TDAnimSpriteElement *)_element withName:(NSString *)_name andParent:(NSString *)_parentStr;
-(TDAnimSpriteElement *)    getChildByName:(NSString *)_name;


@end


@protocol TDAnimCharacter_Delegate <NSObject>

@optional
-(void) characterFrameChanged:(float)_animNormalizedFrame;
-(void) characterAnimationStarted:(NSString *)_animStr;
-(void) characterAnimationStopped;
-(void) characterAnimationLooped:(NSString *)_animStr;

@end
