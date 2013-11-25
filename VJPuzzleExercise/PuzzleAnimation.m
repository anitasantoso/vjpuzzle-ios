//
//  PuzzleAnimation.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 25/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "PuzzleAnimation.h"

//#define CGRectCalcArea(CGRect frame)

#define kTapAnimDuration 0.2
#define kSwipeAnimDuration 0.1

@implementation PuzzleAnimation

+ (void)autoCompleteMoveOfView:(UIView*)view sourceLoc:(CGRect)sourceLoc toDestLoc:(CGRect)destLoc currentLoc:(CGRect)currLoc completion:(void (^)(void))completion {
    CGRect intersect = CGRectIntersection(currLoc, destLoc);
    
    // TODO define macro?
    CGFloat intersectArea = CGRectGetHeight(intersect)*CGRectGetWidth(intersect);
    CGFloat destArea = CGRectGetHeight(destLoc)*CGRectGetWidth(destLoc);
    
    // if more than half way through
    BOOL moveComplete = intersectArea/destArea > 0.5;
    CGRect finalLoc = moveComplete? destLoc : sourceLoc;
    [UIView animateWithDuration:kSwipeAnimDuration animations:^{
        view.frame = finalLoc;
    } completion:^(BOOL finished) {
        if(moveComplete) {
            completion();
        }
    }];
}

+ (void)moveViewOrigin:(UIView*)view toPoint:(CGPoint)point {
    [UIView animateWithDuration:kSwipeAnimDuration animations:^{
        CGRect frame = view.frame;
        frame.origin.x = point.x;
        frame.origin.y = point.y;
        view.frame = frame;
    }];
}

// move a block of views
+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction {
    
    // move along either horizontaly or vertically
    [UIView animateWithDuration:kSwipeAnimDuration animations:^{
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
