//
//  ViewController.m
//  MSFfmpegDemo
//
//  Created by 清风 on 16/7/20.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "ViewController.h"
#import "KxMovieViewController.h"
#import "YCVideoListVC.h"
#import "HLVideoListVC.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(next)];
    [self.view addGestureRecognizer:tap];
//    NSString *path = @"http://192.168.2.13/test/1avi.avi";
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    // increase buffering for .wmv, it solves problem with delaying audio frames
//    if ([path.pathExtension isEqualToString:@"wmv"])
//        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
//    
//    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
//    
//    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
//                                                                               parameters:parameters];
//    [self presentViewController:vc animated:YES completion:nil];
}
- (void)next
{
//    YCVideoListVC *video = [[YCVideoListVC alloc] init];
    HLVideoListVC *video = [[HLVideoListVC alloc] init];
    [self presentViewController:video animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
