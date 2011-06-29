//
//  TDAnimSpriteElement.m
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import "TDAnimSpriteElement.h"


@implementation TDAnimSpriteElement

@synthesize animationTable, name;

-(void) dealloc
{
    [name release];
    [animationTable release];
    [super dealloc];
}


-(id) init 
{
    self = [super init];
    
    if (self)
    {        
        self.animationTable = [NSMutableDictionary dictionary];   
        amplitude = 1.0f;
    }
    return self;
}




-(void) setAnchorPointPixels:(CGPoint)_anchorPoint;
{
    float ax = _anchorPoint.x/self.contentSize.width;
    float ay = (self.contentSize.height-_anchorPoint.y)/self.contentSize.height;
    
    [self setAnchorPoint:CGPointMake(ax, ay)];
}


-(void) __playFrame:(int)_frame forAnimation:(NSString *)_anim
{
    NSArray *transfList = [[self.animationTable valueForKey:_anim] objectAtIndex:_frame];
        
    for (unsigned int t=0; t < transfList.count; t++)
    {
        
        TDAnimTransformation *tr = [transfList objectAtIndex:t];

        
        NSString *_type = [tr type];
        NSString *_attr = [_type substringWithRange:NSMakeRange(0, 1)];
        NSString *_axis = [_type substringWithRange:NSMakeRange(1, 1)];
                
        if ([_attr isEqualToString:@"r"]) [self applyRotAtAxis:_axis value:tr.value];
        if ([_attr isEqualToString:@"l"]) [self applyLocAtAxis:_axis value:tr.value];
        if ([_attr isEqualToString:@"s"]) [self applyLocAtAxis:_axis value:tr.value];
    }
}


-(void) __setAmplitude:(float)_amp
{
    amplitude = _amp;
}


-(void) applyLocAtAxis:(NSString *)_axis value:(float)_val
{
    // we work with one axis for now
    CGPoint addLoc = CGPointZero;
    
    if ([_axis isEqualToString:@"x"]) addLoc.x = _val * amplitude;
    else addLoc.y = _val * amplitude;
                
    self.position = ccpAdd(originalLoc, addLoc);    
}


-(void) applyRotAtAxis:(NSString *)_axis value:(float)_val
{
    // it's 2d so we work just with one axis
    // but it needs to be multiplied by -1 (because of maya rotation system)
    
    if ([_axis isEqualToString:@"z"]) self.rotation = _val * amplitude * -1;

}

-(void) applySclAtAxis:(NSString *)_axis value:(float)_val
{
    CGPoint setScl = CGPointMake(self.scaleX, self.scaleY);
    
    if ([_axis isEqualToString:@"x"]) setScl.x = _val * amplitude;
    else setScl.y = _val * amplitude;
    
    [self setScaleX:setScl.x];
    [self setScaleY:setScl.y];
    
}



-(void) __dumpAnimations
{
    NSLog(@" ");
    NSLog(@"%@", self.name);
    NSLog(@"---------\n");
    
    for (NSString *animationName in self.animationTable)
    {
        NSLog(@" ");
        
        NSLog(@"ANIMATION : '%@'", animationName);
        
        NSArray *_frames = [self.animationTable valueForKey:animationName];
        
        for (int i=0; i<_frames.count; i++)
        {
            NSLog(@"frame %i", i);
            NSArray *transformations = [_frames objectAtIndex:i];
            
            for (TDAnimTransformation *trns in transformations)
            {
                NSLog(@"   %@ : %f", trns.type, trns.value);
    //            NSLog(@"TRANSFO");
            }
        }
    }
}



