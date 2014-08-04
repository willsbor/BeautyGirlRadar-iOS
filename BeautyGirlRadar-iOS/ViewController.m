//
//  ViewController.m
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//
#import <BlocksKit/BlocksKit+UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GLCodeBase/Core.h>

#import "ViewController.h"
#import "GGTool.h"
#import "PreviewPhotoViewController.h"

@interface ViewController () <GMSMapViewDelegate> {
    BOOL _compass;
}
@property (strong,nonatomic)AVAudioPlayer *myAudioPlayer;

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageWithPhotoButton;
@property (weak, nonatomic) IBOutlet UIView *radarView;
@property (weak, nonatomic) IBOutlet UIView *circleMask;
@property (weak, nonatomic) IBOutlet UIView *detailDisplayView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UILabel *hotLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

#pragma mark - 

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TestGirl"]];
//    image.contentMode = UIViewContentModeScaleToFill;
//    image.clipsToBounds = YES;
//    image.frame = CGRectMake(5, 5, 190, 140);
//    image.layer.cornerRadius = 3.0;
//    image.layer.borderWidth = 0.5;
//    image.layer.borderColor = [[UIColor grayColor] CGColor];
//    UIView *v = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 200, 150))];
//    v.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//    v.layer.cornerRadius = 3.0;
//    v.layer.borderWidth = 1;
//    v.layer.borderColor = [[UIColor grayColor] CGColor];
//    [v addSubview:image];
//    
//    return v;
//}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSArray *pics = marker.userData[@"picurls"];
    
    if (![pics isKindOfClass:[NSNull class]] && [pics count] > 0) {
        [self.detailImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.199.246.223:5000/static/uploads/%@.thumb", [pics lastObject]]] placeholderImage:tmImageWithColor([UIColor brownColor])];
    }
    else {
//        self.detailImage.image = [UIImage imageNamed:@"TestGirl"];
        self.detailImage.image = tmImageWithColor([UIColor yellowColor]);
    }
    
    self.hotLabel.text = [NSString stringWithFormat:@"濃度：%@", marker.userData[@"count"]];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.detailDisplayView.alpha = 1.0;
    }];
    
    return YES;
}

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    UIActionSheet *action = [UIActionSheet bk_actionSheetWithTitle:@"動作"];
    [action bk_addButtonWithTitle:@"真的正！" handler:^{
        
    }];
    [action bk_addButtonWithTitle:@"亂來！不夠正！" handler:^{
        
    }];
    [action bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [action showInView:self.view];
}

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TestGirl"]];
//    
//    return image;
//}

- (void)_setMarkers:(NSArray *)datas {
    static NSMutableArray *marks;
    
    if (!marks) {
        marks = [[NSMutableArray alloc] init];
    }

    [marks enumerateObjectsUsingBlock:^(GMSMarker *obj, NSUInteger idx, BOOL *stop) {
        obj.map = nil;
    }];
    
    [marks removeAllObjects];

    //CLLocation *myloc = self.googleMapView.myLocation;
    
    static NSInteger max = 12;
    CGSize size = [UIImage imageNamed:@"HeatMap"].size;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.tintColor = RGBCOLOR(102, 204, 255);
//    imageView.tintColor = RGBCOLOR(40, 80, 255);
    UIImage *image = [UIImage imageNamed:@"HeatMap"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.image = image; // Expensive
    UIImage *redImage = tmUIViewToImage(imageView);
    
    [datas enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([obj[@"lat"] doubleValue], [obj[@"lng"] doubleValue]);
        marker.map = self.googleMapView;
        marker.flat = YES;
        marker.userData = obj;
        
        CGFloat ratio = [obj[@"count"] floatValue] / max;
        ratio = MIN(ratio, 1.0);
        ratio = MAX(ratio, 0.1);
        //marker.opacity = ratio * 0.4 + 0.6;
        ratio *= 2.5;
        marker.icon = tmResizeImageWithScale(redImage, CGSizeMake(size.width * ratio, size.height * ratio), 0);
        
        
        
        [marks addObject:marker];
    }];
}

- (void)_updateAllMarkers {
    NSURL *baseURL = [NSURL URLWithString:@"http://54.199.246.223:5000/"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"/api/bglbs"
      parameters:@{
                   @"lng": @(self.googleMapView.myLocation.coordinate.longitude),
                   @"lat": @(self.googleMapView.myLocation.coordinate.latitude),
                                      @"dist": @(.5),
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self _setMarkers:responseObject[@"results"]];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@ %@", error, operation.responseObject);
         }];
}

- (CLLocationManager *) locationManager
{
    if (_locationManager) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    return _locationManager;
}

- (void) startCompass
{
    if ([CLLocationManager locationServicesEnabled]) {
        
        _compass = YES;
        [self.locationManager startUpdatingHeading];
    } else {
        self.locationManager = nil;
    }
}

- (void) stopCompass
{
    if (_compass) {
        _compass = NO;
        
        if (self.locationManager) {
            [self.locationManager stopUpdatingHeading];
            self.locationManager = nil;
        }
        
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    //// 註 理論上 myLocation 變化時也要調整
    ///  不過實際上 羅盤不可能都不動到 基本上都會被update到
    
        CGFloat nowZoom = self.googleMapView.camera.zoom;
        double nowViewAngle = self.googleMapView.camera.viewingAngle;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.googleMapView.myLocation.coordinate
                                                               zoom:nowZoom
                                                            bearing:newHeading.trueHeading
                                                       viewingAngle:nowViewAngle];
    //    [self.googleMapView animateToCameraPosition:cp];
    [self.googleMapView moveCamera:[GMSCameraUpdate setCamera:camera]];
    
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.myAudioPlayer) {
        [self.myAudioPlayer stop];
        self.myAudioPlayer = nil;
    }
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"sssss" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    self.myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer.numberOfLoops = -1; //infinite loop
    [self.myAudioPlayer play];
    
    //[self startCompass];
}

