//
//  GTImageEditTool.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@class GTPhotoConfiguration;

typedef NS_ENUM(NSUInteger, GTImageEditType) {
    GTImageEditTypeClip     = 1 << 1,
    GTImageEditTypeRotate   = 1 << 2,
    GTImageEditTypeFilter   = 1 << 3,
    GTImageEditTypeDraw     = 1 << 4,
    GTImageEditTypeMosaic   = 1 << 5,
};

@interface GTImageEditTool : UIView

- (instancetype)initWithEditType:(GTImageEditType)type
                           image:(UIImage *)image
                   configuration:(GTPhotoConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) UIImage *editImage;

@property (nonatomic, copy) void (^cancelEditBlock)(void);
@property (nonatomic, copy) void (^doneEditBlock)(UIImage *);

@end
