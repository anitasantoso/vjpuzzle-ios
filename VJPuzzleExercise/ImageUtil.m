//
//  ImageUtil.m
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (UIImage*)cropimage:(UIImage*)originalImage inRect:(CGRect)rect/** resizeTo:(CGSize)size **/{
    // first crop
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    return croppedImage;
    
    // then resize
    //    CGRect newFrame = CGRectMake(0, 0, size.width, size.height);
    //    UIGraphicsBeginImageContext(newFrame.size);
    //    [croppedImage drawInRect:newFrame];
    //
    //    UIImage *scaledImg = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    //    return [UIImage imageWithCGImage:[scaledImg CGImage]];
}


/**
 Cut images into given number of row and column. Assume row count == col count.
 **/
+ (NSArray*)makeTilesFromImage:(NSString*)imageName rowCount:(NSInteger)rowCount colCount:(NSInteger)colCount {
    
    UIImage *originalImage = [UIImage imageNamed:imageName];
    NSMutableArray *tileImages = [NSMutableArray arrayWithCapacity:rowCount];
    
    CGFloat x, y = 0.0;
    CGFloat tileWidth = originalImage.size.width/rowCount;
    CGFloat tileHeight = originalImage.size.height/colCount;
    
    for(int i=0; i<rowCount; i++) {
        for(int j=0; j<rowCount; j++) {
            UIImage *image = [ImageUtil cropimage:originalImage inRect:CGRectMake(x, y, tileWidth, tileHeight)];
            [tileImages addObject:image];
            x += tileWidth;
        }
        
        // reset origin point
        x = 0.0;
        y += tileHeight;
    }
    return tileImages;
}

@end
