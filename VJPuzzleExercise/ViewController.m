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

#define kTileTag 100

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

    // allow user to select random image
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"New Image" style:UIBarButtonItemStyleBordered target:self action:@selector(selImageButtonPressed:)];

    self.data = [[PuzzleData alloc]initWithRowCount:kNumOfRows colCount:kNumOfCols];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // initialise container view - it's a square
    CGFloat puzzleWidth = self.view.frame.size.width;
    self.puzzleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, puzzleWidth, puzzleWidth)];
    [self.view addSubview:self.puzzleView];
    
    // pan gesture
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tileWasDragged:)];
    [self.puzzleView addGestureRecognizer:drag];
 
    // tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tileWasTapped:)];
    [self.puzzleView addGestureRecognizer:tap];
    
    // shuffle then layout tiles
    [self.data randomiseTiles];
    [self layoutTilesWithImageName:@"globe.jpg"];
}

- (void)layoutTilesWithImageName:(NSString*)imageName {
    
    // image tiles in an array
    NSArray *images = [ImageUtil makeTilesFromImage:imageName rowCount:kNumOfRows colCount:kNumOfRows];
    
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
            if(!tile.isEmpty) {
                imgView.image = image;
            }
            imgView.layer.borderWidth = 1.0;
            imgView.layer.borderColor = [UIColor blackColor].CGColor;
            imgView.tag = kTileTag+tile.index;
             
            [self.puzzleView addSubview:imgView];
            x += tileWidth;
        }
        x = 0.0;
        y += tileWidth;
    }
}

- (MoveDirection)directionFromVelocity:(CGPoint)velocity {
    // if moving sideways, use the highest value
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

- (void)tileWasTapped:(id)sender {

    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    Tile *tile = [self.data tileFromTouchPoint:[tap locationInView:self.puzzleView]];
    MoveDirection dir = [self.data findMoveForTile:tile];
    
    if(dir != MoveDirectionNone) {
        [self.data swapTileLocation:tile withTile:[self.data emptyTile]];
        [UIView animateWithDuration:0.2 animations:^{
            [self.puzzleView viewWithTag:kTileTag+tile.index].frame = tile.coordinateInView;
        }];
    }
}

- (void)tileWasDragged:(id)sender {
    UIPanGestureRecognizer *drag = (UIPanGestureRecognizer*)sender;
    
    //start drag
    if(drag.state == UIGestureRecognizerStateBegan) {
        self.swipe = [[TileSwipeEvent alloc]init];
        self.swipe.movedTile = [self.data tileFromTouchPoint:[drag locationInView:self.puzzleView]];
        return;
    }

    // dragging
    if(drag.state == UIGestureRecognizerStateChanged) {
        
        // check if move is legal
        if(!self.swipe.initialised) {
            CGPoint velocity = [drag velocityInView:self.view];
            self.swipe.direction = [self directionFromVelocity:velocity];
            self.swipe.canMove = [self.data canMoveTile:self.swipe.movedTile toDirection:self.swipe.direction];
            self.swipe.initialised = YES;
        }
//        NSLog(@"%@", [NSString stringWithFormat:@"Can move: %d", canMove]);
    
        if(self.swipe.canMove) {
            
            // TODO check bounds here
            
            CGPoint translation = [drag translationInView:self.view];
            UIView *view = [self.puzzleView viewWithTag:kTileTag+self.swipe.movedTile.index];
            
            CGFloat destX = view.center.x;
            CGFloat destY = view.center.y;
            
            // move along either horizontaly or vertically
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
        
        // TODO check if half way move???
        
        if(self.swipe.canMove) {
            [self.data swapTileLocation:self.swipe.movedTile withTile:[self.data emptyTile]];
            [UIView animateWithDuration:0.1 animations:^{
                [self.puzzleView viewWithTag:kTileTag+self.swipe.movedTile.index].frame = self.swipe.movedTile.coordinateInView;
            }];
        }
        self.swipe = nil;
        
        if([self.data isPuzzleSolved]) {
            [[[UIAlertView alloc]initWithTitle:@"Hooray" message:@"Congratulations, you have completed the puzzle!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        }
    }
}

@end
