//
//  YCVideoListVC.h
//  HuanLe
//
//  Created by lx on 15/5/21.
//  Copyright (c) 2015年 shengu. All rights reserved.
//  看视频页面（本地视频+录制视频）

#import <UIKit/UIKit.h>

//extern NSString *const kSegmentedMovieListNotification; // 看视频
//extern NSString *const kSegmentedTakeVideoNotification; // 摄像头

@interface YCVideoListVC : UIViewController
@property (nonatomic, strong) UITableView *tableview;
//@property (nonatomic, strong) TransformTableView *tableview;
@property (nonatomic, strong) NSMutableArray *listData; // 录制的视频数
@end
