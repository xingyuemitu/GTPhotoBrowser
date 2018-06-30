//
//  GTFilterTool.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>
#import "GTFilterItem.h"
#import <GPUImage/GPUImage.h>

@interface GTFilterTool : NSObject

+ (UIImage *)filterImage:(UIImage *)image filterType:(GTFilterType)filterType;

@end
