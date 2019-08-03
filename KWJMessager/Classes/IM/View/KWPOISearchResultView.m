// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "KWPOISearchResultView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "KWPOIItemCell.h"
#import "UITableView+NoDataView.h"
#import "PrefixHeader.pch"

@interface KWPOISearchResultView ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
    AMapSearchDelegate>
@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIView *searchBackView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) NSMutableArray *pois; //关键字POI列表
@property (nonatomic, strong) AMapSearchAPI *searchAPI;
@end

@implementation KWPOISearchResultView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.searchBar];
        [self.searchBar addSubview:self.searchBackView];
        [self.searchBar addSubview:self.inputField];
        [self.searchBar addSubview:self.cancelBtn];
        
        [self addSubview:self.maskView];
        [self addSubview:self.tableView];
    }
    return self;
}

- (UIView *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NaviBarHeight)];
        _searchBar.backgroundColor = KWhite;
    }
    return _searchBar;
}

- (UIView *)searchBackView {
    if (!_searchBackView) {
        _searchBackView = [[UIView alloc] initWithFrame:CGRectMake(12, NaviBarHeight - 36,
                                                                   SCREEN_WIDTH - 64, 28)];
        _searchBackView.backgroundColor = kBackGroundColor;
        _searchBackView.layer.cornerRadius = 14;
        _searchBackView.layer.masksToBounds = YES;
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_1"]];
        [_searchBackView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_searchBackView);
            make.left.equalTo(_searchBackView).offset(12);
        }];
    }
    return _searchBackView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectMake(42, self.searchBackView.top + 2, SCREEN_WIDTH - 106, 24)];
        _inputField.delegate = self;
        _inputField.placeholder = @"搜索地址";
        _inputField.font = kFont(13);
        _inputField.returnKeyType = UIReturnKeySearch;
    }
    return _inputField;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 52, self.searchBackView.top - 6, 52, 40)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:hexColor(@"333333") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = kFont(15);
        [_cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviBarHeight)];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 51;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[KWPOIItemCell class] forCellReuseIdentifier:@"cell"];
        [_tableView addNoDataViewImageName:@"no_tips" text:@"暂未搜索到您想要的结果"];
        [_tableView adjustNoDataTopPosition];
    }
    return _tableView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.tableView.frame];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.6;
        Weakify(self);
        [_maskView addTapGestureWithBlock:^{
            [weakself dismiss];
        }];
    }
    return _maskView;
}

- (NSMutableArray *)pois {
    if (!_pois) {
        _pois = [[NSMutableArray alloc] init];
    }
    return _pois;
}

- (AMapSearchAPI *)searchAPI {
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

- (void)show {
    self.hidden = NO;
    self.tableView.hidden = YES;
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self.inputField becomeFirstResponder];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pois.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMapPOI *poi = [self.pois safeObjectAtIndex:indexPath.row];
    KWPOIItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [cell bindModel:poi selected:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poi = [self.pois safeObjectAtIndex:indexPath.row];
    if (self.selectAtPOI) {
        self.selectAtPOI(poi);
    }
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.inputField resignFirstResponder];
        self.hidden = YES;
    }];
}

#pragma mark - 搜索框内容变化的回调

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self searchNearbyKeywords:newText];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchNearbyKeywords:textField.text];
    [self.inputField resignFirstResponder];
    return YES;
}

//开始关键字搜索
- (void)searchNearbyKeywords:(NSString *)keywords {
    AMapPOIKeywordsSearchRequest *req = [[AMapPOIKeywordsSearchRequest alloc] init];
    req.keywords = keywords;
    if (self.limitCity.length) {
        req.cityLimit = YES;
        req.city = self.limitCity;
    }else if(self.suguestCity.length) {
        req.cityLimit = NO;
        req.city = self.suguestCity;
    }
    req.offset = 50;//拉取50条
    //发起周边POI搜索
    [self.searchAPI cancelAllRequests];
    [self.searchAPI AMapPOIKeywordsSearch:req];
    [self.tableView hiddenNoDataView];
}

//POI搜索成功
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    [self.pois removeAllObjects];
    self.pois = [NSMutableArray arrayWithArray:response.pois];
    [self.tableView reloadData];
    if (self.pois.count == 0) {
        [self.tableView showNoDataView];
    }
//    self.tableView.hidden = self.pois.count==0;
    self.tableView.hidden = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

@end
