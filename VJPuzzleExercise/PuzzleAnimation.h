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

+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction;
+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction;

+ (void)moveView:(UIView*)view toDestLoc:(CGRect)destLoc completion:(void (^)(void))completion;

+ (void)autoCompleteMoveOfView:(UIView*)view sourceLoc:(CGRect)sourceLoc toDestLoc:(CGRect)destLoc currentLoc:(CGRect)currLoc completion:(void (^)(void))completion;
@end
