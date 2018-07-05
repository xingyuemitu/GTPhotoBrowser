//
//  GTCollectionCell.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTCollectionCell.h"
#import "GTPhotoModel.h"
#import "GTPhotoManager.h"
#import "GTPhotoDefine.h"
#import "ToastUtils.h"
#import "UIButton+EnlargeTouchArea.h"
#import "UIImage+GTPhotoBrowser.h"
#import "UIView+Layout.h"

@interface GTCollectionCell ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation GTCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    _cannotSelectLayerButton.frame = self.bounds;
    self.btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-44, 0, 44, 44);
    self.selectImageView.frame = CGRectMake(self.frame.size.width - 27, 3, 24, 24);
//    if (self.selectImageView.image.size.width <= 27) {
//        self.selectImageView.contentMode = UIViewContentModeCenter;
//    } else {
//        self.selectImageView.contentMode = UIViewContentModeScaleAspectFit;
//    }
    if (self.showSelectedIndex) {
        self.indexLabel.frame = self.selectImageView.frame;
    }
    if (self.showMask) {
        self.topView.frame = self.bounds;
    }
    self.videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-15, GetViewWidth(self), 15);
    self.videoImageView.frame = CGRectMake(5, 1, 16, 12);
    self.liveImageView.frame = CGRectMake(5, -1, 15, 15);
    self.timeLabel.frame = CGRectMake(30, 1, GetViewWidth(self)-35, 12);
    [self.contentView sendSubviewToBack:self.imageView];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        [self.contentView bringSubviewToFront:_topView];
        [self.contentView bringSubviewToFront:_videoBottomView];
        [self.contentView bringSubviewToFront:_cannotSelectLayerButton];
        [self.contentView bringSubviewToFront:_btnSelect];
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_indexLabel];
    }
    return _imageView;
}

- (UIButton *)btnSelect
{
    if (!_btnSelect) {
        _btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSelect.frame = CGRectMake(GetViewWidth(self.contentView)-26, 5, 23, 23);
        [_btnSelect addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnSelect];
    }
    return _btnSelect;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.contentMode = UIViewContentModeScaleToFill;
        selectImageView.clipsToBounds = YES;
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UILabel *)indexLabel {
    if (_indexLabel == nil) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.font = [UIFont systemFontOfSize:12];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:indexLabel];
        _indexLabel = indexLabel;
    }
    return _indexLabel;
}

- (UIButton *)cannotSelectLayerButton {
    if (_cannotSelectLayerButton == nil) {
        UIButton *cannotSelectLayerButton = [[UIButton alloc] init];
        [self.contentView addSubview:cannotSelectLayerButton];
        _cannotSelectLayerButton = cannotSelectLayerButton;
    }
    return _cannotSelectLayerButton;
}


- (UIImageView *)videoBottomView
{
    if (!_videoBottomView) {
        _videoBottomView = [[UIImageView alloc] initWithImage:GetImageWithName(@"gt_videoView")];
        _videoBottomView.frame = CGRectMake(0, GetViewHeight(self)-15, GetViewWidth(self), 15);
        [self.contentView addSubview:_videoBottomView];
    }
    return _videoBottomView;
}

- (UIImageView *)videoImageView
{
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 1, 16, 12)];
        _videoImageView.image = GetImageWithName(@"gt_video");
        [self.videoBottomView addSubview:_videoImageView];
    }
    return _videoImageView;
}

- (UIImageView *)liveImageView
{
    if (!_liveImageView) {
        _liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, -1, 15, 15)];
        _liveImageView.image = GetImageWithName(@"gt_livePhoto");
        [self.videoBottomView addSubview:_liveImageView];
    }
    return _liveImageView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 1, GetViewWidth(self)-35, 12)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        [self.videoBottomView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.userInteractionEnabled = NO;
        _topView.hidden = YES;
        [self.contentView addSubview:_topView];
    }
    return _topView;
}

