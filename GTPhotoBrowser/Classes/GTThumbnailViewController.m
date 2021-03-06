//
//  GTThumbnailViewController.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTThumbnailViewController.h"
#import <Photos/Photos.h>
#import "GTPhotoDefine.h"
#import "GTCollectionCell.h"
#import "GTPhotoManager.h"
#import "GTPhotoModel.h"
#import "GTPhotoPreviewController.h"
#import "GTImagePickerController.h"
#import "ToastUtils.h"
#import "GTProgressHUD.h"
#import "GTForceTouchPreviewController.h"
#import "GTEditViewController.h"
#import "GTEditVideoController.h"
#import "GTCustomCameraController.h"
#import "UIImage+GTPhotoBrowser.h"
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_ENUM(NSUInteger, SlideSelectType) {
    SlideSelectTypeNone,
    SlideSelectTypeSelect,
    SlideSelectTypeCancel,
};

@interface GTThumbnailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate>
{
    BOOL _isLayoutOK;
    
    //设备旋转前的第一个可视indexPath
    NSIndexPath *_visibleIndexPath;
    //是否切换横竖屏
    BOOL _switchOrientation;
    
    //开始滑动选择 或 取消
    BOOL _beginSelect;
    /**
     滑动选择 或 取消
     当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
     */
    SlideSelectType _selectType;
    /**开始滑动的indexPath*/
    NSIndexPath *_beginSlideIndexPath;
    /**最后滑动经过的index，开始的indexPath不计入，优化拖动手势计算，避免单个cell中冗余计算多次*/
    NSInteger _lastSlideIndex;
}

@property (nonatomic, strong) NSMutableArray<GTPhotoModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;
/**所有滑动经过的indexPath*/
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *arrSlideIndexPath;
/**所有滑动经过的indexPath的初始选择状态*/
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicOriSelectStatus;
@end

@implementation GTThumbnailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<GTPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        GTProgressHUD *hud = [[GTProgressHUD alloc] init];
        [hud show];
        
        GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
        GTPhotoConfiguration *configuration = nav.configuration;
        
        if (!_albumListModel) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                gt_weakify(self);
                [GTPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(GTAlbumListModel *album) {
                    gt_strongify(weakSelf);
                    GTImagePickerController *weakNav = (GTImagePickerController *)strongSelf.navigationController;
                    
                    strongSelf.albumListModel = album;
                    [GTPhotoManager markSelectModelInArr:strongSelf.albumListModel.models selArr:weakNav.arrSelectedModels];
                    strongSelf.arrDataSources = [NSMutableArray arrayWithArray:strongSelf.albumListModel.models];
                    [hud hide];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (configuration.allowTakePhotoInLibrary && (configuration.allowSelectImage || configuration.allowRecordVideo)) {
                            strongSelf.allowTakePhoto = YES;
                        }
                        strongSelf.title = album.title;
                        [strongSelf.collectionView reloadData];
                        [strongSelf scrollToBottom];
                    });
                }];
            });
        } else {
            if (configuration.allowTakePhotoInLibrary && (configuration.allowSelectImage || configuration.allowRecordVideo) && self.albumListModel.isCameraRoll) {
                self.allowTakePhoto = YES;
            }
            [GTPhotoManager markSelectModelInArr:self.albumListModel.models selArr:nav.arrSelectedModels];
            _arrDataSources = [NSMutableArray arrayWithArray:self.albumListModel.models];
            [hud hide];
        }
    }
    return _arrDataSources;
}

