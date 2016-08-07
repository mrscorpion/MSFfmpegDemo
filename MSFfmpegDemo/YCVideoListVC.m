//
//  HLVideoListVC.m
//  HuanLe
//
//  Created by lx on 15/5/21.
//  Copyright (c) 2015年 shengu. All rights reserved.
//  看视频页面（本地视频+录制视频）

#import "YCVideoListVC.h"
#import "KxMovieViewController.h"
#import "KxAudioManager.h"
#import "KxMovieDecoder.h"
//#import "HGMangerP2P.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YCMovieTableViewCell.h"
//#import "JKAssets.h"
//#import "YCMovieViewController.h"
//#import "UIColor+UIColor_EXT.h"
//#import "HGVideoStram.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kTitleHeight 30

@interface YCVideoListVC ()
<
UITableViewDelegate,
UITableViewDataSource,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSArray *groupTypes;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, assign) NSUInteger numberOfVideos;
@end

@implementation YCVideoListVC
#pragma mark - get
- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}
- (UIImagePickerController *)imagePicker{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.mediaTypes =@[(NSString *)kUTTypeMovie];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

//- (TransformTableView *)tableView
- (UITableView *)tableview
{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 567) style:UITableViewStylePlain];
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [[UIView alloc] init];
    }
    return _tableview;
}

#pragma mark - 禁用IQKeyboard
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 刷新列表页
    NSLog(@"self.assetsArray.count:%lu, self.listData.count:%lu", (unsigned long)self.assetsArray.count, (unsigned long)self.listData.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[HGMangerP2P sharedInstance] writePowerOn:NO];
//    [[LGCentralManager sharedInstance].curPeripheral writePowerOn:NO];
//    [[CommandTool tool] setCrlType:ControlTypeNone];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//    self.parentTitle = kLCT(@"Video list");
    self.title = @"视频";
    self.view.backgroundColor = [UIColor blueColor];
    
//    self.listData = [NSMutableArray arrayWithArray:[HGMangerP2P sharedInstance].videoList];
    
    [self.view addSubview:self.tableview];
    self.tableview.backgroundColor = [UIColor lightTextColor];
    [self.tableview registerClass:[YCMovieTableViewCell class] forCellReuseIdentifier:@"cellID"];
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"blueCell"];
    // 去掉tableview底部分割线样式
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.groupTypes = @[
                        @(ALAssetsGroupLibrary),
                        @(ALAssetsGroupAlbum),
                        @(ALAssetsGroupSavedPhotos),
                        @(ALAssetsGroupPhotoStream)
                        ];
    [self loadAssetsGroups];
    
//    if ([HGMangerP2P sharedInstance].isConnect) {
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeVideoShow) name:kSegmentedTakeVideoNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieListShow) name:kSegmentedMovieListNotification object:nil];
//    }
}
- (void)movieListShow
{
//    self.listData = [NSMutableArray arrayWithArray:[HGMangerP2P sharedInstance].videoList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}
- (void)dealloc
{
//    if ([HGMangerP2P sharedInstance].isConnect) {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSegmentedTakeVideoNotification object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kSegmentedMovieListNotification object:nil];
//    }
}
- (void)loadAssetsGroups
{
    [self loadAssetsGroupsWithTypes:self.groupTypes completion:^(NSArray *assetsGroups) {
        NSLog(@"assetsGroups ----->  %@", assetsGroups);
        NSMutableArray *assets = [NSMutableArray array];
        __block NSUInteger numberOfVideos = 0;
        for (ALAssetsGroup *assetsGroup in assetsGroups) {
            [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSString *type = [result valueForProperty:ALAssetPropertyType];
                    if ([type isEqualToString:ALAssetTypeVideo]){
                        numberOfVideos++;
                    }
                    [assets addObject:result];
                }
            }];
        }
        self.assetsArray = assets;
        self.numberOfVideos = numberOfVideos;
        // Update view
        [self.tableview reloadData];
    }];
}
- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    for (NSNumber *type in types) {
        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue] usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
            if (assetsGroup) {
                // Filter the assets group // 筛选所有的视频
                [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                // Add assets group
                if (assetsGroup.numberOfAssets > 0) {
                    NSLog(@"assetsGroup ---> %@", assetsGroup);
                    // Add assets group
                    [assetsGroups addObject:assetsGroup];
                }
            } else {
                numberOfFinishedTypes++;
            }
            // Check if the loading finished
            if (numberOfFinishedTypes == types.count) {
                // Sort assets groups
                NSArray *sortedAssetsGroups = [self sortAssetsGroups:(NSArray *)assetsGroups typesOrder:types];
                // Call completion block
                if (completion) {
                    completion(sortedAssetsGroups);
                }
            }
        } failureBlock:^(NSError *error) {
        }];
    }
}
- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder
{
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }
        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
        
        for (NSInteger i = 0; i <= sortedAssetsGroups.count; i++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }
            ALAssetsGroup *sortedAssetsGroup = sortedAssetsGroups[i];
            ALAssetsGroupType sortedAssetsGroupType = [[sortedAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(sortedAssetsGroupType)];
            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }
    return sortedAssetsGroups;
}


