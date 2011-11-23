//
//  PictureLoader.m
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/4/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

#import "PictureLoader.h"


@implementation PictureLoader

- (id) init
{
	if((self = [super init]))
	{
		
	}
	
	return self;
}

- (void) puzzleFromImage:(NSString*)path
{
	//make texture from the ccsprite
//	CCMutableTexture2D *texture = [CCMutableTexture2D textureWithImage:[UIImage imageNamed:path]];
	
	//get size of texture
//	int width = texture.pixelsWide;
//	int height = texture.pixelsHigh;
	
	//loop through pixels
//	for(int i=0;i<height;i++)
//	{
//		for(int j=0;j<width;j++)
//		{
//			ccColor4F color = ccc4FFromccc4B([texture pixelAt:ccp(j, i)]);
//		}
//	}
}

@end
