//
//  GameObject.h
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CommonProtocols.h"

@interface GameObject : CCSprite {
    BOOL isActive;
	CGSize screenSize;
	GameObjectType gameObjectType;
}

@property (readwrite) BOOL isActive;
@property (readwrite) CGSize screenSize;
@property (readwrite) GameObjectType gameObjectType;

- (CGRect) adjustedBoundingBox;

@end
