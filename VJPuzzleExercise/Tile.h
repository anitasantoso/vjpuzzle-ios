//
//  Tile.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tile : NSObject

@property CGPoint locationInArray; // i && j
@property CGRect coordinateInView; // move to helper method

@property NSInteger index;

@property BOOL isEmpty;

@end
