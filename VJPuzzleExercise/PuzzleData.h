//
//  PuzzleData.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"

@interface PuzzleData : NSObject

- (id)initWithRowCount:(NSInteger)rowCount colCount:(NSInteger)colCount;
- (Tile*)tileAtRow:(NSInteger)row col:(NSInteger)col;
- (Tile*)tileFromTouchPoint:(CGPoint)point;
- (Tile*)emptyTile;
- (NSArray*)blockTilesNextTo:(Tile*)tile inDirection:(MoveDirection)direction;

- (MoveDirection)findMoveForTile:(Tile*)tile;

- (BOOL)isPuzzleSolved;
- (BOOL)canMoveTile:(Tile*)tile inDirection:(MoveDirection)direction;

- (void)randomiseTiles;
- (void)moveTile:(Tile*)tile; // move to empty slot
- (void)moveBlockOfTiles:(NSArray*)tiles;

@property NSInteger rowCount;
@property NSInteger colCount;

@end