#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // 本地视频
        return self.assetsArray.count;
    } else { // 录制视频
        return self.listData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        YCMovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
        if (!cell) {
            cell = [[YCMovieTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        }
        // 去掉cell选中变灰样式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ALAsset *asset = self.assetsArray[indexPath.row];
        NSLog(@"%@", self.assetsArray);
        cell.asset = asset; // ALAsset 内部转换
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL]; // 获取ALAsset中视频的URL
        cell.nameLabel.text = [[NSString stringWithFormat:@"%@", assetURL] lastPathComponent];
        return cell;
    } else {
        static NSString *identifer = @"blueCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = [self.listData[indexPath.row] lastPathComponent];
        // fileStr = /var/mobile/Containers/Data/Application/AA2F07D9-495A-4CE1-BC4F-8B7A6A4C20FB/Documents/movies/movie-2016-04-11-15:28:55.MOV
        NSLog(@"fileStr = %@", self.listData[indexPath.row]);
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        ALAsset *asset = self.assetsArray[indexPath.row];
        NSURL *fileUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
//        YCMovieViewController *movieVC = [[YCMovieViewController alloc] initWithLocalMediaURL:fileUrl];
//        movieVC.mediaTitle = [[NSString stringWithFormat:@"%@", fileUrl] lastPathComponent];
//        [self presentViewController:movieVC animated:NO completion:^{
//            [tool setCrlType:ControlTypeMusic];
//            [[LGCentralManager sharedInstance].curPeripheral writePowerOn:YES];
//            [[HGMangerP2P sharedInstance] writePowerOn:YES];
//        }];
        
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        NSString *fileName = [assetRep filename];
        // 测试
        NSString *urlStr = asset.defaultRepresentation.url.absoluteString;
        NSString *fileStr = [asset valueForProperty:ALAssetPropertyAssetURL];
//        NSLog(@"%@， urlstr-->%@, fileStr --> %@", asset, urlStr, fileStr);
//        
        KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:urlStr parameters:nil];
        [self presentViewController:vc animated:YES completion:^{
//            [tool setCrlType:ControlTypeMusic];
//            [[LGCentralManager sharedInstance].curPeripheral writePowerOn:YES];
//            [[HGMangerP2P sharedInstance] writePowerOn:YES];
        }];
    } else {
        NSString *fileStr = self.listData[indexPath.row];
        KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:fileStr parameters:nil];
        [self presentViewController:vc animated:YES completion:^{
//            [tool setCrlType:ControlTypeMusic];
//            [[LGCentralManager sharedInstance].curPeripheral writePowerOn:YES];
//            [[HGMangerP2P sharedInstance] writePowerOn:YES];
        }];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if ([LGCentralManager sharedInstance].curPeripheral.isConnected) { // 如果是蓝牙连接，只有看视频 不要录制视频一栏
//        if (section == 0) {
//            return kTitleHeight;
//        }
//        else {
//            return 0;
//        }
//    } else {
        return kTitleHeight; // WiFi连接
//    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 320 - 8, kTitleHeight)];
        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor hexStringToColor:@"#666666"];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"本地视频";
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kTitleHeight * 2)];
//        titleView.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
        [titleView addSubview:label];
//        UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        locButton.frame = titleView.frame;
//        [titleView addSubview:locButton];
//        [locButton setTitle:unitized(@"local.video") forState:UIControlStateNormal];
//        [locButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [locButton addTarget:self action:@selector(clickedChoiceVideo:) forControlEvents:UIControlEventTouchUpInside];
//        locButton.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:184/255. green:204./255. blue:234./255. alpha:0.2];
        return titleView;
    }
//    else {
//        return nil;
////        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kTitleHeight)];
////        titleView.backgroundColor = [UIColor hexStringToColor:@"#eeeeee"];
////        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, kMainScreenWidth - 8, kTitleHeight)];
////        [titleView addSubview:label];
////        label.backgroundColor = [UIColor clearColor];
////        label.textColor = [UIColor hexStringToColor:@"#666666"];
////        label.font = [UIFont systemFontOfSize:14];
////        label.text = @"录制视频";
////        return titleView;
//    }
    return nil; //titleView;
}


#pragma mark - delete删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [[HGMangerP2P sharedInstance] deleteVideoFile:indexPath.row withBlock:^(BOOL isDelete) {
//            if (isDelete) {
//                self.listData = [[HGMangerP2P sharedInstance].videoList mutableCopy];
//                [self.tableview reloadData];
//            }
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
