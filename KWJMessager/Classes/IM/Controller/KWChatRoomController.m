//
//  KWChatRoomController.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/5.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//  聊天室

#import "KWChatRoomController.h"
#import "KWChatTextCell.h"
#import "KWChatImageCell.h"
#import "KWChatVoiceCell.h"
#import "KWChatLocationCell.h"
#import "KWChatGoodsLinkCell.h"
#import "KWJMessagerService.h"
#import "LKInputBar.h"
#import "YWLocationManager.h"
#import "XHVoiceRecordHelper.h"
#import "XHMacro.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "shopMapViewController.h"
#import "WormImgPreviewController.h"
#import "KWLoactionMapSelector.h"
#import <AVFoundation/AVFoundation.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "PrefixHeader.pch"
#define kFetchMsgLimit 20  //每次拉取最新多少条数据

@interface KWChatRoomController ()
 <UITableViewDelegate,UITableViewDataSource, JMessageDelegate, LKInputBarDelegate,
  UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate,
    TZImagePickerControllerDelegate>
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) LKInputBar *inputBar;
@property (nonatomic, strong) JMSGConversation *conversation;
@property (nonatomic, strong) NSMutableArray *allMessagesIds;
@property (nonatomic, strong) NSMutableDictionary *allMessagesDic;
@property (nonatomic, strong) NSMutableArray *allImagesIds;
@property (nonatomic, strong) NSMutableArray *allImages;
@property (nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;
@property (nonatomic, strong) NSIndexPath *currPlayIndexPath;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger offset;
@end

@implementation KWChatRoomController

#pragma mark - LifeCyle -

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化页面控件
    [self initPageSubviews];
    //创建会话
    [self createConversation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated]; 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //关闭红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self removeOtherChatPage];
    
}

#pragma mark - 初始化方法 -
- (void)initPageSubviews {
    [self.naviBar setBarStyle:YWNaviBarStyleBackAndTitle];
    [self.view addSubview:self.messageTableView];
    [self.view addSubview:self.inputBar];
    [self.inputBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
    }];
    Weakify(self)
    self.messageTableView.mj_header = [self loadCircleMJRefresh:^{
        [weakself fectchLastedMessages];
    }];
}

#pragma mark - 创建会话 -
- (void)createConversation {
//    [self showHUD];
    [KWJMessager createConversationUsername:self.userName
                                loginIfNeed:YES completed:^(id resultObject, NSError *error) {
//        [self HidenHUD];
        if (!error) {
            //创建会话成功，准备聊天环境
            self.conversation = resultObject;
            [self.naviBar setTitleText:self.conversation.title];
            //监听会话消息
            [JMessage addDelegate:self withConversation:self.conversation];
            //拉取最新消息
            [self fectchLastedMessages];
        }else {
            //创建会话失败
            NSString *tip = [NSString stringWithFormat:@"创建会话失败：%@",@(error.code)];
//            makeToast(tip);
        }
    }];
}



#pragma mark - 通知方法 -


#pragma mark - JMessage监听方法 -
//发送消息回调
- (void)onSendMessageResponse:(JMSGMessage *)message error:(NSError *)error {
    if (message) {
        self.offset ++;
        //替换本地message数据源
        [self.allMessagesDic setObject:message forKey:message.msgId];
        NSInteger row = [self.allMessagesIds indexOfObject:message.msgId];
        [self.messageTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationNone];
        [self scrollToEnd:YES];
    }else {
        //发送失败
        NSString *tip = [NSString stringWithFormat:@"发送失败：%@",@(error.code)];
//        makeToast(tip);
    }
}
//接收到消息
- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error {
    if (message) {
        self.offset ++;
        [self appendOneMessage:message];
        [self addImageMessageIfNeed:message localImage:nil reverse:NO];
        if (message.contentType != kJMSGContentTypeVoice) {
            [message setMessageHaveRead:^(id resultObject, NSError *error) {}];
            [self.conversation clearUnreadCount];
        }
    }
}

