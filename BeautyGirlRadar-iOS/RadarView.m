//
//  RadarView.m
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import "RadarView.h"

@interface RadarView () {
    CGFloat _duration;
}
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *lines;
@end

@implementation RadarView

- (NSMutableArray *)lines {
    if (_lines) {
        return _lines;
    }
    
    _lines = [[NSMutableArray alloc] init];
    
    return _lines;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _duration = 0.5;
    
    CGPoint center = self.center;
    
    CGFloat width = 30;
    for (int i = 0; i < CGRectGetWidth(self.frame) / width; ++i) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRectMake(i * width, 0, 1, CGRectGetHeight(self.frame)))];
        line.backgroundColor = [UIColor colorWithRed:0 green:0.65 blue:0 alpha:0.75];
        [self addSubview:line];

    }

    for (int j = 0; j < CGRectGetHeight(self.frame); ++j) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRectMake(0, j * width, CGRectGetWidth(self.frame), 1))];
        line.backgroundColor = [UIColor colorWithRed:0 green:0.65 blue:0 alpha:0.75];
        [self addSubview:line];
    }

    
    for (int i = 0; i < 30; ++i) {
        UIView *line = [[UIView alloc] initWithFrame:(CGRectMake(center.x, center.y, CGRectGetHeight(self.frame), 4))];
        line.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1.0];
        line.layer.anchorPoint = CGPointMake(0, 0.5);
        CGAffineTransform t = line.transform;
        t = CGAffineTransformTranslate(t, -CGRectGetHeight(self.frame) / 2, 0);
        t = CGAffineTransformRotate(t, M_2_PI * i / 60);
        line.transform = t;
        line.alpha = ((CGFloat)log(i)) / 30;
        [self addSubview:line];
        [self.lines addObject:line];
    }
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_duration/30 target:self selector:@selector(_nextAction:) userInfo:nil repeats:YES];
}

- (void)_nextAction:(id)sender {
    [UIView animateWithDuration:_duration/30 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent) animations:^{
        [self.lines enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {

            CGAffineTransform t = obj.transform;
            t = CGAffineTransformRotate(t, M_2_PI / 30);
            obj.transform = t;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
