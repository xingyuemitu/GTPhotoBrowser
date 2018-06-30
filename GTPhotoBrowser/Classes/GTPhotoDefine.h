//
//  GTPhotoDefine.h
//  Pods
//
//  Created by liuxc on 2018/6/30.
//

#ifndef GTPhotoDefine_h
#define GTPhotoDefine_h


#import "GTProgressHUD.h"
#import "NSBundle+GTPhotoBrowser.h"

#define GTPhotoBrowserCameraText @"GTPhotoBrowserCameraText"
#define GTPhotoBrowserCameraRecordText @"GTPhotoBrowserCameraRecordText"
#define GTPhotoBrowserAblumText @"GTPhotoBrowserAblumText"
#define GTPhotoBrowserCancelText @"GTPhotoBrowserCancelText"
#define GTPhotoBrowserOriginalText @"GTPhotoBrowserOriginalText"
#define GTPhotoBrowserDoneText @"GTPhotoBrowserDoneText"
#define GTPhotoBrowserOKText @"GTPhotoBrowserOKText"
#define GTPhotoBrowserBackText @"GTPhotoBrowserBackText"
#define GTPhotoBrowserPhotoText @"GTPhotoBrowserPhotoText"
#define GTPhotoBrowserPreviewText @"GTPhotoBrowserPreviewText"
#define GTPhotoBrowserLoadingText @"GTPhotoBrowserLoadingText"
#define GTPhotoBrowserHandleText @"GTPhotoBrowserHandleText"
#define GTPhotoBrowserSaveImageErrorText @"GTPhotoBrowserSaveImageErrorText"
#define GTPhotoBrowserMaxSelectCountText @"GTPhotoBrowserMaxSelectCountText"
#define GTPhotoBrowserNoCameraAuthorityText @"GTPhotoBrowserNoCameraAuthorityText"
#define GTPhotoBrowserNoAblumAuthorityText @"GTPhotoBrowserNoAblumAuthorityText"
#define GTPhotoBrowserNoMicrophoneAuthorityText @"GTPhotoBrowserNoMicrophoneAuthorityText"
#define GTPhotoBrowseriCloudPhotoText @"GTPhotoBrowseriCloudPhotoText"
#define GTPhotoBrowserGifPreviewText @"GTPhotoBrowserGifPreviewText"
#define GTPhotoBrowserVideoPreviewText @"GTPhotoBrowserVideoPreviewText"
#define GTPhotoBrowserLivePhotoPreviewText @"GTPhotoBrowserLivePhotoPreviewText"
#define GTPhotoBrowserNoPhotoText @"GTPhotoBrowserNoPhotoText"
#define GTPhotoBrowserCannotSelectVideo @"GTPhotoBrowserCannotSelectVideo"
#define GTPhotoBrowserCannotSelectGIF @"GTPhotoBrowserCannotSelectGIF"
#define GTPhotoBrowserCannotSelectLivePhoto @"GTPhotoBrowserCannotSelectLivePhoto"
#define GTPhotoBrowseriCloudVideoText @"GTPhotoBrowseriCloudVideoText"
#define GTPhotoBrowserEditText @"GTPhotoBrowserEditText"
#define GTPhotoBrowserSaveText @"GTPhotoBrowserSaveText"
#define GTPhotoBrowserMaxVideoDurationText @"GTPhotoBrowserMaxVideoDurationText"
#define GTPhotoBrowserLoadNetImageFailed @"GTPhotoBrowserLoadNetImageFailed"
#define GTPhotoBrowserSaveVideoFailed @"GTPhotoBrowserSaveVideoFailed"

#define GTPhotoBrowserCameraRoll @"GTPhotoBrowserCameraRoll"
#define GTPhotoBrowserPanoramas @"GTPhotoBrowserPanoramas"
#define GTPhotoBrowserVideos @"GTPhotoBrowserVideos"
#define GTPhotoBrowserFavorites @"GTPhotoBrowserFavorites"
#define GTPhotoBrowserTimelapses @"GTPhotoBrowserTimelapses"
#define GTPhotoBrowserRecentlyAdded @"GTPhotoBrowserRecentlyAdded"
#define GTPhotoBrowserBursts @"GTPhotoBrowserBursts"
#define GTPhotoBrowserSlomoVideos @"GTPhotoBrowserSlomoVideos"
#define GTPhotoBrowserSelfPortraits @"GTPhotoBrowserSelfPortraits"
#define GTPhotoBrowserScreenshots @"GTPhotoBrowserScreenshots"
#define GTPhotoBrowserDepthEffect @"GTPhotoBrowserDepthEffect"
#define GTPhotoBrowserLivePhotos @"GTPhotoBrowserLivePhotos"
#define GTPhotoBrowserAnimated @"GTPhotoBrowserAnimated"

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define gt_weakify(var)   __weak typeof(var) weakSelf = var
#define gt_strongify(var) __strong typeof(var) strongSelf = var

#define GT_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define GT_IS_IPHONE_X (GT_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)
#define GT_SafeAreaBottom (GT_IS_IPHONE_X ? 34 : 0)

#define kGTPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

