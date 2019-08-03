// Auther: kaiwei Xu.
// Created Date: 2019/3/18.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo. All rights reserved.
// Descriptioin: 文件描述.


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MesageModel : NSObject
@property (nonatomic, copy) NSString *readFlag;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *protocol;
@property (nonatomic, copy) NSString *notificationTitle;

@property (nonatomic, assign) NSInteger noReadCount;//未读个数
@property (nonatomic, copy) NSString *messageType;
@property (nonatomic, copy) NSString *pushTime;//推送时间
@end

NS_ASSUME_NONNULL_END
