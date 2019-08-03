//
//  shopMapViewController.m
//  WormwormLife
//
//  Created by 李亚飞 on 2018/2/27.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "shopMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "YWNavigationSheeter.h"
#import <KWOCMacroDefinite/KWOCMacro.h>
#import <KWLogger/KWLogger.h>
#import <KWPublicUISDK/PublicHeader.h>
#import <KWCategoriesLib/NSArray+Safe.h>
#import <KWCategoriesLib/UIView+Common.h>
#import <Masonry.h>

#define kStartTitle     @"起点"
#define kEndTitle       @"终点"

@interface shopMapViewController ()<MAMapViewDelegate,CLLocationManagerDelegate,AMapSearchDelegate,MAOverlay,AMapLocationManagerDelegate>

@property(nonatomic,strong)MAMapView *mapView;

@property(nonatomic,assign) CGFloat currentZoomLevel;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAPolyline *line;
@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong)MAPointAnnotation *serviceAnnotation;
@end

@implementation shopMapViewController

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer * polyLine = [[MAPolylineRenderer alloc]initWithPolyline:(MAPolyline *)overlay];
        //设置属性
        //设置线宽
        polyLine.lineWidth = 8;
        //设置填充颜色
        polyLine.fillColor = [UIColor redColor];
        //设置笔触颜色
        polyLine.strokeColor = hexColor(@"00b5ff");
        //设置断点类型
        polyLine.lineCapType = kMALineCapRound;
        return polyLine;
        
    }
    return nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mapView selectAnnotation:self.serviceAnnotation animated:YES];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.naviBar.hidden = YES;
    [self createMapView];
    [self creatNavigation];
    if (self.lat.length && self.lng.length) {
        self.latitude = [self.lat doubleValue];
        self.longitude = [self.lng doubleValue];
        //现在已经知道了经纬度
        [self initAnnotations];
        //创建当前用户的地址并划线
        [self initUserSite];
    }else {
        //创建店铺大头针,根据详细地址去搜索
        [self initShopSite];
    }
}

- (void)creatNavigation {
    UIButton *_topBackButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _topBackButton.frame=CGRectMake(10, 30, 30, 30);
    [_topBackButton setImage:[UIImage imageNamed:@"signBack"] forState:UIControlStateNormal];
    _topBackButton.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.3];
    [_topBackButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _topBackButton.layer.cornerRadius=15;
    _topBackButton.clipsToBounds=YES;
    [self.view addSubview:_topBackButton];
}

- (void)initUserSite {
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

//店铺地址
- (void)initShopSite {
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    AMapPOIKeywordsSearchRequest *geo = [[AMapPOIKeywordsSearchRequest alloc] init];
    geo.keywords = [NSString stringWithFormat:@"%@%@%@%@", String_NotNil(_addressProvince), String_NotNil(_addressCity), String_NotNil(_addressDistrict), String_NotNil(_addressStr)];
    DDLogDebug(@"搜索地址：%@",geo.keywords);
    [self.search AMapPOIKeywordsSearch:geo];
}


- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D coor=CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    pointAnnotation.coordinate =coor;
   pointAnnotation.title = kStartTitle;
    [self.mapView addAnnotation:pointAnnotation];
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    navi.requireExtension = YES;
 
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude
                                           longitude:location.coordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:_latitude
                                                longitude:_longitude];
    
    [self.search AMapDrivingRouteSearch:navi];
    
    [self.locationManager stopUpdatingLocation];

}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    DDLogDebug(@"Error: %@", error);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0) {
        return;
    }
    AMapPOI *poi = [response.pois firstObject];
    _latitude = poi.location.latitude;
    _longitude = poi.location.longitude;
    DDLogDebug(@"搜索出来的经纬度：%@，%@",@(_latitude), @(_longitude));
    [self initAnnotations];
    //创建当前用户的地址并划线
    [self initUserSite];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if (response.geocodes.count == 0) {
        return;
    }
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        _latitude=obj.location.latitude;
        _longitude=obj.location.longitude;
        DDLogDebug(@"搜索出来的经纬度：%@，%@",@(_latitude), @(_longitude));
        [self initAnnotations];
        //创建当前用户的地址并划线
        [self initUserSite];
    }];
}

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    if (response.route == nil) {
        return;
    }
    if (response.count > 0) {
        AMapPath *path = [response.route.paths safeObjectAtIndex:0]; //选择一条路径
        [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
            NSUInteger count = 0;
            CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                             coordinateCount:&count
                                                                  parseToken:@";"];
            
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [self.mapView addOverlay:polyline];
        _mapView.selectedAnnotations = @[_serviceAnnotation];
        free(coordinates), coordinates = NULL;
        }];
    }
}

