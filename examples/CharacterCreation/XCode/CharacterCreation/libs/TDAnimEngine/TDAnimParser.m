//
//  TDAnimParser.m
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import "TDAnimParser.h"
#import "TDAnimCharacter.h"

@implementation TDAnimParser



//-(BOOL) parseXML:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character
//{
    
-(BOOL) parseXMLAnimationFile:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character
{
   
    tbxml = [[TBXML tbxmlWithXMLFile:_fileStr] retain];
    
    TBXMLElement    *_root = tbxml.rootXMLElement;
    

    
    if (_root) {
        
        NSMutableSet *elementsToProcess = [NSMutableSet set];
        
        
        TBXMLElement *_animationsList = [TBXML childElementNamed:@"animations" parentElement:_root];
        
        TBXMLElement *_animations = [TBXML childElementNamed:@"animation" parentElement:_animationsList];
        
        while (_animations != nil) {
            
            NSString *animName = (NSString *)[TBXML valueOfAttributeNamed:@"id" forElement:_animations];

            
            // NODE PARSING
            
            TBXMLElement *_nodeList = [TBXML childElementNamed:@"nodes" parentElement:_animations];
            
            TBXMLElement *_nodes = [TBXML childElementNamed:@"node" parentElement:_nodeList];
            
            while (_nodes != nil) {
                
                NSString *nodeName = (NSString *)[TBXML valueOfAttributeNamed:@"id" forElement:_nodes];

                TDAnimSpriteElement *element = [_character getChildByName:nodeName];
                                
                NSMutableDictionary *frameInformation = [NSMutableDictionary dictionary];
                
                
                
                TBXMLElement *_frames = [TBXML childElementNamed:@"frame" parentElement:_nodes];
                
                while (_frames != nil) {
                    
                    int frameNumber = [[TBXML valueOfAttributeNamed:@"id" forElement:_frames] intValue];
                    
                    NSMutableArray *transformation = [NSMutableArray array];
                    
                    
                    
                    TBXMLElement  *_transformations = [TBXML childElementNamed:@"transform" parentElement:_frames];
                    
                    while (_transformations != nil) {
                        
                        
                        NSString *type = (NSString *)[TBXML valueOfAttributeNamed:@"attr" forElement:_transformations];
                        float    value = [[TBXML valueOfAttributeNamed:@"value" forElement:_transformations] floatValue];
                    
                        TDAnimTransformation *trans = [[TDAnimTransformation alloc] initWithType:type andValue:value forFrame:frameNumber-1];
                        
                        [transformation addObject:trans];
                                                
                        _transformations = [TBXML nextSiblingNamed:@"transform" searchFromElement:_transformations];
                                             
                    }
                    
                    [frameInformation setValue:transformation forKey:[NSString stringWithFormat:@"F%i", (frameNumber-1)]];
                    
                    _frames = [TBXML nextSiblingNamed:@"frame" searchFromElement:_frames];
                }
        
                
                [element.animationTable setValue:frameInformation forKey:animName];
                
                [elementsToProcess addObject:element];
                                

                 _nodes = [TBXML nextSiblingNamed:@"node" searchFromElement:_nodes];
            }
            
                        
            _animations = [TBXML nextSiblingNamed:@"animation" searchFromElement:_animations];

            
        }
        
        // process all the keyframes
        
        [_character parseAnimations];
        
        
        // PARSE EVENTS
        
        
         
         // EVENTS PARSING
         
        NSMutableDictionary *eventsDict = [NSMutableDictionary dictionary];
         
        
        TBXMLElement *_eventsList = [TBXML childElementNamed:@"events" parentElement:_root];
        
        
        if (_eventsList!=nil)
        {
        
            TBXMLElement *_aniEvents = [TBXML childElementNamed:@"animation" parentElement:_eventsList];
            
            while (_aniEvents != nil) {
             
                NSString *animEventStr = [TBXML valueOfAttributeNamed:@"id" forElement:_aniEvents];
             
                
                NSMutableDictionary *evList = [NSMutableDictionary dictionary];
                
                TBXMLElement *_event = [TBXML childElementNamed:@"event" parentElement:_aniEvents];
                
                while (_event !=nil) {
                    
                    NSString *eventType = [TBXML valueOfAttributeNamed:@"type" forElement:_event];
                    int         frame   = [[TBXML valueOfAttributeNamed:@"frame" forElement:_event] intValue];
                    
                    TDAnimEvent *tdaEv = [[TDAnimEvent alloc] initWithEvent:eventType atFrame:frame];
                                    
                    [evList setValue:tdaEv forKey:[NSString stringWithFormat:@"F%i", frame]];
                    
                    _event = [TBXML nextSiblingNamed:@"event" searchFromElement:_event];
                }
                
                [eventsDict setValue:evList forKey:animEventStr];
           
                _aniEvents = [TBXML nextSiblingNamed:@"animation" searchFromElement:_aniEvents];
            }          
        } 
        
        [_character __parseEvents:eventsDict];
        
        [tbxml release];
        
        return YES;
    }
    
    [tbxml release];
    
    return NO;
}



