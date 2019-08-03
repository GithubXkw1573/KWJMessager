// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "KWLoactionMapSelector.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "YWLocationManager.h"
#import "KWPOIItemCell.h"
#import "KWPOISearchResultView.h"
#import <CoreLocation/CoreLocation.h>
#import "UITableView+NoDataView.h"
#import "PrefixHeader.pch"
#import <KWCategoriesLib/UIButton+ClickBounds.h>

@interface KWLoactionMapSelector ()<MAMapViewDelegate, UITableViewDelegate, UITableViewDataSource,
AMapSearchDelegate>
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UITableView *poiTableView;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) KWPOI *currLocation;
@property (nonatomic, strong) AMapSearchAPI *searchAPI;
@property (nonatomic, strong) NSMutableArray *pois; //周边POI列表
@property (nonatomic, assign) NSInteger currSelectIndex;
@property (nonatomic, strong) KWPOI *locPOI;//当前位置的坐标，固定
@property (nonatomic, strong) UIImageView *pinImageView;//大头针
@property (nonatomic, strong) KWPOISearchResultView *searchView;
@property (nonatomic, strong) AMapPOI *searchItemPoi;
@property (nonatomic, strong) NSString *locCityName;
@end

@implementation KWLoactionMapSelector

- (void)showSearch {
#pragma mark -- 进入搜索状态
    [self.view bringSubviewToFront:self.searchView];
    [self.searchView show];
}

- (void)sendAction {
#pragma mark -- 发送 按钮点击
    [self sendPOI];
}

- (void)locationAction {
#pragma mark -- 点击当前位置
    [self.mapView setCenterCoordinate:self.locPOI.coordinate animated:YES];
    self.currLocation = self.locPOI;
    //以中心点坐标开始搜索
    [self searchNearbyPOIs:self.locPOI.coordinate];
}

#pragma mark - getter and setter -

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [[UIButton alloc] init];
        [_searchBtn setImage:[UIImage imageNamed:@"location_search"] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        _sendBtn.backgroundColor = WormThemeColor;
        _sendBtn.layer.cornerRadius = 3;
        _sendBtn.layer.masksToBounds = YES;
        NSString *text = self.sureBtnText.length ? self.sureBtnText : @"发送";
        [_sendBtn setTitle:text forState:UIControlStateNormal];
        [_sendBtn setTitleColor:KWhite forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = kFont(16);
        [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] init];
        _mapView.showsUserLocation = YES;
        _mapView.showsScale = YES;
        _mapView.zoomLevel = 15;
        _mapView.delegate = self;
        _mapView.showsCompass = NO;
        [_mapView addSubview:self.locationBtn];
        [self.locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_mapView).offset(-12);
            make.bottom.equalTo(_mapView).offset(-18);
        }];
    }
    return _mapView;
}

- (UIButton *)locationBtn {
    if (!_locationBtn) {
        _locationBtn = [[UIButton alloc] init];
        [_locationBtn setImage:[UIImage imageNamed:@"location_map"] forState:UIControlStateNormal];
        [_locationBtn addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationBtn;
}

- (UIImageView *)pinImageView {
    if (!_pinImageView) {
        _pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buoy"]];
    }
    return _pinImageView;
}

- (UITableView *)poiTableView {
    if (!_poiTableView) {
        _poiTableView = [[UITableView alloc] init];
        _poiTableView.backgroundColor = KWhite;
        _poiTableView.dataSource = self;
        _poiTableView.delegate = self;
        _poiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_poiTableView registerClass:[KWPOIItemCell class] forCellReuseIdentifier:@"poi"];
        [_poiTableView addNoDataViewImageName:@"no_tips" text:@"抱歉，没有找到您周边信息"];
    }
    return _poiTableView;
}

- (KWPOISearchResultView *)searchView {
    if (!_searchView) {
        _searchView = [[KWPOISearchResultView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _searchView.hidden = YES;
        _searchView.limitCity = self.limitCity;
        Weakify(self)
        _searchView.selectAtPOI = ^(AMapPOI * _Nonnull poi) {
            #pragma mark -- 搜索选择的POI
            weakself.searchItemPoi = poi;
            CLLocationCoordinate2D cor = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            weakself.currLocation = nil;
            [weakself.mapView setCenterCoordinate:cor animated:YES];
            [weakself searchNearbyPOIs:cor];
        };
    }
    return _searchView;
}

- (AMapSearchAPI *)searchAPI {
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

- (NSMutableArray *)pois {
    if (!_pois) {
        _pois = [[NSMutableArray alloc] init];
    }
    return _pois;
}

#pragma mark - page cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigateSusviews];
    [self addMainUI];
    
    //开始定位
    [self startLocation];
}

#pragma mark - 私有方法 -
- (void)leftButtonAction:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addNavigateSusviews {
    [self.naviBar setTitleText:@"位置"];
    
    [self.naviBar addSubview:self.sendBtn];
    [self.naviBar addSubview:self.searchBtn];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.naviBar).offset(-6);
        make.right.equalTo(self.naviBar).offset(-12);
        make.size.mas_equalTo(CGSizeMake(57, 32));
    }];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendBtn);
        make.right.equalTo(self.sendBtn.mas_left).offset(-13);
    }];
    self.searchBtn.extendClickInsets = UIEdgeInsetsMake(10, 10, 10, 12);
}

