//
//  YCMovieTableViewCell.m
//  HuanLe
//
//  Created by mr.scorpion on 16/4/2.
//  Copyright © 2016年 shengu. All rights reserved.
//

#import "YCMovieTableViewCell.h"

@implementation YCMovieTableViewCell
//- (void)prepareForReuse {
//    [super prepareForReuse];
//    self.contentView.transform = CGAffineTransformMakeScale(self.miniumScale, self.miniumScale);
//}
//- (void)transformCellForScale:(float)scale {
//    self.contentView.transform = CGAffineTransformMakeScale(1.0 - scale, 1.0 - scale);
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self movieImageView];
        [self nameLabel];
        [self line];
        
//        self.miniumScale = 0.85;
    }
    return self;
}

#pragma mark - setter/getter
- (void)setAsset:(ALAsset *)asset
{
    if (_asset != asset) {
        _asset = asset;
        CGImageRef thumbnailImageRef = [asset thumbnail];
        if (thumbnailImageRef) {
            self.movieImageView.image = [UIImage imageWithCGImage:thumbnailImageRef];
            self.img = [UIImage imageWithCGImage:thumbnailImageRef];
        } else {
            self.movieImageView.image = [UIImage imageNamed:@"assets_placeholder_picture"];
        }
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL]; // 获取ALAsset中视频的URL
        NSError *error = nil;
        self.nameLabel.text = [NSString stringWithContentsOfURL:assetURL encoding:NSUTF8StringEncoding error:&error];
    }
}
- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
}

- (UIImageView *)movieImageView
{
    if (!_movieImageView) {
        _movieImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        _movieImageView.backgroundColor = [UIColor clearColor];
        _movieImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_movieImageView];
    }
    return _movieImageView;
}
- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        CGFloat labelW = 320 - 50 - 20;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, labelW, 40)];
        _nameLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, 320, 1)];
//        _line.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [self.contentView addSubview:_line];
    }
    return _line;
}
@end
