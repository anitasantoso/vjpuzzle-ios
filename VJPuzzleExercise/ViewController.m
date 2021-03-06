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
#import "PuzzleAnimation.h"

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Start Over" style:UIBarButtonItemStyleBordered target:self action:@selector(startButtonPressed:)];

    self.view.backgroundColor = [UIColor whiteColor];
    
    // initialise container view - it's a square
    CGFloat puzzleWidth = self.view.frame.size.width;
    self.puzzleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, puzzleWidth, puzzleWidth)];
    [self.view addSubview:self.puzzleView];
    
    // pan gesture
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.puzzleView addGestureRecognizer:drag];
 
    // tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.puzzleView addGestureRecognizer:tap];
    
    [self createDefaultPuzzle];
}

- (void)createDefaultPuzzle {
    // shuffle then layout tiles
    self.data = [[PuzzleData alloc]initWithRowCount:kNumOfRows colCount:kNumOfCols];
    [self.data randomiseTiles];
    [self layoutTilesWithImageName:@"globe.jpg"];
}

- (void)startButtonPressed:(id)sender {
    for(UIView *view in self.puzzleView.subviews) {
        [view removeFromSuperview];
    }
    [self createDefaultPuzzle];
}

- (void)layoutTilesWithImageName:(NSString*)imageName {
    
    // image tiles in an array
    NSArray *images = [ImageUtil makeTilesFromImage:imageName rowCount:kNumOfRows colCount:kNumOfRows];
    
    CGFloat x = 0.0, y = 0.0;
    CGFloat tileWidth = self.puzzleView.frame.size.width/kNumOfRows;
    
    for(int row=0; row<self.data.rowCount; row++) {
        for(int col=0; col<self.data.colCount; col++) {
            
            Tile *tile = [self.data tileAtRow:row col:col];
            UIImage *image = [images objectAtIndex:tile.index];
             
            // TODO these shouldn't be stored in the model? Oh well..
            tile.coordinateInView = CGRectMake(x, y, tileWidth, tileWidth);
            
            // tile view
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, tileWidth, tileWidth)];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            if(!tile.isEmpty) {
                imgView.image = image;
                imgView.layer.borderWidth = 1.0;
                imgView.layer.borderColor = [UIColor blackColor].CGColor;
            }
            imgView.tag = kTileTag+tile.index;
             
            [self.puzzleView addSubview:imgView];
            y += tileWidth;
        }
        y = 0.0;
        x += tileWidth;
    }
}

- (CGFloat)animDurationFromVelocity:(CGPoint)velocity {
    velocity = [self refineVelocity:velocity];
    CGFloat value = velocity.x > 0? velocity.x : velocity.y;
    return (ABS(value)*.0002)+.7;
}

- (MoveDirection)directionFromVelocity:(CGPoint)velocity {
    velocity = [self refineVelocity:velocity];
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

- (CGPoint)refineVelocity:(CGPoint)velocity {
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
    return velocity;
}

- (void)handleTap:(id)sender {

    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    Tile *tile = [self.data tileFromTouchPoint:[tap locationInView:self.puzzleView]];
    MoveDirection dir = [self.data findMoveForTile:tile];
    
    if(dir != MoveDirectionNone) {
        UIView *view = [self viewForTile:tile];
        [PuzzleAnimation moveView:view toDestLoc:[self.data emptyTile].coordinateInView completion:^{
            [self.data moveTile:tile];
            [self checkIfPuzzleSolved];
        }];
    }
}

- (void)handlePan:(id)sender {
    UIPanGestureRecognizer *drag = (UIPanGestureRecognizer*)sender;
    
    //start drag
    if(drag.state == UIGestureRecognizerStateBegan) {
        self.swipe = [[TileSwipeEvent alloc]init];
        self.swipe.movedTile = [self.data tileFromTouchPoint:[drag locationInView:self.puzzleView]];
        return;
    }
    // dragging
    if(drag.state == UIGestureRecognizerStateChanged) {
        
        // check if move is legal, initialise swipe event
        if(!self.swipe.initialised) {
            [self initSwipeEvent:self.swipe fromGesture:drag];
        }
        [self animateGesture:drag moveTile:NO gestureEnd:NO];
    }
    // end drag
    else if(drag.state == UIGestureRecognizerStateEnded) {
       
        [self animateGesture:drag moveTile:YES gestureEnd:YES];
        [self checkIfPuzzleSolved];
    }
}

- (void)initSwipeEvent:(TileSwipeEvent*)swipe fromGesture:(UIPanGestureRecognizer*)drag {
    CGPoint velocity = [drag velocityInView:self.view];
    MoveDirection direction = [self directionFromVelocity:velocity];
    
    // somehow swipe begin was not recognized?
    if(!self.swipe.movedTile) {
        self.swipe = nil;
        return;
    }
    Tile *tile = self.swipe.movedTile;
    self.swipe.direction = direction;
    self.swipe.canMove = [self.data canMoveTile:tile inDirection:self.swipe.direction];
    self.swipe.blockTiles = [self.data blockTilesNextTo:tile inDirection:direction];
    self.swipe.initialised = YES;
}

- (void)animateGesture:(UIPanGestureRecognizer*)drag moveTile:(BOOL)moveTile gestureEnd:(BOOL)gestureEnd {
    if(self.swipe.initialised && self.swipe.canMove) {
        
        NSArray *tiles = self.swipe.blockTiles;
        NSArray *views = [self viewsForTiles:tiles];
        CGPoint translation = [drag translationInView:self.view];
        
        CGPoint velocity = [drag velocityInView:self.view];
        
        // not sure if this is better than having a fixed duration
        CGFloat duration = [self animDurationFromVelocity:velocity];
        
        [PuzzleAnimation moveViews:views WithTranslation:translation direction:self.swipe.direction startBounds:((Tile*)[tiles firstObject]).coordinateInView endBounds:self.data.emptyTile.coordinateInView completion:^{
            [self.data moveBlockOfTiles:tiles];
            self.swipe = nil;
        } gestureEnd:gestureEnd animationDuration:duration];
        [drag setTranslation:CGPointMake(0, 0) inView:self.view]; // reset translation
    }
}

- (void)checkIfPuzzleSolved {
    if([self.data isPuzzleSolved]) {
        [[[UIAlertView alloc]initWithTitle:@"Hooray" message:@"Congratulations, you have completed the puzzle!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        self.puzzleView.userInteractionEnabled = NO;
    }
}

- (NSArray*)viewsForTiles:(NSArray*)tiles {
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:tiles.count];
    for(Tile *tile in tiles) {
        [views addObject:[self viewForTile:tile]];
    }
    return views;
}

- (UIView*)viewForTile:(Tile*)tile {
    return [self.puzzleView viewWithTag:kTileTag+tile.index];
}

@end
