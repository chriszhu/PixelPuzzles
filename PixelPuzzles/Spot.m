//
//  Spot.m
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "Spot.h"


@implementation Spot

@synthesize direction;
@synthesize state;
@synthesize lineID;
@synthesize isNode;

- (id) init {
	
	if ( (self = [super init]) ) {
		
		CCLOG(@"Spot->init");
		gameObjectType = kObjectTypeSpot;
		direction = kDirectionNone;
		state = kStateDisabled;
	}
	
	return self;
}

- (void) dealloc {
	
	[lineID release];
	[super dealloc];
}

- (void) loadFromDictionary:(NSDictionary*)dict {
	
	// grab values from dictionary
	NSString *tempLineID = [dict objectForKey:@"id"];
	NSString *tempColor = [dict objectForKey:@"color"];
	isNode = [[dict objectForKey:@"node"] boolValue];
	
	// set the line ID no matter what
	lineID = [tempLineID retain];
	
	// set the color only if this spot is a node
	if(isNode == YES) {
		
		// grab color array from string in dictionary
		NSArray *colorValues = [tempColor componentsSeparatedByString:@","];
		
		// convert to GLubytes for r, g, b
		GLubyte r = [[colorValues objectAtIndex:0] floatValue];
		GLubyte g = [[colorValues objectAtIndex:1] floatValue];
		GLubyte b = [[colorValues objectAtIndex:2] floatValue];
		
		// set the color based on the values above
		[self setColor:ccc3(r, g, b)];
		
		[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:<#(NSString *)#>
	}
}

- (void) changeDirection:(SpotDirection)newDirection {
	
	// only change image if we need to
	if(newDirection != direction) {
		
		direction = newDirection;
		
	}
}

- (void) setImageForDirection:(SpotDirection)newDirection {
	
}

@end
