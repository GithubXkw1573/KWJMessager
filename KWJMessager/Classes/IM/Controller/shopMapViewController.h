//
//  shopMapViewController.h
//  WormwormLife
//
//  Created by 李亚飞 on 2018/2/27.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "YWBaseViewController.h"
#import <KWBaseViewController/YWBaseViewController.h>

@interface shopMapViewController : YWBaseViewController

@property (nonatomic,copy) NSString *addressStr;
@property (nonatomic,copy) NSString *lat;
@property (nonatomic,copy) NSString *lng;
@property (nonatomic,copy) NSString *addressProvince;
@property (nonatomic,copy) NSString *addressCity;
@property (nonatomic,copy) NSString *addressDistrict;


@end
