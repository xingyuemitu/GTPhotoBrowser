//
//  UIView+Layout.h
//  GTImagePickerController
//
//  Created by liuxc on 2018/6/29.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GTOscillatoryAnimationToBigger,
    GTOscillatoryAnimationToSmaller,
} GTOscillatoryAnimationType;

@interface UIView (Layout)

@property (nonatomic) CGFloat gt_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat gt_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat gt_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat gt_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat gt_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat gt_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat gt_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat gt_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint gt_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  gt_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(GTOscillatoryAnimationType)type;

@end
