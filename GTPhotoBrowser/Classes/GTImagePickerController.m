//
//  GTImagePickerController.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTImagePickerController.h"
#import "GTPhotoManager.h"
#import "GTPhotoModel.h"
#import "GTAlbumCell.h"
#import "GTProgressHUD.h"
#import "GTThumbnailViewController.h"
#import <SDWebImage/SDWebImageManager.h>


@interface GTImagePickerController ()

@end

@implementation GTImagePickerController

- (void)dealloc
{
    [[SDWebImageManager sharedManager] cancelAll];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = YES;
    }
    return self;
}

- (NSMutableArray<GTPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (void)setConfiguration:(GTPhotoConfiguration *)configuration
{
    _configuration = configuration;
    
    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
    [self.navigationBar setBackgroundImage:[self imageWithColor:configuration.navBarColor] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor:configuration.navTitleColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: configuration.navTitleColor}];
    [self.navigationBar setBackIndicatorImage:GetImageWithName(@"gt_navBack")];
    [self.navigationBar setBackIndicatorTransitionMaskImage:GetImageWithName(@"gt_navBack")];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
    //    [self setNeedsStatusBarAppearanceUpdate];
}

BOOL dismiss = NO;
- (UIStatusBarStyle)previousStatusBarStyle
{
    if (!dismiss) {
        return UIStatusBarStyleLightContent;
    } else {
        return self.previousStatusBarStyle;
    }
}

@end

@interface GTAlbumPickerController()

@property (nonatomic, strong) NSMutableArray<GTAlbumListModel *> *arrayDataSources;

@property (nonatomic, strong) UIView *placeholderView;

@property (assign, nonatomic) BOOL isFirstAppear;

@end

@implementation GTAlbumPickerController

- (void)dealloc
{
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (UIView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        imageView.image = GetImageWithName(@"gt_defaultphoto");
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.center = CGPointMake(kViewWidth/2, kViewHeight/2-90);
        [_placeholderView addSubview:imageView];
        
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kViewHeight/2-40, kViewWidth, 20)];
        placeholderLabel.text = GetLocalLanguageTextValue(GTPhotoBrowserNoPhotoText);
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        placeholderLabel.textColor = [UIColor darkGrayColor];
        placeholderLabel.font = [UIFont systemFontOfSize:15];
        [_placeholderView addSubview:placeholderLabel];
        
        _placeholderView.hidden = YES;
        [self.view addSubview:_placeholderView];
    }
    return _placeholderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstAppear = YES;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = GetLocalLanguageTextValue(GTPhotoBrowserPhotoText);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GetLocalLanguageTextValue(GTPhotoBrowserBackText) style:UIBarButtonItemStylePlain target:nil action:nil];
    [self initNavBtn];
    
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    GTProgressHUD *hud = [[GTProgressHUD alloc] init];
    if (self.isFirstAppear) {
        [hud show];
    }
    self.isFirstAppear = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
        gt_weakify(self);
        [GTPhotoManager getPhotoAblumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(NSArray<GTAlbumListModel *> *albums) {
            gt_strongify(weakSelf);
            
            GTImagePickerController *imagePickerVc = (GTImagePickerController *)self.navigationController;
            for (GTAlbumListModel *albumModel in albums) {
                albumModel.selectedModels = imagePickerVc.arrSelectedModels;
            }
            
            strongSelf.arrayDataSources = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
                [hud hide];
            });
        }];
    });
}

- (void)initNavBtn
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(GTPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)navRightBtn_Click
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayDataSources.count == 0 && !_isFirstAppear) {
        self.placeholderView.hidden = NO;
    } else {
        self.placeholderView.hidden = YES;
    }
    return self.arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GTAlbumCell"];
    
    if (!cell) {
        cell = [kGTPhotoBrowserBundle loadNibNamed:@"GTAlbumCell" owner:self options:nil].firstObject;
    }
    
    GTAlbumListModel *albumModel = self.arrayDataSources[indexPath.row];
    
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    cell.cornerRadio = configuration.cellCornerRadio;
    
    cell.model = albumModel;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    GTAlbumListModel *model = self.arrayDataSources[index];
    
    GTThumbnailViewController *tvc = [[GTThumbnailViewController alloc] init];
    tvc.albumListModel = model;

    [self.navigationController showViewController:tvc sender:self];
}

@end

