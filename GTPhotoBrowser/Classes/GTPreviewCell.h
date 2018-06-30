//
//  GTPreviewCell.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

@class GTPhotoModel;
@class PHAsset;
@class GTPreviewView;

@interface GTPreviewCell : UICollectionViewCell


@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) GTPreviewView *previewView;
@property (nonatomic, strong) GTPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);
@property (nonatomic, assign) BOOL willDisplaying;


/**
 重置缩放比例
 */
- (void)resetCellStatus;

/**
 界面停止滑动后，加载gif和livephoto，保持界面流畅
 */
- (void)reloadGifLivePhoto;

/**
 界面滑动时，停止播放gif、livephoto、video
 */
- (void)pausePlay;

@end


@class GTPreviewImageAndGif;
@class GTPreviewLivePhoto;
@class GTPreviewVideo;
@class GTPreviewNetVideo;

//预览大图，image、gif、livephoto、video
@interface GTPreviewView : UIView

@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) GTPreviewImageAndGif *imageGifView;
@property (nonatomic, strong) GTPreviewLivePhoto *livePhotoView;
@property (nonatomic, strong) GTPreviewVideo *videoView;
@property (nonatomic, strong) GTPreviewNetVideo *netVideoView;
@property (nonatomic, strong) GTPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);

/**
 界面每次即将显示时，重置scrollview缩放状态
 */
- (void)resetScale;

/**
 处理划出界面后操作
 */
- (void)handlerEndDisplaying;

/**
 reload gif,livephoto,video
 */
- (void)reload;

- (void)resumePlay;

- (void)pausePlay;

- (UIImage *)image;

@end


//---------------base preview---------------
@interface GTBasePreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);

- (void)singleTapAction;

- (void)loadNormalImage:(PHAsset *)asset;

- (void)resetScale;

- (UIImage *)image;

@end

//---------------image、gif、net image---------------
@interface GTPreviewImageAndGif : GTBasePreviewView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) BOOL loadOK;

@property (nonatomic, copy)   void (^longPressCallBack)(void);

- (void)loadGifImage:(PHAsset *)asset;
- (void)loadImage:(id)obj;

- (void)resumeGif;
- (void)pauseGif;

@end


//---------------livephoto---------------
@interface GTPreviewLivePhoto : GTBasePreviewView

@property (nonatomic, strong) PHLivePhotoView *lpView;

- (void)loadLivePhoto:(PHAsset *)asset;

- (void)stopPlayLivePhoto;

@end


//---------------video---------------
@interface GTPreviewVideo : GTBasePreviewView

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;
@property (nonatomic, strong) UIButton *playBtn;

- (BOOL)haveLoadVideo;

- (void)stopPlayVideo;

@end


//---------------net video---------------
@interface GTPreviewNetVideo : GTBasePreviewView

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UIButton *playBtn;

- (void)loadNetVideo:(NSURL *)url;

- (void)seekToZero;

- (void)stopPlayNetVideo;

@end

