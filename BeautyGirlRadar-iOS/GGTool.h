//
//  GGTool.h
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GGTool : NSObject

@end

UIImage *tmUIViewToImage(UIView *view);

UIImage *tmImageWithColor(UIColor *color);

UIImage *tmImageWithColorWithSize(UIColor *color, CGSize size);

UIImage *tmResizeImageWithScale(UIImage *aOriImage, CGSize aTargetSize, CGFloat aScale);