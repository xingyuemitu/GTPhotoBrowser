//
//  GTFilterItem.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GTFilterType) {
    GTFilterTypeOriginal,          // 原图
    GTFilterTypeSepia,             // 怀旧
    GTFilterTypeGrayscale,         // 黑白
    GTFilterTypeBrightness,        // 高亮
    GTFilterTypeSketch,            // 素描
    GTFilterTypeSmoothToon,        // 卡通
    GTFilterTypeGaussianBlur,      // 毛玻璃
    GTFilterTypeVignette,          // 晕影
    GTFilterTypeEmboss,            // 浮雕
    GTFilterTypeGamma,             // 伽马
    GTFilterTypeBulgeDistortion,   // 鱼眼
    GTFilterTypeStretchDistortion, // 哈哈镜
    GTFilterTypePinchDistortion,   // 凹面镜
    GTFilterTypeColorInvert,       // 反色
};

@interface GTFilterItem : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        Image:(UIImage *)image
                   filterType:(GTFilterType)filterType
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) GTFilterType filterType;
@property (nonatomic, strong) UIImage *iconImage;

@end

