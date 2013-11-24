//
//  PuzzleData.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"

typedef enum {
    MoveDirectionLeft, MoveDirectionRight, MoveDirectionTop, MoveDirectionBottom
} MoveDirection;

@interface PuzzleData : NSObject

- (id)initWithRowCount:(NSInteger)rowCount colCount:(NSInteger)colCount;
- (Tile*)tileAtRow:(NSInteger)row col:(NSInteger)col;
- (Tile*)tileFromTouchPoint:(CGPoint)point;
- (Tile*)emptyTile;

- (void)randomiseTiles;

- (BOOL)pointWithinBounds:(CGPoint)point;
- (BOOL)isPuzzleSolved;
- (BOOL)canMoveTile:(Tile*)tile toDirection:(MoveDirection)direction;
- (void)swapTileLocation:(Tile*)tile1 withTile:(Tile*)tile2;

@property NSInteger rowCount;
@property NSInteger colCount;

@end
