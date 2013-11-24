//
//  ViewController.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "ViewController.h"
#import "ImageUtil.h"
#import "PuzzleData.h"
#import "TileSwipeEvent.h"

#define kNumOfRows 4
#define kNumOfCols 4

@interface ViewController ()
@property (nonatomic, strong) UIView *puzzleView;
@property (nonatomic, strong) PuzzleData *data;
@property (nonatomic, strong) TileSwipeEvent *swipe;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Solve" style:UIBarButtonItemStyleBordered target:self action:@selector(solveButtonPressed:)];
    
    self.data = [[PuzzleData alloc]initWithRowCount:kNumOfRows colCount:kNumOfRows];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // initialise container view - it's a square
    CGFloat puzzleWidth = self.view.frame.size.width;
    self.puzzleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, puzzleWidth, puzzleWidth)];
    [self.view addSubview:self.puzzleView];
    
    // register gesture recognizer to container view
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tileDragged:)];
    [self.puzzleView addGestureRecognizer:drag];
 
    [self.data randomiseTiles];
    [self layoutTileImages];
}

- (void)solveButtonPressed:(id)sender {
    // TODO
    for(UIView *view in [self.puzzleView subviews]) {
        [view removeFromSuperview];
    }
    // self.data solve
    // [self layoutTileImages]
}

- (void)layoutTileImages {
    
    // tile images in 2D Array
    NSArray *images = [ImageUtil makeTilesFromImage:@"globe.jpg" rowCount:kNumOfRows colCount:kNumOfRows];
    
    // init vars
    CGFloat x, y = 0.0;
    CGFloat tileWidth = self.puzzleView.frame.size.width/kNumOfRows;
    
    for(int i=0; i<self.data.rowCount; i++) {
        
         for(int j=0; j<self.data.colCount; j++) {

            Tile *tile = [self.data tileAtRow:i col:j];
             UIImage *image = [images objectAtIndex:tile.index];
             
            // TODO these shouldn't be stored in the model? Oh well..
            tile.coordinateInView = CGRectMake(x, y, tileWidth, tileWidth);
            
            // tile view
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, tileWidth, tileWidth)];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            if(tile.isEmpty) {
//                imgView.backgroundColor = [UIColor whiteColor];
            } else {
                imgView.image = image;
            }
            imgView.layer.borderWidth = 1.0;
            imgView.layer.borderColor = [UIColor blackColor].CGColor;
            imgView.tag = 100+tile.index;
             
            [self.puzzleView addSubview:imgView];
            x += tileWidth;
        }
        x = 0.0;
        y += tileWidth;
    }
}

- (MoveDirection)directionFromVelocity:(CGPoint)velocity {
    
    // TODO smoothen vector?
    CGFloat absX = fabs(velocity.x);
    CGFloat absY = fabs(velocity.y);
    if(absX > 0.0 && absY > 0.0) {
        if(absX > absY) {
            velocity.y = 0;
        } else {
            velocity.x = 0;
        }
    }
    
    MoveDirection direction;
    if(velocity.x > 0) {
        direction = MoveDirectionRight;
    } else if(velocity.x < 0) {
        direction = MoveDirectionLeft;
    } else if(velocity.y > 0) {
        direction = MoveDirectionBottom;
    } else {
        direction = MoveDirectionTop;
    }
    return direction;
}

- (void)tileDragged:(id)sender {
    UIPanGestureRecognizer *drag = (UIPanGestureRecognizer*)sender;
    
    //start drag
    if(drag.state == UIGestureRecognizerStateBegan) {
        self.swipe = [[TileSwipeEvent alloc]init];
        self.swipe.movedTile = [self.data tileFromTouchPoint:[drag locationInView:self.puzzleView]];
        return;
    }

    // dragging
    if(drag.state == UIGestureRecognizerStateChanged) {
        
        if(!self.swipe.initialised) {
            // check if moving to an empty slot
            CGPoint velocity = [drag velocityInView:self.view];
            self.swipe.direction = [self directionFromVelocity:velocity];
            self.swipe.canMove = [self.data canMoveTile:self.swipe.movedTile toDirection:self.swipe.direction];
            self.swipe.initialised = YES;
        }
//        NSLog(@"%@", [NSString stringWithFormat:@"Can move: %d", canMove]);
    
        if(self.swipe.canMove) {
            CGPoint translation = [drag translationInView:self.view];
            UIView *view = [self.puzzleView viewWithTag:100+self.swipe.movedTile.index];
            
            CGFloat destX = view.center.x;
            CGFloat destY = view.center.y;
            if(self.swipe.direction == MoveDirectionLeft || self.swipe.direction == MoveDirectionRight) {
                destX += translation.x;
            } else {
                destY += translation.y;
            }
            [UIView animateWithDuration:0.1 animations:^{
                view.center = CGPointMake(destX, destY);
            }];
            [drag setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    }
    // end drag
    else if(drag.state == UIGestureRecognizerStateEnded) {
        
        if(self.swipe.canMove) {
            [self.data swapTileLocation:self.swipe.movedTile withTile:[self.data emptyTile]];
            [UIView animateWithDuration:0.1 animations:^{
                [self.puzzleView viewWithTag:100+self.swipe.movedTile.index].frame = self.swipe.movedTile.coordinateInView;
            }];
        }
        self.swipe = nil;
        
        if([self.data isPuzzleSolved]) {
            [[[UIAlertView alloc]initWithTitle:@"Hooray" message:@"Congratulations, you have completed the puzzle!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }
    }
}

@end
