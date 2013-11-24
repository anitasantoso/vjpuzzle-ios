//
//  TileSwipeEvent.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"
#import "PuzzleData.h"

@interface TileSwipeEvent : NSObject
@property (nonatomic, strong) Tile *movedTile;
@property MoveDirection direction;
@property BOOL canMove;
@property BOOL initialised;
@end
