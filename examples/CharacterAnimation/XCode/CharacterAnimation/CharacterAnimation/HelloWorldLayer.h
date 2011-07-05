//
//  HelloWorldLayer.h
//  MayaToCocos2D
//
//  Created by Jordi Martinez on 6/24/11.
//  Copyright Wieden + Kennedy 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "TDAnimCharacter.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    TDAnimCharacter *robot;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
