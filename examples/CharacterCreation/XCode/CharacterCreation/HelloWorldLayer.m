//
//  HelloWorldLayer.m
//  CharacterCreation
//
//  Created by Jordi Martinez on 6/29/11.
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
		
        
        
        // BOTH WAYS ARE OK

//         This line will create the character using the individual PNG files        
//        TDAnimCharacter *robot = [TDAnimCharacter characterFromConfigFile:@"robot_config.xml"];
        
//         This line will use the SpriteSheet to create the character
        TDAnimCharacter *robot = [TDAnimCharacter characterFromConfigFile:@"robot_config.xml" andAtlasInfoFile:@"robot_sprtsheet"];
        
        [robot setPosition:ccp(500, 300)];        
        [self addChild:robot];         
        
        
        // you can control the indivual CCSprites like this:
        
        // TDAnimSpriteElement *arm = [robot getChildByName:@"ShoulderR"];
        // [arm setRotation:180];
        
        
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
