//
//  GameScene.m
//  ColorGates
//
//  Created by Nikhil Aggarwal on 11-12-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleAudioEngine.h"
#import "GameScene.h"
#import "ColorSplotch.h"
#import "Gate.h"
#import "Lightning.h"

@implementation GameScene


@synthesize activeSplotches;
@synthesize gateRate;
@synthesize gateArray;

BOOL gameOver;
static GameScene* gs = NULL;
CCLabelTTF *pointsLabel;
CCLabelTTF *scoreLabel;

CCShaky3D *shake;
 

int score;


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
    
    gs = layer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(GameScene*) getGameScene {
    return gs;
}

-(id) init
{
    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        //set main splotch colors
        ccColor3B c1;
        ccColor3B c2;
        ccColor3B c3;
        
        //TODO: change to array shuffling
        int x = arc4random() % 30;
        if (x < 5) {
            c1 = ccBLUE;
            c2 = ccRED;
            c3 = ccGREEN;
        }
        else if (x < 15) {
            c1 = ccRED;
            c2 = ccBLUE;
            c3 = ccGREEN;
        }
        else if (x < 20) {
            c1 = ccGREEN;
            c2 = ccBLUE;
            c3 = ccRED;
        }
        else {
            c1 = ccRED;
            c2 = ccGREEN;
            c3 = ccBLUE;
        }
        
        
        //add splotche generators to scene
        ColorSplotch *splotch1 = [ColorSplotch spawn:c1 withPos:ccp(30, 30) andScene:self];
        [self addChild:splotch1];
        ColorSplotch *splotch2 = [ColorSplotch spawn:c2 withPos:ccp(160, 30) andScene:self];
        [self addChild:splotch2];
        ColorSplotch *splotch3 = [ColorSplotch spawn:c3 withPos:ccp(280, 30) andScene:self];
        [self addChild:splotch3];
        
        //start speed of gates
        [self setGateRate:2];
        
        //set arrays
        activeSplotches = [[NSMutableArray alloc] init];
        gateArray = [[NSMutableArray alloc] init];
        
        //label setup
        scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Marker Felt" fontSize:20];
        scoreLabel.position = ccp(160, 450);
        [self addChild:scoreLabel];
        
        gameOver = NO;
        
        score = 0;
        
        [self gameStart];
        
	}
	return self;
}


-(void) gameStart {
    
    //ui touching, pause button, reset etc
    self.isTouchEnabled = YES;
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];

    
    //reset all variables and counters to 0
    [Gate resetGateSum];
    
    //schedule selector method to check splotches in activeSplotches array for closeness
    [self schedule:@selector(runGame:)];
    [self schedule:@selector(spawnGate:) interval:[self gateRate]];
    
    
}

-(void) spawnGate:(ccTime)dt {
    
    Gate *gate = [Gate spawn];
    
    //make the gate spawn so that the whole thing is seen on screen
    //this is important because the widths are random (but always smaller than screen width)
    int num = [[CCDirector sharedDirector] winSize].width - [gate gateWidth];
    int gateX = arc4random() % num;
    if (gateX < 20) gateX = 20;
    
    //spawn the gate above the screen
    gate.position = ccp(gateX,600);
    
    [self addChild:gate];

    [gateArray addObject:gate];
    
    [gate release]; //retains when added to array

    //the lower the gate rate the faster the gates will spawn (not move)
    [self setGateRate:([self gateRate]-.1)];
    if ([self gateRate] < .5)
        [self setGateRate:.5];
    
}


- (void) runGame:(ccTime)dt {
     

    [self moveGates];
    [self checkCollisions];
    

}

-(void)draw {
    
    //draw a line separating the splotch spawners from the action
    [super draw];
    glColor4f(0.8, 1.0, 0.76, 1.0);  
    glLineWidth(2.0f);
    
    int lineHeight = 70;
    ccDrawLine(ccp(0,lineHeight), ccp(400, lineHeight));
   

}   

-(void) explosion:(CGPoint)pos {
    
    //play explosion sound
    //[[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
    
    //emits a fun explosion effect when you destroy a gate
    CCParticleSystem* emitter = [CCParticleExplosion node];
            
    emitter.positionType = kCCPositionTypeGrouped;
    
    emitter.gravity = ccp(0,0);
    
    emitter.scale = 2.5;
    
    emitter.blendAdditive = NO;
    
    emitter.startSize = 2;
    emitter.endSize = 0.8;
    
    emitter.emissionRate = 500;
    
    emitter.life = 0.2;
    
    emitter.position = ccp(pos.x, pos.y + 50);
    
    [self addChild: emitter];
}


