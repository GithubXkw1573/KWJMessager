//
//  KWChatVoiceCell.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface KWChatVoiceCell : KWChatBaseCell

/**
 开始播放音频的动画
 */
- (void)startPlayingAnimate;

/**
 停止播放音频的动画
 */
- (void)stopPlayingAnimate;

@end

NS_ASSUME_NONNULL_END
