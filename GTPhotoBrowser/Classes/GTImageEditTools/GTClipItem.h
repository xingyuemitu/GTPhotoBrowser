//
//  GTClipItem.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@interface GTClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end


@interface GTGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;

@end


@interface GTClipRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end


@interface GTClipItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, strong) GTClipRatio *ratio;

- (instancetype)initWithFrame:(CGRect)frame
                        image:(UIImage *)image
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

- (void)refreshViews;

- (void)changeOrientation;

@end