-(void) __processFrames
{
    
    originalLoc = self.position;
    // for each animation
    // convert 
    
    NSMutableDictionary *newAnimationTable = [NSMutableDictionary dictionary];
    
    for (NSString *animationkey in self.animationTable)
    {        
        NSDictionary *frameInfo = [self.animationTable valueForKey:animationkey];
        
        NSArray *sortedKFrames = [[frameInfo allKeys] sortedArrayUsingComparator:(NSComparator)^(NSString *f1, NSString *f2) {
            int if1 = [[[f1 componentsSeparatedByString:@"F"] objectAtIndex:1] intValue];
            int if2 = [[[f2 componentsSeparatedByString:@"F"] objectAtIndex:1] intValue];
            

            if (if1 == if2) return NSOrderedSame;
            else if (if1 > if2) return NSOrderedDescending;
            else return NSOrderedAscending;
        }];
        
        
        NSString *lastkey = [sortedKFrames lastObject];
        int lastFrame = [[[lastkey componentsSeparatedByString:@"F"] objectAtIndex:1] intValue] +1;
                
        NSMutableArray *keys = [NSMutableArray arrayWithCapacity:lastFrame];

        
        for (int i=0; i<lastFrame; i++) [keys addObject:[NSArray array]];
        
        for (NSString *framekey in frameInfo)
        {
            NSArray *frameTrans = [frameInfo valueForKey:framekey];
            int f = ([[[framekey componentsSeparatedByString:@"F"] objectAtIndex:1] intValue]);
            [keys replaceObjectAtIndex:f withObject:frameTrans];
        }
        
        [newAnimationTable setValue:[NSArray arrayWithArray:keys] forKey:animationkey];
    }
    
    [self setAnimationTable:newAnimationTable];
    // CHECK IF FRAMES HAVE ALL NSARRAY INFO
    
    newAnimationTable = [NSMutableDictionary dictionary];
    
    for (NSString *animationName in self.animationTable)
    {
        
        NSArray *transformations = [[self.animationTable valueForKey:animationName] objectAtIndex:0];
        
        for (unsigned int t=0; t < transformations.count; t++)
        {

            NSString *transType = [[transformations objectAtIndex:t] type];
            
            TDAnimTransformation *lastTrans = [self __getTransformationType:transType fromFrameTransformation:[[self.animationTable valueForKey:transType] objectAtIndex:0]];
            TDAnimTransformation *nextTrans = [self __getNextTransformationType:transType fromFrameNumber:(t+1) onAnimation:animationName];
            
            // we fill the frames
            // starting from 1 because 0 should be filled with KEYFRAME
            // stopping at TOTAL FRAMES -1 because the last frame HAS TO BE KEYFRAMED
            
            NSMutableArray *frames = [NSMutableArray arrayWithArray:[self.animationTable valueForKey:animationName]];
            
            NSMutableArray *trans;
            
            for (unsigned int f=0; f < frames.count; f++)
            {
                // is it a  keyframe with a valid value?
                if ([[frames objectAtIndex:f] count] > 0) {
                    

                    trans = [NSMutableArray arrayWithArray:[frames objectAtIndex:f]];
                    TDAnimTransformation *isKeyFrame = nil;
                
                    for (TDAnimTransformation *tr in trans)
                    {
                        if ([tr.type isEqualToString:transType]) {
                            isKeyFrame = tr;
                            break;
                        }
                    }
            
                
                    if (isKeyFrame != nil) {
                        
                        [newAnimationTable setValue:frames forKey:animationName];
                        
                        // it's a keyframe, so this will be our lastTrans and then we look for the nextTrans
                        lastTrans = isKeyFrame;
                        nextTrans = [self __getNextTransformationType:transType fromFrameNumber:(lastTrans.frame+1) onAnimation:animationName];                    
                        continue;
                        
                    } 
                
                } else {

                    trans = [NSMutableArray array];
                }
                    
                
                
                // it's not a keyframe. 
                // create a transformation interpolating the values 
                    

                int frameDif = (nextTrans.frame - lastTrans.frame);
                float valueDif = (nextTrans.value - lastTrans.value) / frameDif;                
                float newValue = lastTrans.value + valueDif * (f - lastTrans.frame);
                
                /*
                NSLog(@"nf %i, lf %i", nextTrans.frame, lastTrans.frame);
                NSLog(@"nv %f, lv %f", nextTrans.value, lastTrans.value);
                NSLog(@"nt '%@', lt '%@'", nextTrans.type, lastTrans.type);
                
                NSLog(@"fd %i , vd %f, nv %f", frameDif, valueDif, newValue);
                */
                 
                TDAnimTransformation *_nt = [[TDAnimTransformation alloc] initWithType:transType andValue:newValue forFrame:f];
                    
                [trans addObject:_nt];
                
                // replace frame info 
                [frames replaceObjectAtIndex:f withObject:[NSArray arrayWithArray:trans]];
                
                [newAnimationTable setValue:frames forKey:animationName];
            
            }                                        
        }
    }
    
    [self setAnimationTable:newAnimationTable];
}


-(TDAnimTransformation *) __getTransformationType:(NSString *)_type fromFrameTransformation:(NSArray *)_translist
{
    for (TDAnimTransformation *tr in _translist)
    {
        if ([tr.type isEqualToString:_type]) return tr;
    }
    
    return nil;
}

-(TDAnimTransformation *) __getNextTransformationType:(NSString *)_type fromFrameNumber:(int)_f onAnimation:(NSString *)_anStr 
{
    NSArray *frames = [self.animationTable valueForKey:_anStr];
    
    for (unsigned int f=_f; f<frames.count; f++)
    {
        
        if ([frames objectAtIndex:f]!=[NSNull null]){
           
            NSArray *frame = [frames objectAtIndex:f];
            
            
            for (unsigned int tl=0; tl < frame.count; tl++)
            {
                TDAnimTransformation *tf = [frame objectAtIndex:tl];

                if ([tf.type isEqualToString:_type]) {
                    return tf;
                }
            }
        }
    }
    return nil;
}

/*-(void) draw
{
    glColor4f(0, 0, 1, 1);
    glLineWidth(5.0);
    
    ccDrawCircle(ccp(0, 0), 40, 0, 4, NO);  
}*/

@end
