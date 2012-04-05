//
//  MenuScene.m
//  ColorGates
//
//  Created by Nikhil Aggarwal on 12-01-02.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"
#import "SimpleAudioEngine.h"
#import "GameScene.h"



@implementation MenuScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuScene *layer = [MenuScene node];
    	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {
    
    if ((self = [super init])) {
        
    
        //play background music
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgmusic.wav"];

        //set up menu buttons
        
        CCMenuItemFont* playButton = [CCMenuItemFont itemFromString:@"Play" target:self selector:@selector(playGame)];
        
        CCMenuItemFont* howButton = [CCMenuItemFont itemFromString:@"How to Play" target:self selector:@selector(tutorial)];

       
        CCMenu* menu = [CCMenu menuWithItems:playButton, howButton, nil];
        
        [menu alignItemsVerticallyWithPadding:10];        
        
        [self addChild:menu];
        
        
    }
    
    return self;
    
}

-(void) playGame {
    
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    
}

-(void) tutorial {
    
    CCLayer* tutLayer = [CCLayer node];
    
    //TODO
    //add sprites and text to layer, overlay on top, tap to make it go away
    
    
}

-(void) muteBG {
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
    
}

-(void) muteFX {
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    
}

@end
