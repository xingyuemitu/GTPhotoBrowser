//
//  GTFilterItem.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTFilterItem.h"
#import "GTFilterTool.h"

@interface GTFilterItem ()
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@end

@implementation GTFilterItem

- (void)dealloc
{
    //    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:CGRectZero Image:nil filterType:GTFilterTypeOriginal target:nil action:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:CGRectZero Image:nil filterType:GTFilterTypeOriginal target:nil action:nil];
}

- (id)initWithFrame:(CGRect)frame Image:(UIImage *)image filterType:(GTFilterType)filterType target:(id)target action:(SEL)action
{
    self = [super initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        CGFloat W = frame.size.width;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, W-20, W-20)];
        _iconView.image = image;
        _iconView.clipsToBounds = YES;
        _iconView.layer.cornerRadius = 5;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconView.frame) + 5, W, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.filterType = filterType;
        self.iconImage = image;
    }
    return self;
}

- (void)setFilterType:(GTFilterType)filterType
{
    _filterType = filterType;
    NSString *title = nil;
    switch (filterType) {
        case GTFilterTypeOriginal: title = @"原图"; break;
        case GTFilterTypeSepia: title = @"怀旧"; break;
        case GTFilterTypeGrayscale: title = @"黑白"; break;
        case GTFilterTypeBrightness: title = @"高亮"; break;
        case GTFilterTypeSketch: title = @"素描"; break;
        case GTFilterTypeSmoothToon: title = @"卡通"; break;
        case GTFilterTypeGaussianBlur: title = @"毛玻璃"; break;
        case GTFilterTypeVignette: title = @"晕影"; break;
        case GTFilterTypeEmboss: title = @"浮雕"; break;
        case GTFilterTypeGamma: title = @"伽马"; break;
        case GTFilterTypeBulgeDistortion: title = @"鱼眼"; break;
        case GTFilterTypeStretchDistortion: title = @"哈哈镜"; break;
        case GTFilterTypePinchDistortion: title = @"凹透镜"; break;
        case GTFilterTypeColorInvert: title = @"反色"; break;
        default: title = nil;
    }
    _titleLabel.text = title;
}

- (void)setIconImage:(UIImage *)iconImage
{
    _iconImage = iconImage;
    [self filterImage:iconImage];
}

- (void)filterImage:(UIImage *)image
{
    if (!image) return;
    //加滤镜
    image = [GTFilterTool filterImage:image filterType:self.filterType];
    _iconView.image = image;
}

@end