- (UIImage*) createInvertMask:(UIImage *)maskImage withTargetImage:(UIImage *) image {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef mask = CGImageCreate(CGImageGetWidth(maskRef),
                                    CGImageGetHeight(maskRef),
                                    CGImageGetBitsPerComponent(maskRef),
                                    CGImageGetBitsPerPixel(maskRef),
                                    CGImageGetBytesPerRow(maskRef),
                                    CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo,
                                    CGImageGetDataProvider(maskRef),
                                    nil, NO,
                                    renderingIntent);
    
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    
    CGImageRelease(mask);
    CGImageRelease(maskRef);
    
    return [UIImage imageWithCGImage:masked];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    self.detailDisplayView.alpha = 0.0;
    self.detailDisplayView.layer.cornerRadius = 3.0;
    self.detailDisplayView.layer.borderWidth = 1.0;
    self.detailDisplayView.layer.borderColor = [[UIColor grayColor] CGColor];

    
    self.detailImage.layer.cornerRadius = 3.0;
    self.detailImage.layer.borderWidth = 0.5;
    self.detailImage.layer.borderColor = [[UIColor grayColor] CGColor];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:23.868
                                                            longitude:121.2086
                                                                 zoom:16];
//    marker.animated = YES;
//    marker.map = mapView;
    
    self.googleMapView.settings.myLocationButton = YES;
    self.googleMapView.settings.compassButton = YES;
//    [self.googleMapView.settings setAllGesturesEnabled:NO];
    self.googleMapView.settings.scrollGestures = NO;
    self.googleMapView.settings.rotateGestures = NO;
    self.googleMapView.settings.tiltGestures = NO;
    self.googleMapView.settings.zoomGestures = YES;
    
    self.googleMapView.myLocationEnabled = YES;
    self.googleMapView.delegate = self;
    
    [self.googleMapView moveCamera:[GMSCameraUpdate setCamera:camera]];
    
    
    self.circleMask.layer.cornerRadius = 
    
    self.sendMessageButton.layer.cornerRadius = 50;
    self.sendMessageWithPhotoButton.layer.cornerRadius = 50;
//    [self.sendMessageButton setBackgroundImage:tmImageWithColor([UIColor blueColor]) forState:(UIControlStateHighlighted)];
//    [self.sendMessageWithPhotoButton setBackgroundImage:tmImageWithColor([UIColor blueColor]) forState:(UIControlStateHighlighted)];
    
    [self.googleMapView addObserver:self forKeyPath:@"myLocation" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"myLocation"]) {
        CLLocation *loc = change[NSKeyValueChangeNewKey];
        //NSLog(@"%@", loc);
        
        
        double nowViewAngle = self.googleMapView.camera.viewingAngle;
        double bear = self.googleMapView.camera.bearing;
        double zoom = self.googleMapView.camera.zoom;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude
                                                                longitude:loc.coordinate.longitude
                                                                     zoom:zoom bearing:bear viewingAngle:nowViewAngle];
        
        [self.googleMapView moveCamera:[GMSCameraUpdate setCamera:camera]];
        
//        [self _testRandomMarks];
        
        static NSInteger timeCount = 0;
        
        if (timeCount == 0) {
            [self _updateAllMarkers];
            timeCount = 20;
        }
        else {
            timeCount--;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToMainView:(UIStoryboardSegue *)unwindSegue {
    //[unwindSegue.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToMainViewWithSendPhoto:(UIStoryboardSegue *)unwindSegue {
    NSLog(@"[%@", [unwindSegue.sourceViewController class]);
    
}

- (IBAction)clickSendMessage:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://54.199.246.223:5000/"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *dic = @{
                          @"fbid": @"iphoneffffffffbbbb",
                          @"lat": @(self.googleMapView.myLocation.coordinate.latitude),
                          @"lng": @(self.googleMapView.myLocation.coordinate.longitude),
                          };
    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:(0) error:nil];
    
//    [manager POST:@"/api/bglbs" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:data name:@"data"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject = %@", responseObject);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//            [SVProgressHUD showSuccessWithStatus:@"你已經散發了費洛蒙"];
//        });
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error = %@", error);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//            [SVProgressHUD showSuccessWithStatus:@"你的發射器失效了！"];
//        });
//        
//    }];
    
    [manager POST:@"/api/bglbs"
       parameters:dic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"responseObject = %@", responseObject);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
                  [SVProgressHUD showSuccessWithStatus:@"你已經散發了費洛蒙"];
              });
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error = %@", error);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
                  [SVProgressHUD showSuccessWithStatus:@"你的發射器失效了！"];
              });
              
          }];
    
    
}

- (IBAction)clickDetailImage:(id)sender {
    UIActionSheet *action = [UIActionSheet bk_actionSheetWithTitle:@"動作"];
    [action bk_addButtonWithTitle:@"真的正！" handler:^{
        
    }];
    [action bk_addButtonWithTitle:@"亂來！不夠正！" handler:^{
        
    }];
    [action bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [action showInView:self.view];
}

- (IBAction)clickDetailClose:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.detailDisplayView.alpha = 0.0;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"takePhotoSegue"]) {
        ((PreviewPhotoViewController *)segue.destinationViewController).nowLocation = self.googleMapView.myLocation.coordinate;
    }
}

@end
