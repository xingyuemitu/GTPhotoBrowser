//
//  GTDrawItem.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GTDrawItemColorType) {
    GTDrawItemColorTypeWhite,
    GTDrawItemColorTypeDarkGray,
    GTDrawItemColorTypeRed,
    GTDrawItemColorTypeYellow,
    GTDrawItemColorTypeGreen,
    GTDrawItemColorTypeBlue,
    GTDrawItemColorTypePurple,
};

@interface GTDrawItem : UIView

- (UIColor *)color;

- (instancetype)initWithFrame:(CGRect)frame
                    colorType:(GTDrawItemColorType)colorType
                       target:(id)target
                       action:(SEL)action NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL selected;

@end
