//
//  LKInputBar.m
//  InputViewPractice
//
//  Created by 小屁孩 on 2019/3/7.
//  Copyright © 2019年 小屁孩. All rights reserved.
//

#import "LKInputBar.h"
#import "LKEmojView.h"
#import "LKExpansionView.h"
#import "LKRecordView.h"
#import "LKBaseLabel.h"
#import <KWOCMacroDefinite/KWOCMacro.h>
#import <KWLogger/KWLogger.h>
#import <KWPublicUISDK/PublicHeader.h>
#import <KWCategoriesLib/NSArray+Safe.h>
#import <KWCategoriesLib/UIView+Common.h>
#import <Masonry.h>
#define LKNaviHeight ((SCREEN_HEIGHT > 800?YES:NO)?88:64)
#define LKTextView_MaxHeight 80
#define LKTextView_MinHeight 36
#define LKRecordMaxTime 60   //录音最大时间
typedef NS_ENUM(NSInteger, LKChartMode) {
    LKChartModeChart,//聊天模式
    LKChartModeRecord,//录音模式
};
@interface LKInputBar()<UITextViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate> {
    LKChartMode chartMode;
    NSTimeInterval currentRecordTime; //当前记录剩余时间
}

@property (nonatomic, strong) UIView *inputBgView; //键盘弹出框的底层View
@property (nonatomic, strong) LKEmojView *emojView; //表情View
@property (nonatomic, strong) LKExpansionView *expansionView; //更多功能的View
@property (nonatomic, strong) UIButton *leftBtn;//左边切换语音和键盘的按钮
@property (nonatomic, strong) UIButton *emojBtn; //点击展示表情
@property (nonatomic, strong) UIButton *moreBtn; //展示更多
@property (nonatomic, strong) UITextView *textView; //输入框
@property (nonatomic, strong) UITextField *textField; //录音和开始说话
@property (nonatomic, strong) LKBaseLabel *recordLabel; //录音的按钮
@property (nonatomic, strong) LKBaseLabel *placeholderL; //placeholder
@property (nonatomic, strong) UIView *bgView; //bgView 这个控件完全是为了美观而设计的
@property (nonatomic, strong) LKRecordView *recordView; //开始录音时候的显示图片

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes; //长按录音
@property (nonatomic, assign) CGFloat textViewHeight; //当前输入框的高度
@property (nonatomic, assign) CGFloat keyboardHeight; //键盘高度=
@property (nonatomic, assign) CGFloat currOffset;//当前手指录音移动的距离

@property (nonatomic, strong) NSTimer *timer; //录音倒计时定时器

@end

@implementation LKInputBar
- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
        self.textViewHeight = LKTextView_MinHeight;
        self.recordCancelDistance = 50;
        self.keyboardHeight = 0;
        currentRecordTime = LKRecordMaxTime;
        chartMode = LKChartModeChart;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideNoti:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeNoti:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.leftBtn];
    [self addSubview:self.textView];
    [self addSubview:self.moreBtn];
    [self addSubview:self.recordLabel];
    [self addSubview:self.textField];
    [self addSubview:self.placeholderL];
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kWidth(16));
        make.bottom.offset(-kWidth(12) - (LKNaviHeight - 64));
        make.size.mas_equalTo(CGSizeMake(kWidth(33), kWidth(33)));
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-kWidth(16));
        make.bottom.offset(-kWidth(12) - (LKNaviHeight - 64));
        make.size.mas_equalTo(CGSizeMake(kWidth(33), kWidth(33)));
    }];
    
    [self.recordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
        make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
        make.bottom.offset(-kWidth(10) - (LKNaviHeight - 64));
        make.height.mas_equalTo(LKTextView_MinHeight);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
        make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
        make.top.offset(kWidth(10));
        make.bottom.offset(-kWidth(10) - (LKNaviHeight - 64));
        make.height.mas_equalTo(LKTextView_MinHeight);
    }];
    
    [self.placeholderL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
        make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
        make.bottom.offset(-kWidth(10) - (LKNaviHeight - 64));
        make.height.mas_equalTo(LKTextView_MinHeight);
    }];
}

//语音和键盘切换，更新约束
- (void)updateUIWithMode:(LKChartMode)mode {
    chartMode = mode;
    switch (mode) {
        case LKChartModeChart:{
            self.textView.hidden = NO;
            self.recordLabel.hidden = YES;
            self.placeholderL.hidden = NO;
        }
            break;
        case LKChartModeRecord:{
            [self endEditing:YES];
            self.textView.hidden = YES;
            self.recordLabel.hidden = NO;
            self.placeholderL.hidden = YES;
        }
            break;
        default:
            break;
    }
    [self updateUICons];
}

