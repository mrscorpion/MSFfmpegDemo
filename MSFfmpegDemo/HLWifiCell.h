//
//  HLWifiCell.h
//  HuanLe
//
//  Created by lx on 15/5/13.
//  Copyright (c) 2015年 shengu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLWifiCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *stateLabel;


+(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
