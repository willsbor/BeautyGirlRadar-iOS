//
//  GGTool.m
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import "GGTool.h"

@implementation GGTool



@end

UIImage *tmUIViewToImage(UIView *view)
{
    
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef context=UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    //取得影像
    UIImage *the_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return the_image;
}

UIImage *tmResizeImageWithScale(UIImage *aOriImage, CGSize aTargetSize, CGFloat aScale)
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, aTargetSize.width, aTargetSize.height));
    CGImageRef imageRef = aOriImage.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(aTargetSize, NO, aScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, aTargetSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

UIImage *tmImageWithColorWithSize(UIColor *color, CGSize size) {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

UIImage *tmImageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