//消息回执
- (void)onReceiveMessageReceiptStatusChangeEvent:(JMSGMessageReceiptStatusChangeEvent *)receiptEvent {
    NSMutableArray *paths = [NSMutableArray array];
    for (JMSGMessage *msg in receiptEvent.messages) {
        JMSGMessage *old = [self.allMessagesDic objectForKey:msg.msgId];
        [old updateFlag:@(YES)];//标记已读
        NSInteger i = -1;
        for (NSString *msgid in self.allMessagesIds) {
            if ([msgid isEqualToString:msg.msgId]) {
                i = [self.allMessagesIds indexOfObject:msgid];
                break;
            }
        }
        if (i >= 0 ) {
            NSIndexPath *indexPaths = [NSIndexPath indexPathForRow:i inSection:0];
            [paths addObject:indexPaths];
        }
    }
    [self.messageTableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - 私有方法 -
//拉取最新20条聊天数据
- (void)fectchLastedMessages {
    if (self.offset == 0) {
//        [self showHUD];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *messages = [self.conversation messageArrayFromNewestWithOffset:@(self.offset)
                                                                          limit:@(kFetchMsgLimit)];
        //消息排序
        NSArray *sortResultArr = [messages sortedArrayUsingFunction:sortMessageType context:nil];
        if (self.serviceDic) {
            //插入商品链接
            NSString *json = [self.serviceDic mj_JSONString];
            NSDictionary *dic = @{@"servcieMap":String_NotNil(json)};
            JMSGCustomContent *content = [[JMSGCustomContent alloc] initWithCustomDictionary:dic];
            JMSGMessage *msg = [JMSGMessage createSingleMessageWithContent:content username:self.userName];
            [self setSendTime:msg];
            [msg.content addNumberExtra:@(YES) forKey:kShowSendKey];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:sortResultArr];
            [arr addObject:msg];
            sortResultArr = arr;
        }
        //将排好序的历史消息添加到页面数组中
        [self addBatchMessages:sortResultArr];
        //最后，显示
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.offset == 0) {
                //第一页首次加载，遮罩
//                [self HidenHUD];
                [self.messageTableView reloadData];
                [self scrollToEnd:NO];
            }else {
                //下拉更多
                [self.messageTableView.mj_header endRefreshing];
                [self.messageTableView reloadData];
                NSInteger currRow = sortResultArr.count;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currRow inSection:0];
                [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            if (messages.count < kFetchMsgLimit) {
                self.messageTableView.mj_header.hidden = YES;
            }else {
                self.offset = self.offset + kFetchMsgLimit;
            }
        });
    });
}
//发送服务链接消息
- (void)sendGoodsLinkMessage:(BOOL)showSend {
    NSString *json = [self.serviceDic mj_JSONString];
    NSDictionary *dic = @{@"servcieMap":String_NotNil(json)};
    JMSGCustomContent *content = [[JMSGCustomContent alloc] initWithCustomDictionary:dic];
    JMSGMessage *msg = [JMSGMessage createSingleMessageWithContent:content username:self.userName];
    if (showSend || [self needShowSendTime]) {
        [self setSendTime:msg];
    }
    [msg.content addNumberExtra:@(showSend) forKey:kShowSendKey];
    if (!showSend) {
        [self.conversation sendMessage:msg];
    }
    //将消息显示到table上
    [self appendOneMessage:msg];
}

//发送1条消息
- (void)sendMessage:(JMSGMessage *)msg needAppend:(BOOL)append {
    //计算距离上一条消息的间隔时间
    if ([self needShowSendTime]) {
        [self setSendTime:msg];
    }else {
        if([msg.content.extras objectForKey:kShowTimeKey]) {
            [msg.content addNumberExtra:@(NO) forKey:kShowTimeKey];
        }
    }
    JMSGOptionalContent *opt = [JMSGOptionalContent new];
    opt.needReadReceipt = YES;//需要对方发送消息已读回执
    [self.conversation sendMessage:msg optionalContent:opt];
    if (append) {
        //将消息显示到table上
        [self appendOneMessage:msg];
    }
}

