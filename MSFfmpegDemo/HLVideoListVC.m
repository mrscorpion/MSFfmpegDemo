//
//  HLVideoListVC.m
//  HuanLe
//
//  Created by lx on 15/5/21.
//  Copyright (c) 2015年 shengu. All rights reserved.
//

#import "HLVideoListVC.h"
#import "HLWifiCell.h"

#import "KxMovieViewController.h"
#import "KxAudioManager.h"
#import "KxMovieDecoder.h"

//#import "HGMangerP2P.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YCMovieTableViewCell.h"

@interface HLVideoListVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *listData;
@property (nonatomic,strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSArray *groupTypes;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, assign) NSUInteger numberOfVideos;

@end

@implementation HLVideoListVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.parentTitle = kLCT(@"Video list");
    
    self.view.backgroundColor = [UIColor orangeColor];
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"conctrolBack"]];
//    [self.view addSubview:image];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(next)];
    [self.view addGestureRecognizer:tap];
    
//    
//    
//    self.groupTypes = @[
//                        @(ALAssetsGroupLibrary),
//                        @(ALAssetsGroupAlbum),
//                        @(ALAssetsGroupSavedPhotos),
//                        @(ALAssetsGroupPhotoStream)
//                        ];
//    [self loadAssetsGroups];
//    
//    
////    self.listData = [NSMutableArray arrayWithArray:[HGMangerP2P sharedInstance].videoList];
//    //[self.listData addObject:[self testFilePath]];
//    [self.view addSubview:self.tableview];
//    [self.tableview registerClass:[YCMovieTableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (void)next
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
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



//测试视频
-(NSString *)testFilePath{

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/李宇春-再不疯狂我们就老了-国语[mtvxz.cn].mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        NSString *str = [[NSBundle mainBundle] pathForResource:@"李宇春-再不疯狂我们就老了-国语[mtvxz.cn].mp4" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:str];
        [data writeToFile:filePath atomically:NO];
    }
    return filePath;

}

#pragma mark - get
-(UIImagePickerController *)imagePicker{

    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.mediaTypes =@[(NSString *)kUTTypeMovie];
       // _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.delegate = self;
    }

    return _imagePicker;

}


-(UITableView *)tableview{
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

#pragma mark - UITableViewDelegate&UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YCMovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[YCMovieTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    // 去掉cell选中变灰样式
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell.titleLabel.text = [self.listData[indexPath.row] lastPathComponent];
    ALAsset *asset = self.assetsArray[indexPath.row];
    NSLog(@"%@", self.assetsArray);
    cell.asset = asset; // ALAsset 内部转换
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL]; // 获取ALAsset中视频的URL
    cell.nameLabel.text = [[NSString stringWithFormat:@"%@", assetURL] lastPathComponent];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileStr = self.listData[indexPath.row];


        KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:fileStr parameters:nil];
        [self presentViewController:vc animated:YES completion:nil];


}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [[HGMangerP2P sharedInstance] deleteVideoFile:indexPath.row withBlock:^(BOOL isDelete) {
//            if (isDelete) {
//                self.listData = [HGMangerP2P sharedInstance].videoList;
//                [self.tableview reloadData];
//            }
//        }];
    }
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 50;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//
//    UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [locButton setTitle:unitized(@"local.video") forState:UIControlStateNormal];
//    [locButton addTarget:self action:@selector(clickedChoiceVideo:) forControlEvents:UIControlEventTouchUpInside];
//    locButton.backgroundColor = [UIColor colorWithRed:184/255. green:204./255. blue:234./255. alpha:0.2];
//    return locButton;}
//
//#pragma mark -------video selector
//-(void)clickedChoiceVideo:(UIButton *)sender{
//    [self presentViewController:self.imagePicker animated:YES completion:nil];
//}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
   // NSLog(@"----------%@",info);
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        //不是视频选择是败
        return;
    }
    //选中了视频，直接播放
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:^{
        
         KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:mediaURL.path parameters:nil];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