//更新输入框高度约束
- (void)updateUICons {
    if (!self.recordLabel.hidden) {
        [self.recordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
            make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
            make.top.offset(kWidth(10));
            make.bottom.offset(-kWidth(10) - (LKNaviHeight - 64));
            make.height.mas_equalTo(LKTextView_MinHeight).priorityHigh();
        }];
        
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
            make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
            make.bottom.offset(-kWidth(10));
            make.height.mas_equalTo(LKTextView_MinHeight).priorityMedium();
        }];
    } else {
        [self.recordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
            make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
            make.bottom.offset(-kWidth(10));
            make.height.mas_equalTo(LKTextView_MinHeight);
        }];
        
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftBtn.mas_right).with.offset(kWidth(15));
            make.right.equalTo(self.moreBtn.mas_left).with.offset(-kWidth(15));
            make.top.offset(kWidth(10));
            make.bottom.offset(-kWidth(10) - (LKNaviHeight - 64));
            make.height.mas_equalTo(self.textViewHeight);
        }];
    }
}

//是否是cancel状态
- (BOOL)isShowCancelState {
    if (self.currOffset >= self.recordCancelDistance) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark -------按钮点击事件
//切换聊天方式---语音和打字
- (void)changeChartModeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    LKChartMode mode = sender.selected?LKChartModeRecord:LKChartModeChart;
    [self updateUIWithMode:mode];
    if (mode == LKChartModeChart) {
        [self.textView becomeFirstResponder];
    }
    self.moreBtn.transform = CGAffineTransformIdentity;
    self.moreBtn.selected = NO;
}
//展示更多
- (void)showMoreAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.textView resignFirstResponder];
        [self.inputBgView addSubview:self.expansionView];
        self.textField.inputView = self.inputBgView;
        self.inputBgView.frame = self.expansionView.frame;
        [self.textField reloadInputViews];
        [self.textField becomeFirstResponder];
        [UIView animateWithDuration:.25 animations:^{
            sender.transform = CGAffineTransformMakeRotation(M_PI_4);
        }];
    } else {
        [UIView animateWithDuration:.35 animations:^{
            sender.transform = CGAffineTransformIdentity;
        }];
        [self endEditing:YES];
    }
}

//显示表情
- (void)showEmojiAction:(UIButton *)sender {
    self.moreBtn.transform = CGAffineTransformIdentity;
    self.moreBtn.selected = NO;
}

#pragma mark-------setter and getter方法
- (void)setSpeakPower:(CGFloat)speakPower {
    _speakPower = speakPower;
    [self.recordView configRecordingImageWithPeakPower:speakPower];
}

- (void)clearTextContent {
    if (self.recordLabel.hidden) {
        self.textView.text = @"";
        self.placeholderL.hidden = NO;
    }
}

#pragma mark -------textView的代理
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderL.hidden = textView.attributedText.length || textView.text.length;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) { //点击键盘的确定键，意义是换行，这里拦截一下，改成发送
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didTapSendActionWithMessage:)]) {
            [self.delegate inputBar:self didTapSendActionWithMessage:textView.text];
        }
        return NO;
    }
    return YES;
}

//换行处理
- (void)textViewDidChange:(UITextView *)textView {
    //防止拼音输入时，文本直接获取拼音
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    NSString * newText = [textView textInRange:selectedRange];
    if(newText.length > 0) {
        self.placeholderL.hidden = YES;
        return;
    }
    //为了使光标的位置不会有变化
    NSRange range = textView.selectedRange;
    //防止输入时在中文后输入英文过长直接中文和英文换行
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
    textView.selectedRange = range;
    self.placeholderL.hidden = textView.attributedText.length;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //    [self resetPositionAnimation];
    self.moreBtn.transform = CGAffineTransformIdentity;
    self.moreBtn.selected = NO;
}

//强制取消音频录制
- (void)cancelRecordVoice {
    self.longPressGes.state = UIGestureRecognizerStateCancelled;
}


