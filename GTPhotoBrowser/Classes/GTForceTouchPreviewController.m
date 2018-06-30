//
//  GTForceTouchPreviewController.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTForceTouchPreviewController.h"
#import "GTPhotoDefine.h"
#import "GTPhotoManager.h"
#import "GTPhotoModel.h"
#import <PhotosUI/PhotosUI.h>

@interface GTForceTouchPreviewController ()

@end

@implementation GTForceTouchPreviewController

- (void)dealloc
{
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    
    switch (self.model.type) {
        case GTAssetMediaTypeImage:
            [self loadNormalImage];
            break;
            
        case GTAssetMediaTypeGif:
            self.allowSelectGif ? [self loadGifImage] : [self loadNormalImage];
            break;
            
        case GTAssetMediaTypeLivePhoto:
            self.allowSelectLivePhoto ? [self loadLivePhoto] : [self loadNormalImage];
            break;
            
        case GTAssetMediaTypeVideo:
            [self loadVideo];
            break;
            
        default:
            break;
    }
}

#pragma mark - 加载静态图
- (void)loadNormalImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = [self getSize];
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [GTPhotoManager requestImageForAsset:self.model.asset size:CGSizeMake(size.width*2, size.height*2) completion:^(UIImage *img, NSDictionary *info) {
        imageView.image = img;
    }];
}

- (void)loadGifImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [GTPhotoManager requestOriginalImageDataForAsset:self.model.asset completion:^(NSData *data, NSDictionary *info) {
        imageView.image = [GTPhotoManager transformToGifImageWithData:data];
    }];
}

- (void)loadLivePhoto
{
    PHLivePhotoView *lpView = [[PHLivePhotoView alloc] init];
    lpView.contentMode = UIViewContentModeScaleAspectFit;
    lpView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:lpView];
    
    [GTPhotoManager requestLivePhotoForAsset:self.model.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
        lpView.livePhoto = lv;
        [lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }];
}

- (void)loadVideo
{
    AVPlayerLayer *playLayer = [[AVPlayerLayer alloc] init];
    playLayer.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view.layer addSublayer:playLayer];
    
    [GTPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            playLayer.player = player;
            [player play];
        });
    }];
}

- (CGSize)getSize
{
    CGFloat w = MIN(self.model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * self.model.asset.pixelHeight / self.model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight) {
        h = kViewHeight;
        w = h * self.model.asset.pixelWidth / self.model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

@end

