//
//  PuzzleAnimation.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 25/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "PuzzleAnimation.h"

#define kTapAnimDuration 0.2
#define kSwipeAnimDuration 0.1

@implementation PuzzleAnimation

+ (void)moveViewOrigin:(UIView*)view toPoint:(CGPoint)point {
    [UIView animateWithDuration:kSwipeAnimDuration animations:^{
        CGRect frame = view.frame;
        frame.origin.x = point.x;
        frame.origin.y = point.y;
        view.frame = frame;
    }];
}

// move a block of views
+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction completion:(void (^)(BOOL finished))completion {
    
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
    } completion:^(BOOL finished) {
        if(completion) {
            completion(finished);
        }
    }];
}

+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction completion:(void (^)(BOOL finished))completion {
    [PuzzleAnimation moveViews:@[view] WithTranslation:translation direction:direction completion:completion];
}

+ (void)moveView:(UIView*)view WithTranslation:(CGPoint)translation direction:(MoveDirection)direction {
    [PuzzleAnimation moveView:view WithTranslation:translation direction:direction completion:nil];
}

@end