-(void) displayScore:(CGPoint)position {
    

    int points = (int)position.y;
    score += points;

    [scoreLabel setString:[NSString stringWithFormat:@"Score: %i", score]];

    
    // create and initialize a Label
    pointsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%i",points] fontName:@"Marker Felt" fontSize:20];
    
    // position the label on the center of the screen
    pointsLabel.position = ccp(position.x, position.y + 100);
    
    // add the label as a child to this Layer
    [self addChild: pointsLabel];
    
    //ccaction fade and scale
    [pointsLabel runAction:([CCFadeOut actionWithDuration:(1)])];
    [pointsLabel runAction:([CCMoveBy actionWithDuration:2 position:ccp(0,100)])];

    //scheduled deactivate 
    //[self schedule:@selector(ridLabel:) interval:1];

}

-(void) checkGatesPassed {
    
    
    for (Gate* gateZ in self->gateArray) {

        if (gateZ.position.y < 10) {
        
            if ([gateZ active]){
                //a gate reached the bottom without being destroyed
                
                gateZ.active = NO;
        
                NSLog(@"Get rid of it");
        
                score -= 1000; 
                
                //TODO: get this working!
                shake = [CCShaky3D actionWithRange:5 shakeZ:NO grid:ccg(1,1) duration:0.5];
                //[self runAction:shake];
        
                [scoreLabel setString:[NSString stringWithFormat:@"Score: %i", score]];
        
        
                // create and initialize a Label
                pointsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"-%i",1000] fontName:@"Marker Felt" fontSize:20];
        
                // position the label on the center of the screen
                pointsLabel.position = ccp(150, 60);
        
                // add the label as a child to this Layer
                [self addChild: pointsLabel];
        
                //ccaction fade and scale
                [pointsLabel runAction:([CCFadeOut actionWithDuration:(1)])];
                [pointsLabel runAction:([CCMoveBy actionWithDuration:2 position:ccp(0,100)])];
        
            }
        }
        
    }

    
}

-(void) checkCollisions {
    
    //NSLog(@"Active Splotches: %i", [[self activeSplotches] count]);
    //NSLog(@"Gate count: %i", [[self gateArray] count]);
    
    //first see if any have gotten passed the player
    [self checkGatesPassed];
    
    if ([[self activeSplotches] count] > 0) {
        
        for (ColorSplotch* splotch in activeSplotches) {
            
            for (Gate* gateZ in self->gateArray) {
                
                if ([gateZ active]){
                    //for all active splotches (ie splotches the player is touching)
                    //check if that splotch collides with a gate
                                        
                    CGRect checkRect = CGRectMake(gateZ.position.x, gateZ.position.y - 80, [gateZ gateWidth], 80);
                    if (CGRectContainsPoint(checkRect, [splotch position])) {
                    
                        //check color
                        //if color matches, send gate deactivate
                        //if color doesnt match, send self game over
                        if ([ColorSplotch checkColorEquiv:[splotch splotchColor] with:[gateZ gateColor]]){
                            NSLog(@"Gate y position: %f", gateZ.position.y);
                            [gateZ neutralizeAtPosition:gateZ.position];
                            [self explosion:splotch.position];
                            [self displayScore:splotch.position];
                            
                        }
                        else [self gameOverAt:[splotch position]];
                    }

    
                }
            
            }
            
        }
        
    }
    
}


-(void) gameOverAt:(CGPoint)pos {
    
    NSLog(@"Game Over!!");
    gameOver = YES;
    [self unschedule:@selector(runGame:)];
    [self unschedule:@selector(spawnGate:)];
    

    [scoreLabel setString:[NSString stringWithFormat:@"Score: %i", score]];
    scoreLabel.position = ccp(150, 300);
    
    pointsLabel = [CCLabelTTF labelWithString:@"Tap to try again!" fontName:@"Marker Felt" fontSize:30];
    pointsLabel.position = ccp(150, 270);
    [self addChild:pointsLabel];
    
    //display game over
    //try again
    //then take to high score menu (TODO)
    
}


-(void) moveGates {
    
    //move the gates down according to their speed
    //and cleans up any that have moved off screen
    
    Gate* del = nil;
    for (id gateZ in self->gateArray) {
        
        Gate* gate = gateZ;
        float newVal = gate.position.y - ([gate speed]);
        gate.position = ccp(gate.position.x, newVal);
        
        if (gate.position.y < 0) {
            
            //mark for deletion for now
            //can't delete from array while iterating over it
            del = gateZ;
            
        }
    }
    if (del) {
        [gateArray removeObject:del];
        [self removeChild:del cleanup:NO];
    }
    
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //restarts the game if game over
    //splotches have their own touch code
            
    if (gameOver){
        
        [[CCDirector sharedDirector]replaceScene:[GameScene scene]];
    }
    
    
    return YES;
}




- (void) dealloc
{
    [shake release];
    
    [pointsLabel release];
    [scoreLabel release];
    
    [gateArray release];
    [activeSplotches release];
    
    [super dealloc];
}






@end
