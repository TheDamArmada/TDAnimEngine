//
//  HelloWorldLayer.m
//  MayaToCocos2D
//
//  Created by Jordi Martinez on 6/24/11.
//  Copyright Wieden + Kennedy 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        robot = [TDAnimCharacter characterFromConfigFile:@"robot_config.xml"];
        [robot setPosition:ccp(500, 300)];   
        [robot createCharacterAnimationsFromXML:@"robot_anim.xml"];
        
        [self addChild:robot];        
        
        [robot playAnimation:@"waving" loop:YES wait:NO];
    }
	return self;
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