#pragma mark -----手势的代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarShouldStartRecord:)]) {
        return [self.delegate inputBarShouldStartRecord:self];
    }
    return YES;
}
#pragma mark--------手势响应
//录音
- (void)recordVoice:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{ //开始
            [self startTimer];
            [self.recordView configRecordingImageWithPeakPower:0];
            self.recordLabel.text = @"松开 结束";
            self.recordLabel.backgroundColor = hexColor(@"B3B3B3");
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidStartRecord:)]) {
                [self.delegate inputBarDidStartRecord:self];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ //移动改变
            CGPoint point = [gesture locationInView:self];
            CGFloat offset = fabs(point.y);
            self.currOffset = offset;
            if (offset >= self.recordCancelDistance) {
                [self.recordView showCancel];
            } else {
                self.recordView.recordContentHidden = NO;
                [self.recordView configRecordingImageWithPeakPower:self.speakPower];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled: {//中途取消
            [self stopTimer];
            [self.recordView removeFromSuperview];
            self.recordView  = nil;
            self.recordLabel.text = @"按住 说话";
            self.recordLabel.backgroundColor = hexColor(@"F2F6FA");
            self.recordLabel.textColor = KRedColor;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self stopTimer];
            [self.recordView removeFromSuperview];
            self.recordView  = nil;
            self.recordLabel.text = @"按住 说话";
            self.recordLabel.backgroundColor = hexColor(@"F2F6FA");
            self.recordLabel.textColor = kBlackFontColor;
            CGPoint point = [gesture locationInView:self];
            CGFloat offset = fabs(point.y);
            self.currOffset = offset;
            if (offset >= self.recordCancelDistance) { //移动超过定义的最大距离之后取消录音
                if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidCancelRecord:)]) {
                    [self.delegate inputBarDidCancelRecord:self];
                }
                [self.recordView removeFromSuperview];
                self.recordView = nil;
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidEndRecord:)]) {
                    [self.delegate inputBarDidEndRecord:self];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark --------timer定时器
- (void)startTimer {
    currentRecordTime = LKRecordMaxTime;
    self.recordView.recordContent = LKDefaultRecordConten;
    [self.timer setFireDate:[NSDate date]];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showRecordTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)showRecordTime {
    currentRecordTime--;
    if (currentRecordTime <= 10) {
        self.recordView.recordContent = [NSString stringWithFormat:@"还可以说%.0f秒",currentRecordTime];
    }
    if (currentRecordTime <= 0) {
        [self stopTimer];
        self.longPressGes.state = UIGestureRecognizerStateEnded;
    }
    
}

#pragma mark----------KVO观察者
//监听TextView内容的改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.textView]) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            CGFloat height = self.textView.contentSize.height;
            if (height <= LKTextView_MinHeight+1) {
                height = LKTextView_MinHeight;
            } else if (height >= LKTextView_MaxHeight) {
                height = LKTextView_MaxHeight;
            }
            if ((self.textView.height >= LKTextView_MaxHeight && height >= LKTextView_MaxHeight) || (height <= LKTextView_MinHeight+1 && self.textView.height <= LKTextView_MinHeight+1)) { //为了保证在最小h高度和最大高度的时候，不用多次调用改变高度的的代理
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:heightWillChange:y:)]) {
                CGFloat dheight = height - LKTextView_MinHeight + self.keyboardHeight;
                [self.delegate inputBar:self heightWillChange:dheight y:(SCREEN_HEIGHT - height - kWidth(20) - self.keyboardHeight - NaviBarHeight + 64)];
            }
            self.textViewHeight = height;
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            [self layoutIfNeeded];
        }
    }
}

#pragma mark-------通知
//键盘弹出的通知
- (void)keyboardChangeNoti:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    CGRect rect = [dic[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = rect.size.height;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:heightWillChange:y:)]) {
        if (chartMode == LKChartModeChart) {
            [self.delegate inputBar:self heightWillChange:(rect.size.height + self.textViewHeight - LKTextView_MinHeight) y:(SCREEN_HEIGHT - self.keyboardHeight - self.textViewHeight - kWidth(20))];
        } else {
            [self.delegate inputBar:self heightWillChange:rect.size.height y:(self.top - self.keyboardHeight)];
        }
    }
    [UIView animateWithDuration:.25 animations:^{
        self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, rect.size.height);
        self.transform = CGAffineTransformMakeTranslation(0,-rect.size.height+(LKNaviHeight - 64));
    }];
}
//键盘收起的通知
- (void)keyboardHideNoti:(NSNotification *)noti {
    [self resetPositionAnimation];
    
}

