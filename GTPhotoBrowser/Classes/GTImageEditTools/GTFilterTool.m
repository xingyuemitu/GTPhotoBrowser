//
//  GTFilterTool.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTFilterTool.h"

@implementation GTFilterTool

+ (UIImage *)filterImage:(UIImage *)image filterType:(GTFilterType)filterType
{
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    id filter;
    
    switch (filterType) {
        case GTFilterTypeOriginal:
            return image;
        case GTFilterTypeSepia:
        {
            filter = [[GPUImageSepiaFilter alloc] init];
            break;
        }
        case GTFilterTypeGrayscale:
        {
            filter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        }
        case GTFilterTypeBrightness:
        {
            filter = [[GPUImageBrightnessFilter alloc] init];
            ((GPUImageBrightnessFilter *)filter).brightness = 0.1;
            break;
        }
        case GTFilterTypeSketch:
        {
            filter = [[GPUImageSketchFilter alloc] init];
            break;
        }
        case GTFilterTypeSmoothToon:
        {
            filter = [[GPUImageSmoothToonFilter alloc] init];
            break;
        }
        case GTFilterTypeGaussianBlur:
        {
            filter = [[GPUImageGaussianBlurFilter alloc] init];
            ((GPUImageGaussianBlurFilter *)filter).blurRadiusInPixels = 5.0f;
            break;
        }
        case GTFilterTypeVignette:
        {
            filter = [[GPUImageVignetteFilter alloc] init];
            break;
        }
        case GTFilterTypeEmboss:
        {
            filter = [[GPUImageEmbossFilter alloc] init];
            ((GPUImageEmbossFilter *)filter).intensity = 1;
            break;
        }
        case GTFilterTypeGamma:
        {
            filter = [[GPUImageGammaFilter alloc] init];
            ((GPUImageGammaFilter *)filter).gamma = 1.5;
            break;
        }
        case GTFilterTypeBulgeDistortion:
        {
            filter = [[GPUImageBulgeDistortionFilter alloc] init];
            ((GPUImageBulgeDistortionFilter *)filter).radius = 0.5;
            break;
        }
        case GTFilterTypeStretchDistortion:
        {
            filter = [[GPUImageStretchDistortionFilter alloc] init];
            break;
        }
        case GTFilterTypePinchDistortion:
        {
            filter = [[GPUImagePinchDistortionFilter alloc] init];
            break;
        }
        case GTFilterTypeColorInvert:
        {
            filter = [[GPUImageColorInvertFilter alloc] init];
            break;
        }
        default:
            return image;
    }
    
    [filter useNextFrameForImageCapture];
    [pic addTarget:filter];
    [pic processImage];
    
    return [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
}

@end
