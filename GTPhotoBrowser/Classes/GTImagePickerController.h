//
//  GTImagePickerController.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>
#import "GTPhotoDefine.h"
#import "GTPhotoConfiguration.h"

@class GTPhotoModel;

@interface GTImagePickerController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

/**
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<GTPhotoModel *> *arrSelectedModels;

/**
 相册框架配置
 */
@property (nonatomic, strong) GTPhotoConfiguration *configuration;

/**
 点击确定选择照片回调
 */
@property (nonatomic, copy) void (^callSelectImageBlock)(void);

/**
 编辑图片后回调
 */
@property (nonatomic, copy) void (^callSelectClipImageBlock)(UIImage *, PHAsset *);

/**
 取消block
 */
@property (nonatomic, copy) void (^cancelBlock)(void);


@end

@interface GTAlbumPickerController : UITableViewController

@end