- (NSMutableArray<NSIndexPath *> *)arrSlideIndexPath
{
    if (!_arrSlideIndexPath) {
        _arrSlideIndexPath = [NSMutableArray array];
    }
    return _arrSlideIndexPath;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dicOriSelectStatus
{
    if (!_dicOriSelectStatus) {
        _dicOriSelectStatus = [NSMutableDictionary dictionary];
    }
    return _dicOriSelectStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = true;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.albumListModel.title;
    
    [self initNavBtn];
    [self setupCollectionView];
    [self setupBottomView];
    
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    if (configuration.allowSlideSelect) {
        //添加滑动选择手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.view addGestureRecognizer:pan];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self resetBottomBtnsStatus:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    
    BOOL showBottomView = YES;
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        showBottomView = NO;
        inset.bottom = 0;
    }
    
    CGFloat bottomViewH = showBottomView ? 44 : 0;
    CGFloat bottomBtnH = 30;
    
    CGFloat width = kViewWidth-inset.left-inset.right;
    self.collectionView.frame = CGRectMake(inset.left, 0, width, kViewHeight-inset.bottom-bottomViewH);
    
    if (!showBottomView) return;
    
    self.bottomView.frame = CGRectMake(inset.left, kViewHeight-bottomViewH-inset.bottom, width, bottomViewH+inset.bottom);
    self.bline.frame = CGRectMake(0, 0, width, 1/[UIScreen mainScreen].scale);
    
    CGFloat offsetX = 12;
    if (configuration.allowEditImage || configuration.allowEditVideo) {
        self.btnEdit.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserEditText), 15, YES, bottomBtnH), bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnEdit.frame) + 10;
    }
    self.btnPreView.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserPreviewText), 15, YES, bottomBtnH), bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnPreView.frame) + 10;
    
    if (configuration.allowSelectOriginal) {
        self.btnOriginalPhoto.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserOriginalText), 15, YES, bottomBtnH)+25, bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnOriginalPhoto.frame) + 5;
        
        self.labPhotosBytes.frame = CGRectMake(offsetX, 7, 80, bottomBtnH);
    }
    
    CGFloat doneWidth = GetMatchValue(self.btnDone.currentTitle, 15, YES, bottomBtnH);
    doneWidth = MAX(70, doneWidth);
    self.btnDone.frame = CGRectMake(width-doneWidth-12, 7, doneWidth, bottomBtnH);
    
    if (!_isLayoutOK && self.albumListModel) {
        [self scrollToBottom];
    } else if (_switchOrientation) {
        _switchOrientation = NO;
        [self.collectionView scrollToItemAtIndexPath:_visibleIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    CGPoint pInView = [self.view convertPoint:CGPointMake(0, 70) toView:self.collectionView];
    _visibleIndexPath = [self.collectionView indexPathForItemAtPoint:pInView];
    _switchOrientation = YES;
}

- (BOOL)forceTouchAvailable
{
    if (@available(iOS 9.0, *)) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    } else {
        return NO;
    }
}

