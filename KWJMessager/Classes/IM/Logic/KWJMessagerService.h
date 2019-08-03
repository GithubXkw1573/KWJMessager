//
//  KWJMessagerService.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/5.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JMessage/JMessage.h>

#define KWJMessager [KWJMessagerService sharedInstance]

#define kDefaultJPassword @"123456"  //默认注册的极光IM账号密码统一默认值

typedef void (^IMCompletionBlock)(id resultObject, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface KWJMessagerService : NSObject

/**
 当前IM user
 */
@property (nonatomic, strong) JMSGUser *user;

+ (instancetype)sharedInstance;

/**
 IM注册
 
 @param account 账号
 @param pwd 密码
 @param block 回调
 */
- (void)registerJMessagerUsername:(NSString *)account
                         password:(NSString *)pwd completed:(IMCompletionBlock)block ;

/**
 IM登陆
 
 @param account 账号
 @param pwd 密码
 @param block 回调
 */
- (void)loginJMessagerUsername:(NSString *)account
                      password:(NSString *)pwd completed:(IMCompletionBlock)block;

/**
 退出极光账号
 */
- (void)logout;

/**
 IM创建聊天会话
 
 @param account 对方账号
 @param flag 如果未登录，是否自登陆
 @param block 回调
 */
- (void)createConversationUsername:(NSString *)account
                       loginIfNeed:(BOOL)flag
                         completed:(IMCompletionBlock)block;

/**
 删除会话
 
 @param username 对方账号
 */
- (void)deleteConversation:(NSString *)username;

/**
 用蜗蜗账号自登陆极光IM账号
 注：如果该账号未注册极光IM账号，则该方法会自行注册IM账号
 
 @param block 登陆结果回调
 */
- (void)loginWowoliftJMessagerRegisterIfNeed:(BOOL)flag block:(IMCompletionBlock)block;

/**
 获取当前登录的IM账号下的会话列表
 
 @param block 回调
 */
- (void)queryAllConversationList:(IMCompletionBlock)block;


//设置录音路径
- (NSString *)getRecorderPath;


@end

NS_ASSUME_NONNULL_END
