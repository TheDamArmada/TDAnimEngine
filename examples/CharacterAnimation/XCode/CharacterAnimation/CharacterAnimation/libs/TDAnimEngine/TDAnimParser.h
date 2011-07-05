//
//  TDAnimParser.h
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "TDAnimSpriteElement.h"
#import "TDAnimTransformation.h"
#import "TBXML.h"

@class TDAnimCharacter;


typedef struct 
{
    NSString    *name;
    NSString    *parent;
    NSString    *imagename;
    float       x;
    float       y;
    float       z;
    float       ax;
    float       ay;
    float       rz;
    float       sx;
    float       sy;
    
} NodeInfo;

@interface TDAnimParser : NSObject {
    
    TBXML   *tbxml;
    BOOL    useSpriteSheet;
}

-(BOOL) parseXML:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character;
-(BOOL) parseXMLAnimationFile:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character;
-(BOOL) parseXML:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character withAtlasFile:(NSString *)_atlasInfo;


@end
