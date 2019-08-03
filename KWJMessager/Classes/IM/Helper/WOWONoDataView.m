//
//  WOWONoDataView.m
//  WormwormLife
//
//  Created by 张文彬 on 2018/2/10.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "WOWONoDataView.h"
#import "PrefixHeader.pch"

@implementation WOWONoDataView
{
    UIImageView *imageView;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    UIButton *button;
    
}
- (instancetype)initWithNoNetViewWithReloadBlock:(void (^)(void))block{
    self = [self initWithImageName:@"no_net" text:@"网络请求失败" detailText:@"别紧张，试试看刷新页面" buttonTitle:@"刷新"];
    if (self) {
        self.buttonAction = block;
    }
    return self;
}


- (instancetype)initWithImageName:(NSString *)imageName text:(NSString *)text detailText:(NSString *)detailText buttonTitle:(NSString *)buttonTitle {
    self = [super init];
    if (self) {
        self.backgroundColor = KWhite;
        
        CGFloat y = 160;
        
        imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:imageName];
        [imageView sizeToFit];
        imageView.center= CGPointMake(SCREEN_WIDTH / 2, y) ;
       
        [self addSubview:imageView];
        
        y = imageView.bottom + 25;
        
        textLabel = [[UILabel alloc]init];
        textLabel.text = text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = kLightFontColor;
        textLabel.font = [UIFont systemFontOfSize:17];
        [textLabel sizeToFit];
        textLabel.width = SCREEN_WIDTH - 20;
       
        textLabel.center = CGPointMake(SCREEN_WIDTH / 2, y);
        textLabel.height = 20;
        [self addSubview:self.text = textLabel];
        
        y = textLabel.bottom + 15;
        
        
        
        if (detailText.length > 0) {
            detailTextLabel = [[UILabel alloc]init];
            detailTextLabel.textAlignment = NSTextAlignmentCenter;
            detailTextLabel.text = detailText;
            detailTextLabel.textColor =hexColor(@"cccccc");
            detailTextLabel.font = [UIFont systemFontOfSize:13];
            detailTextLabel.width = SCREEN_WIDTH - 20;
            detailTextLabel.height = 20;

           
            detailTextLabel.center = CGPointMake(SCREEN_WIDTH/2, y);
            [self addSubview:  detailTextLabel];
            y = detailTextLabel.bottom + 25;
        }
        
        
        if (buttonTitle.length > 0) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:kLightFontColor forState:UIControlStateNormal];
            button.titleLabel.font = kFont(15);
            button.layer.cornerRadius = 14;
            button.layer.borderWidth = 1.0f;
            button.layer.borderColor = kLightFontColor.CGColor;
            button.width = 80;
            button.height = 28;
            [button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
            button.center = CGPointMake(SCREEN_WIDTH/2, y);
            [self addSubview:self.reloadButton = button];
        }
        
    }
    return self;
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_isAdjust) {
        CGFloat y = self.height/2 - imageView.height;
        imageView.top = y;
        y = imageView.bottom + 25;
        textLabel.top = y;
        detailTextLabel.top = y;
        button.top = y;
    }
    
    
}
- (void)clickAction{
    if (self.buttonAction) {
        self.buttonAction();
    }
    [self removeFromSuperview];
}
- (void)dealloc{
    
}
@end
