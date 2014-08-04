//
//  PreviewPhotoViewController.m
//  BeautyGirlRadar-iOS
//
//  Created by willsbor Kang on 2014/7/26.
//  Copyright (c) 2014年 gogolook. All rights reserved.
//

#import <GLCodeBase/Core.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

#import "PreviewPhotoViewController.h"

@interface PreviewPhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *pickerController;

@end

@implementation PreviewPhotoViewController

- (UIImagePickerController *)pickerController {
    if (_pickerController) {
        return _pickerController;
    }
    
    _pickerController = [[UIImagePickerController alloc] init];
    _pickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    _pickerController.allowsEditing = NO;
    _pickerController.delegate = self;
    
    return _pickerController;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    self.previewPhotoImage.image = img;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.previewPhotoImage.image) {
        [self presentViewController:self.pickerController animated:NO completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"segue.identifier = %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"takePhotoSegue"]) {
    }
    
}

- (UIImage *)fixOrientation:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (IBAction)clickToSendData:(id)sender {
    NSLog(@"clickToSendData");
//    GLDPRINT_METHOD_NAME();
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://54.199.246.223:5000/"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *dic = @{
                          @"fbid": @"iphoneffffffffbbbb",
                          @"lat": @(self.nowLocation.latitude),
                          @"lng": @(self.nowLocation.longitude),
                          };
    
    [manager POST:@"/api/bglbs"
       parameters:dic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"responseObject = %@", responseObject);
              [manager POST:[NSString stringWithFormat:@"api/%@/upload", responseObject[@"uid"]]
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      [formData appendPartWithFileData:UIImagePNGRepresentation([self fixOrientation:self.previewPhotoImage.image]) name:@"file" fileName:@"file.png" mimeType:@"image/png"];
              } success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error = %@", error);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
                  [SVProgressHUD showSuccessWithStatus:@"你的發射器失效了！"];
              });
              
          }];
    
    

    
}

@end