- (void)addMainUI {
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.poiTableView];
    [self.mapView addSubview:self.pinImageView];
    [self.view addSubview:self.searchView];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.naviBar.mas_bottom);
        make.height.mas_equalTo(kHeight(283));
    }];
    [self.poiTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.mapView.mas_bottom);
    }];
    [self.pinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapView);
        make.centerY.equalTo(self.mapView).offset(-16);
    }];
}

//发起定位请求
- (void)startLocation {
    [[YWLocationManager shared] loactionWithResultBlock:^(YWLocationResult *result) {
        if (result.success) {
            KWPOI *poi = [[KWPOI alloc] init];
            poi.coordinate = result.location.coordinate;
            poi.address = result.regeocode.formattedAddress;
            self.currLocation = poi;
            self.locPOI = poi;
            self.locCityName = result.regeocode.city;
            self.searchView.suguestCity = self.locCityName;
            //设置默认当前定位位置作为地图中心点
            [self.mapView setCenterCoordinate:result.location.coordinate animated:YES];
            //开始搜索周边POI
            [self searchNearbyPOIs:result.location.coordinate];
        }else {
            if (result.authStatus == kCLAuthorizationStatusRestricted ||
                result.authStatus == kCLAuthorizationStatusDenied) {
                //引导开启定位权限
                [WormAlert popConfirmTitle:@"开启定位权限" message:@"需要开启定位权限以获取您的位置" actionAtIndex:^(NSInteger index) {
                    if (index == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
            }else {
                [self.poiTableView showNoDataView];
                Alert(@"未获取到当前位置，请检查网络是否良好，再重试");
            }
        }
    }];
}

//开始搜索附近POI
- (void)searchNearbyPOIs:(CLLocationCoordinate2D)coordinate {
    AMapPOIAroundSearchRequest *req = [[AMapPOIAroundSearchRequest alloc] init];
    AMapGeoPoint *point = [[AMapGeoPoint alloc] init];
    point.latitude = coordinate.latitude;
    point.longitude = coordinate.longitude;
    req.location = point;
    req.types = @"商务住宅|宾馆酒店|交通设施服务|商场|银行|风景名胜|综合医院|影剧院|标志性建筑物|热点地名|餐饮服务";
    req.offset = 50;
    req.sortrule = 1;
    req.requireExtension = YES;
    //发起周边POI搜索
    [self.searchAPI AMapPOIAroundSearch:req];
    [self.pois removeAllObjects];
    [self.poiTableView reloadData];
    [self.poiTableView hiddenNoDataView];
}

- (void)searchReGeocode:(CLLocationCoordinate2D)coordinate {
    AMapReGeocodeSearchRequest *req = [[AMapReGeocodeSearchRequest alloc] init];
    AMapGeoPoint *point = [[AMapGeoPoint alloc] init];
    point.latitude = coordinate.latitude;
    point.longitude = coordinate.longitude;
    req.location = point;
    //发起逆地理信息请求
    [self.searchAPI AMapReGoecodeSearch:req];
}

- (void)sendPOI {
    id item = [self.pois safeObjectAtIndex:self.currSelectIndex];
    if (!item) {
        Alert(@"请选择一个位置");
        return;
    }
    KWPOI *selectPOI = nil;
    if ([item isKindOfClass:[AMapPOI class]]) {
        AMapPOI *poi = item;
        KWPOI *myPoi = [KWPOI new];
        myPoi.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        myPoi.address = poi.name;
        selectPOI = myPoi;
    }else {
        selectPOI = item;
    }
    selectPOI.zoomLevel = self.mapView.zoomLevel;
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.resultData) {
            self.resultData(selectPOI);
        }
    }];
}

