//
//  GTPhotoModel.m
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import "GTPhotoModel.h"

@implementation GTPhotoModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(GTAssetMediaType)type duration:(NSString *)duration
{
    GTPhotoModel *model = [[GTPhotoModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.duration = duration;
    model.selected = NO;
    return model;
}

@end

@implementation GTAlbumListModel

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (GTPhotoModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (GTPhotoModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

@end
