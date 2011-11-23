//
//  Spot.h
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "GameObject.h"

@interface Spot : GameObject {
    SpotDirection direction;
	SpotState state;
	NSString *lineID;
	BOOL isNode;
}

@property (readwrite) SpotDirection direction;
@property (readwrite) SpotState state;
@property (nonatomic, retain) NSString *lineID;
@property (readwrite) BOOL isNode;

- (void) loadFromDictionary:(NSDictionary*)dict;

@end