// 图片路径
#define kGTPhotoBrowserSrcName(file) [@"GTPhotoBrowser.bundle" stringByAppendingPathComponent:file]
#define kGTPhotoBrowserFrameworkSrcName(file) [@"Frameworks/GTPhotoBrowser.framework/GTPhotoBrowser.bundle" stringByAppendingPathComponent:file]

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

//app名字
#define kInfoDict [NSBundle mainBundle].infoDictionary
#define kAPPName [kInfoDict valueForKey:@"CFBundleDisplayName"] ?: [kInfoDict valueForKey:@"CFBundleName"]

//自定义图片名称存于plist中的key
#define GTCustomImageNames @"GTCustomImageNames"
//设置框架语言的key
#define GTLanguageTypeKey @"GTLanguageTypeKey"
//自定义多语言key value存于plist中的key
#define GTCustomLanguageKeyValue @"GTCustomLanguageKeyValue"

////////GTShowBigImgViewController
#define kItemMargin 40

///////GTBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

#define ClippingRatioValue1 @"value1"
#define ClippingRatioValue2 @"value2"
#define ClippingRatioTitleFormat @"titleFormat"

#define GTPreviewPhotoObj @"GTPreviewPhotoObj"
#define GTPreviewPhotoTyp @"GTPreviewPhotoTyp"

typedef NS_ENUM(NSUInteger, GTLanguageType) {
    //跟随系统语言，默认
    GTLanguageSystem,
    //中文简体
    GTLanguageChineseSimplified,
    //中文繁体
    GTLanguageChineseTraditional,
    //英文
    GTLanguageEnglish,
    //日文
    GTLanguageJapanese,
};

//录制视频及拍照分辨率
typedef NS_ENUM(NSUInteger, GTCaptureSessionPreset) {
    GTCaptureSessionPreset325x288,
    GTCaptureSessionPreset640x480,
    GTCaptureSessionPreset1280x720,
    GTCaptureSessionPreset1920x1080,
    GTCaptureSessionPreset3840x2160,
};

//导出视频类型
typedef NS_ENUM(NSUInteger, GTExportVideoType) {
    //default
    GTExportVideoTypeMov,
    GTExportVideoTypeMp4,
};

//导出视频水印位置
typedef NS_ENUM(NSUInteger, GTWatermarkLocation) {
    GTWatermarkLocationTopLeft,
    GTWatermarkLocationTopRight,
    GTWatermarkLocationCenter,
    GTWatermarkLocationBottomLeft,
    GTWatermarkLocationBottomRight,
};

//混合预览图片时，图片类型
typedef NS_ENUM(NSUInteger, GTPreviewPhotoType) {
    GTPreviewPhotoTypePHAsset,
    GTPreviewPhotoTypeUIImage,
    GTPreviewPhotoTypeURLImage,
    GTPreviewPhotoTypeURLVideo,
};


static inline NSDictionary * GetDictForPreviewPhoto(id obj, GTPreviewPhotoType type) {
    if (nil == obj) {
        @throw [NSException exceptionWithName:@"error" reason:@"预览对象不能为空" userInfo:nil];
    }
    return @{GTPreviewPhotoObj: obj, GTPreviewPhotoTyp: @(type)};
}

static inline void SetViewWidth(UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth(UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight(UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight(UIView *view) {
    return view.frame.size.height;
}

static inline NSString *  GetLocalLanguageTextValue (NSString *key) {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:GTCustomLanguageKeyValue];
    if ([dic.allKeys containsObject:key]) {
        return dic[key];
    }
    return [NSBundle gtLocalizedStringForKey:key];
}

static inline UIImage * GetImageWithName(NSString *name) {
    NSArray *names = [[NSUserDefaults standardUserDefaults] valueForKey:GTCustomImageNames];
    if ([names containsObject:name]) {
        return [UIImage imageNamed:name];
    }
    return [UIImage imageNamed:kGTPhotoBrowserSrcName(name)]?:[UIImage imageNamed:kGTPhotoBrowserFrameworkSrcName(name)];
}

static inline CGFloat GetMatchValue(NSString *text, CGFloat fontSize, BOOL isHeightFixed, CGFloat fixedValue) {
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}

static inline void ShowAlert(NSString *message, UIViewController *sender) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(GTPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [sender presentViewController:alert animated:YES completion:nil];
}

static inline CABasicAnimation * GetPositionAnimation(id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}

static inline NSInteger GetDuration (NSString *duration) {
    NSArray *arr = [duration componentsSeparatedByString:@":"];
    
    NSInteger d = 0;
    for (int i = 0; i < arr.count; i++) {
        d += [arr[i] integerValue] * pow(60, (arr.count-1-i));
    }
    return d;
}


static inline NSDictionary * GetCustomClipRatio() {
    return @{ClippingRatioValue1: @(0), ClippingRatioValue2: @(0), ClippingRatioTitleFormat: @"Custom"};
}

static inline NSDictionary * GetClipRatio(NSInteger value1, NSInteger value2) {
    return @{ClippingRatioValue1: @(value1), ClippingRatioValue2: @(value2), ClippingRatioTitleFormat: @"%g : %g"};
}



#endif /* GTPhotoDefine_h */
