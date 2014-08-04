//
//  OverlaySearchView.m
//  MelmanSkin
//
//  Created by willsbor Kang on 2014/7/8.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import "OverlaySearchView.h"

@implementation OverlaySearchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    else {
        return hitView;
    }
}


@end
