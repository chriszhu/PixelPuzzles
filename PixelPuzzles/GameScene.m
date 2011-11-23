//
//  GameScene.m
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

- (id) init {
	
	if ( (self = [super init]) ) {
		
		CCLOG(@"GameScene->init");
		// make game layer
		GameLayer *gameLayer = [GameLayer node];
		[self addChild:gameLayer z:0];
	}
	
	return self;
}

@end