-(BOOL) parseXML:(NSString *)_xmlStr toCharacter:(TDAnimCharacter *)_character
{
    tbxml = [[TBXML tbxmlWithXMLFile:_xmlStr] retain];
    
    TBXMLElement    *_root = tbxml.rootXMLElement;
    
    float RATIO;
    
    
    if (_root) {
        
        TBXMLElement *_configNodesList = [TBXML childElementNamed:@"nodesConfig" parentElement:_root];

        TBXMLElement *_configNode = [TBXML childElementNamed:@"node" parentElement:_configNodesList];
        
        NSString *parentId = @"";
        NSString *nodeName = @"";
        NSString *imageName = @"";
        float _width;
        float _height;
        
        // FIND THE ROOT NODE
        

        while ([parentId isEqualToString:@"root"]==NO) {
        
            nodeName    = [TBXML valueOfAttributeNamed:@"id" forElement:_configNode];
            parentId    = [TBXML valueOfAttributeNamed:@"parent" forElement:_configNode];
            _width      = [[TBXML valueOfAttributeNamed:@"w" forElement:_configNode] floatValue];
            _height     = [[TBXML valueOfAttributeNamed:@"h" forElement:_configNode] floatValue];
            imageName   = [TBXML valueOfAttributeNamed:@"image" forElement:_configNode];            
            _configNode = [TBXML nextSiblingNamed:@"node" searchFromElement:_configNode];            
        }
        
        
        CCSprite *__rootSp = [CCSprite spriteWithFile:imageName];
        CGSize sprSize = [__rootSp contentSize];
        float sprW = sprSize.width;
                
        RATIO = fabsf(_width/sprW);

        
        _configNode = [TBXML childElementNamed:@"node" parentElement:_configNodesList];
        
        NSMutableDictionary *nodesDict = [NSMutableDictionary dictionary];
        
        while (_configNode != nil) {

            
            // create struct object
            NSString *_nodename = [TBXML valueOfAttributeNamed:@"id" forElement:_configNode];
            
            
            NSString *_parentname = [TBXML valueOfAttributeNamed:@"parent" forElement:_configNode];            
            if ([_parentname isEqualToString:@"root"] || [_parentname isEqualToString:@""]) _parentname = nil;

            NSString *_imagename = [TBXML valueOfAttributeNamed:@"image" forElement:_configNode];
            
            float apx = [[TBXML valueOfAttributeNamed:@"apx" forElement:_configNode] floatValue] / RATIO;
            float apy = [[TBXML valueOfAttributeNamed:@"apy" forElement:_configNode] floatValue] / RATIO;            
            
            float x = [[TBXML valueOfAttributeNamed:@"x" forElement:_configNode] floatValue] / RATIO;            
            float y = [[TBXML valueOfAttributeNamed:@"y" forElement:_configNode] floatValue] / RATIO;  
            float z = [[TBXML valueOfAttributeNamed:@"z" forElement:_configNode] floatValue];
            float rz = [[TBXML valueOfAttributeNamed:@"rz" forElement:_configNode] floatValue] * -1;
            float sx = [[TBXML valueOfAttributeNamed:@"sx" forElement:_configNode] floatValue];
            float sy = [[TBXML valueOfAttributeNamed:@"sy" forElement:_configNode] floatValue];
            
            z = (int)round(z*100);
            
            NodeInfo info;
            info.name = _nodename;
            info.parent = _parentname;
            info.x = x;
            info.y = y;
            info.z = z;
            info.ax = apx;
            info.ay = apy;
            info.rz = rz;
            info.sx = sx;
            info.sy = sy;
            
            
            [nodesDict setValue:[NSValue value:&info withObjCType:@encode(NodeInfo)] forKey:_nodename];
            
            NSLog(@"CREATE SPRITE WITH %@", _imagename);
                            
            TDAnimSpriteElement *spEl;
            
            if (!useSpriteSheet)
                spEl = [TDAnimSpriteElement spriteWithFile:_imagename];
            else
                spEl = [TDAnimSpriteElement spriteWithSpriteFrameName:_imagename];
            
            
            CCNode *parentEl = (_parentname != nil)? (CCNode *)[_character getChildByName:_parentname] : (CCNode *) _character;
            
            CGPoint worldAP = ccp(apx, apy);
            
            if (_parentname != nil)
            {
                NSString *pprnt = [NSString stringWithString:_parentname];
                
               while (pprnt != nil && ![pprnt isEqualToString:@""])
                {
                // get original info
                    NodeInfo parentInfo;
                    [[nodesDict objectForKey:pprnt] getValue:&parentInfo];
                    
                    x+= parentInfo.x;
                    y+= parentInfo.y;
                    
                    pprnt = parentInfo.parent;
                    
                }
            } 
            
            [spEl setPosition:ccp(x, y)];

            
            CGPoint objAP = [spEl convertToNodeSpace:worldAP];            
            CGSize oSize = [spEl contentSize];
            apx = objAP.x / oSize.width;
            apy = objAP.y / oSize.height;
                       
            
            CGPoint oldAPabsolute=spEl.anchorPointInPixels;             
            CGPoint newAnchorPoint = ccp(apx, apy);            
            CGPoint newAPabsolute=ccp(newAnchorPoint.x*spEl.contentSize.width*spEl.scaleX,newAnchorPoint.y*spEl.contentSize.height*spEl.scaleY);            
            CGPoint translation = ccpSub([spEl convertToWorldSpace:newAPabsolute],[spEl convertToWorldSpace:oldAPabsolute]);
            
           
            [spEl setPosition:ccpAdd(spEl.position,translation)];
            [spEl setAnchorPoint:newAnchorPoint];

            if (_parentname != nil && ![_parentname isEqualToString:@""])
            {
                
                CGPoint newPos = [parentEl convertToNodeSpace:spEl.position];                
                [spEl setPosition:newPos];
                
            } 
            
            
            [_character addElement:spEl withName:_nodename andParent:_parentname];                
            [parentEl reorderChild:spEl z:z];                

            _configNode = [TBXML nextSiblingNamed:@"node" searchFromElement:_configNode];
        }
        
        
        // SET ROTATIONS
        
        for (NSString *nodinf in nodesDict)
        {
            NodeInfo node;
            [[nodesDict objectForKey:nodinf] getValue:&node];
            
            TDAnimSpriteElement *el = [_character getChildByName:node.name];
            [el setRotation:node.rz];
        }             
    }

    return  YES;
}



-(BOOL) parseXML:(NSString *)_fileStr toCharacter:(TDAnimCharacter *)_character withAtlasFile:(NSString *)_atlasInfo
{    
    useSpriteSheet = YES;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", _atlasInfo]];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", _atlasInfo]];
    [_character addChild:spriteSheet];
        
    return [self parseXML:_fileStr toCharacter:_character];
}





@end
