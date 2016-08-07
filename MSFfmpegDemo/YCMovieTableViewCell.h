//
//  YCMovieTableViewCell.h
//  HuanLe
//
//  Created by mr.scorpion on 16/4/2.
//  Copyright © 2016年 shengu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import "TransformTableView.h"

@class YCMovieTableViewCell;

@protocol YCMovieTableViewCellDelegate <NSObject>
@optional
- (void)startPhotoAssetsViewCell:(YCMovieTableViewCell *)assetsCell;
- (void)didSelectItemAssetsViewCell:(YCMovieTableViewCell *)assetsCell;
- (void)didDeselectItemAssetsViewCell:(YCMovieTableViewCell *)assetsCell;
@end

@interface YCMovieTableViewCell : UITableViewCell//<TransformCell>
//@property (nonatomic, assign) float miniumScale;

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL    isSelected;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIImageView *movieImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, weak) id<YCMovieTableViewCellDelegate>  delegate;
@end
