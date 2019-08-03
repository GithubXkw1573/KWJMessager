// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "KWPOI.h"

@implementation KWPOI

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)cor address:(NSString *)addr {
    if (self = [super init]) {
        self.coordinate = cor;
        self.address = addr;
    }
    return self;
}

@end
