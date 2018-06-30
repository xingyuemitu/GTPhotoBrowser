//
//  GTEditViewController.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@class GTPhotoModel;

@interface GTEditViewController : UIViewController

@property (nonatomic, strong) UIImage *oriImage;
@property (nonatomic, strong) GTPhotoModel *model;

@end
