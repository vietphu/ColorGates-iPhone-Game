//
//  Gate.h
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Lightning;

@interface Gate : CCNode {
    
    float gateWidth;
    Lightning* lightning;
    ccColor3B gateColor;
    
    CCSprite* leftCoil;
    CCSprite* rightCoil;

    
}

@property ccColor3B gateColor;
@property float speed;
@property (retain) NSDictionary* sectionDict;
@property (retain) Lightning* lightning;
@property CGRect colRect;
@property float gateWidth;
@property BOOL active;





+(Gate*) spawn;
+(void) resetGateSum;
+ (ccColor3B) randomColor;
-(id) initWithWidth:(float)width andColor:(ccColor3B)gateColorSet;
-(void) neutralizeAtPosition:(CGPoint)position; //colors match opening parts, gate disappears


@end
