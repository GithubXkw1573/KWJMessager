//
//  LKExpansionView.h
//  InputViewPractice
//
//  Created by 小屁孩 on 2019/3/7.
//  Copyright © 2019年 小屁孩. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, LKInputBarActionType) {
    LKInputBarActionTypePhotoLibrary,//相册
    LKInputBarActionTypeCamera,//拍照
    LKInputBarActionTypeLocation, //定位
};
@interface LKExpansionView : UIView

@property (nonatomic, copy)  void (^ clickIndexBlock)(LKInputBarActionType type);

@end

