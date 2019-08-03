//
//  KWJMessagerService.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/5.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWJMessagerService.h"

//#define JUserAppKey     @"1b616791aaa34b766cf54638" //商家app
#define JUserAppKey     @"3ce353a697d5c0532207ae8e" //用户app

@interface KWJMessagerService ()

@end

@implementation KWJMessagerService

//单例模式
+ (instancetype)sharedInstance {
    static KWJMessagerService *intance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        intance = [[KWJMessagerService alloc] init];
    });
    return intance;
}


/**
 IM注册

 @param account 账号
 @param pwd 密码
 @param block 回调
 */
- (void)registerJMessagerUsername:(NSString *)account
                   password:(NSString *)pwd completed:(IMCompletionBlock)block {
    [JMSGUser registerWithUsername:account password:pwd completionHandler:block];
}


/**
 IM登陆

 @param account 账号
 @param pwd 密码
 @param block 回调
 */
- (void)loginJMessagerUsername:(NSString *)account
                password:(NSString *)pwd completed:(IMCompletionBlock)block {
    [JMSGUser loginWithUsername:account password:pwd completionHandler:^(id resultObject, NSError *error) {
        if (error.code == 801003) {
            [self registerJMessagerUsername:account password:pwd completed:block];
        }else {
            block(resultObject, error);
        }
    }];
}

/**
 退出极光账号
 */
- (void)logout {
    [JMSGUser logout:^(id resultObject, NSError *error) {
        
    }];
}

/**
 IM创建聊天会话

 @param account 对方账号
 @param flag 如果未登录，是否自登陆
 @param block 回调
 */
- (void)createConversationUsername:(NSString *)account
                       loginIfNeed:(BOOL)flag
                         completed:(IMCompletionBlock)block {
    [JMSGConversation createSingleConversationWithUsername:account
                                                    appKey:JUserAppKey
                                         completionHandler:^(id resultObject, NSError *error) {
                                             if (error.code == 863004) {
                                                 //未登录
                                                 [self loginWowoliftJMessagerRegisterIfNeed:YES block:^(id resultObj, NSError *err) {
                                                     if (!err) {
                                                         [self createConversationUsername:account loginIfNeed:NO completed:block];
                                                     }else {
                                                         if (block) {
                                                             block(resultObj, err);
                                                         }
                                                     }
                                                 }];
                                             }else {
                                                 if (block) {
                                                     block(resultObject, error);
                                                 }
                                             }
                                         }];
}

/**
 删除会话
 
 @param username 对方账号
 */
- (void)deleteConversation:(NSString *)username {
    [JMSGConversation deleteSingleConversationWithUsername:username appKey:JUserAppKey];
}

/**
 用蜗蜗账号自登陆极光IM账号
 注：如果该账号未注册极光IM账号，则该方法会自行注册IM账号
 
 @param block 登陆结果回调
 */
- (void)loginWowoliftJMessagerRegisterIfNeed:(BOOL)flag block:(IMCompletionBlock)block {
    NSString *prfex = @"kJMMerchantPrefex";
    NSString *account = [NSString stringWithFormat:@"%@%@",prfex,@"123456"];
    [JMSGUser loginWithUsername:account password:kDefaultJPassword completionHandler:^(id resultObject, NSError *error) {
        if (error.code == 801003 && flag) {//未注册极光账号
            //自行注册
            [JMSGUser registerWithUsername:account password:kDefaultJPassword
                         completionHandler:^(id resultObj, NSError *err) {
                             if (!err) {
                                 //注册成功,重新登录
                                 [self loginWowoliftJMessagerRegisterIfNeed:NO block:block];
                             }else {
                                 if (block) {
                                     block(resultObj, err);
                                 }
                             }
                         }];
        }else {
            if (block) {
                block(resultObject, error);
            }
        }
    }];
}

/**
 获取当前登录的IM账号下的会话列表

 @param block 回调
 */
- (void)queryAllConversationList:(IMCompletionBlock)block {
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
        if (!error && resultObject) {
            if (block) {
                block(resultObject, error);
            }
        }else {
            if (error.code == 863004) {
                //未登录
                [KWJMessager loginWowoliftJMessagerRegisterIfNeed:NO block:^(id resultObj, NSError *err) {
                    if (!err) {
                        [self queryAllConversationList:block];
                    }else {
                        block(resultObj, err);
                    }
                }];
            }else {
                block(resultObject, error);
            }
        }
    }];
}

//设置录音路径
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yy-MMMM-dd";
    recorderPath = [[NSString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.ilbc", [dateFormatter stringFromDate:now]];
    return recorderPath;
}

@end