- (void)scrollToBottom
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    if (!configuration.sortAscending) {
        return;
    }
    if (self.arrDataSources.count > 0) {
        NSInteger index = self.arrDataSources.count-1;
        if (self.allowTakePhoto) {
            index += 1;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)resetBottomBtnsStatus:(BOOL)getBytes
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        if (nav.isSelectOriginalPhoto) {
            if (getBytes) [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(GTPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = [configuration.sureBtnNormalBgColor colorWithAlphaComponent:1.0];
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:GetLocalLanguageTextValue(GTPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnDone setTitleColor:configuration.sureBtnDisableTitleColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = [configuration.sureBtnNormalBgColor colorWithAlphaComponent:0.5];

        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
    }
    
    BOOL canEdit = NO;
    if (nav.arrSelectedModels.count == 1) {
        GTPhotoModel *m = nav.arrSelectedModels.firstObject;
        canEdit = (configuration.allowEditImage && ((m.type == GTAssetMediaTypeImage) ||
                                                    (m.type == GTAssetMediaTypeGif && !configuration.allowSelectGif) ||
                                                    (m.type == GTAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto))) ||
        (configuration.allowEditVideo && m.type == GTAssetMediaTypeVideo && round(m.asset.duration) >= configuration.maxEditVideoTime);
    }
    [self.btnEdit setTitleColor:canEdit?configuration.bottomBtnsNormalTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateNormal];
    self.btnEdit.userInteractionEnabled = canEdit;
}

#pragma mark - ui
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = MIN(kViewWidth, kViewHeight);
    
    NSInteger columnCount;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        columnCount = 6;
    } else {
        columnCount = 4;
    }
    
    layout.itemSize = CGSizeMake((width-1.5*columnCount)/columnCount, (width-1.5*columnCount)/columnCount);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:NSClassFromString(@"GTTakePhotoCell") forCellWithReuseIdentifier:@"GTTakePhotoCell"];
    [self.collectionView registerClass:NSClassFromString(@"GTCollectionCell") forCellWithReuseIdentifier:@"GTCollectionCell"];
    //注册3d touch
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    if (configuration.allowForceTouch && [self forceTouchAvailable]) {
        if (@available(iOS 9.0, *)) {
            [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        }
    }
}

- (void)setupBottomView
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        return;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = configuration.bottomViewBgColor;
    [self.view addSubview:self.bottomView];
    
    self.bline = [[UIView alloc] init];
    self.bline.backgroundColor = kRGB(232, 232, 232);
    [self.bottomView addSubview:self.bline];
    
    if (configuration.allowEditImage || configuration.allowEditVideo) {
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnEdit setTitle:GetLocalLanguageTextValue(GTPhotoBrowserEditText) forState:UIControlStateNormal];
        [self.btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnEdit];
    }
    
    self.btnPreView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPreView.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnPreView setTitle:GetLocalLanguageTextValue(GTPhotoBrowserPreviewText) forState:UIControlStateNormal];
    [self.btnPreView addTarget:self action:@selector(btnPreview_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnPreView];
    
    if (configuration.allowSelectOriginal) {
        self.btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOriginalPhoto.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        self.btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"gt_btn_original_circle") forState:UIControlStateNormal];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"gt_btn_original_sel_circle") forState:UIControlStateSelected];
        [self.btnOriginalPhoto setTitle:GetLocalLanguageTextValue(GTPhotoBrowserOriginalText) forState:UIControlStateNormal];
        [self.btnOriginalPhoto addTarget:self action:@selector(btnOriginalPhoto_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = configuration.bottomBtnsNormalTitleColor;
        [self.bottomView addSubview:self.labPhotosBytes];
    }
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnDone setTitle:GetLocalLanguageTextValue(GTPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
}

- (void)initNavBtn
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    nav.viewControllers.firstObject.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GetLocalLanguageTextValue(GTPhotoBrowserBackText) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(GTPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(GTPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - UIButton Action
- (void)btnEdit_Click:(id)sender {
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoModel *m = nav.arrSelectedModels.firstObject;
    
    if (m.type == GTAssetMediaTypeVideo) {
        GTEditVideoController *vc = [[GTEditVideoController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (m.type == GTAssetMediaTypeImage ||
               m.type == GTAssetMediaTypeGif ||
               m.type == GTAssetMediaTypeLivePhoto) {
        GTEditViewController *vc = [[GTEditViewController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)btnPreview_Click:(id)sender
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    UIViewController *vc = [self getBigImageVCWithData:nav.arrSelectedModels index:nav.arrSelectedModels.count-1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<GTPhotoModel *> *)data index:(NSInteger)index
{
    GTPhotoPreviewController *vc = [[GTPhotoPreviewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    gt_weakify(self);
    [vc setBtnBackBlock:^(NSArray<GTPhotoModel *> *selectedModels, BOOL isOriginal) {
        gt_strongify(weakSelf);
        [GTPhotoManager markSelectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    return vc;
}

- (void)btnOriginalPhoto_Click:(id)sender
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    nav.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(id)sender
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    if (nav.callSelectImageBlock) {
        nav.callSelectImageBlock();
    }
}

- (void)navLeftBtn_Click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - pan action
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    
    BOOL asc = !self.allowTakePhoto || configuration.sortAscending;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginSelect = !indexPath ? NO : ![cell isKindOfClass:GTTakePhotoCell.class];
        
        if (_beginSelect) {
            NSInteger index = asc ? indexPath.row : indexPath.row-1;
            
            GTPhotoModel *m = self.arrDataSources[index];
            _selectType = m.isSelected ? SlideSelectTypeCancel : SlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected && [self canAddModel:m]) {
                if (configuration.editAfterSelectThumbnailImage &&
                    configuration.maxSelectCount == 1 &&
                    (configuration.allowEditImage || configuration.allowEditVideo)) {
                    [self shouldDirectEdit:m];
                    _selectType = SlideSelectTypeNone;
                    return;
                } else {
                    m.selected = YES;
                    [nav.arrSelectedModels addObject:m];
                }
            } else if (m.isSelected) {
                m.selected = NO;
                for (GTPhotoModel *sm in nav.arrSelectedModels) {
                    if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                        [nav.arrSelectedModels removeObject:sm];
                        break;
                    }
                }
            }
            GTCollectionCell *c = (GTCollectionCell *)cell;
            c.btnSelect.selected = m.isSelected;
            c.selectImageView.image = c.btnSelect.selected ? c.photoSelImage :  c.photoDefImage;
            c.topView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            if (configuration.showSelectedIndex) {
                c.index = [self getIndexWithSelectArrayWithModel:c.model];
            }
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_beginSelect ||
            !indexPath ||
            indexPath.row == _lastSlideIndex ||
            [cell isKindOfClass:GTTakePhotoCell.class] ||
            _selectType == SlideSelectTypeNone) return;
        
        _lastSlideIndex = indexPath.row;
        
        NSInteger minIndex = MIN(indexPath.row, _beginSlideIndexPath.row);
        NSInteger maxIndex = MAX(indexPath.row, _beginSlideIndexPath.row);
        
        BOOL minIsBegin = minIndex == _beginSlideIndexPath.row;
        
        for (NSInteger i = _beginSlideIndexPath.row;
             minIsBegin ? i<=maxIndex: i>= minIndex;
             minIsBegin ? i++ : i--) {
            if (i == _beginSlideIndexPath.row) continue;
            NSIndexPath *p = [NSIndexPath indexPathForRow:i inSection:0];
            if (![self.arrSlideIndexPath containsObject:p]) {
                [self.arrSlideIndexPath addObject:p];
                NSInteger index = asc ? i : i-1;
                GTPhotoModel *m = self.arrDataSources[index];
                [self.dicOriSelectStatus setValue:@(m.isSelected) forKey:@(p.row).stringValue];
            }
        }
        
        for (NSIndexPath *path in self.arrSlideIndexPath) {
            NSInteger index = asc ? path.row : path.row-1;
            
            //是否在最初和现在的间隔区间内
            BOOL inSection = path.row >= minIndex && path.row <= maxIndex;
            
            GTPhotoModel *m = self.arrDataSources[index];
            switch (_selectType) {
                case SlideSelectTypeSelect: {
                    if (inSection &&
                        !m.isSelected &&
                        [self canAddModel:m]) m.selected = YES;
                }
                    break;
                case SlideSelectTypeCancel: {
                    if (inSection) m.selected = NO;
                }
                    break;
                default:
                    break;
            }
            
            if (!inSection) {
                //未在区间内的model还原为初始选择状态
                m.selected = [self.dicOriSelectStatus[@(path.row).stringValue] boolValue];
            }
            
            //判断当前model是否已存在于已选择数组中
            BOOL flag = NO;
            NSMutableArray *arrDel = [NSMutableArray array];
            for (GTPhotoModel *sm in nav.arrSelectedModels) {
                if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                    if (!m.isSelected) {
                        [arrDel addObject:sm];
                    }
                    flag = YES;
                    break;
                }
            }
            
            [nav.arrSelectedModels removeObjectsInArray:arrDel];
            
            if (!flag && m.isSelected) {
                [nav.arrSelectedModels addObject:m];
            }
            
            GTCollectionCell *c = (GTCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
            c.btnSelect.selected = m.isSelected;
            c.selectImageView.image = c.btnSelect.selected ? c.photoSelImage :  c.photoDefImage;
            c.topView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            if (configuration.showSelectedIndex) {
                c.index = [self getIndexWithSelectArrayWithModel:c.model];
            }
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        //清空临时属性及数组
        _selectType = SlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
        [self resetBottomBtnsStatus:YES];
    }

    if (configuration.showPhotoCannotSelectLayer || configuration.showSelectedIndex) {
        [self setUseCachedImageAndReloadData];
    }
}

- (BOOL)canAddModel:(GTPhotoModel *)model
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration =nav.configuration;
    
    if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
        ShowToastLong(GetLocalLanguageTextValue(GTPhotoBrowserMaxSelectCountText), configuration.maxSelectCount);
        return NO;
    }
    if (nav.arrSelectedModels.count > 0) {
        GTPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!configuration.allowMixSelect &&
            ((model.type < GTAssetMediaTypeVideo && sm.type == GTAssetMediaTypeVideo) || (model.type == GTAssetMediaTypeVideo && sm.type < GTAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserCannotSelectVideo));
            return NO;
        }
    }
    if (![GTPhotoManager judgeAssetisInLocalAblum:model.asset]) {
        ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowseriCloudPhotoText));
        return NO;
    }
    if (model.type == GTAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
        ShowToastLong(GetLocalLanguageTextValue(GTPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
        return NO;
    }
    return YES;
}

- (NSInteger)getIndexWithSelectArrayWithModel:(GTPhotoModel *)model
{
    GTImagePickerController *imagePicker = (GTImagePickerController *)self.navigationController;
    NSInteger index = 0;
    for (NSInteger i = 0; i < imagePicker.arrSelectedModels.count; i++) {
        if ([model.asset.localIdentifier isEqualToString:imagePicker.arrSelectedModels[i].asset.localIdentifier]) {
            index = i + 1;
            break;
        }
    }
    return index;
}

- (void)setUseCachedImageAndReloadData {
    self.useCachedImage = YES;
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.useCachedImage = NO;
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.allowTakePhoto) {
        return self.arrDataSources.count + 1;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GTImagePickerController *imagePicker = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = [imagePicker configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        GTTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GTTakePhotoCell" forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = configuration.cellCornerRadio;
        if (configuration.showCaptureImageOnTakePhotoBtn) {
            [cell startCapture];
        }
        return cell;
    }
    
    GTCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GTCollectionCell" forIndexPath:indexPath];

    cell.photoSelImage = configuration.showSelectedIndex ? [UIImage createImageWithColor:nil size:CGSizeMake(24, 24) radius:12] : GetImageWithName(@"gt_btn_selected");
    cell.photoDefImage = GetImageWithName(@"gt_btn_unselected");
    cell.useCachedImage = self.useCachedImage;

    GTPhotoModel *model;
    if (!self.allowTakePhoto || configuration.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }

    if (configuration.showSelectedIndex) {
        cell.index = [self getIndexWithSelectArrayWithModel:model];
    }

    cell.allSelectGif = configuration.allowSelectGif;
    cell.allSelectLivePhoto = configuration.allowSelectLivePhoto;
    cell.showSelectBtn = configuration.showSelectBtn;
    cell.cornerRadio = configuration.cellCornerRadio;
    cell.showMask = configuration.showSelectedMask;
    cell.maskColor = configuration.selectedMaskColor;
    cell.showSelectedIndex = configuration.showSelectedIndex;
    cell.showPhotoCannotSelectLayer = configuration.showPhotoCannotSelectLayer;
    cell.cannotSelectLayerColor = configuration.cannotSelectLayerColor;
    cell.model = model;

    if (imagePicker.arrSelectedModels.count >= configuration.maxSelectCount && configuration.showPhotoCannotSelectLayer && !model.isSelected) {
        cell.cannotSelectLayerButton.backgroundColor = configuration.cannotSelectLayerColor;
        cell.cannotSelectLayerButton.hidden = NO;
    } else {
        cell.cannotSelectLayerButton.hidden = YES;
    }

    gt_weakify(self);
    __weak typeof(cell) weakCell = cell;
    cell.selectedBlock = ^(BOOL selected) {
        gt_strongify(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;

        GTImagePickerController *weakNav = (GTImagePickerController *)strongSelf.navigationController;
        if (!selected) {
            //选中
            if ([strongSelf canAddModel:model]) {
                if (![strongSelf shouldDirectEdit:model]) {
                    model.selected = YES;
                    [weakNav.arrSelectedModels addObject:model];
                    strongCell.btnSelect.selected = YES;
                    strongCell.selectImageView.image = strongCell.photoSelImage;
                    [strongSelf shouldDirectEdit:model];
                }
            }
        } else {
            strongCell.btnSelect.selected = NO;
            strongCell.selectImageView.image = strongCell.photoDefImage;
            model.selected = NO;
            for (GTPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [weakNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        if (configuration.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        if (configuration.showSelectedIndex) {
            strongCell.index = [self getIndexWithSelectArrayWithModel:model];
        }
        if (configuration.showPhotoCannotSelectLayer || configuration.showSelectedIndex) {
            model.needOscillatoryAnimation = YES;
            [strongSelf setUseCachedImageAndReloadData];
        }
        [strongSelf resetBottomBtnsStatus:YES];
    };
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        //拍照
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
        index = indexPath.row - 1;
    }
    GTPhotoModel *model = self.arrDataSources[index];
    
    if ([self shouldDirectEdit:model]) return;
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:nil];
    }
}

- (BOOL)shouldDirectEdit:(GTPhotoModel *)model
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    //当前点击图片可编辑
    BOOL editImage = configuration.editAfterSelectThumbnailImage && configuration.allowEditImage && configuration.maxSelectCount == 1 && (model.type == GTAssetMediaTypeImage || model.type == GTAssetMediaTypeGif || model.type == GTAssetMediaTypeLivePhoto);
    //当前点击视频可编辑
    BOOL editVideo = configuration.editAfterSelectThumbnailImage && configuration.allowEditVideo && model.type == GTAssetMediaTypeVideo && configuration.maxSelectCount == 1 && round(model.asset.duration) >= configuration.maxEditVideoTime;
    //当前未选择图片 或 已经选择了一张并且点击的是已选择的图片
    BOOL flag = nav.arrSelectedModels.count == 0 || (nav.arrSelectedModels.count == 1 && [nav.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    } else if (editVideo && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    }
    
    return configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo);
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(GTPhotoModel *)model
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        GTPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!configuration.allowMixSelect &&
            ((model.type < GTAssetMediaTypeVideo && sm.type == GTAssetMediaTypeVideo) || (model.type == GTAssetMediaTypeVideo && sm.type < GTAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserCannotSelectVideo));
            return nil;
        }
    }
    
    BOOL allowSelImage = !(model.type==GTAssetMediaTypeVideo)?YES:configuration.allowMixSelect;
    BOOL allowSelVideo = model.type==GTAssetMediaTypeVideo?YES:configuration.allowMixSelect;
    
    NSArray *arr = [GTPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:configuration.allowSelectGif allowSelectLivePhoto:configuration.allowSelectLivePhoto];
    
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (GTPhotoModel *m in nav.arrSelectedModels) {
        [selIdentifiers addObject:m.asset.localIdentifier];
    }
    
    int i = 0;
    BOOL isFind = NO;
    for (GTPhotoModel *m in arr) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            isFind = YES;
        }
        if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
            m.selected = YES;
        }
        if (!isFind) {
            i++;
        }
    }
    
    return [self getBigImageVCWithData:arr index:i];
}

- (void)takePhoto
{
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    if (![GTPhotoManager haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(GTPhotoBrowserNoCameraAuthorityText), kAPPName];
        ShowAlert(message, self);
        return;
    }
    if (!configuration.allowSelectImage &&
        !configuration.allowRecordVideo) {
        ShowAlert(@"allowSelectImage与allowRecordVideo不能同时为NO", self);
        return;
    }
    if (configuration.useSystemCamera) {
        //系统相机拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            NSArray *a1 = configuration.allowSelectImage?@[(NSString *)kUTTypeImage]:@[];
            NSArray *a2 = (configuration.allowSelectVideo && configuration.allowRecordVideo)?@[(NSString *)kUTTypeMovie]:@[];
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObjectsFromArray:a1];
            [arr addObjectsFromArray:a2];
            
            picker.mediaTypes = arr;
            picker.videoMaximumDuration = configuration.maxRecordDuration;
            [self showDetailViewController:picker sender:nil];
        }
    } else {
        if (![GTPhotoManager haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(GTPhotoBrowserNoMicrophoneAuthorityText), kAPPName];
            ShowAlert(message, self);
            return;
        }
        GTCustomCameraController *camera = [[GTCustomCameraController alloc] init];
        camera.allowTakePhoto = configuration.allowSelectImage;
        camera.allowRecordVideo = configuration.allowSelectVideo && configuration.allowRecordVideo;
        camera.sessionPreset = configuration.sessionPreset;
        camera.videoType = configuration.exportVideoType;
        camera.circleProgressColor = configuration.bottomBtnsNormalTitleColor;
        camera.maxRecordDuration = configuration.maxRecordDuration;
        gt_weakify(self);
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            gt_strongify(weakSelf);
            [strongSelf saveImage:image videoUrl:videoUrl];
        };
        [self showDetailViewController:camera sender:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL *url = [info valueForKey:UIImagePickerControllerMediaURL];
        [self saveImage:image videoUrl:url];
    }];
}

