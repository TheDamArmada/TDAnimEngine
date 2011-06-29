//
//  TDAnimCharacter.m
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import "TDAnimCharacter.h"


@implementation TDAnimCharacter

@synthesize childrenTable, delegate;

// OVERWRITTABLE


// ----------------------------------------------------------


-(void) executeEvent:(TDAnimEvent *)_evt
{
    NSLog(@"EVENT: %@", _evt.event);
}



// ----------------------------------------------------------



-(void) dealloc
{
    delegate = nil;
    [childrenTable release];
    [super dealloc];
}

+(TDAnimCharacter *) character
{
    return [[[self alloc] init] autorelease]; 
    
}

+(TDAnimCharacter *) characterFromConfigFile:(NSString *)_fileStr
{
    TDAnimCharacter *character = [[[self alloc] init] autorelease];
    [character createCharacterWithXMLFile:_fileStr];

    return character;
}

+(TDAnimCharacter *) characterFromConfigFile:(NSString *)_fileStr andAtlasInfoFile:(NSString *)_atlasInfo
{
    TDAnimCharacter *character = [[[self alloc] init] autorelease];
    [character createCharacterWithXMLFile:_fileStr andAtlasInfoFile:_atlasInfo];
    
    return character;
}



-(id) init
{
    self = [super init];
    if (self) {
        self.childrenTable  = [NSMutableDictionary dictionary];
        FPS                 = 1/24.0f;
        eventsTable         = [NSMutableArray array];
        amplitude           = 1.0f;
    }
    return self;
}

-(void) debug
{
    glColor4f(1, 0, 0, 1);
    glLineWidth(30.0);
    
    
    for (NSString *el in childrenTable)
    {
        [self drawRectangle:(CCSprite *)[self getChildByName:el]];
    }    
}


-(void) drawRectangle:(CCSprite *)_sprite
{
    CGSize s = [_sprite contentSize];
    CGRect r = CGRectMake(-s.width / 2 + _sprite.anchorPointInPixels.x, -s.height / 2 + _sprite.anchorPointInPixels.y, s.width, s.height);
    r.origin.x -= (_sprite.anchorPointInPixels.x);
    r.origin.y += (_sprite.anchorPointInPixels.y/2);
    
    ccDrawLine(ccp(r.origin.x, r.origin.y), ccp(r.origin.x+r.size.width, r.origin.y));
    ccDrawLine(ccp(r.origin.x + r.size.width, r.origin.y), ccp(r.origin.x + r.size.width, r.origin.y + r.size.height));
    ccDrawLine(ccp(r.origin.x + r.size.width, r.origin.y + r.size.height), ccp(r.origin.x, r.origin.y + r.size.height));
    ccDrawLine(ccp(r.origin.x, r.origin.y + r.size.height), ccp(r.origin.x, r.origin.y));

    
}
// LOOP

-(void) tick:(ccTime)_timeDif
{
    [self debug];
    
    time    += _timeDif;
    
    currentFrame = (int)(time/FPS) % currentAnimLength;
    
    if (currentFrame==prevFrame) return;
    
    prevFrame = currentFrame;
    
    // PLAY FRAMES FOR ELEMENTS
    
    for (NSString *elStr in childrenTable)
    {
        
        TDAnimSpriteElement *el = [childrenTable valueForKey:elStr];
        
        [el __playFrame:currentFrame forAnimation:currentAnimStr];
    }

    
    // EXECUTE EVENT IF THERE'S ANY
    TDAnimEvent *evt = [self getEventForFrame:currentFrame inAnimation:currentAnimStr];
    
    if (evt!=nil) 
    {
        [self executeEvent:evt];
    }
    
    
    // delegate: frameChanged
    if ([delegate respondsToSelector:@selector(characterFrameChanged:)])
        [delegate characterFrameChanged:(currentFrame/currentAnimLength)];
    
    
    if (currentFrame == currentAnimLength-1)
    {
        if ([delegate respondsToSelector:@selector(characterAnimationLooped:)])
            [delegate characterAnimationLooped:currentAnimStr];
        
        if (nextAnimStr != nil) 
        {
            [self playAnimation:nextAnimStr loop:nextAnimLoopable wait:NO];
            nextAnimStr = nil;
            nextAnimLoopable = NO;
            
        } else {
            
            if (currentAnimLoopable == NO) {
                
                [self stopAnimation];
                
            }
            
        }
    }    

}


