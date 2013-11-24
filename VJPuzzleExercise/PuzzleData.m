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
@property NSArray *tiles2DArr;
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
    NSMutableArray *tiles2DArr = [NSMutableArray arrayWithCapacity:self.rowCount];
    NSInteger index = 0;
    
    for(int i=0; i<self.rowCount; i++) {
        
        NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self.colCount];
        for(int j=0; j<self.colCount; j++) {
            
            Tile *tile = [[Tile alloc]init];
            tile.index = index++;
            tile.locationInArray = CGPointMake(j, i);
            
            // if last tile
            if(i == self.rowCount-1 && j == self.colCount-1) {
                tile.isEmpty = YES;
            }
            [tiles addObject:tile];
        }
        [tiles2DArr addObject:tiles];
    }
    self.tiles2DArr = tiles2DArr;
}

- (void)randomiseTiles {
    for(int i=0; i<self.rowCount; i++) {
        [((NSMutableArray*)[self.tiles2DArr objectAtIndex:i]) shuffle];
    }

    for(int i=0; i<self.rowCount; i++) {
        for(int j=0; j<self.colCount; j++) {
            Tile *tile = [self tileAtRow:i col:j];
            tile.locationInArray = CGPointMake(i, j);
        }
    }
}

- (Tile*)emptyTile {
    for(int i=0; i<self.rowCount; i++) {
        NSArray *tiles = [self.tiles2DArr objectAtIndex:i];
        for(int j=0; j<self.rowCount; j++) {
            Tile *tile = [tiles objectAtIndex:j];
            if(tile.isEmpty) {
                return tile;
            }
        }
    }
    return nil;
}

- (Tile*)tileFromTouchPoint:(CGPoint)point {
    for(int i=0; i<self.tiles2DArr.count; i++) {
        NSArray *tiles = [self.tiles2DArr objectAtIndex:i];
        
        for(int j=0; j<tiles.count; j++) {
            Tile *tile = (Tile*)[tiles objectAtIndex:j];
            if(CGRectContainsPoint(tile.coordinateInView, point)) {
                return tile;
            }
        }
    }
    return nil;
}

- (Tile*)tileAtRow:(NSInteger)row col:(NSInteger)col {
    if([self pointWithinBounds:CGPointMake(row, col)]) {
        return [[self.tiles2DArr objectAtIndex:row]objectAtIndex:col];
    }
    return nil;
}

- (BOOL)pointWithinBounds:(CGPoint)point {
    BOOL xInBound = point.x >= 0 && point.x < self.rowCount;
    BOOL yInBound = point.y >= 0 && point.y < self.colCount;
    return xInBound && yInBound;
}

- (BOOL)canMoveTile:(Tile*)tile toDirection:(MoveDirection)direction {
    NSInteger x = tile.locationInArray.x;
    NSInteger y = tile.locationInArray.y;
    
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
    // can move if there is empty tile at coordinate
    CGPoint destPoint = CGPointMake(x, y);
    if([self pointWithinBounds:destPoint]) {
        return CGPointEqualToPoint(destPoint, [self emptyTile].locationInArray);
    }
    return NO;

}

- (void)swapTileLocation:(Tile*)tile1 withTile:(Tile*)tile2 {
    CGPoint locInArray = tile1.locationInArray;
    CGRect coordInView = tile1.coordinateInView;
    
    tile1.locationInArray = tile2.locationInArray;
    tile1.coordinateInView = tile2.coordinateInView;
    
    tile2.locationInArray = locInArray;
    tile2.coordinateInView =coordInView;
}

- (BOOL)isPuzzleSolved {
    NSInteger index = 0;
    for(int i=0; i<self.rowCount; i++) {
        for(int j=0; j<self.colCount; i++) {
            Tile *tile = [self tileAtRow:i col:j];
            if(tile.index != index++) {
                return NO;
            }
        }
    }
    return YES;
}

@end
