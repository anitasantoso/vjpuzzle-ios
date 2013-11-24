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

#define kNumOfRows 4
#define kNumOfCols 4

@interface ViewController ()
@property (nonatomic, strong) UIView *puzzleView;
@property (nonatomic, strong) PuzzleData *data;
@property (nonatomic, strong) Tile *movedTile;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [[PuzzleData alloc]initWithRowCount:kNumOfRows colCount:kNumOfRows];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // initialise container view - it's a square
    CGFloat puzzleWidth = self.view.frame.size.width;
    self.puzzleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, puzzleWidth, puzzleWidth)];
    [self.view addSubview:self.puzzleView];
    
    // solve button
    UIButton *btn = [UIButton alloc]initWithFrame:CGREc
    
    // register gesture recognizer to container view
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tileDragged:)];
    [self.puzzleView addGestureRecognizer:drag];
 
    [self.data randomiseTiles];
    [self layoutTileImages];
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
            imgView.tag = tile.index;
             
            [self.puzzleView addSubview:imgView];
            x += tileWidth;
        }
        x = 0.0;
        y += tileWidth;
    }
}

- (MoveDirection)directionFromVelocity:(CGPoint)velocity {
    
    // TODO smoothen vector?
    
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
        self.movedTile = [self.data tileFromTouchPoint:[drag locationInView:self.puzzleView]];
    }
    
    // end drag
    else if(drag.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [drag velocityInView:self.view];
        
        // check if moving to an empty slot
        MoveDirection direction = [self directionFromVelocity:velocity];
        BOOL canMove = [self.data canMoveTile:self.movedTile toDirection:direction];
        NSLog(@"%@", [NSString stringWithFormat:@"Can move: %d", canMove]);

        if(canMove) {
            [self.data swapTileLocation:self.movedTile withTile:[self.data emptyTile]];

            [UIView animateWithDuration:0.5 animations:^{
                [self.puzzleView viewWithTag:self.movedTile.index].frame = self.movedTile.coordinateInView;
            }];
        }
        self.movedTile = nil;
        
        if([self.data isPuzzleSolved]) {
            [[[UIAlertView alloc]initWithTitle:@"Hooray" message:@"Congratulations, you have completed the puzzle!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }
    }
}

@end
