//
//  PuzzleAnimation.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 25/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "PuzzleAnimation.h"

#define kDefaultAnimDuration 0.1

@implementation PuzzleAnimation

+ (void)autoCompleteMoveOfView:(UIView*)view sourceLoc:(CGRect)sourceLoc toDestLoc:(CGRect)destLoc currentLoc:(CGRect)currLoc completion:(void (^)(void))completion {
    CGRect intersect = CGRectIntersection(currLoc, destLoc);
    
    // TODO define macro?
    CGFloat intersectArea = CGRectGetHeight(intersect)*CGRectGetWidth(intersect);
    CGFloat destArea = CGRectGetHeight(destLoc)*CGRectGetWidth(destLoc);
    
    // if more than half way through
    BOOL moveComplete = intersectArea/destArea > 0.5;
    CGRect finalLoc = moveComplete? destLoc : sourceLoc;
    [UIView animateWithDuration:kDefaultAnimDuration animations:^{
        view.frame = finalLoc;
    } completion:^(BOOL finished) {
        if(moveComplete) {
            completion();
        }
    }];
}

+ (void)moveView:(UIView*)view toDestLoc:(CGRect)destLoc completion:(void (^)(void))completion {
    [UIView animateWithDuration:kDefaultAnimDuration animations:^{
        view.frame = destLoc;
    } completion:^(BOOL finished) {
        completion();
    }];
}

// move a block of views
+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction {
    
    // move along either horizontaly or vertically
    [UIView animateWithDuration:kDefaultAnimDuration animations:^{
        for(UIView *view in views) {
            CGFloat destX = view.center.x;
            CGFloat destY = view.center.y;
            if(direction == MoveDirectionLeft || direction == MoveDirectionRight) {
                destX += translation.x;
            } else {
                destY += translation.y;
            }
            view.center = CGPointMake(destX, destY);
        }
    }];
}

+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction {
    [PuzzleAnimation moveViews:@[view] WithTranslation:translation direction:direction];
}

@end
