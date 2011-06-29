//
//  TDAnimTransformation.h
//  TurtleFromMaya
//
//  Created by Jordi Martinez on 6/7/11.
//  Copyright 2011 Wieden + Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDAnimTransformation : NSObject {
    
    NSString    *type;
    float       value;
    NSString    *ease;
    int         frame;
}

-(id) initWithType:(NSString *)_t andValue:(float)_val forFrame:(int)_fr;

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *ease;
@property (assign)            float     value;
@property (assign)            int       frame;

@end
