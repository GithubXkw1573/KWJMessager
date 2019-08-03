// Auther: 小屁孩.
// Created Date: 2019/3/12.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019年 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import <UIKit/UIKit.h>
#define LKDefaultRecordConten @"手指上滑，取消发送"
@interface LKRecordView : UIView
@property (nonatomic, copy) NSString *recordContent;
@property (nonatomic, assign) BOOL recordContentHidden;
//显示取消的UI
- (void)showCancel;
//显示录音的状态           1-9
- (void)configRecordingImageWithPeakPower:(CGFloat)peakPower;

@end

