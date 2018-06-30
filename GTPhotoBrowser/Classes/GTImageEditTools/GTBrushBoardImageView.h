//
//  GTBrushBoardImageView.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@interface GTBrushBoardImageView : UIImageView

@property (nonatomic, strong) UIColor *drawColor;

@property (nonatomic, assign) BOOL drawEnable;

- (void)revoke;

@end
