//
//  GameScene.h
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer {
    
    NSMutableArray* activeSplotches;
    NSMutableArray* gateArray;
    
}



@property (retain) NSMutableArray* activeSplotches;
@property float gateRate;
@property (retain) NSMutableArray* gateArray;


+(CCScene *) scene;
+(GameScene*) getGameScene;
-(void) gameStart;
- (void) runGame:(ccTime)dt;
-(void) spawnGate:(ccTime)dt;
-(void) moveGates;
-(void) checkCollisions;
-(void) gameOverAt:(CGPoint)pos;

@end
