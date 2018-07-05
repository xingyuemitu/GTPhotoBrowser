//
//  GTCollectionCell.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@class GTPhotoModel;

@interface GTCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) UIImageView *selectImageView;
@property (nonatomic, strong) UIButton *btnSelect;
@property (weak, nonatomic) UIButton *cannotSelectLayerButton;
@property (weak, nonatomic) UILabel *indexLabel;
@property (nonatomic, strong) UIImageView *videoBottomView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *topView;

@property (assign, nonatomic) NSInteger index;
@property (nonatomic, assign) BOOL allSelectGif;
@property (nonatomic, assign) BOOL allSelectLivePhoto;
@property (nonatomic, assign) BOOL showSelectBtn;
@property (nonatomic, assign) CGFloat cornerRadio;
@property (nonatomic, strong) GTPhotoModel *model;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) BOOL showMask;
@property (nonatomic, assign) BOOL showSelectedIndex;
@property (nonatomic, assign) BOOL showPhotoCannotSelectLayer;
@property (strong, nonatomic) UIColor *cannotSelectLayerColor;
@property (assign, nonatomic) BOOL useCachedImage;

@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;



@property (nonatomic, copy) void (^selectedBlock)(BOOL);

@end


@interface GTTakePhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (void)startCapture;

- (void)restartCapture;

@end
