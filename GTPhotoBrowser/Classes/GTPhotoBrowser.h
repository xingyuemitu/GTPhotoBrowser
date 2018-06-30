//
//  GTPhotoBrowser.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class GTPhotoModel;
@class GTPhotoBrowser;

typedef void(^layoutBlock)(GTPhotoBrowser *photoBrowser, CGRect superFrame);

@protocol GTPhotoBrowserDelegate<NSObject>

@optional

// 滚动到一半时索引改变
- (void)photoBrowser:(GTPhotoBrowser *)browser didChangedIndex:(NSInteger)index;

// 滚动结束时索引改变
- (void)photoBrowser:(GTPhotoBrowser *)browser scrollEndedIndex:(NSInteger)index;

// 单击事件
- (void)photoBrowser:(GTPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index;

// 长按事件
- (void)photoBrowser:(GTPhotoBrowser *)browser longPressWithIndex:(NSInteger)index;

// 旋转事件
- (void)photoBrowser:(GTPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandspace:(BOOL)isLandspace;

// 上下滑动消失
// 开始滑动时
- (void)photoBrowser:(GTPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index;

// 结束滑动时 disappear：是否消失
- (void)photoBrowser:(GTPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear;


- (void)photoBrowser:(GTPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index;

@end

@interface GTPhotoBrowser : UIViewController

@property (nonatomic, strong) NSArray<GTPhotoModel *> *models;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

//点击选择后的图片预览数组，预览相册图片时为 UIImage，预览网络图片时候为UIImage/NSUrl
@property (nonatomic, strong) NSMutableArray *arrSelPhotos;

/**预览 网络/本地 图片时候是否 隐藏底部工具栏和导航右上角按钮*/
@property (nonatomic, assign) BOOL hideToolBar;

//预览相册图片回调
@property (nonatomic, copy) void (^previewSelectedImageBlock)(NSArray<UIImage *> *arrP, NSArray<PHAsset *> *arrA);

//预览网络图片回调
@property (nonatomic, copy) void (^previewNetImageBlock)(NSArray *photos);

//预览 相册/网络 图片时候，点击返回回调
@property (nonatomic, copy) void (^cancelPreviewBlock)(void);


// 初始化方法

/**
 创建图片浏览器
 
 @param photos 包含GKPhoto对象的数组
 @param currentIndex 当前的页码
 @return 图片浏览器对象
 */
+ (instancetype)photoBrowserWithPhotos:(NSArray<GTPhotoModel *> *)photos currentIndex:(NSInteger)currentIndex;

- (instancetype)initWithPhotos:(NSArray<GTPhotoModel *> *)photos currentIndex:(NSInteger)currentIndex;

/**
 为浏览器添加自定义遮罩视图
 
 @param coverViews  视图数组
 @param layoutBlock 布局
 */
- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock;

/**
 显示图片浏览器
 
 @param vc 控制器
 */
- (void)showFromVC:(UIViewController *)vc;


@end
