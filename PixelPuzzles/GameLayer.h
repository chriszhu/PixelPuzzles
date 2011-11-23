//
//  GameLayer.h
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CommonProtocols.h"
#import "Spot.h"

@interface GameLayer : CCLayer {
	CCSpriteBatchNode *batchNode;
    CCSprite *background;
	NSMutableArray *spots;
	GameState state;
}

- (void) createBackground;
- (void) setBackgroundWidth:(int)width height:(int)height;
- (void) loadPuzzleFromFile:(NSString*)filename;

@end
