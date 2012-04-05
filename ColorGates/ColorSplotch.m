//
//  ColorSplotch.m
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColorSplotch.h"
#import "GameScene.h"


@implementation ColorSplotch


@synthesize splotchColor;
@synthesize particle;
@synthesize isBeingTouched;
@synthesize gs;


+(ColorSplotch*) spawn:(ccColor3B)colorToSet withPos:(CGPoint)pos andScene:(GameScene*)scene {
    
    //create a new colorsplotch with supplied color
    //at the desired location
    
    ColorSplotch *newSplotch = [[ColorSplotch alloc] initWithAColor:colorToSet andScene:scene];
        
    newSplotch.position = pos; //ccp(pos.x, pos.y);
        
    return newSplotch;
    
}


-(id) initWithAColor:(ccColor3B)colorToSet andScene:(GameScene*)scene {
    
    //create a new colorsplotch
    //with supplied color
    if( (self=[super init])) {
                
        //color setting code
        [self setSplotchColor:colorToSet]; //make a ccColor3B
        
        //enable touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

        //particle code
        [self setParticle:([CCParticleMeteor node])];
        
        //particle emitter follows position of ColorSplotch
        [self particleSetUp];
        
        [self setIsBeingTouched:NO];
        
        [self setGs:scene];
        
        
        
    }
    
    return self;

}


-(void) particleSetUp {
    
    //splotch is really just a position
    //with rectangular bounds for touch and gate collide checks
    //and an emitter that looks pretty cool (like a paint splotch)
    
    emitter = [CCParticleSun node];
        
    emitter.positionType = kCCPositionTypeGrouped;

    emitter.gravity = ccp(0,0);
    
    emitter.scale = 2.5;
    
    emitter.blendAdditive = NO;
    
    emitter.startColor = ccc4FFromccc3B([self splotchColor]);
    emitter.endColor = ccc4FFromccc3B([self splotchColor]);
    
    emitter.startSize = 2;
    emitter.endSize = 0.8;
    
    emitter.emissionRate = 500;
    
    emitter.life = 0.2;
        
    emitter.position = ccp(self.position.x, self.position.y);//self.position;
    
    [self addChild: emitter];


    
}


- (BOOL)containsTouchLocation:(UITouch *)touch
{
        
    //converts touch and location points from world space to node space
    //to see if the user tap on screen falls within the splotch bounds
    
    //touch point
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
    //CGPoint here = [self convertToNodeSpaceAR:self.position];

    //bounds
	CGRect r = CGRectMake(-30, -20, 80, 80);
	//r.origin = ccp(here.x - 20, here.y - 20);
	return CGRectContainsPoint(r, p);
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //if you touch a splotch it follows your finger
    //if you have one following already any other touches will cause the touched splotch
    //to fly to that one and combine their colors and generate a new one at the old location
    
    if ([self containsTouchLocation:touch] && ![self isBeingTouched]) {
        
        //combine on tap
        if ([[gs activeSplotches] count] == 1) {
            
            [[self parent] addChild:[ColorSplotch spawn:[self splotchColor] withPos:self.position andScene:[GameScene getGameScene]]];
            [ColorSplotch combine:self with:[[gs activeSplotches] objectAtIndex:0]];
            return YES;
        }
        
        
        NSLog(@"Touched Splotch");
        [self setIsBeingTouched:YES];
        
        //add to array in gamescene for close checking
        [[gs activeSplotches] addObject:self];

        //best line
        [[self parent] addChild:[ColorSplotch spawn:[self splotchColor] withPos:self.position andScene:[GameScene getGameScene]]];
        
        
        [emitter runAction:([CCMoveTo actionWithDuration:.2 position:(ccp(emitter.position.x, emitter.position.y + 60))])];
        emitter.scale = 3;  
        
        
        

        return YES;
        
    }
    
    return NO;
    
}
    

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {     
    
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        
        CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
        oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
        oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
        
        CGPoint translation = ccpSub(touchLocation, oldTouchLocation);    
        CGPoint newPos = ccpAdd(self.position, translation);
        
        newPos = ccp(newPos.x, newPos.y);// * 1.001);
    
        self.position = newPos;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    //if you life your finger off a splotch that splotch will die
    
    [[gs activeSplotches] removeObject:self];
    
    emitter.scale = 2.5;
    [emitter runAction:([CCMoveTo actionWithDuration:.2 position:(ccp(emitter.position.x, emitter.position.y - 60))])];

    [self runAction:[CCScaleBy actionWithDuration:.2 scale:.1]];
    [self schedule:@selector(scheduledDeactivate:) interval:.2];

        

    
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //same as touch ended without combine
    [self setIsBeingTouched:NO];
    [[gs activeSplotches] removeObject:self];
    
    
}