-(void) stopAnimation
{
    if (!isRunning) return;
    
    // delegate animationStopped
    if ([delegate respondsToSelector:@selector(characterAnimationStopped)])
        [delegate characterAnimationStopped];
    
    isRunning= NO;    
    [self unschedule:@selector(tick:)];
}



// ANIMATION MANAGEMENT



-(void) setAmplitude:(float)_amplitude
{
    amplitude = _amplitude;
    
    for (NSString *elStr in childrenTable)
    {
        
        TDAnimSpriteElement *el = [childrenTable valueForKey:elStr];
        
        [el __setAmplitude:amplitude];
    }
}


-(void) parseAnimations
{

    
    // we need to know how long each animation takes
    // we look through all the children looking for animiations and their length
    
    NSMutableDictionary *animsList = [NSMutableDictionary dictionary];
    
    for (NSString *childStr in self.childrenTable)
    {
        // first we process the frames
        
        TDAnimSpriteElement *child = [childrenTable valueForKey:childStr];
        [child __processFrames];
        
        // and then we add the animation if necessary
        
        NSDictionary *childAnims = [child animationTable];
        for (NSString *animStr in childAnims)
        {
            if ([animsList valueForKey:animStr]==nil)
            {
                [animsList setValue:[NSNumber numberWithInt:[[childAnims valueForKey:animStr] count]] forKey:animStr];
            }
        }
    }
    
    animationTable = [animsList retain];        
}





-(void) playAnimation:(NSString *)_animStr loop:(BOOL)_loop wait:(BOOL)_wait
{
    currentAnimLoopable = _loop;
    
    if (_wait == NO || currentAnimStr == nil)
    {        
        if ([delegate respondsToSelector:@selector(characterAnimationStarted:)])
            [delegate characterAnimationStarted:_animStr];
        
        currentAnimStr      = _animStr;
        currentAnimLength   = [[animationTable valueForKey:currentAnimStr] intValue];
        time                = 0;
    } else {
        
        nextAnimStr         = _animStr;
        nextAnimLoopable    = _loop;
    }
    
    if (isRunning == NO) 
    {
        isRunning = YES;
        [self schedule:@selector(tick:)];        
    }
}


-(void) setFPS:(float)_fps
{
    FPS = _fps;
}


-(NSString *) getCurrentAnimation 
{
    return currentAnimStr;
}


// EVENTS MANAGEMENT

-(void) __parseEvents:(NSMutableDictionary *)_evtsList
{
    eventsTable = [_evtsList retain];
    
}


-(TDAnimEvent *) getEventForFrame:(int)_frame inAnimation:(NSString *)_animStr
{    
    if (eventsTable.count==0) return nil;
    
    NSDictionary *animEvents = [eventsTable valueForKey:_animStr];
    
    return (TDAnimEvent*)[animEvents valueForKey:[NSString stringWithFormat:@"F%i", _frame]];
}



// CHILDREN MANAGEMENT

-(TDAnimSpriteElement *) getChildByName:(NSString *)_name 
{
    return (TDAnimSpriteElement *)[self.childrenTable valueForKey:_name];
}



-(void) addElement:(TDAnimSpriteElement *)_element withName:(NSString *)_name andParent:(NSString *)_parentStr
{
    CCNode  *parent = self;
    
    if (_parentStr!=nil) parent = [self getChildByName:_parentStr];
    
    [parent addChild:_element];
    
    [_element setName:_name];
    
    [self.childrenTable setValue:_element forKey:_name];
}


// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------



-(void) createCharacterAnimationsFromXML:(NSString *)_xmlStr
{
    BOOL success = [[[[TDAnimParser alloc] init] autorelease] parseXMLAnimationFile:_xmlStr toCharacter:self];
    if (!success) NSLog(@"TDA >> There was an error parsing the animation xml file %@", _xmlStr);
}

-(void) createCharacterWithXMLFile:(NSString *)_xmlStr
{
    BOOL success = [[[[TDAnimParser alloc] init] autorelease] parseXML:_xmlStr toCharacter:self];
    
    if (!success) NSLog(@"TDA >> There was an error parsing the configuration xml file %@", _xmlStr);
}

-(void) createCharacterWithXMLFile:(NSString *)_xmlStr andAtlasInfoFile:(NSString *)_atlasInfo
{
    BOOL success = [[[[TDAnimParser alloc] init] autorelease] parseXML:_xmlStr toCharacter:self withAtlasFile:_atlasInfo];
    
    if (!success) NSLog(@"TDA >> The was an error parsing either the configuration file %@ or the atlasinfo file %@", _xmlStr, _atlasInfo);
}


@end