//发送多条消息
- (void)sendBatchMessages:(NSArray<JMSGMessage *> *)messages {
    NSInteger startIndex = [self.messageTableView numberOfRowsInSection:0];
    NSMutableArray *paths = [NSMutableArray array];
    [messages enumerateObjectsUsingBlock:^(JMSGMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //先逐条发送消息出去
        [self sendMessage:obj needAppend:NO];
        //把消息添加到维护列表和索引里
        [self.allMessagesIds addObject:obj.msgId];
        [self.allMessagesDic setObject:obj forKey:obj.msgId];
        NSIndexPath *path = [NSIndexPath indexPathForRow:(startIndex+idx) inSection:0];
        [paths addObject:path];
    }];
    //批量插入到table
    [self.messageTableView beginUpdates];
    [self.messageTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self.messageTableView endUpdates];
    //最后滚动到底部
    [self scrollToEnd:YES];
}

//滑至底部
- (void)scrollToEnd:(BOOL)animated {

    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    rows = MIN(rows, self.allMessagesIds.count);
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:
                                                       rows-1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
    
}
//判断是否需要显示聊天时间
- (BOOL)needShowSendTime {
    BOOL needShowTime = NO;
    if (self.allMessagesIds.count) {
        NSString *msgId = [self.allMessagesIds lastObject];
        JMSGMessage *lastMessage = [self.allMessagesDic objectForKey:msgId];
        NSTimeInterval interval = [lastMessage.timestamp doubleValue]/1000.0;
        NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:interval];
        if (fabs([lastDate timeIntervalSinceNow]) > 5 * 60) {
            needShowTime = YES;
        }
    }else{
        needShowTime = YES;
    }
    return needShowTime;
}
//设置聊天时间
- (void)setSendTime:(JMSGMessage *)message {
    NSTimeInterval secs = [[NSDate date] timeIntervalSince1970];
    long timestamp = secs * 1000;
    NSNumber *time = [NSNumber numberWithLong:timestamp];
    [message.content addNumberExtra:time forKey:kTimeKey];
    [message.content addNumberExtra:@(YES) forKey:kShowTimeKey];
}


//追加一条消息到table上
- (void)appendOneMessage:(JMSGMessage *)message {
    if (message) {
        NSString *lastMsgId = [self.allMessagesIds lastObject];
        JMSGMessage *lastMsg = [self.allMessagesDic objectForKey:lastMsgId];
        [self showTimeMessage:message accordWith:lastMsg];
        NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
        if (rows == self.allMessagesIds.count) {
            [self.allMessagesIds addObject:message.msgId];
            [self.allMessagesDic setObject:message forKey:message.msgId];
            NSIndexPath *path = [NSIndexPath indexPathForRow:[self.allMessagesIds count]-1 inSection:0];
            [self.messageTableView beginUpdates];
            [self.messageTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [self.messageTableView endUpdates];
            
            [self scrollToEnd:YES];
        }
    }
}

- (void)showTimeMessage:(JMSGMessage *)msg accordWith:(JMSGMessage *)pre {
    if (!pre) {
        [msg.content addNumberExtra:msg.timestamp forKey:kTimeKey];
        [msg.content addNumberExtra:@(YES) forKey:kShowTimeKey];
        return;
    }
    NSTimeInterval interval = [pre.timestamp doubleValue]/1000.0;
    NSTimeInterval nowInterval = [msg.timestamp doubleValue]/1000.0;
    if (fabs(nowInterval - interval) > 5 * 60) {
        [msg.content addNumberExtra:msg.timestamp forKey:kTimeKey];
        [msg.content addNumberExtra:@(YES) forKey:kShowTimeKey];
    }else {
        [msg.content addNumberExtra:@(NO) forKey:kShowTimeKey];
    }
}

//将历史消息一次性添加到页面上
- (void)addBatchMessages:(NSArray <JMSGMessage *> *)messages {
    messages = [[messages reverseObjectEnumerator] allObjects];
    [messages enumerateObjectsUsingBlock:^(JMSGMessage * _Nonnull obj,
                                           NSUInteger idx, BOOL * _Nonnull stop) {
        //设置是否显示时间
        JMSGMessage *pre = [messages safeObjectAtIndex:idx+1];
        [self showTimeMessage:obj accordWith:pre];
        [obj updateFlag:@(YES)];//全部更新已读
        if (obj.isReceived) {
            [obj setMessageHaveRead:^(id resultObject, NSError *error) {}];
        }
        [self.allMessagesIds insertObject:obj.msgId atIndex:0];
        [self.allMessagesDic setObject:obj forKey:obj.msgId];
        [self addImageMessageIfNeed:obj localImage:nil reverse:YES];
    }];
}

//本地持有一个图片的数组，为图片预览准备的
- (void)addImageMessageIfNeed:(JMSGMessage *)message localImage:(UIImage *)img reverse:(BOOL)reverse {
    if (!message) {
        return;
    }
    if ([message.content isKindOfClass:[JMSGImageContent class]]) {
        if (reverse) {
            [self.allImagesIds insertObject:message.msgId atIndex:0];
        }else {
            [self.allImagesIds addObject:message.msgId];
        }
        if (img) {
            if (reverse) {
                [self.allImages insertObject:img atIndex:0];
            }else {
                [self.allImages addObject:img];
            }
        }else {
            JMSGImageContent *content = (JMSGImageContent *)message.content;
            if (reverse) {
                [self.allImages insertObject:content atIndex:0];
            }else {
                [self.allImages addObject:content];
            }
        }
    }
}

//结束录音
- (void)finishRecorded {
    DDLogDebug(@"Action - finishRecorded");
    WEAKSELF
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf sendMessageWithVoice:strongSelf.voiceRecordHelper.recordPath
                           voiceDuration:strongSelf.voiceRecordHelper.recordDuration];
    }];
}
//消息重发
- (void)resendMessage:(JMSGMessage *)message {
    DDLogDebug(@"Action - 消息重发");
    [WormAlert popAlertTitle:nil message:@"重发该消息？" leftBtnText:@"取消" rightBtnText:@"重发" actionAtIndex:^(NSInteger index) {
        if (index == 1) {
            JMSGMessage *msg = [JMSGMessage createSingleMessageWithContent:message.content username:self.userName];
            [self sendMessage:msg needAppend:YES];
        }
    }];
}

