//
//  LKExpansionView.m
//  InputViewPractice
//
//  Created by 小屁孩 on 2019/3/7.
//  Copyright © 2019年 小屁孩. All rights reserved.
//

#import "LKExpansionView.h"
#import "LKIMToolCell.h"
#import "PrefixHeader.pch"
#define Item_Width (SCREEN_WIDTH - 12 * 5)/4.0
#define Item_Height 50
@interface LKExpansionView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArr;
@end
@implementation LKExpansionView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}
- (void)initData {
    NSDictionary *dic1 = @{
                           @"name":@"相册",
                           @"icon":@"im_photo",
                           @"type":@(LKInputBarActionTypePhotoLibrary)
                           };
    NSDictionary *dic2 = @{
                           @"name":@"拍照",
                           @"icon":@"im_camera",
                           @"type":@(LKInputBarActionTypeCamera)
                           };
    NSDictionary *dic3 = @{
                           @"name":@"定位",
                           @"icon":@"im_position",
                           @"type":@(LKInputBarActionTypeLocation)
                           };
    self.dataArr = @[dic1,dic2,dic3];
    if (self.dataArr.count > 4) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 130 + NaviBarHeight - 64);
    }else {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100 + NaviBarHeight - 64);
    }
}
- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}

#pragma mark- --------collectonDataSource and Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LKIMToolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LKIMToolCell" forIndexPath:indexPath];
    cell.model = [self.dataArr safeObjectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataArr safeObjectAtIndex:indexPath.row];
    if (self.clickIndexBlock) {
        self.clickIndexBlock([dic[@"type"] integerValue]);
    }
}

#pragma mark ------ 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(Item_Width, Item_Height);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[LKIMToolCell class] forCellWithReuseIdentifier:@"LKIMToolCell"];
        _collectionView.contentInset = UIEdgeInsetsMake(12, 12, 12 + NaviBarHeight - 64, 12);
    }
    return _collectionView;
}



@end
