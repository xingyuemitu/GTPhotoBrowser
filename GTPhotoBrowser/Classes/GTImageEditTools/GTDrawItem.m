//
//  GTDrawItem.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTDrawItem.h"

@interface GTDrawItem ()
{
    GTDrawItemColorType _type;
    UIView *_colorView;
}

@end

@implementation GTDrawItem

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:CGRectZero colorType:GTDrawItemColorTypeWhite target:nil action:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithFrame:CGRectZero colorType:GTDrawItemColorTypeWhite target:nil action:nil];
}

- (instancetype)initWithFrame:(CGRect)frame colorType:(GTDrawItemColorType)colorType target:(id)target action:(SEL)action
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _type = colorType;
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-10, CGRectGetMidY(self.bounds)-10, 20, 20)];
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.cornerRadius = 10;
        _colorView.backgroundColor = [self colorWithType:colorType];;
        [self addSubview:_colorView];
    }
    return self;
}

- (UIColor *)color
{
    return [self colorWithType:_type];
}

- (UIColor *)colorWithType:(GTDrawItemColorType)colorType
{
    switch (colorType) {
        case GTDrawItemColorTypeWhite:    return [UIColor whiteColor];
        case GTDrawItemColorTypeDarkGray: return [UIColor darkGrayColor];
        case GTDrawItemColorTypeRed:      return [UIColor redColor];
        case GTDrawItemColorTypeYellow:   return [UIColor yellowColor];
        case GTDrawItemColorTypeGreen:    return [UIColor greenColor];
        case GTDrawItemColorTypeBlue:     return [UIColor blueColor];
        case GTDrawItemColorTypePurple:   return [UIColor purpleColor];
        default:                          return [UIColor redColor];
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
        [UIView animateWithDuration:0.15 animations:^{
            _colorView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        }];
    } else {
        _colorView.transform = CGAffineTransformIdentity;
    }
}

@end

