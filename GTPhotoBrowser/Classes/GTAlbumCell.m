//
//  GTAlbumCell.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTAlbumCell.h"
#import "UIView+Layout.h"

@interface GTAlbumCell()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation GTAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectedCountButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setModel:(GTAlbumListModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.posterImageView.layer.masksToBounds = YES;
        self.posterImageView.layer.cornerRadius = self.cornerRadio;
    }
    
    gt_weakify(self);
    
    self.identifier = model.headImageAsset.localIdentifier;
    [GTPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(GetViewHeight(self)*2.5, GetViewHeight(self)*2.5) completion:^(UIImage *image, NSDictionary *info) {
        gt_strongify(weakSelf);
        
        if ([strongSelf.identifier isEqualToString:model.headImageAsset.localIdentifier]) {
            strongSelf.posterImageView.image = image?:GetImageWithName(@"gt_defaultphoto");
        }
    }];
    
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
    self.labTitle.text = model.title;
    self.labCount.text = [NSString stringWithFormat:@"(%ld)", (long)model.count];
}


@end
