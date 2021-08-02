//
//  TDLocationResultCell.m
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDLocationResultCell.h"

NSString * const TDLocationResultCellReuseIdentifier = @"TDLocationResultCellReuseIdentifier";

@interface TDLocationResultCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation TDLocationResultCell

+ (instancetype)locationCellWithTableView:(UITableView *)tableView {
    
    TDLocationResultCell *cell = [tableView dequeueReusableCellWithIdentifier:TDLocationResultCellReuseIdentifier];
    if (!cell) {
        cell = [[TDLocationResultCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:TDLocationResultCellReuseIdentifier];
        [cell configUI];
    }
    return cell;
}

- (void)reloadData:(void(^)(UILabel *titleLabel, UILabel *descLabel))handleBlock {
    
    if (handleBlock) {
        handleBlock(_titleLabel,_descLabel);
    }
    
}

- (void)configUI {
    
    _icon = ({
        UIImageView *icon = [[UIImageView alloc]init];
        icon.image = [UIImage imageNamed:@"icon_cell_location"];
        [self.contentView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(15.f);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        icon;
    });
    
    _titleLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:17.f];
//        label.textColor = UIColor.color;
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(8.f);
            make.left.equalTo(_icon.mas_right).offset(20.f);
        }];
        label;
    });
    
    _descLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:12.f];
//        label.textColor = TDRGBHex(0x333333);
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-8.f);
            make.left.equalTo(_titleLabel.mas_left);
        }];
        label;
    });
}

@end