//还原当前的位置
- (void)resetPositionAnimation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:heightWillChange:y:)]) {
        if (chartMode == LKChartModeChart) {
            [self.delegate inputBar:self heightWillChange:0 y:(SCREEN_HEIGHT - self.textViewHeight - kWidth(20) - NaviBarHeight + 64)];
        } else {
            [self.delegate inputBar:self heightWillChange:0 y:(SCREEN_HEIGHT - LKInputBarBaseHeight)];
        }
    }
    [UIView animateWithDuration:.25 animations:^{
        self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.height);
        self.transform = CGAffineTransformIdentity;
    }];
}


#pragma mark -------懒加载
- (UIView *)inputBgView {
    if (!_inputBgView) {
        _inputBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _inputBgView.backgroundColor = [UIColor whiteColor];
    }
    return _inputBgView;
}

- (LKEmojView *)emojView {
    if (!_emojView) {
        _emojView = [[LKEmojView alloc] init];
        _emojView.backgroundColor = [UIColor redColor];
    }
    return _emojView;
}

- (LKExpansionView *)expansionView {
    if (!_expansionView) {
        _expansionView = [[LKExpansionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        Weakify(self)
        _expansionView.clickIndexBlock = ^(LKInputBarActionType type) {
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(inputBar:didSelectAction:)]) {
                [weakself.delegate inputBar:weakself didSelectAction:type];
            }
        };
    }
    return _expansionView;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, 0, 40, 40);
        [_leftBtn setImage:ImageNamed(@"im_voice") forState:UIControlStateNormal];
        [_leftBtn setImage:ImageNamed(@"im_jianpan") forState:UIControlStateSelected];
        [_leftBtn addTarget:self action:@selector(changeChartModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)emojBtn {
    if (!_emojBtn) {
        _emojBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emojBtn.frame = CGRectMake(0, 0, 40, 40);
        [_emojBtn setTitle:@"表情" forState:UIControlStateNormal];
        [_emojBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_emojBtn addTarget:self action:@selector(showEmojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(0, 0, 40, 40);
        [_moreBtn setImage:ImageNamed(@"im_more") forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.backgroundColor = hexColor(@"F2F6FA");
        _textView.font = kFont(14);
        _textView.layer.cornerRadius = kWidth(5);
        _textView.textContainerInset = UIEdgeInsetsMake(10, 12, 10, 12);
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        //使用KVO监听TextView的contentSize计算高度，比直接计算文字rect之后再改变TextView高度要准确
        [_textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _textView;
}
- (LKBaseLabel *)recordLabel {
    if (!_recordLabel) {
        _recordLabel = [[LKBaseLabel alloc] init];
        _recordLabel.backgroundColor = hexColor(@"F2F6FA");
        _recordLabel.textColor = kBlackFontColor;
        _recordLabel.font = kFont(13);
        _recordLabel.layer.cornerRadius = kWidth(5);
        _recordLabel.text = @"按住 说话";
        _recordLabel.textAlignment = NSTextAlignmentCenter;
        _recordLabel.textColor = hexColor(@"4D5055");
        _recordLabel.clipsToBounds = YES;
        _recordLabel.edgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
        _recordLabel.hidden = YES;
        [self.recordLabel addGestureRecognizer:self.longPressGes];
        self.recordLabel.userInteractionEnabled = YES;
        
    }
    return _recordLabel;
}

- (LKBaseLabel *)placeholderL {
    if (!_placeholderL) {
        _placeholderL = [[LKBaseLabel alloc] init];
        _placeholderL.backgroundColor = [UIColor clearColor];
        _placeholderL.font = kFont(13);
        _placeholderL.layer.cornerRadius = kWidth(5);
        _placeholderL.text = @"说点什么吧..";
        _placeholderL.textAlignment = NSTextAlignmentLeft;
        _placeholderL.textColor = hexColor(@"4D5055");
        _placeholderL.clipsToBounds = YES;
        _placeholderL.edgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    }
    return _placeholderL;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
        _textField.delegate = self;
        _textField.hidden = YES;
    }
    return _textField;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self insertSubview:_bgView atIndex:0];
    }
    return _bgView;
}

- (LKRecordView *)recordView {
    if (!_recordView) {
        _recordView = [[LKRecordView alloc] init];
        [self.window addSubview:_recordView];
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.window);
        }];
    }
    return _recordView;
}

- (UILongPressGestureRecognizer *)longPressGes {
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordVoice:)];
        _longPressGes.minimumPressDuration = 0.3;
        _longPressGes.delegate = self;
    }
    return _longPressGes;
}

- (void)dealloc {
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
