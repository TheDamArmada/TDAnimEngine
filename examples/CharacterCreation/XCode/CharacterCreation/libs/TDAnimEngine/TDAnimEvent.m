//
//  TDAnimEvent.m
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/9/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import "TDAnimEvent.h"


@implementation TDAnimEvent

@synthesize event, frame;

-(void) dealloc
{
    [event release];
    [super dealloc];
}

-(id) initWithEvent:(NSString *)_ev atFrame:(int)_frame
{
    self = [super init];
    if (self)
    {
        self.event  = _ev;
        self.frame  = _frame;
    }
    return self;
}
@end
