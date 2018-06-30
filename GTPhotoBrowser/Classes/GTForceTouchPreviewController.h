//
//  GTForceTouchPreviewController.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@class GTPhotoModel;

@interface GTForceTouchPreviewController : UIViewController

@property (nonatomic, assign) BOOL allowSelectGif;
@property (nonatomic, assign) BOOL allowSelectLivePhoto;
@property (nonatomic, strong) GTPhotoModel *model;

@end
