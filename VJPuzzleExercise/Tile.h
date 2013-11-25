//
//  Tile.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MoveDirectionNone, MoveDirectionTop, MoveDirectionRight, MoveDirectionBottom, MoveDirectionLeft
} MoveDirection;

@interface Tile : NSObject

@property CGPoint locationInArray; // i && j
@property CGRect coordinateInView; // frame in view

@property NSInteger index;
@property BOOL isEmpty; // empty slot

@end
