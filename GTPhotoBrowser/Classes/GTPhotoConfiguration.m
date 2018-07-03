//
//  GTPhotoConfiguration.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTPhotoConfiguration.h"

@implementation GTPhotoConfiguration

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GTCustomImageNames];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GTLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GTCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)defaultPhotoConfiguration
{
    GTPhotoConfiguration *configuration = [GTPhotoConfiguration new];
    
    configuration.statusBarStyle = UIStatusBarStyleLightContent;
    configuration.maxSelectCount = 9;
    configuration.maxPreviewCount = 20;
    configuration.cellCornerRadio = .0;
    configuration.allowMixSelect = YES;
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.allowSelectLivePhoto = NO;
    configuration.allowTakePhotoInLibrary = YES;
    configuration.allowForceTouch = YES;
    configuration.allowEditImage = YES;
    configuration.allowEditVideo = NO;
    configuration.allowSelectOriginal = YES;
    configuration.maxEditVideoTime = 10;
    configuration.maxVideoDuration = 120;
    configuration.allowSlideSelect = YES;
    configuration.allowDragSelect = NO;
    configuration.clipRatios = @[GetCustomClipRatio(),
                                 GetClipRatio(1, 1),
                                 GetClipRatio(4, 3),
                                 GetClipRatio(3, 2),
                                 GetClipRatio(16, 9)];
    configuration.editAfterSelectThumbnailImage = NO;
    configuration.saveNewImageAfterEdit = YES;
    configuration.showCaptureImageOnTakePhotoBtn = YES;
    configuration.sortAscending = YES;
    configuration.showSelectBtn = NO;
    configuration.showSelectedIndex = NO;
    configuration.showPhotoCannotSelectLayer = NO;
    configuration.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    configuration.navBarColor = kRGB(34, 34, 34);
    configuration.navTitleColor = [UIColor whiteColor];
    configuration.bottomViewBgColor = kRGB(38, 46, 52);
    configuration.bottomBtnsNormalTitleColor = [UIColor whiteColor];
    configuration.bottomBtnsDisableBgColor = kRGB(104, 108, 113);
    configuration.sureBtnNormalTitleColor = [kRGB(83, 179, 17) colorWithAlphaComponent:1.0];
    configuration.sureBtnDisableTitleColor = [kRGB(83, 179, 17) colorWithAlphaComponent:0.5];
    configuration.sureBtnNormalBgColor = kRGB(83, 179, 17);
    configuration.showSelectedMask = NO;
    configuration.selectedMaskColor = [UIColor blackColor];
    configuration.customImageNames = nil;
    configuration.shouldAnialysisAsset = YES;
    configuration.languageType = GTLanguageSystem;
    configuration.useSystemCamera = NO;
    configuration.allowRecordVideo = YES;
    configuration.maxRecordDuration = 10;
    configuration.sessionPreset = GTCaptureSessionPreset1280x720;
    configuration.exportVideoType = GTExportVideoTypeMov;
    
    return configuration;
}

- (void)setMaxSelectCount:(NSInteger)maxSelectCount
{
    _maxSelectCount = MAX(maxSelectCount, 1);
}

- (BOOL)showSelectBtn
{
    return _maxSelectCount > 1 ? YES : _showSelectBtn;
}

- (void)setAllowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    if (@available(iOS 9.0, *)) {
        _allowSelectLivePhoto = allowSelectLivePhoto;
    } else {
        _allowSelectLivePhoto = NO;
    }
}

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime
{
    _maxEditVideoTime = MAX(maxEditVideoTime, 10);
}

- (void)setCustomImageNames:(NSArray<NSString *> *)customImageNames
{
    [[NSUserDefaults standardUserDefaults] setValue:customImageNames forKey:GTCustomImageNames];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLanguageType:(GTLanguageType)languageType
{
    [[NSUserDefaults standardUserDefaults] setValue:@(languageType) forKey:GTLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle resetLanguage];
}

- (void)setCustomLanguageKeyValue:(NSDictionary<NSString *,NSString *> *)customLanguageKeyValue
{
    [[NSUserDefaults standardUserDefaults] setValue:customLanguageKeyValue forKey:GTCustomLanguageKeyValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setMaxRecordDuration:(NSInteger)maxRecordDuration
{
    _maxRecordDuration = MAX(maxRecordDuration, 1);
}


@end