//拍照权限判断
- (void)prepareOpenCamara {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted ||
         authStatus == AVAuthorizationStatusDenied)) {
        // 无相机权限 做一个友好的提示
        [self.view endEditing:YES];
        [WormAlert popAlertTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" leftBtnText:@"取消" rightBtnText:@"设置" actionAtIndex:^(NSInteger index) {
            if (index == 1) {
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self prepareOpenCamara];
                                         });
                                     }
                                 }];
    } else {
        [self takePhoto];
    }
}
//开始拍照
- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 公共方法 -
//消息排序
NSInteger sortMessageType(id object1,id object2,void *cha) {
    JMSGMessage *message1 = (JMSGMessage *)object1;
    JMSGMessage *message2 = (JMSGMessage *)object2;
    if([message1.timestamp integerValue] > [message2.timestamp integerValue]) {
        return NSOrderedDescending;
    } else if([message1.timestamp integerValue] < [message2.timestamp integerValue]) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

//移除栈里面其他的聊天页面,保证唯一
- (void)removeOtherChatPage {
    NSMutableArray *controllers = [NSMutableArray array];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc == self) {//自己要加上
            [controllers addObject:vc];
        }
        if (![vc isKindOfClass:NSClassFromString(@"KWChatRoomController")]) {
            [controllers addObject:vc];
        }
    }
    [self.navigationController setViewControllers:controllers animated:NO];
}

#pragma mark - Action方法 -


#pragma mark - 发送语音
- (void)sendMessageWithVoice:(NSString *)voicePath
               voiceDuration:(NSString*)voiceDuration {
    DDLogDebug(@"Action - SendMessageWithVoice");
    
    if ([voiceDuration integerValue]<0.5 || [voiceDuration integerValue]>60) {
        if ([voiceDuration integerValue]<0.5) {
            DDLogDebug(@"录音时长小于 0.5s");
//            makeToast(@"录音时长太短！");
        } else {
            DDLogDebug(@"录音时长大于 60s");
        }
        return;
    }
    
    JMSGMessage *voiceMessage = nil;
    JMSGVoiceContent *voiceContent = [[JMSGVoiceContent alloc] initWithVoiceData:[NSData dataWithContentsOfFile:voicePath]
                                                                   voiceDuration:[NSNumber numberWithInteger:[voiceDuration integerValue]]];
    
    voiceMessage = [_conversation createMessageWithContent:voiceContent];
    [self sendMessage:voiceMessage needAppend:YES];
}

