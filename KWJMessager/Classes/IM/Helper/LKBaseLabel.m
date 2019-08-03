//
//  LKBaseLabel.m
//  WormwormLife
//
//  Created by 小屁孩 on 2018/10/18.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "LKBaseLabel.h"
#import <KWPublicUISDK/PublicHeader.h>
#import <KWOCMacroDefinite/KWOCMacro.h>
@interface LKBaseLabel()

@end

@implementation LKBaseLabel
- (instancetype)init{
    return [self initWithTextSize:0 isBold:NO];
}

- (instancetype)initWithTextSize:(CGFloat)textSize isBold:(BOOL)isBold{
    self = [super init];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        if (isBold) {
            [self initDataWithBoldTextSize:textSize];
        }else{
            [self initDataWithTextSize:textSize];
        }
    }
    return self;
}
- (void)initDataWithTextSize:(CGFloat)textSize{
    
    self.textColor = hexColor(@"333333");
    self.textAlignment = NSTextAlignmentLeft;
    self.font = textSize?kFont(textSize):kFont(15);
}
- (void)initDataWithBoldTextSize:(CGFloat)textSize{
    
    self.textColor = hexColor(@"333333");
    self.textAlignment = NSTextAlignmentLeft;
    self.font = textSize?kBoldFont(textSize):kBoldFont(15);
}

// 修改绘制文字的区域，edgeInsets增加bounds
-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    
    /*
     调用父类该方法
     注意传入的UIEdgeInsetsInsetRect(bounds, self.edgeInsets),bounds是真正的绘图区域
     */
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds,
                                                                 self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    //根据edgeInsets，修改绘制文字的bounds
    rect.origin.x -= self.edgeInsets.left;
    rect.origin.y -= self.edgeInsets.top;
    rect.size.width += self.edgeInsets.left + self.edgeInsets.right;
    rect.size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return rect;
}

//绘制文字
- (void)drawTextInRect:(CGRect)rect
{
    //令绘制区域为原始区域，增加的内边距区域不绘制
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
