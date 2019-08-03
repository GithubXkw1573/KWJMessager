//
//  LKInputBar.h
//  InputViewPractice
//
//  Created by 小屁孩 on 2019/3/7.
//  Copyright © 2019年 小屁孩. All rights reserved.
//
//
//  如果有
//
//
//

#import <UIKit/UIKit.h>
#import "LKExpansionView.h"
#define LKInputBarBaseHeight (36 + kWidth(20) + NaviBarHeight - 64)
@class LKInputBar;
@protocol LKInputBarDelegate <NSObject>
@required
/**
 点击更多之后选中某个功能
 
 @param inputBar inputBar
 @param actionType 点击事件的类型
 */
- (void)inputBar:(LKInputBar *)inputBar didSelectAction:(LKInputBarActionType)actionType;

/**
 用户点击发送按钮的事件
 
 @param inputBar inputBar
 @param message 用户输入的内容
 */
- (void)inputBar:(LKInputBar *)inputBar didTapSendActionWithMessage:(NSString *)message;


/**
 开始录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidStartRecord:(LKInputBar *)inputBar;
/**
 结束录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidEndRecord:(LKInputBar *)inputBar;

/**
 取消录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidCancelRecord:(LKInputBar *)inputBar;

@optional
/**
 底部inputView的高度改变(只是键盘的高度，如果键盘收起来之后，height为textView多出的高度或者为0，不包含inputBar的高度)
 
 @param inputBar inputBar
 @param height 高度改变后的高度
 @param y InputBar的y坐标的值
 */
- (void)inputBar:(LKInputBar *)inputBar heightWillChange:(CGFloat)height y:(CGFloat)y;

/**
 将要开始录音
 
 @param inputBar inputBar
 @return YES 表示开始录音，NO表示不开始录音
 */
- (BOOL)inputBarShouldStartRecord:(LKInputBar *)inputBar;

@end

@interface LKInputBar : UIView
@property (nonatomic, weak) id<LKInputBarDelegate> delegate;
@property (nonatomic, assign) CGFloat recordCancelDistance;  //录音取消手势的偏移量， 默认50pt

@property (nonatomic, assign) CGFloat speakPower; //说话的音量 0 - 1

//清空出入框的内容
- (void)clearTextContent;

//是否是cancel状态
- (BOOL)isShowCancelState;

//强制取消音频录制
- (void)cancelRecordVoice;

@end