//图片预览、音频播放、定位点击
- (void)playContentMessage:(JMSGMessage *)message indexPath:(NSIndexPath *)indexPath {
    if ([message.content isKindOfClass:[JMSGImageContent class]]) {
        #pragma mark - 图片预览
        WormImgPreviewController *preview = [[WormImgPreviewController alloc] init];
        preview.index = [self.allImagesIds indexOfObject:message.msgId];
        preview.previewArray = self.allImages;
        [self presentViewController:preview animated:YES completion:nil];
    }else if ([message.content isKindOfClass:[JMSGVoiceContent class]]) {
        #pragma mark - 音频播放
        JMSGVoiceContent *voice = (JMSGVoiceContent *)message.content;
        if ([self.player isPlaying]) {//有正在播放的音频
            //先停止正在播放的音频（如果有的话）
            [self hiddenVoicePlayAnimate];
            if (self.currPlayIndexPath == indexPath) {
                //如果点击的是正在播放的那一条音频，则停止
                [self.player stop];//播放停止
                [self resumeOtherAppAudioPlay];
                return ;
            }else {
                //点击别的音频
                [self.player stop];//播放停止
            }
        }
        //开始播放新的音频
        self.currPlayIndexPath = indexPath;
        [self showVoicePlayAnimate];
        //1先获取音频数据
        [voice voiceData:^(NSData *data, NSString *objectId, NSError *error) {
            //2.初始化播放器AVAudioPlayer
            NSError *err = nil;
            self.player = [[AVAudioPlayer alloc] initWithData:data error:&err];
            self.player.delegate = self;
            if (self.player && !err) {
                //3.开始播放
                [self.player prepareToPlay];
                [self.player play];
                //开启红外感应
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                //标记已读
                [message setMessageHaveRead:^(id resultObject, NSError *error) {}];
                [self.conversation clearUnreadCount];
            }else {
                [self hiddenVoicePlayAnimate];
            }
        }];
        
    }else if ([message.content isKindOfClass:[JMSGLocationContent class]]) {
        #pragma mark - 定位点击
        JMSGLocationContent *loc = (JMSGLocationContent *)message.content;
        shopMapViewController *map = [[shopMapViewController alloc] init];
        map.lat = [NSString stringWithFormat:@"%@",loc.latitude];
        map.lng = [NSString stringWithFormat:@"%@",loc.longitude];
        map.addressStr = loc.address;
        [self.navigationController pushViewController:map animated:YES];
    }
}

- (void)showVoicePlayAnimate {
    KWChatVoiceCell *cell = [self.messageTableView cellForRowAtIndexPath:self.currPlayIndexPath];
    [cell startPlayingAnimate];
}

- (void)hiddenVoicePlayAnimate {
    if (self.currPlayIndexPath) {
        KWChatVoiceCell *cell = [self.messageTableView cellForRowAtIndexPath:self.currPlayIndexPath];
        [cell stopPlayingAnimate];
    }
}

#pragma mark - getter and setter -

- (UITableView *)messageTableView {
    if (!_messageTableView) {
        _messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviBarHeight - LKInputBarBaseHeight)];
        _messageTableView.backgroundColor = kBackGroundColor;
        _messageTableView.dataSource = self;
        _messageTableView.delegate = self;
        _messageTableView.estimatedRowHeight = 60;
        _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_messageTableView registerClass:[KWChatTextCell class] forCellReuseIdentifier:@"text"];
        [_messageTableView registerClass:[KWChatImageCell class] forCellReuseIdentifier:@"image"];
        [_messageTableView registerClass:[KWChatLocationCell class] forCellReuseIdentifier:@"location"];
        [_messageTableView registerClass:[KWChatVoiceCell class] forCellReuseIdentifier:@"voice"];
        [_messageTableView registerClass:[KWChatGoodsLinkCell class] forCellReuseIdentifier:@"link"];
    }
    return _messageTableView;
}

- (NSMutableArray *)allMessagesIds {
    if (!_allMessagesIds) {
        _allMessagesIds = [[NSMutableArray alloc] init];
    }
    return _allMessagesIds;
}

