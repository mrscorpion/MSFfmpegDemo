//
//  HLWifiCell.m
//  HuanLe
//
//  Created by lx on 15/5/13.
//  Copyright (c) 2015年 shengu. All rights reserved.
//

#import "HLWifiCell.h"

@implementation HLWifiCell

- (void)awakeFromNib {
    // Initialization code
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:195.f/255 green:183.f/255 blue:209.f/255 alpha:1];
        self.titleLabel.frame = CGRectMake(10, 5, 200, 40);
        self.stateLabel.frame = CGRectMake(320 - 80, 10, 80, 30);
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.stateLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - get
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:19];//kFontForBody;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor whiteColor];
       //_titleLabel.adjustsFontSizeToFitWidth = YES;

    }
    return _titleLabel;
}

-(UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:19];//kBoldFontForBody;
        _stateLabel.textAlignment = NSTextAlignmentLeft;
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.textColor = [UIColor colorWithRed:226.f/255 green:209.f/255 blue:227.f/255 alpha:1];
        _stateLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _stateLabel;
}

+(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
@end
