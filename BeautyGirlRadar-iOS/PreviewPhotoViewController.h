//
//  PreviewPhotoViewController.h
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PreviewPhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *previewPhotoImage;
@property (nonatomic) CLLocationCoordinate2D nowLocation;

@end