-(void) scheduledDeactivate:(ccTime)dt {

    //fades, deletes object
    [self setIsBeingTouched:NO];
    [[gs activeSplotches] removeObject:self];
    [self.particle runAction:([CCFadeOut actionWithDuration:(1)])];
    [self removeFromParentAndCleanup:YES];

}



+(void) combine:(ColorSplotch*)fromSplotch with:(ColorSplotch*)toSplotch  {
    

    
    //move fromSplotch (lifted finger) to toSplotch (finger still held)
    //deactivate touches on it
    [fromSplotch setIsBeingTouched:YES];
    [fromSplotch runAction:([CCMoveTo actionWithDuration:.2 position:(ccp(toSplotch.position.x, toSplotch.position.y + 60))])];
    [fromSplotch schedule:@selector(scheduledDeactivate:) interval:.2];

    
    
    //change color of toSplotch
    [toSplotch changeColor:([ColorSplotch getNewColorFrom:(fromSplotch.splotchColor) andFrom:(toSplotch.splotchColor)])];
    



}

+(BOOL) checkColorEquiv:(ccColor3B)c1 with:(ccColor3B)c2 {
    
    if (c1.r == c2.r && c1.b == c2.b && c1.g == c2.g)
        return YES;
    return NO;
    
}

+(ccColor3B) getNewColorFrom:(ccColor3B)color1 andFrom:(ccColor3B)color2 {
    //TODO: add more colors, color combinations
    //maybe make this method look a little nicer with arrays or something but for now its fine
    
    
    if ([ColorSplotch checkColorEquiv:color1 with:ccRED]) { //color1 is red
        
        
        if ([ColorSplotch checkColorEquiv:color2 with:ccRED]) //color2 is red
            return ccRED; //both are red -- should it return dark red?
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccBLUE]) //color2 is blue
            return ccMAGENTA; //red and blue
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccGREEN]) //color2 is green
            return ccYELLOW; //color 1 and 2 are red
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccYELLOW]) //color2 is green
            return ccORANGE; //red and yellow
        
    }
    else if ([ColorSplotch checkColorEquiv:color1 with:ccBLUE]) { //color1 is blue
        
        
        if ([ColorSplotch checkColorEquiv:color2 with:ccRED]) //color2 is red
            return ccMAGENTA; //both are red -- should it return dark red?
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccBLUE]) //color2 is blue
            return ccBLUE; //red and blue
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccGREEN]) //color2 is green
            return ccCYAN; // -- CYAN!!
    }
    else if ([ColorSplotch checkColorEquiv:color1 with:ccGREEN]) { //color1 is green
        
        if ([ColorSplotch checkColorEquiv:color2 with:ccRED]) //color2 is red
            return ccYELLOW; //both are red -- should it return dark red?
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccBLUE]) //color2 is blue
            return ccCYAN; // -- CYAN!!
        
        else if ([ColorSplotch checkColorEquiv:color2 with:ccGREEN]) //color2 is green
            return ccGREEN; //color 1 and 2 are red
    }
    else if ([ColorSplotch checkColorEquiv:color1 with:ccYELLOW]) { //color1 is green
        
        if ([ColorSplotch checkColorEquiv:color2 with:ccRED]) //color2 is red
            return ccORANGE; //red and yellow
    }
    
    //all other combos
    return ccWHITE;
    
}


-(void) changeColor:(ccColor3B)newColor {
    
    //for gate checking, change property
    self.splotchColor = newColor;
    
    //change particle color
    emitter.startColor = ccc4FFromccc3B(self.splotchColor);
    emitter.endColor = ccc4FFromccc3B(self.splotchColor);
    
}




-(void) dealloc {
    
    
    [emitter release];
    [super dealloc];
}


@end
