//
//  GameObject.m
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

@synthesize isActive;
@synthesize screenSize;
@synthesize gameObjectType;

- (id) init {
	if ( (self = [super init]) ) {
		CCLOG(@"GameObject->init");
		isActive = YES;
		screenSize = [CCDirector sharedDirector].winSize;
		gameObjectType = kObjectTypeNone;
	}
	
	return self;
}

- (CGRect) adjustedBoundingBox {
	CCLOG(@"GameObject->adjustedBoundingBox should be overridden in subclasses");
	return [self boundingBox];
}

@end
