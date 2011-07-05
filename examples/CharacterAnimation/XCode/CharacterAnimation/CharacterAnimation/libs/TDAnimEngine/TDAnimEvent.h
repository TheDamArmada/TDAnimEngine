//
//  TDAnimEvent.h
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/9/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDAnimEvent : NSObject {
    
    NSString    *event;
    int         frame;
}

@property (nonatomic, retain) NSString *event;
@property (assign)            int       frame;

-(id) initWithEvent:(NSString *)_ev atFrame:(int)_frame;

@end
