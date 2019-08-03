// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWPOI : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy)   NSString *address;
@property (nonatomic, assign) float zoomLevel;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)cor address:(NSString *)addr;

@end

NS_ASSUME_NONNULL_END