- (void)setModel:(GTPhotoModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.cornerRadio;
    }
    
    if (model.type == GTAssetMediaTypeVideo) {
        self.videoBottomView.hidden = NO;
        self.videoImageView.hidden = NO;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = model.duration;
    } else if (model.type == GTAssetMediaTypeGif) {
        self.videoBottomView.hidden = !self.allSelectGif;
        self.videoImageView.hidden = YES;
        self.liveImageView.hidden = YES;
        self.timeLabel.text = @"GIF";
    } else if (model.type == GTAssetMediaTypeLivePhoto) {
        self.videoBottomView.hidden = !self.allSelectLivePhoto;
        self.videoImageView.hidden = YES;
        self.liveImageView.hidden = NO;
        self.timeLabel.text = @"Live";
    } else {
        self.videoBottomView.hidden = YES;
    }
    
    if (self.showMask) {
        self.topView.backgroundColor = [self.maskColor colorWithAlphaComponent:.2];
        self.topView.hidden = !model.isSelected;
    }
    
    self.btnSelect.hidden = !self.showSelectBtn;
    self.btnSelect.enabled = self.showSelectBtn;
    self.btnSelect.selected = model.isSelected;
    self.selectImageView.image = self.btnSelect.selected ? self.photoSelImage :  self.photoDefImage;
    self.indexLabel.hidden = !self.btnSelect.isSelected;

    if (model.needOscillatoryAnimation) {
        [UIView showOscillatoryAnimationWithLayer:self.selectImageView.layer type:GTOscillatoryAnimationToBigger];
    }
    model.needOscillatoryAnimation = NO;
    if (self.showSelectBtn) {
        //扩大点击区域
        [_btnSelect setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
    }
    
    CGSize size;
    size.width = GetViewWidth(self) * 1.7;
    size.height = GetViewHeight(self) * 1.7;
    
    gt_weakify(self);
    if (model.asset && self.imageRequestID >= PHInvalidImageRequestID) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.identifier = model.asset.localIdentifier;
    if (self.useCachedImage && model.cachedImage) {
        self.imageView.image = model.cachedImage;
    } else {
        self.imageView.image = nil;
        self.model.cachedImage = nil;
        self.imageRequestID = [GTPhotoManager requestImageForAsset:model.asset size:size completion:^(UIImage *image, NSDictionary *info) {
            gt_strongify(weakSelf);

            if ([strongSelf.identifier isEqualToString:model.asset.localIdentifier]) {
                strongSelf.imageView.image = image;
                strongSelf.model.cachedImage = image;
            }

            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                strongSelf.imageRequestID = -1;
            }
        }];
    }

    [self setNeedsLayout];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.hidden = !self.btnSelect.isSelected;
    self.indexLabel.text = [NSString stringWithFormat:@"%zd", index];
    [self.contentView bringSubviewToFront:self.indexLabel];
}

- (void)setShowSelectedIndex:(BOOL)showSelectedIndex {
    _showSelectedIndex = showSelectedIndex;
    if (showSelectedIndex) {
        self.photoSelImage = [UIImage createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    }
}

- (void)btnSelectClick:(UIButton *)sender {
    if (self.selectedBlock) {
        self.selectedBlock(self.btnSelect.selected);
    }
    if (self.btnSelect.selected) {
        [self.selectImageView.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
}

@end


//////////////////////////////////////
@import AVFoundation;

@interface GTTakePhotoCell ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutPut;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation GTTakePhotoCell

- (void)dealloc
{
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    _session = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"gt_takePhoto")];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat width = GetViewHeight(self)/3;
        self.imageView.frame = CGRectMake(0, 0, width, width);
        self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    }
    return self;
}

- (void)restartCapture
{
    [self.session stopRunning];
    [self startCapture];
}

- (void)startCapture
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] ||
        status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.session stopRunning];
                [self.previewLayer removeFromSuperlayer];
            });
        }
    }];
    
    if (self.session && [self.session isRunning]) {
        return;
    }
    
    [self.session stopRunning];
    [self.session removeInput:self.videoInput];
    [self.session removeOutput:self.stillImageOutPut];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    self.session = [[AVCaptureSession alloc] init];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    self.stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    NSDictionary *dicOutputSetting = [NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    [self.stillImageOutPut setOutputSettings:dicOutputSetting];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutPut]) {
        [self.session addOutput:self.stillImageOutPut];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.contentView.layer setMasksToBounds:YES];
    
    self.previewLayer.frame = self.contentView.layer.bounds;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.contentView.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


@end
