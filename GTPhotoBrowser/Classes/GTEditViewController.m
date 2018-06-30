//
//  GTEditViewController.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTEditViewController.h"
#import "GTPhotoModel.h"
#import "GTPhotoDefine.h"
#import "GTPhotoManager.h"
#import "ToastUtils.h"
#import "GTProgressHUD.h"
#import "GTImagePickerController.h"
#import "GTImageEditTool.h"

@interface GTEditViewController ()

{
    UIActivityIndicatorView *_indicator;
    
    GTImageEditTool *_editTool;
}

@end

@implementation GTEditViewController

- (void)dealloc
{
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _editTool.frame = self.view.bounds;
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self loadEditTool];
    [self loadImage];
}

- (void)loadImage
{
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.center = self.view.center;
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.hidesWhenStopped = YES;
    [self.view addSubview:_indicator];
    
    CGFloat scale = 3;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*self.model.asset.pixelHeight/self.model.asset.pixelWidth);
    
    [_indicator startAnimating];
    gt_weakify(self);
    [GTPhotoManager requestImageForAsset:self.model.asset size:size completion:^(UIImage *image, NSDictionary *info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            gt_strongify(weakSelf);
            [strongSelf->_indicator stopAnimating];
            strongSelf->_editTool.editImage = image;
        }
    }];
}

- (void)loadEditTool
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    GTImageEditType editType = GTImageEditTypeClip | GTImageEditTypeRotate | GTImageEditTypeFilter;
    _editTool = [[GTImageEditTool alloc] initWithEditType:editType image:_oriImage configuration:configuration];
    gt_weakify(self);
    _editTool.cancelEditBlock = ^{
        gt_strongify(weakSelf);
        GTImagePickerController *nav = (GTImagePickerController *)strongSelf.navigationController;
        GTPhotoConfiguration *configuration = nav.configuration;
        
        if (configuration.editAfterSelectThumbnailImage &&
            configuration.maxSelectCount == 1) {
            [nav.arrSelectedModels removeAllObjects];
        }
        UIViewController *vc = [strongSelf.navigationController popViewControllerAnimated:NO];
        if (!vc) {
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    _editTool.doneEditBlock = ^(UIImage *image) {
        gt_strongify(weakSelf);
        [strongSelf saveImage:image];
    };
    [self.view addSubview:_editTool];
}

- (void)saveImage:(UIImage *)image
{
    //确定裁剪，返回
    GTProgressHUD *hud = [[GTProgressHUD alloc] init];
    [hud show];
    
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    
    if (nav.configuration.saveNewImageAfterEdit) {
        __weak typeof(nav) weakNav = nav;
        [GTPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide];
                if (suc) {
                    __strong typeof(weakNav) strongNav = weakNav;
                    if (strongNav.callSelectClipImageBlock) {
                        strongNav.callSelectClipImageBlock(image, asset);
                    }
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserSaveImageErrorText));
                }
            });
        }];
    } else {
        [hud hide];
        if (image) {
            if (nav.callSelectClipImageBlock) {
                nav.callSelectClipImageBlock(image, self.model.asset);
            }
        } else {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserSaveImageErrorText));
        }
    }
}


@end