//解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token {
    if (string == nil) {
        return NULL;
    }
    
    if (token == nil) {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","]) {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    } else {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL) {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components safeObjectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components safeObjectAtIndex:2 * i + 1] doubleValue];
    }
    return coordinates;
}

- (void)createMapView {
    
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), SCREEN_HEIGHT)];
    //地图视图加到主视图
    [self.view addSubview:_mapView];
    //地图的缩放
    [_mapView setZoomLevel:15 animated:YES];
    _currentZoomLevel = 15;
    //设置MapView的委托为自己
    _mapView.rotateEnabled = NO;
    self.mapView.delegate = self;
    
    //创建定位按钮
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(15, SCREEN_HEIGHT-30 - 32, 32, 32);
    [locationButton setImage:[UIImage imageNamed:@"location_point"] forState:UIControlStateNormal];
    [locationButton setBackgroundColor:[UIColor whiteColor]];
    [locationButton addTarget:self action:@selector(refreshButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(16, SCREEN_HEIGHT-30 - 31, 30, 30);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(1.5, 2);
    layer.shadowOpacity = 0.2;
    layer.cornerRadius = 2;

    [self.view.layer addSublayer:layer];
    [self.view addSubview:locationButton];
    locationButton.layer.masksToBounds =YES;
    locationButton.layer.cornerRadius =2;
    //创建放大缩小按钮
    
    UIButton *miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
    miniButton.frame = CGRectMake(SCREEN_WIDTH - 15 - 32, SCREEN_HEIGHT-10 - 32, 32, 32);
    
    [miniButton setImage:[UIImage imageNamed:@"location_narrow"] forState:UIControlStateNormal];
    [miniButton setBackgroundColor:[UIColor whiteColor]];
    [miniButton addTarget:self action:@selector(miniMapView) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *layer1 = [CALayer layer];
    layer1.frame = CGRectMake(SCREEN_WIDTH - 14 - 32, SCREEN_HEIGHT-10 - 31, 30, 30);
    layer1.backgroundColor = [UIColor blackColor].CGColor;
    layer1.shadowOffset = CGSizeMake(1.5, 2);
    layer1.shadowOpacity = 0.2;
    layer1.cornerRadius = 2;
    
    [self.view.layer addSublayer:layer1];
    [self.view addSubview:miniButton];
    miniButton.layer.masksToBounds =YES;
    miniButton.layer.cornerRadius =2;
    
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(miniButton.left, miniButton.top - 32 - 10, 32, 32);
    
    [plusButton setImage:[UIImage imageNamed:@"location_enlarge"] forState:UIControlStateNormal];
    [plusButton setBackgroundColor:[UIColor whiteColor]];
    [plusButton addTarget:self action:@selector(enlagerMapView) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *layer11 = [CALayer layer];
    layer11.frame = CGRectMake(miniButton.left, miniButton.top - 31 - 10, 30, 30);
    layer11.backgroundColor = [UIColor blackColor].CGColor;
    layer11.shadowOffset = CGSizeMake(1.5, 2);
    layer11.shadowOpacity = 0.2;
    layer11.cornerRadius = 2;
    
    [self.view.layer addSublayer:layer11];
    [self.view addSubview:plusButton];
    plusButton.layer.masksToBounds =YES;
    plusButton.layer.cornerRadius =2;
    
}


- (void)refreshButtonAction {
     CLLocationCoordinate2D coor=CLLocationCoordinate2DMake(_latitude, _longitude);
    [_mapView setCenterCoordinate:coor animated:YES];
}

- (void)enlagerMapView {
    _currentZoomLevel+=0.5;
   [_mapView setZoomLevel:_currentZoomLevel animated:YES];
}

- (void)miniMapView {
    _currentZoomLevel -=.5;
   [_mapView setZoomLevel:_currentZoomLevel animated:YES];
    
}
- (void)initAnnotations{
    _serviceAnnotation = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D coor=CLLocationCoordinate2DMake(_latitude, _longitude);
    _serviceAnnotation.coordinate =coor;
    _serviceAnnotation.title = kEndTitle;
    self.mapView.centerCoordinate =coor;
    [self.mapView addAnnotation:_serviceAnnotation];
}

//修复高德地图bug:当缩放一定级别后，终点气泡自动隐藏，后再也显示不出来的bug
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    if (wasUserAction && mapView.zoomLevel < 13) {
        [mapView deselectAnnotation:self.serviceAnnotation animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil) {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        poiAnnotationView.canShowCallout = YES;
        
//        /* 起点. */
        if ([[annotation title] isEqualToString:(NSString*)kStartTitle]) {
            poiAnnotationView.image = [UIImage imageNamed:@"location_origin"];
        }
//         终点.
        else if([[annotation title] isEqualToString:(NSString*)kEndTitle]) {
            poiAnnotationView.image = [UIImage imageNamed:@"location_finish"];
            UIView *bac = [[UIView alloc] initWithFrame:CGRectMake(0, 0 ,kWidth(260), 65)];
            bac.backgroundColor = [UIColor clearColor];
            bac.layer.cornerRadius = 2;
            
            UIView *contentView = [[UIView alloc] init];
            contentView.backgroundColor = [UIColor whiteColor];
            [bac addSubview:contentView];
            contentView.layer.cornerRadius = 2;
            contentView.layer.shadowColor = [hexColor(@"333333") CGColor];
            contentView.layer.shadowRadius = 4;
            contentView.layer.shadowOpacity = 0.2;
            contentView.layer.shadowOffset = CGSizeMake(0, 1);
            [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(bac);
                make.height.mas_equalTo(50);
            }];
            
            BOOL haveNavApps = [[YWNavigationSheeter shared] avalibleMapApps].count > 0 ;
            
            UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, kWidth(180), 50)];
            if (!haveNavApps) {
                leftL.width = kWidth(247);
            }
            leftL.font = [UIFont systemFontOfSize:12];
            leftL.numberOfLines = 2;
            leftL.textAlignment = NSTextAlignmentLeft;
            leftL.textColor = hexColor(@"999999");
            leftL.text = _addressStr;
            [contentView addSubview:leftL];
            
            UIImageView *trangle = [[UIImageView alloc] init];
            trangle.image = [UIImage imageNamed:@"guide_Triangle"];
            [bac addSubview:trangle];
            [trangle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(contentView);
                make.top.equalTo(contentView.mas_bottom).offset(0);
            }];
            
            if (haveNavApps) {
                UIButton *rightB = [[UIButton alloc] init];
                [rightB setBackgroundImage:[UIImage imageNamed:@"guide_nav_bg"] forState:UIControlStateNormal];
                [rightB setTitle:@"导航" forState:UIControlStateNormal];
                rightB.titleLabel.font = kFont(14);
                [rightB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [rightB setImage:[UIImage imageNamed:@"guide_navigation"] forState:UIControlStateNormal];
                [rightB setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
                [rightB setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
                [rightB addTarget:self action:@selector(showNavigate) forControlEvents:UIControlEventTouchUpInside];
                [contentView addSubview:rightB];
                [rightB mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(kWidth(70));
                    make.right.equalTo(contentView);
                    make.height.mas_equalTo(50);
                    make.top.equalTo(contentView);
                }];
            }
            MACustomCalloutView *bb = [[MACustomCalloutView alloc] initWithCustomView:bac];
            poiAnnotationView.customCalloutView = bb;
        }
        return poiAnnotationView;
    }
    return nil;
}

- (void)showNavigate {
    //导航
    [[YWNavigationSheeter shared] showWithEndLocation:
     CLLocationCoordinate2DMake(self.latitude,self.longitude) endPlaceName:self.addressStr];
}

- (CLLocationCoordinate2D)translateAddressWith:(NSString*)addressStr {
    return CLLocationCoordinate2DMake(_latitude,_longitude);
}

-(void)backButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}



@synthesize boundingMapRect;

@synthesize coordinate;

@end
