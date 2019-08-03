//
//  KWChatImageCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatImageCell.h"
#import "PrefixHeader.pch"

@interface KWChatImageCell ()
@property (nonatomic, strong) UIImageView *photoView;
@end

@implementation KWChatImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.messageView addSubview:self.photoView];
    }
    return self;
}

//覆写父类的方法
- (void)layout {
    [super layout];
    
    //专注图片区域的布局即可
    JMSGImageContent *content = (JMSGImageContent *)self.message.content;
    CGSize showSize = [self photoShowSize:content.imageSize];
    
    [self.photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(showSize).priority(751);
        make.edges.equalTo(self.messageView).priority(751);
    }];
}

- (CGSize)photoShowSize:(CGSize)photoSize {
    CGSize maxSize = CGSizeMake(150, 150);
    CGSize showSize = CGSizeZero;
    if (photoSize.width <= maxSize.width &&
        photoSize.height <= maxSize.height) {
        showSize = photoSize;
    }else if (photoSize.width <= maxSize.width &&
              photoSize.height > maxSize.height) {
        CGFloat width = photoSize.width/photoSize.height * maxSize.height;
        showSize = CGSizeMake(width, maxSize.height);
    }else if (photoSize.width > maxSize.width &&
              photoSize.height <= maxSize.height) {
        CGFloat height = photoSize.height/photoSize.width * maxSize.width;
        showSize = CGSizeMake(maxSize.width, height);
    }else {
        if (photoSize.width/photoSize.height > maxSize.width/maxSize.height) {
            //宽图，以最大宽度为宽
            CGFloat height = photoSize.height/photoSize.width * maxSize.width;
            showSize = CGSizeMake(maxSize.width, height);
        }else {
            //瘦图，以最大高度为高
            CGFloat width = photoSize.width/photoSize.height * maxSize.height;
            showSize = CGSizeMake(width, maxSize.height);
        }
    }
    return showSize;
}

//覆写父类的属性
- (void)setMessage:(JMSGMessage *)message {
    [super setMessage:message];
    
    //专注图片区域的赋值即可
    if ([message.content isKindOfClass:[JMSGImageContent class]]) {
        JMSGImageContent *content = (JMSGImageContent *)message.content;
        [content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
            if (!error && data && [message.msgId isEqualToString:objectId]) {
                self.photoView.image = [UIImage imageWithData:data] ;
            }
        }];
    }
}

- (void)bindModel:(id)model {
    
}

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.backgroundColor = hexColor(@"f5f5f5");
        _photoView.layer.cornerRadius = 5;
        _photoView.layer.masksToBounds = YES;
        _photoView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClicked)];
        [_photoView addGestureRecognizer:tap];
    }
    return _photoView;
}

- (void)photoClicked {
    if (self.actionBlock) {
        self.actionBlock(ActionTypeLookDetail);
    }
}

@end