- (NSMutableDictionary *)allMessagesDic {
    if (!_allMessagesDic) {
        _allMessagesDic = [[NSMutableDictionary alloc] init];
    }
    return _allMessagesDic;
}

- (NSMutableArray *)allImagesIds {
    if (!_allImagesIds) {
        _allImagesIds = [[NSMutableArray alloc] init];
    }
    return _allImagesIds;
}

- (NSMutableArray *)allImages {
    if (!_allImages) {
        _allImages = [[NSMutableArray alloc] init];
    }
    return _allImages;
}

- (LKInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [[LKInputBar alloc] init];
        _inputBar.delegate = self;
    }
    return _inputBar;
}

- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            DDLogDebug(@"已经达到最大限制时间了，进入下一步的提示");
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf finishRecorded];
        };
        //录音音调高低变化
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel){
            if (![weakSelf.inputBar isShowCancelState]) {
                weakSelf.inputBar.speakPower = peakPowerForChannel;
            }
        };
        
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource -

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.allMessagesIds.count;
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *msgId = [self.allMessagesIds safeObjectAtIndex:indexPath.row];
     JMSGMessage *message = [self.allMessagesDic objectForKey:msgId];
     KWChatBaseCell *cell = nil;
     Weakify(self);
     if ([message.content isKindOfClass:[JMSGTextContent class]]) {
         cell = [tableView dequeueReusableCellWithIdentifier:@"text"];
     }else if ([message.content isKindOfClass:[JMSGImageContent class]]) {
         cell = [tableView dequeueReusableCellWithIdentifier:@"image"];
     }else if ([message.content isKindOfClass:[JMSGLocationContent class]]) {
         cell = [tableView dequeueReusableCellWithIdentifier:@"location"];
     }else if ([message.content isKindOfClass:[JMSGVoiceContent class]]) {
         cell = [tableView dequeueReusableCellWithIdentifier:@"voice"];
     }else if ([message.content isKindOfClass:[JMSGCustomContent class]]) {
         KWChatGoodsLinkCell *linkCell = [tableView dequeueReusableCellWithIdentifier:@"link"];
         linkCell.message = message;
         linkCell.actionBlock = ^{
             #pragma mark - 发送服务链接
             [weakself sendGoodsLinkMessage:NO];
         };
         return linkCell;
     }
     cell.message = message;
     cell.actionBlock = ^(ActionType type){
         if (type == ActionTypeLookDetail) {
             [weakself playContentMessage:message indexPath:indexPath];
         }else {
             //消息重发
             [weakself resendMessage:message];
         }
     };
     return cell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //结束编辑
    [self.view endEditing:YES];
}

#pragma mark - 其他 Delegate -

/**
 点击更多之后选中某个功能
 
 @param inputBar inputBar
 @param actionType 点击事件的类型
 */
- (void)inputBar:(LKInputBar *)inputBar didSelectAction:(LKInputBarActionType)actionType {
    if (actionType == LKInputBarActionTypeLocation) {//定位
        KWLoactionMapSelector *mapSelector = [[KWLoactionMapSelector alloc] init];
        Weakify(self)
        mapSelector.resultData = ^(id result) {
            KWPOI *poi = result;
            JMSGLocationContent *content = [[JMSGLocationContent alloc] initWithLatitude:@(poi.coordinate.latitude) longitude:@(poi.coordinate.longitude) scale:@(16) address:poi.address];
            JMSGMessage *message = [JMSGMessage createSingleMessageWithContent:content username:weakself.userName];
            [weakself sendMessage:message needAppend:YES];
        };
        [self presentViewController:mapSelector animated:YES completion:nil];
        
        return;
    }
    //拍照、相册
    if (actionType == LKInputBarActionTypePhotoLibrary) {
        TZImagePickerController *picker = [[TZImagePickerController alloc]
                                           initWithMaxImagesCount:9 delegate:self];
        picker.allowPickingVideo = NO;
        picker.allowTakePicture = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }else if (actionType == LKInputBarActionTypeCamera) {
        //拍照
        [self prepareOpenCamara];
    }
}

