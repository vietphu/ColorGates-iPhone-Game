//
//  ColorSplotch.h
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"



@interface ColorSplotch : CCNode <CCTargetedTouchDelegate> {
    
    CCParticleSystem* emitter;

}

@property ccColor3B splotchColor;
@property (retain) CCParticleMeteor* particle;
@property BOOL isBeingTouched;
@property (retain) GameScene* gs;

+(ColorSplotch*) spawn:(ccColor3B)color withPos:(CGPoint)pos andScene:(GameScene*)scene;
-(id) initWithAColor:(ccColor3B)color andScene:(GameScene*)scene;
+(void) combine:(ColorSplotch*)fromSplotch with:(ColorSplotch*)toSplotch;
+(ccColor3B) getNewColorFrom:(ccColor3B)color1 andFrom:(ccColor3B)color2;
-(void) changeColor:(ccColor3B)newColor;
-(void) particleSetUp;
+(BOOL) checkColorEquiv:(ccColor3B)c1 with:(ccColor3B)c2;
-(void) scheduledDeactivate:(ccTime)dt;



//Touch and drag this object
//Has a color associated
//Color can change when combining ColorSplotches



@end
