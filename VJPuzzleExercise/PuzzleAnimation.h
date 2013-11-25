//
//  PuzzleAnimation.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 25/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"

@interface PuzzleAnimation : NSObject

+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction completion:(void (^)(BOOL finished))completion;
+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction;

+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction completion:(void (^)(BOOL finished))completion;
+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction;
+ (void)moveViewOrigin:(UIView*)view toPoint:(CGPoint)point;
@end
