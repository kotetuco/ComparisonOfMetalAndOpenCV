//
//  OpenCVFunctions.h
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVFunctions : NSObject
- (UIImage *)thresholdImageWith:(UIImage *)sourceImage threashold:(int)threashold maxValue:(int)maxValue;
- (UIImage *)greyScaleImageWith:(UIImage *)sourceImage;
- (UIImage *)blurWith:(UIImage *)sourceImage width:(int)width height:(int)height scale:(double)scale;
- (UIImage *)gaussianBlurWith:(UIImage *)sourceImage sigma:(float)sigma width:(int)width height:(int)height;
- (UIImage *)resizeWith:(UIImage *)sourceImage scale:(double)scale;
@end

NS_ASSUME_NONNULL_END
