//
//  GTViewController.m
//  GTPhotoBrowser
//
//  Created by liuxc123 on 06/29/2018.
//  Copyright (c) 2018 liuxc123. All rights reserved.
//

#import "GTViewController.h"
#import <GTPhotoBrowser/GTPhotoActionSheet.h>

@interface GTViewController ()

@end

@implementation GTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickAction:(id)sender {
    
    GTPhotoActionSheet *ac = [[GTPhotoActionSheet alloc] init];
    
    //相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxSelectCount = 10;
    ac.configuration.maxPreviewCount = 10;
//    ac.configuration.showSelectedMask = YES;
    ac.configuration.showSelectedIndex = YES;
    ac.configuration.showPhotoCannotSelectLayer = YES;

    //如调用的方法无sender参数，则该参数必传
    ac.sender = self;
    
    //选择回调
    [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
    }];
    
    //调用相册
//    [ac showPreviewAnimated:YES];

//    [ac showCamera];

    [ac showPhotoLibrary];

//    //预览网络图片
//    [ac previewPhotos:arrNetImages index:0 hideToolBar:YES complete:^(NSArray * _Nonnull photos) {
//        //your codes
//    }];
}

@end
