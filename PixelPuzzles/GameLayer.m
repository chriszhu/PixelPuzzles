//
//  GameLayer.m
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "GameLayer.h"


@implementation GameLayer

- (id) init {
	
	if ( (self = [super init]) ) {
		
		// preload spritesheet
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet_default.plist"];
		batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet_default.png"];
		[self addChild:batchNode];
		
		// create and add background to layer
		[self createBackground];
		
		// enable touches on this layer
		self.isTouchEnabled = YES;
		
		// make array for spots
		spots = [[NSMutableArray alloc] init];
		
		// load test puzzle
		[self loadPuzzleFromFile:@"testPuzzle"];
	}
	
	return self;
}

- (void) dealloc {
	
	// get rid of spots
	[spots release];
	
	[super dealloc];
}

#pragma mark Background Sprite
- (void) createBackground {
	
	// make background image
	background = [CCSprite spriteWithFile:@"background.png"];
	
	// change params so it repeats X and Y
	ccTexParams texParams = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };
	[[background texture] setTexParameters:&texParams];
	
	// add it to the layer
	//[self addChild:background z:0];
}

- (void) setBackgroundWidth:(int)width height:(int)height {
	
	// change size to fit screen
	[background setTextureRect:CGRectMake(0, 0, width*32, height*32)];
	[background setPosition:ccp(width*16, [CCDirector sharedDirector].winSize.height - height*16)];
}

#pragma mark Spots
- (void) loadPuzzleFromFile:(NSString*)filename {
	
	// get dictionary from plist
	NSDictionary *puzzleData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"plist"]];
	
	// if the data exists, continue
	if(puzzleData) {
		
		// get puzzle size from dictionary
		int width = [[puzzleData objectForKey:@"width"] intValue];
		int height = [[puzzleData objectForKey:@"height"] intValue];
		
		// update puzzle background
		[self setBackgroundWidth:width height:height];
		
		// get spots from dictionary
		NSArray *spotsData = [puzzleData objectForKey:@"spots"];
		
		// loop through array
		for(int i=0,j=[spotsData count];i<j;i++) {
			
			// get current array
			NSArray *curArray = [spotsData objectAtIndex:i];
			
			// loop through curArray
			for(int k=0,l=[curArray count];k<l;k++) {
				
				// get current dictionary
				NSDictionary *curDictionary = [curArray objectAtIndex:k];
				
				// create spot
				Spot *s = [[Spot alloc] init];
				
				// load data for spot from curDictionary
				[s loadFromDictionary:curDictionary];
				
				// set position based on puzzle size
				//[s.sprite setPosition:ccp(k * 32 + 16, [CCDirector sharedDirector].winSize.height - (i * 32 + 16))];
				
				// add as child
				//[self addChild:s z:-1];
				
				//CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"singleUnfilled.png"];
				//[batchNode addChild:s];
			}
		}
	}
}

#pragma mark Touch Input
- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CCLOG(@"GameLayer->ccTouchesBegan");
	
	// make sure state is idle
	if(state == kStateIdle) {
		
		// get touch
		UITouch *touch = [touches anyObject];
		
		// get position of touch
		CGPoint location = [touch locationInView:[touch view]];
		
		// check if this touch collides with the background sprite
		if( CGRectContainsPoint([background textureRect], location) ) {
			
			// check if this touch collides with any of our spots
			for(int i=0,j=[spots count];i<j;i++) {
				
				// get current spot
				Spot *s = [spots objectAtIndex:i];
				
				// see if this spot is even valid for touches
				if(s.state != kStateDisabled) {
					
					// see if this touch collides with this spot
					if( CGRectContainsPoint([s.sprite textureRect], location) ) {
						
						state = kStateTouchDownActiveNode;
						break;
					}
				}
			}
			
			// if we're touching the background but no active spots, allow the player to move the background
			state = kStateTouchDownInactiveNode;
		}
	}
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CCLOG(@"GameLayer->ccTouchesMoved");
	
	// check state
	if(state == kStateTouchDownActiveNode) {
		
		// change state to move the node
		state = kStateTouchMoveActiveNode;
	}
	else if(state == kStateTouchDownInactiveNode) {
		
		// change state to move the background
		state = kStateTouchMoveInactiveNode;
	}
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CCLOG(@"GameLayer->ccTouchesEnded");
	
	// switch state back to idle
	state = kStateIdle;
}

@end
