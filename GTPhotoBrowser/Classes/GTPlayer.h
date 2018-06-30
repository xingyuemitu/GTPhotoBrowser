//
//  GTPlayer.h
//  GPUImage
//
//  Created by liuxc on 2018/6/30.
//

#import <Foundation/Foundation.h>

@interface GTPlayer : UIView

@property (nonatomic, strong) NSURL *videoUrl;


/**
 开始播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 重置
 */
- (void)reset;

/**
 是否正在播放
 */
- (BOOL)isPlay;


@end