- (void)saveImage:(UIImage *)image videoUrl:(NSURL *)videoUrl
{
    GTProgressHUD *hud = [[GTProgressHUD alloc] init];
    [hud show];
    gt_weakify(self);
    if (image) {
        [GTPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            gt_strongify(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    GTPhotoModel *model = [GTPhotoModel modelWithAsset:asset type:GTAssetMediaTypeImage duration:nil];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserSaveImageErrorText));
                }
                [hud hide];
            });
        }];
    } else if (videoUrl) {
        [GTPhotoManager saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
            gt_strongify(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    GTPhotoModel *model = [GTPhotoModel modelWithAsset:asset type:GTAssetMediaTypeVideo duration:nil];
                    model.duration = [GTPhotoManager getDuration:asset];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(GTPhotoBrowserSaveVideoFailed));
                }
                [hud hide];
            });
        }];
    }
}

- (void)handleDataArray:(GTPhotoModel *)model
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    GTPhotoConfiguration *configuration = nav.configuration;
    
    BOOL (^shouldSelect)(void) = ^BOOL() {
        if (model.type == GTAssetMediaTypeVideo) {
            return (model.asset.duration <= configuration.maxVideoDuration);
        }
        return YES;
    };
    
    if (configuration.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    
    BOOL sel = shouldSelect();
    if (configuration.maxSelectCount > 1 && nav.arrSelectedModels.count < configuration.maxSelectCount && sel) {
        model.selected = sel;
        [nav.arrSelectedModels addObject:model];
    } else if (configuration.maxSelectCount == 1 && !nav.arrSelectedModels.count && sel) {
        if (![self shouldDirectEdit:model]) {
            model.selected = sel;
            [nav.arrSelectedModels addObject:model];
            [self btnDone_Click:nil];
            return;
        }
    }
    
    self.albumListModel = [GTPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage];
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getOriginalImageBytes
{
    GTImagePickerController *nav = (GTImagePickerController *)self.navigationController;
    gt_weakify(self);
    [GTPhotoManager getPhotosBytesWithArray:nav.arrSelectedModels completion:^(NSString *photosBytes) {
        gt_strongify(weakSelf);
        strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[GTTakePhotoCell class]]) {
        return nil;
    }
    
    //设置突出区域
    previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    
    GTForceTouchPreviewController *vc = [[GTForceTouchPreviewController alloc] init];
    
    GTPhotoConfiguration *configuration = [(GTImagePickerController *)self.navigationController configuration];
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
        index = indexPath.row - 1;
    }
    GTPhotoModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = configuration.allowSelectGif;
    vc.allowSelectLivePhoto = configuration.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    GTPhotoModel *model = [(GTForceTouchPreviewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:self];
    }
}

- (CGSize)getSize:(GTPhotoModel *)model
{
    CGFloat w = MIN(model.asset.pixelWidth, kViewWidth);
    CGFloat h = w * model.asset.pixelHeight / model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kViewHeight || isnan(h)) {
        h = kViewHeight;
        w = h * model.asset.pixelWidth / model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}




@end