//大头针选择动画
- (void)pinReSelectAnimate {
    [self.pinImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mapView).offset(-35);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.mapView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.pinImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mapView).offset(-16);
        }];
        [UIView animateWithDuration:0.4 delay:0.1 usingSpringWithDamping:0.7
              initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.mapView layoutIfNeeded];
                         } completion:nil];
    }];
}

- (NSArray *)sortedPOIList:(NSArray<AMapPOI *> *)pois {
    NSMutableArray *foodList = [NSMutableArray array];
    NSMutableArray *otherList = [NSMutableArray array];
    for (AMapPOI *p in pois) {
        if ([p.type containsString:@"餐饮"]) {
            [foodList addObject:p];
        }else {
            [otherList addObject:p];
        }
    }
    [otherList addObjectsFromArray:foodList];
    return otherList;
}

#pragma mark - 周边POI搜索结果回调

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        //逆地理请求失败
        AMapReGeocodeSearchRequest *regeo = request;
        KWPOI *poi = [[KWPOI alloc] init];
        poi.coordinate = CLLocationCoordinate2DMake(regeo.location.latitude, regeo.location.longitude);
        self.currLocation = nil;
        //以中心点坐标开始搜索
        [self searchNearbyPOIs:poi.coordinate];
    }else {
        //附近POI搜索失败
        if (self.searchItemPoi) {
            [self.pois removeAllObjects];
            [self.pois addObject:self.searchItemPoi];
            self.currSelectIndex = 0;
            [self.poiTableView reloadData];
        }else {
            [self.poiTableView showNoDataView];
        }
    }
}
//附近POI搜索成功
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    [self.pois removeAllObjects];
    self.pois = [NSMutableArray arrayWithArray:[self sortedPOIList:response.pois]];
    //把当前定位放在第一个位置
    if (self.currLocation) {
        [self.pois insertObject:self.currLocation atIndex:0];
    }
    if (self.searchItemPoi) {
        //如果有搜索，把搜索选择的放第一个位置
        [self.pois insertObject:self.searchItemPoi atIndex:0];
    }
    self.currSelectIndex = 0;
    [self.poiTableView reloadData];
}
//逆地理信息请求成功
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    KWPOI *poi = [[KWPOI alloc] init];
    poi.coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    poi.address = response.regeocode.formattedAddress;
    self.currLocation = poi;//更新当前位置
    //以中心点坐标开始搜索
    [self searchNearbyPOIs:poi.coordinate];
}

#pragma mark - MAMapViewDelegate

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        //获取地图中心点坐标
        CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
        //以新的坐标搜索地址位置
        [self searchReGeocode:coordinate];
        //大头针动画
        [self pinReSelectAnimate];
        //清除搜索的POI
        self.searchItemPoi = nil;
    }
}

#pragma mark - UITableviweDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KWPOIItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi"];
    id model = [self.pois safeObjectAtIndex:indexPath.row];
    [cell bindModel:model selected:(indexPath.row == self.currSelectIndex)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 51;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currSelectIndex = indexPath.row;
    
    id model = [self.pois safeObjectAtIndex:indexPath.row];
    if ([model isKindOfClass:[AMapPOI class]]) {
        AMapPOI *poi = model;
        CLLocationCoordinate2D cor = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        [self.mapView setCenterCoordinate:cor animated:YES];
    }else {
        KWPOI *poi = model;
        CLLocationCoordinate2D cor = CLLocationCoordinate2DMake(poi.coordinate.latitude, poi.coordinate.longitude);
        [self.mapView setCenterCoordinate:cor animated:YES];
    }
    
    [self.poiTableView reloadData];
}

@end
