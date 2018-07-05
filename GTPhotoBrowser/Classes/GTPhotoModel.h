//
//  GTPhotoModel.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, GTAssetMediaType) {
    GTAssetMediaTypeUnknown,
    GTAssetMediaTypeImage,
    GTAssetMediaTypeGif,
    GTAssetMediaTypeLivePhoto,
    GTAssetMediaTypeVideo,
    GTAssetMediaTypeAudio,
    GTAssetMediaTypeNetImage,
    GTAssetMediaTypeNetVideo,
};

@interface GTPhotoModel : NSObject

//asset对象
@property (nonatomic, strong) PHAsset *asset;
//asset类型
@property (nonatomic, assign) GTAssetMediaType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//网络/本地 图片url
@property (nonatomic, strong) NSURL *url ;
//图片
@property (nonatomic, strong) UIImage *image;
//缓存Image
@property (strong, nonatomic) UIImage *cachedImage;
//是否立即弹性动画
@property (assign, nonatomic) BOOL needOscillatoryAnimation;


/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(GTAssetMediaType)type duration:(NSString *)duration;

@end

@interface GTAlbumListModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isCameraRoll;
@property (nonatomic, strong) PHFetchResult *result;
//相册第一张图asset对象
@property (nonatomic, strong) PHAsset *headImageAsset;

@property (nonatomic, strong) NSArray<GTPhotoModel *> *models;
@property (nonatomic, strong) NSArray *selectedModels;
//待用
@property (nonatomic, assign) NSUInteger selectedCount;

@end
