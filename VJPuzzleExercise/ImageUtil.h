//
//  ImageUtil.h
//  VJPuzzleExercise
//
//  Created by Anita Santoso on 24/11/13.
//  Copyright (c) 2013 AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject
+ (UIImage*)cropimage:(UIImage*)originalImage inRect:(CGRect)rect;
+ (NSArray*)makeTilesFromImage:(NSString*)imageName rowCount:(NSInteger)rowCount colCount:(NSInteger)colCount;
@end
