//
//  WormImgPreviewController.m
//  WormwormLife
//
//  Created by Rocco on 2018/9/14.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "WormImgPreviewController.h"
#import "WormPreviewPhotoCell.h"
#import "PrefixHeader.pch"

@interface WormImgPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *naviView;
@property (nonatomic, strong) UIView *naviContentView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *indexLab;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation WormImgPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex = _index;
    [self setupDataSource];
    [self setupNaviView];
    [self setupCollectionView];
    [self.view bringSubviewToFront:_naviView];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupNaviView {
    self.naviBar.hidden = YES;
    [self.view addSubview:self.naviView];
    [self.naviView addSubview:self.naviContentView];
    [self.naviContentView addSubview:self.closeBtn];
    [self.naviContentView addSubview:self.indexLab];
    
    [self.naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.view);
        make.height.offset(NaviBarHeight);
    }];
    
    [self.naviContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.naviView);
        make.height.offset(44);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.naviContentView);
        make.left.equalTo(self.naviContentView).offset(24);
        make.height.and.width.offset(19);
    }];
    
    [self.indexLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.naviContentView);
    }];
    _indexLab.text = [NSString stringWithFormat:@"%ld/%ld", _currentIndex + 1, _previewArray.count];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[WormPreviewPhotoCell class] forCellWithReuseIdentifier:@"WormPreviewPhotoCell"];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
    [self.view addSubview:self.collectionView];
}

- (void)setupDataSource {
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < _previewArray.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[_previewArray safeObjectAtIndex:i] forKey:@"image"];
        [dic setObject:@(1.0) forKey:@"zoom"];
        [_dataSource addObject:dic];
    }
}

#pragma mark- UICollectionViewDelegate DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.previewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dic = [_dataSource safeObjectAtIndex:indexPath.row];
    WormPreviewPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WormPreviewPhotoCell" forIndexPath:indexPath];
    cell.data = dic;
//    Weakify(self);
    cell.singleTapEvent = ^(){
//        weakself.naviView.hidden = !weakself.naviView.hidden;
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dic = [_dataSource safeObjectAtIndex:indexPath.row];
    WormPreviewPhotoCell *photoCell = (WormPreviewPhotoCell *)cell;
    photoCell.data = dic;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x / SCREEN_WIDTH;
    NSInteger page = 1;
    if (offset < 1 - 0.5) {
        page = 1;
    } else if (offset > self.previewArray.count - 1) {
        page = self.previewArray.count;
    } else {
        page = roundf(offset) + 1;
    }
    self.indexLab.text = [NSString stringWithFormat:@"%@/%@", @(page), @(self.previewArray.count)];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)scrollView.contentOffset.x / SCREEN_WIDTH;
//    self.indexLab.text = [NSString stringWithFormat:@"%lu/%lu",index  + 1,(unsigned long)self.previewArray.count];
    if (index != _currentIndex) {
        NSMutableDictionary *dic = [_dataSource safeObjectAtIndex:_currentIndex];
        if ([dic[@"zoom"] floatValue] != 1.0) {
            dic[@"zoom"] = @(1.0);
        }
        _currentIndex = index;
    }
}

- (UIView *)naviView {
    if (!_naviView) {
        _naviView = [UIView new];
        _naviView.backgroundColor = [UIColor clearColor];
    }
    return _naviView;
}

- (UIView *)naviContentView {
    if (!_naviContentView) {
        _naviContentView = [UIView new];
    }
    return _naviContentView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:ImageNamed(@"no") forState:UIControlStateNormal];
        [_closeBtn setImage:ImageNamed(@"no") forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(dismiessPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UILabel *)indexLab {
    if (!_indexLab) {
        _indexLab = [UILabel new];
        _indexLab.textColor = [UIColor whiteColor];
        _indexLab.font = kFont(18);
    }
    return _indexLab;
}

- (void)dismiessPage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
