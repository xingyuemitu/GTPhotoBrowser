//
//  GTAlbumCell.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//  多选相册照片

#import <UIKit/UIKit.h>
#import "GTPhotoModel.h"
#import "GTPhotoManager.h"
#import "GTPhotoDefine.h"

@interface GTAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labCount;


@property (weak, nonatomic) UIButton *selectedCountButton;

@property (nonatomic, assign) CGFloat cornerRadio;

@property (nonatomic, strong) GTAlbumListModel *model;

@property (nonatomic, copy) void (^albumCellDidLayoutSubviewsBlock)(GTAlbumCell *cell, UIImageView *posterImageView, UILabel *lableTitle);

@end
