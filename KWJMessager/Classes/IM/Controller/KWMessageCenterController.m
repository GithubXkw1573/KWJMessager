// Auther: kaiwei Xu.
// Created Date: 2019/3/11.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 消息中心页面. 订单、服务通知 + 极光IM消息


#import "KWMessageCenterController.h"
#import "KWMessageListCell.h"
#import <JMessage/JMessage.h>
#import "KWJMessagerService.h"
#import "KWChatRoomController.h"
#import "MesageModel.h"
#import "PrefixHeader.pch"
#import <KWHttpManager/YWHttpClient.h>

@interface KWMessageCenterController ()
 <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *wowoMessageList;//订单服务类消息
@property (nonatomic, strong) NSMutableArray *chatMessageList;//IM聊天消息
@property (nonatomic, strong) MesageModel *serviceMsg;//服务类消息
@property (nonatomic, strong) MesageModel *orderMsg;//订单类消息
@property (nonatomic, assign) BOOL isHaveLoad;
@end

@implementation KWMessageCenterController

#pragma mark ====== LifeCyle ======

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.naviBar setTitleText:@"消息中心"];
    self.view.backgroundColor = kBackGroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessagesNoti:) name:@"receviceMessages" object:nil];
    
    [self.view addSubview:self.tableView];
    
    [self requestDataMask:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isHaveLoad) {
        [self requestDataMask:NO];
    }
    self.isHaveLoad = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.resultData) {
        self.resultData(nil);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ====== 初始化方法 ======

- (void)requestDataMask:(BOOL)mask {
    if (mask) {
//        [self showHUD];
    }
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.wowolife.messeages",
                                                   DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [KWJMessager queryAllConversationList:^(id resultObject, NSError *error) {
            if (!error && [resultObject isKindOfClass:[NSArray class]]) {
                NSMutableArray *temp = [NSMutableArray arrayWithArray:resultObject];
                //过滤一下，没发过消息的空会话
                self.chatMessageList = [[NSMutableArray alloc] init];
                for (JMSGConversation *conv in temp) {
                    if (conv.latestMessage) {
                        [self.chatMessageList addObject:conv];
                    }
                }
            }
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
//        NSString *url = base_URL(@"/merchant-app/businessJpushRecord/recordClassifyCount");
        NSString *url = @"/merchant-app/businessJpushRecord/recordClassifyCount";
        [YWHttpEngine requestUrl:url parmaters:@{} finishBlock:^(YWResponse *resp) {
            if (resp.success) {
                if ([resp.responseData objectForKey:@"serviceMsg"]) {
                    self.serviceMsg = [MesageModel mj_objectWithKeyValues:[resp.responseData objectForKey:@"serviceMsg"]];
                    self.serviceMsg.messageType = @"服务消息";
                }
                if ([resp.responseData objectForKey:@"orderMsg"]) {
                    self.orderMsg = [MesageModel mj_objectWithKeyValues:[resp.responseData objectForKey:@"orderMsg"]];
                    self.orderMsg.messageType = @"订单消息";
                }
                [self.wowoMessageList removeAllObjects];
                [self.wowoMessageList safeAddObject:self.serviceMsg];
                [self.wowoMessageList safeAddObject:self.orderMsg];
            }
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self HidenHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        });
    });
}



#pragma mark ====== 通知方法 ======
- (void)refreshMessagesNoti:(NSNotification *)noti {
    //重新刷新消息
    [self requestDataMask:NO];
}


#pragma mark ====== 私有方法 ======



#pragma mark ====== Action方法 ======



#pragma mark ====== getter and setter =====
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviBarHeight)];
        _tableView.backgroundColor = kBackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[KWMessageListCell class] forCellReuseIdentifier:@"chat"];
    }
    return _tableView;
}

- (NSMutableArray *)wowoMessageList {
    if (!_wowoMessageList) {
        _wowoMessageList = [[NSMutableArray alloc] init];
    }
    return _wowoMessageList;
}

#pragma mark ==== UITableViewDelegate,UITableViewDataSource ====

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 2;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (section == 0) {
         return self.wowoMessageList.count;
     }
     return self.chatMessageList.count;
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     KWMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat"];
     if (indexPath.section == 1) {
         JMSGConversation *conv = [self.chatMessageList safeObjectAtIndex:indexPath.row];
         [cell bindModel:conv];
     }else {
         MesageModel *msg = [self.wowoMessageList safeObjectAtIndex:indexPath.row];
         [cell bindModel:msg];
     }
     return cell;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 75;
 }

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 6)];
    hview.backgroundColor = kBackGroundColor;
    return hview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [WormAlert popConfirmTitle:nil message:@"确认删除聊天窗口？" actionAtIndex:^(NSInteger index) {
        if (index == 1) {
            JMSGConversation *conv = [self.chatMessageList safeObjectAtIndex:indexPath.row];
            JMSGUser *user = conv.target;
            [KWJMessager deleteConversation:user.username];
            [self.chatMessageList removeObject:conv];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationBottom];
        }
    }];
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        //进入某个聊天会话
        KWChatRoomController *chat = [[KWChatRoomController alloc] init];
        JMSGConversation *conv = [self.chatMessageList safeObjectAtIndex:indexPath.row];
        JMSGUser *user = conv.target;
        chat.userName = user.username;
        chat.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chat animated:YES];
        //未读数清0
        [conv clearUnreadCount];
        [self.tableView reloadData];
    }else {
        MesageModel *msg = [self.wowoMessageList safeObjectAtIndex:indexPath.row];
        NSInteger msgType = 0;
        if ([msg.messageType isEqualToString:@"订单消息"]) {
            msgType = 1;
        }
//        [YWUtils goToViewControllerWithClassName:@"WormMessageViewController"
//                                          params:@{@"msgType":@(msgType)} animated:YES block:nil];
    }
}

#pragma mark ====== 其他 Delegate ======



@end
