//
//  GTThumbnailViewController.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <UIKit/UIKit.h>

@class GTAlbumListModel;

@interface GTThumbnailViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *bline;
@property (nonatomic, strong) UIButton *btnEdit;
@property (nonatomic, strong) UIButton *btnPreView;
@property (nonatomic, strong) UIButton *btnOriginalPhoto;
@property (nonatomic, strong) UILabel *labPhotosBytes;
@property (nonatomic, strong) UIButton *btnDone;

//相册model
@property (nonatomic, strong) GTAlbumListModel *albumListModel;

@end
