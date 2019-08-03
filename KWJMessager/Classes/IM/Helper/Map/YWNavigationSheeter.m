//
//  YWNavigationSheeter.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2018/9/6.
//  Copyright © 2018年 张文彬. All rights reserved.
//  导航选择器

#import "YWNavigationSheeter.h"
#import <Masonry/Masonry.h>
#import <KWOCMacroDefinite/KWOCMacro.h>
#import <KWPublicUISDK/PublicHeader.h>
#import <KWCategoriesLib/NSArray+Safe.h>
#import <KWCategoriesLib/UIButton+ClickBounds.h>

@interface YWNavigationSheeter ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UITableView *sheetTable;
@property (nonatomic, copy) NSArray *dataArray;
@end

@implementation YWNavigationSheeter

static YWNavigationSheeter *instance = nil;
static dispatch_once_t onceToken;

/**
 单例
 @return return value description
 */
+ (instancetype)shared{
    dispatch_once(&onceToken, ^{
        instance = [[YWNavigationSheeter alloc] init];
    });
    return instance;
}

//单例销毁
+ (void)destroy{
    onceToken = 0;
    instance = nil;
}

- (instancetype)init{
    if (self = [super init]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.backView];
        [window addSubview:self.sheetTable];
        self.dataArray = [self avalibleMapApps];
        
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
        [self.sheetTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset([self tableHeight]);
            make.left.right.equalTo(window);
            make.top.equalTo(window.mas_bottom).offset(0);
        }];
        [window layoutIfNeeded];
    }
    return self;
}

- (void)showWithEndLocation:(CLLocationCoordinate2D)loc endPlaceName:(NSString *)name{
    self.endLocation = loc;
    self.endPlaceName = name;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //更新table位置约束（使其出现在可视区域）
    [self.sheetTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_bottom).offset(-[self tableHeight]);
    }];
    [UIView animateWithDuration:0.3f animations:^{
        [window layoutIfNeeded];//约束动画生效关键代码
        self.backView.alpha = 0.5;
    }];
}

- (void)dismiss{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    //更新table位置约束（使其平移出可视区域）
    [self.sheetTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_bottom).offset(0);
    }];
    [UIView animateWithDuration:0.3f animations:^{
        [window layoutIfNeeded];//约束动画生效关键代码
        self.backView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.sheetTable removeFromSuperview];
        self.backView = nil;
        self.sheetTable = nil;
        [YWNavigationSheeter destroy];
    }];
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        _backView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (UITableView *)sheetTable{
    if (!_sheetTable) {
        _sheetTable = [[UITableView alloc] init];
        _sheetTable.backgroundColor = [UIColor whiteColor];
        _sheetTable.dataSource = self;
        _sheetTable.delegate = self;
        _sheetTable.bounces = NO;
        _sheetTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_sheetTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _sheetTable;
}

- (CGFloat)tableHeight{
    CGFloat adapX = IsNotchScreen ? 34 : 0;
    return self.dataArray.count * 50 + 56 + adapX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    UILabel *itemLable = [[UILabel alloc] init];
    itemLable.textColor = hexColor(@"333333");
    itemLable.textAlignment = NSTextAlignmentCenter;
    itemLable.font = kFont(18);
    NSDictionary *itemDic = [self.dataArray safeObjectAtIndex:indexPath.row];
    itemLable.text = [[itemDic allValues] firstObject];
    [cell.contentView addSubview:itemLable];
    [itemLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = hexColor(@"f5f5f5");
    [cell.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(cell.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
    if (indexPath.row < self.dataArray.count - 1) {
        line.hidden = NO;
    }else{
        line.hidden = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *fengeLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 6)];
    fengeLine.backgroundColor = hexColor(@"f5f5f5");
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, 50)];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:hexColor(@"333333") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = kFont(18);
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56)];
    [foot addSubview:fengeLine];
    [foot addSubview:cancelBtn];
    
    return foot;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemDic = [self.dataArray safeObjectAtIndex:indexPath.row];
    NSString *map = [[itemDic allKeys] firstObject];
    if ([map isEqualToString:AppleMap]) {
        [self navAppleMap];
    }else if ([map isEqualToString:BaiduMap]){
        [self navBaiduMap];
    }else if ([map isEqualToString:GaodeMap]){
        [self navGaodeMap];
    }else if ([map isEqualToString:TengxunMap]){
        [self navTengxunMap];
    }
    [self dismiss];
}

/**
 返回本机安装的地图导航软件

 @return 数组
 */
- (NSArray *)avalibleMapApps{
    NSMutableArray *selectableNaviArr = [NSMutableArray array];
    // 遍历手机的地图软件
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"Apple地图" forKey:AppleMap];
        [selectableNaviArr addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"百度地图" forKey:BaiduMap];
        [selectableNaviArr addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"高德地图" forKey:GaodeMap];
        [selectableNaviArr addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"腾讯地图" forKey:TengxunMap];
        [selectableNaviArr addObject:dic];
    }
    return selectableNaviArr;
}


/**
 苹果地图导航
 */
- (void)navAppleMap
{
    //用户位置
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    //终点位置
    MKMapItem *toLocation = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.endLocation addressDictionary:nil] ];
    NSString *name = self.endPlaceName.length ? self.endPlaceName : @"目的地";
    toLocation.name = name;
    NSArray *items = @[currentLoc,toLocation];
    //第一个
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}


/**
 百度地图导航
 */
- (void)navBaiduMap{
    NSString *lon = [NSString stringWithFormat:@"%@",@(self.endLocation.longitude)];
    NSString *lat = [NSString stringWithFormat:@"%@",@(self.endLocation.latitude)];
    NSString *name = self.endPlaceName.length ? self.endPlaceName : @"目的地";
    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%@,%@|name:%@&mode=driving",lat,lon,name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


/**
 高德地图导航
 */
- (void)navGaodeMap{
    NSString *lon = [NSString stringWithFormat:@"%@",@(self.endLocation.longitude)];
    NSString *lat = [NSString stringWithFormat:@"%@",@(self.endLocation.latitude)];
    NSString *name = self.endPlaceName.length ? self.endPlaceName : @"目的地";
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&slat=&slon=&sname=&did=BGVIS2&dlat=%@&dlon=%@&dname=%@&dev=0&t=0",@"蜗蜗生活",@"wowolife",lat,lon,name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


/**
 腾讯地图导航
 */
- (void)navTengxunMap{
    NSString *lon = [NSString stringWithFormat:@"%@",@(self.endLocation.longitude)];
    NSString *lat = [NSString stringWithFormat:@"%@",@(self.endLocation.latitude)];
    NSString *name = self.endPlaceName.length ? self.endPlaceName : @"目的地";
    NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%@,%@&to=%@&coord_type=1&policy=0",lat, lon, name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
