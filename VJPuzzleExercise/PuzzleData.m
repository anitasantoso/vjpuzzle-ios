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
        if([self canMoveTile:tile inDirection:dir allowBlockMove:NO]) {
            return dir;
        }
    }
    return MoveDirectionNone;
}

- (BOOL)isBlockMove:(Tile*)tile {
    NSInteger distanceX = abs(self.emptyTile.locationInGrid.x-tile.locationInGrid.x);
    NSInteger distanceY = abs(self.emptyTile.locationInGrid.y-tile.locationInGrid.y);
    return distanceX > 1 || distanceY > 1;
}

- (BOOL)canMoveTile:(Tile*)tile inDirection:(MoveDirection)direction {
    return [self canMoveTile:tile inDirection:direction allowBlockMove:YES];
}

/**
 Check if a tile can move to certain direction. For tap gesture, no block move is allowed.
 **/
- (BOOL)canMoveTile:(Tile*)tile inDirection:(MoveDirection)direction allowBlockMove:(BOOL)allowBlockMove {
    
    Tile *theTile = tile;
    do {
        Tile *checkTile = [self _nextTileTo:theTile inDirection:direction];
        if(checkTile.isEmpty) {
            return YES;
        }
        if(!allowBlockMove) {
            return NO; // break here if no block move
        }
        theTile = checkTile;
    } while(theTile != nil);
    return NO;
}

- (NSArray*)blockTilesNextTo:(Tile*)tile inDirection:(MoveDirection)direction {
    NSMutableArray *tiles = [NSMutableArray arrayWithObject:tile];
    Tile *currTile = tile;
    while(true) {
        Tile *nextTile = [self _nextTileTo:currTile inDirection:direction];
        if(!nextTile || nextTile.isEmpty) {
            break;
        }
        [tiles addObject:nextTile];
        currTile = nextTile;
    } 
    return tiles;
}

- (Tile*)_nextTileTo:(Tile*)tile inDirection:(MoveDirection)direction {
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
 Move a block of tiles to an empty slot
 **/
- (void)moveBlockOfTiles:(NSArray*)tiles  {
    Tile *emptyTile = [self emptyTile];
    
    CGPoint lastLocInGrid = emptyTile.locationInGrid;
    CGRect lastCoordInView = emptyTile.coordinateInView;
    
    CGPoint currLocInGrid;
    CGRect currCoordInView;
    
    // work backwards
    for(int i=tiles.count-1; i>=0; i--) {
        Tile *tile = [tiles objectAtIndex:i];
        
        currLocInGrid = tile.locationInGrid;
        currCoordInView = tile.coordinateInView;
        
        tile.locationInGrid = lastLocInGrid;
        tile.coordinateInView = lastCoordInView;
        
        lastLocInGrid = currLocInGrid;
        lastCoordInView = currCoordInView;
    }
    emptyTile.locationInGrid = currLocInGrid;
    emptyTile.coordinateInView = currCoordInView;
}

/**
 Move tile to an empty slot
 **/
- (void)moveTile:(Tile*)tile {
    [self moveBlockOfTiles:@[tile]];
}

- (BOOL)isPuzzleSolved {
    NSInteger index = 0;
    for(int row=0; row<self.rowCount; row++) {
        for(int col=0; col<self.colCount; col++) {
            Tile *tile = [self tileAtRow:row col:col];
            if(tile.index != index++) {
                return NO;
            }
        }
    }
    return YES;
}

@end

