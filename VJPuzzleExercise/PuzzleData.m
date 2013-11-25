//
//  PuzzleData.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "PuzzleData.h"
#import "NSMutableArray+Shuffling.h"

@interface PuzzleData()
@property NSMutableArray *tiles;
@end

@implementation PuzzleData

- (id)initWithRowCount:(NSInteger)rowCount colCount:(NSInteger)colCount {
    if(self = [super init]) {
        
        self.rowCount = rowCount;
        self.colCount = colCount;
        [self initData];
    }
    return self;
}

- (void)initData {
    
    // construct data structure
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self.rowCount*self.colCount];
    NSInteger index = 0;
    
    for(int row=0; row<self.rowCount; row++) {
        for(int col=0; col<self.colCount; col++) {
            
            Tile *tile = [[Tile alloc]init];
            tile.index = index++;
            tile.locationInGrid = CGPointMake(row, col);
            
            // if last tile
            if(row == self.rowCount-1 && col == self.colCount-1) {
                tile.isEmpty = YES;
            }
            [tiles addObject:tile];
        }
    }
    self.tiles = tiles;
}

- (void)randomiseTiles {
    [self.tiles shuffle];

    int index = 0;
    for(int row=0; row<self.rowCount; row++) {
        for(int col=0; col<self.colCount; col++) {
            Tile *tile = [self.tiles objectAtIndex:index++];
            tile.locationInGrid = CGPointMake(row, col);
        }
    }
}

- (Tile*)emptyTile {
    for(Tile *tile in self.tiles) {
        if(tile.isEmpty) {
            return tile;
        }
    }
    return nil;
}

- (Tile*)tileFromTouchPoint:(CGPoint)point {
    for(Tile *tile in self.tiles) {
        if(CGRectContainsPoint(tile.coordinateInView, point)) {
            return tile;
        }
    }
    return nil;
}

- (Tile*)tileAtRow:(NSInteger)row col:(NSInteger)col {
    if([self _isPointWithinBounds:CGPointMake(row, col)]) {
        for(Tile *tile in self.tiles) {
            if(tile.locationInGrid.x == row && tile.locationInGrid.y == col) {
                return tile;
            }
        }
    }
    return nil;
}

- (BOOL)_isPointWithinBounds:(CGPoint)point {
    BOOL xInBound = point.x >= 0 && point.x < self.rowCount;
    BOOL yInBound = point.y >= 0 && point.y < self.colCount;
    return xInBound && yInBound;
}

- (MoveDirection)findMoveForTile:(Tile*)tile {
    for(int dir=MoveDirectionTop; dir<=MoveDirectionLeft; dir++) {
        if([self canMoveTile:tile inDirection:dir]) {
            return dir;
        }
    }
    return MoveDirectionNone;
}

/** 
 Allow a block of tiles to move?
 **/
- (BOOL)canMoveTiles:(NSArray*)tiles inDirection:(MoveDirection)direction {
    for(Tile *tile in tiles) {
        if([self _adjacentTileTo:tile inDirection:direction].isEmpty) {
            return YES;
        }
    }
    return NO;
}

/**
 Allow a single tile to move? 
 **/
- (BOOL)canMoveTile:(Tile*)tile inDirection:(MoveDirection)direction {
    Tile *possiblyEmptyTile = [self _adjacentTileTo:tile inDirection:direction];
    return possiblyEmptyTile.isEmpty;
}

- (Tile*)_adjacentTileTo:(Tile*)tile inDirection:(MoveDirection)direction {
    NSInteger x = tile.locationInGrid.x;
    NSInteger y = tile.locationInGrid.y;
    
    switch (direction) {
        case MoveDirectionLeft:
            x -= 1;
            break;
        case MoveDirectionRight:
            x += 1;
            break;
        case MoveDirectionTop:
            y -= 1;
            break;
        case MoveDirectionBottom:
            y += 1;
            break;
        default:
            break;
    }
    return [self tileAtRow:x col:y];
}

/**
 TODO to move a block of tiles to an empty slot
 **/
- (void)moveTiles:(NSArray*)tiles toTile:(Tile*)emptyTile {
    // TODO
}

// TODO no need for emptyTile arg
- (void)moveTile:(Tile*)tile {
    CGPoint locInGrid = tile.locationInGrid;
    CGRect coordInView = tile.coordinateInView;
   
    Tile *emptyTile = [self emptyTile];
    
    tile.locationInGrid = emptyTile.locationInGrid;
    tile.coordinateInView = emptyTile.coordinateInView;
 
    emptyTile.locationInGrid = locInGrid;
    emptyTile.coordinateInView = coordInView;
    
    emptyTile = [self emptyTile];
}

- (BOOL)isPuzzleSolved {
    NSInteger index = 0;
    for(Tile *tile in self.tiles) {
        if(tile.index != index++) {
            return NO;
        }
    }
    return YES;
}

@end

