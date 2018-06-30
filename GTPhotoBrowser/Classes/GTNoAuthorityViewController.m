//
//  GTNoAuthorityViewController.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTNoAuthorityViewController.h"
#import "GTPhotoDefine.h"
#import "GTImagePickerController.h"

@interface GTNoAuthorityViewController ()
{
    UIImageView *_imageView;
    UILabel *_labPrompt;
}

@end

@implementation GTNoAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = GetLocalLanguageTextValue(GTPhotoBrowserPhotoText);
    
    _imageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"gt_lock")];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = CGRectMake((kViewWidth-kViewWidth/3)/2, 100, kViewWidth/3, kViewWidth/3);
    [self.view addSubview:_imageView];
    
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width+20, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(GTPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:nav.configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(GTPhotoBrowserNoAblumAuthorityText), kAPPName];
    
    _labPrompt = [[UILabel alloc] init];
    _labPrompt.numberOfLines = 0;
    _labPrompt.font = [UIFont systemFontOfSize:14];
    _labPrompt.textColor = kRGB(170, 170, 170);
    _labPrompt.text = message;
    _labPrompt.frame = CGRectMake(50, CGRectGetMaxY(_imageView.frame), kViewWidth-100, 100);
    _labPrompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labPrompt];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)navRightBtn_Click
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
