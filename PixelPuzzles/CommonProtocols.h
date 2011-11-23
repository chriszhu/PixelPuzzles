//
//  CommonProtocols.h
//  PixelPuzzles
//
//  Created by Kristian Bauer on 10/8/11.
//  Copyright 2011 Bauerkraut. All rights reserved.
//

typedef enum
{
	kStateDisabled,
	kStateEnabled,
	kStateCompleted
} SpotState;

typedef enum
{
	kDirectionNone,
	kDirectionVertical,
	kDirectionHorizontal,
	kDirectionLeftToTop,
	kDirectionLeftToBottom,
	kDirectionRightToTop,
	kDirectionRightToBottom,
	kDirectionCapTop,
	kDirectionCapLeft,
	kDirectionCapRight,
	kDirectionCapBottom
} SpotDirection;

typedef enum
{
	kObjectTypeNone,
	kObjectTypeSpot
} GameObjectType;

typedef enum
{
	kStateIdle,
	kStateTouchDownActiveNode,
	kStateTouchMoveActiveNode,
	kStateTouchDownInactiveNode,
	kStateTouchMoveInactiveNode
} GameState;