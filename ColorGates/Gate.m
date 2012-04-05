//
//  Gate.m
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Gate.h"
#import "Lightning.h"
#import "math.h"
#import "GameScene.h"

@implementation Gate

@synthesize speed;
@synthesize sectionDict;
@synthesize lightning;
@synthesize colRect;
@synthesize gateColor;
@synthesize gateWidth;
@synthesize active;

int sum;
CCParticleSystem* emitter;

+(Gate*) spawn {
    
    //spawns a gate object at the top, out of the screen
    //with a random color from the colorArray
    //which starts out simple and gets colors added to it as time passes
    //gates also speed up over time, get smaller gaps
    
    
    //CGSize size = [[CCDirector sharedDirector] winSize];
    
        
    float widthValue = 50 + arc4random()% 250;
    

    ccColor3B gateColor = [Gate randomColor];
    
    return [[Gate alloc] initWithWidth:widthValue andColor:gateColor];

    
}

+(void) resetGateSum {
    
    sum = 0;
}


+ (ccColor3B) randomColor {
    //starts off with colors that you don't need to combine to get
    //and then adds all combo colors
    
    NSLog(@"Gate count is: %u", sum);
    
    if (sum < 5){
        
        sum += 1;
        
        int x = arc4random() % 3;
        if (x == 1)
            return ccBLUE;
        if (x == 2)
            return ccGREEN;
        else return ccRED;
    }
    
    else {
        
        int x = arc4random() % 8;
        if (x == 1)
            return ccBLUE;
        if (x == 2)
            return ccGREEN;
        if (x ==3)
            return ccRED;
        if (x == 4)
            return ccYELLOW;
        if (x == 5)
            return ccMAGENTA;
        if (x == 6)
            return ccCYAN;
        if (x == 7)
            return ccORANGE;
        else return ccWHITE;
        
        
    }    

    
    

}


- (void) runGate:(ccTime)dt {
    
    //cool lighting effect between the gate points
    [lightning strikeRandom];
 
    
}


-(id) initWithWidth:(float)width andColor:(ccColor3B)gateColorSet {
    //create-a-gate
    
    if (self = [super init]){
        
        gateWidth = width;
        [self setGateColor:gateColorSet];
                
        [self setColRect:CGRectMake(0, 0, width, 30)];
        
        //random speed
        int r = 1 + arc4random() % 6;
        
        [self setSpeed:r*.7];
        
        
        
        lightning = [Lightning lightningWithStrikePoint:ccp(gateWidth,0)];
        lightning.position = ccp(0,0);
        
        lightning.color = gateColor;
        
        [lightning setDisplacement:gateWidth/2];
        
        [self addChild:lightning];
        
        //add coil sprites
        float coilScale = 0.3;

        leftCoil = [CCSprite spriteWithFile:@"coil.png"];
        leftCoil.rotation = 90;
        leftCoil.position = ccp(-10,0);
        leftCoil.scale = coilScale;
        [self addChild:leftCoil];
        
        rightCoil = [CCSprite spriteWithFile:@"coil.png"];
        rightCoil.rotation = 90;
        rightCoil.flipY = YES;
        rightCoil.position = ccp(width+10,0);
        rightCoil.scale = coilScale;
        [self addChild:rightCoil];
        
        
        [self setActive:YES];
        
        [self schedule:@selector(runGate:) interval:.07];

        
        
    }
    
    return self;
}



-(void) delGate:(ccTime)dt {
    
    
    [self removeFromParentAndCleanup:YES];
    
    
}

-(void) neutralizeAtPosition:(CGPoint)position {
    
    //delete gate
    //display point label, fade it away
    //points depend on position
    //display different effects emitter on position
    
    //NOTE: moved most of this logic to the loop in
    //GameScene.checkCollisions
    
    
    [self setActive:NO];
    self.visible = NO;


    
}

-(void) dealloc {
    
    [emitter release];
    [leftCoil release];
    [rightCoil release];
    [lightning release];
    
    [super dealloc];
}



@end