//
//  WormPreviewPhotoCell.m
//  WormwormLife
//
//  Created by Rocco on 2018/9/14.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "WormPreviewPhotoCell.h"
#import <JMessage/JMessage.h>
#import "PrefixHeader.pch"
#import <SDWebImage/SDWebImageManager.h>
@interface WormPreviewPhotoCell() <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WormPreviewPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _zoomScale = 1;
        self.backgroundColor = [UIColor blackColor];
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.contentView addSubview:self.scrollView];
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imgView];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureAction:)];
    [self.scrollView addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureAction:)];
    [doubleTapGesture setNumberOfTapsRequired:2]; // Default is 1
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    
    // 如果满足双击条件，单击事件触发失败，防止双击时单击事件同时被触发
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

- (void)setImg:(id)img {
    if (!img) {
        return;
    }
    if ([img isKindOfClass:[NSString class]]) {
        NSString *imgStr = img;
        if ([imgStr containsString:@"http://"] || [imgStr containsString:@"https://"]) {//网络图片
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgStr]
                                                        options:SDWebImageAllowInvalidSSLCertificates
                                                       progress:nil
                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                          if (!error && image) {
                                                              [self scaleImageFrame:image];
                                                          }
            }];
        } else {
            [self scaleImageFrame:ImageNamed(imgStr)];
        }
    }
    if ([img isKindOfClass:[UIImage class]]) {
        [self scaleImageFrame:img];
    }
    if ([img isKindOfClass:[JMSGImageContent class]]) {
        JMSGImageContent *content = img;
        [content largeImageDataWithProgress:nil completionHandler:^(NSData *data, NSString *objectId, NSError *error) {
            if (!error && data) {
                [self scaleImageFrame:[UIImage imageWithData:data]];
            }
        }];
    }
}

- (void)scaleImageFrame:(UIImage *)image {
    self.imgView.image = image;
    CGFloat scale_W = SCREEN_WIDTH / image.size.width;
    
    CGSize size;
    size = CGSizeMake(SCREEN_WIDTH, scale_W * image.size.height);
    if (size.height > SCREEN_HEIGHT) {
        self.imgView.frame = CGRectMake(0, 0, size.width, size.height);
    } else {
        self.imgView.center = self.scrollView.center;
    }
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, size.height > SCREEN_HEIGHT ? size.height : SCREEN_HEIGHT);
}

- (void)setZoomScale:(CGFloat)zoomScale {
    _zoomScale = zoomScale;
    self.scrollView.zoomScale = _zoomScale;
}

- (void)setData:(NSMutableDictionary *)data {
    _data = data;
    self.zoomScale = [data[@"zoom"] floatValue];
    self.img = data[@"image"];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize viewSize = self.imgView.frame.size;
    CGPoint centerPoint;
    
    if (viewSize.width<=CGRectGetWidth(self.bounds) && viewSize.height<=CGRectGetHeight(self.bounds)) {
        centerPoint = CGPointMake(CGRectGetWidth(self.bounds)*0.5f, CGRectGetHeight(self.bounds)*0.5f);
        
    }else if (viewSize.width>=CGRectGetWidth(self.bounds) && viewSize.height>=CGRectGetHeight(self.bounds) ){
        centerPoint = CGPointMake(scrollView.contentSize.width*0.5f, scrollView.contentSize.height*0.5f);
        
    }else if (viewSize.width<=CGRectGetWidth(self.bounds) && viewSize.height>=CGRectGetHeight(self.bounds) ){
        centerPoint = CGPointMake(CGRectGetWidth(self.bounds)*0.5f, scrollView.contentSize.height*0.5f);
        
    }else if (viewSize.width>=CGRectGetWidth(self.bounds) && viewSize.height<=CGRectGetHeight(self.bounds)){
        centerPoint = CGPointMake(scrollView.contentSize.width*0.5f, CGRectGetHeight(self.bounds)*0.5f);
    }
    if (viewSize.height > SCREEN_HEIGHT) {
        self.imgView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    } else {
        self.imgView.center = self.scrollView.center;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)singleTapGestureAction:(UITapGestureRecognizer *)sender {
    
    self.singleTapEvent();
    
}

- (void)doubleTapGestureAction:(UITapGestureRecognizer *)sender {
    if (self.zoomScale == 3) {
        self.zoomScale = 1;
    }else {
        CGFloat newScale = self.zoomScale + 1.0;
        self.zoomScale = newScale;
    }
    _data[@"zoom"] = @(_zoomScale);
}

@end