/**
 用户点击发送按钮的事件
 
 @param inputBar inputBar
 @param message 用户输入的内容
 */
- (void)inputBar:(LKInputBar *)inputBar didTapSendActionWithMessage:(NSString *)message {
    //发送文本信息
    JMSGTextContent *content = [[JMSGTextContent alloc] initWithText:message];
    JMSGMessage *msg = [JMSGMessage createSingleMessageWithContent:content username:self.userName];
    
    [self sendMessage:msg needAppend:YES];
    
    [self.inputBar clearTextContent];
}

/**
 开始录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidStartRecord:(LKInputBar *)inputBar {
    DDLogDebug(@"Action - startRecord");
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        //第一次询问
        [self.inputBar cancelRecordVoice];//中途取消录制
    }
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL isOpen) {
        if (isOpen) {
            [self.voiceRecordHelper startRecordingWithPath:[KWJMessager getRecorderPath]
                                   StartRecorderCompletion:^{
                                   }];
        } else {
            DDLogDebug(@"麦克风关闭了");
            [self.inputBar cancelRecordVoice];//中途取消录制
            [WormAlert popConfirmTitle:@"麦克风权限已关闭" message:@"如要发送语音消息，请开启麦克风访问权限" actionAtIndex:^(NSInteger index) {
                if (index == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
    }];
}

/**
 结束录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidEndRecord:(LKInputBar *)inputBar {
    [self finishRecorded];
}

/**
 取消录音
 
 @param inputBar inputBar
 */
- (void)inputBarDidCancelRecord:(LKInputBar *)inputBar {
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}

#pragma mark - 图片选择器回调 -
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
//    [self showHUD];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *messages = [self createBatchImageMessages:photos];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self HidenHUD];
            if (messages.count == 0) {
                DDLogError(@"未获取到选择的图片数据，发送图片失败");
            }else {
                //发送批量消息
                [self sendBatchMessages:messages];
            }
        });
    });
}

- (NSArray<JMSGMessage *> *)createBatchImageMessages:(NSArray<UIImage *> *)images {
    NSMutableArray *messages = [NSMutableArray array];
    for (UIImage *image in images) {
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        if (data) {
            JMSGImageContent *content = [[JMSGImageContent alloc] initWithImageData:data];
            JMSGMessage *message = [JMSGMessage createSingleMessageWithContent:content username:self.userName];
            [messages addObject:message];
            [self addImageMessageIfNeed:message localImage:image reverse:NO];
        }
    }
    return messages;
}

//拍照回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
//    [self showHUD];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        [self sendImageMessageWithData:data];
    });
}

- (void)sendImageMessageWithData:(NSData *)data {
    if (data) {
        JMSGImageContent *content = [[JMSGImageContent alloc] initWithImageData:data];
        JMSGMessage *message = [JMSGMessage createSingleMessageWithContent:content username:self.userName];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self HidenHUD];
            [self dismissViewControllerAnimated:YES completion:^{
                [self sendMessage:message needAppend:YES];
                [self addImageMessageIfNeed:message localImage:[UIImage imageWithData:data] reverse:NO];
            }];
        });
    }else {
        //无图片数据
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogError(@"未获取到选择的图片数据，发送图片失败");
//            [self HidenHUD];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

//inputbar高度变化的回调
- (void)inputBar:(LKInputBar *)inputBar heightWillChange:(CGFloat)height y:(CGFloat)y {
    [UIView animateWithDuration:0.5 animations:^{
        self.messageTableView.height = y - NaviBarHeight;
    } completion:^(BOOL finished) {
        [self scrollToEnd:YES];
    }];
}

#pragma mark - 滚动table,键盘归位
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.messageTableView) {
        //结束编辑
        [self.view endEditing:YES];
    }
}

#pragma mark - 音频播放的回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //停止音频播放动画
    [self hiddenVoicePlayAnimate];
    [self resumeOtherAppAudioPlay];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    [self hiddenVoicePlayAnimate];
    [self resumeOtherAppAudioPlay];
}

- (void)resumeOtherAppAudioPlay {
    //让后台其他音频继续播放（如QQ音乐等）
    AVAudioSession *avAudioSession = [AVAudioSession sharedInstance];
    [avAudioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    //关闭红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

@end
