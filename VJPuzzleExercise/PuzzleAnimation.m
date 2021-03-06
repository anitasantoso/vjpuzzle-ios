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

+ (void)moveView:(UIView*)view toDestLoc:(CGRect)destLoc completion:(void (^)(void))completion {
    [UIView animateWithDuration:kDefaultAnimDuration animations:^{
        view.frame = destLoc;
    } completion:^(BOOL finished) {
        completion();
    }];
}

// move a block of views
// may not need to pass in direction..
+ (void)moveViews:(NSArray*)views WithTranslation:(CGPoint)translation direction:(MoveDirection)direction startBounds:(CGRect)startBounds endBounds:(CGRect)endBounds completion:(void (^)(void))completion gestureEnd:(BOOL)gestureEnd animationDuration:(CGFloat)duration {
    
    for(UIView *view in views) {
        CGFloat destX = view.center.x;
        CGFloat destY = view.center.y;
        if(direction == MoveDirectionLeft || direction == MoveDirectionRight) {
            destX += translation.x;
        } else {
            destY += translation.y;
        }
        [UIView animateWithDuration:duration animations:^{
            view.center = CGPointMake(destX, destY);
        }];
    }

    if(!CGRectEqualToRect(endBounds, CGRectZero)) {
        UIView *view = [views lastObject];
        CGRect intersect = CGRectIntersection(view.frame, endBounds);
        
        CGFloat intersectArea = CGRectGetHeight(intersect)*CGRectGetWidth(intersect);
        CGFloat destArea = CGRectGetHeight(endBounds)*CGRectGetWidth(endBounds);
        
        // check if need to snap i.e. if more than half way
        if(intersectArea/destArea > 0.5) {
            CGFloat deltaX = CGRectGetMinX(endBounds)-CGRectGetMinX(view.frame);
            CGFloat deltaY = CGRectGetMinY(endBounds)-CGRectGetMinY(view.frame);
            [self _moveViews:views byPoint:CGPointMake(deltaX, deltaY) animationDuration:duration];
            completion();
        } else if(gestureEnd) {
            CGRect viewBounds = ((UIView*)[views firstObject]).frame;
            CGFloat deltaX = CGRectGetMinX(startBounds)-CGRectGetMinX(viewBounds);
            CGFloat deltaY = CGRectGetMinY(startBounds)-CGRectGetMinY(viewBounds);
            [self _moveViews:views byPoint:CGPointMake(deltaX, deltaY) animationDuration:duration];
        }
    }
}

+ (void)_moveViews:(NSArray*)views byPoint:(CGPoint)point animationDuration:(CGFloat)duration {
    for(UIView *view in views) {
        CGRect frame = view.frame;
        frame.origin.x += point.x;
        frame.origin.y += point.y;
        [UIView animateWithDuration:kDefaultAnimDuration animations:^{
            view.frame = frame;
        }];
    }
}

@end
