//
//  WormPreviewPhotoCell.h
//  WormwormLife
//
//  Created by Rocco on 2018/9/14.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WormPreviewPhotoCell : UICollectionViewCell

@property (nonatomic, strong) id img;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) void(^singleTapEvent)(void) ;

@end
