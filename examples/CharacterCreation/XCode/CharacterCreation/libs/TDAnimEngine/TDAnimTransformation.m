//
//  TDAnimTransformation.m
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import "TDAnimTransformation.h"


@implementation TDAnimTransformation

@synthesize type, value, ease, frame;


-(void) dealloc
{
    [type release];
    [ease release];
    [super dealloc];
}

-(id) initWithType:(NSString *)_t andValue:(float)_val forFrame:(int)_fr
{
    self = [super init];
    if (self) {
        self.type   = _t;
        self.value  = _val;
        self.frame  = _fr;
    }
    
    return self;
}


@end
