//
//  TDLocationResultCell.h
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const TDLocationResultCellReuseIdentifier;

@interface TDLocationResultCell : UITableViewCell

+ (instancetype)locationCellWithTableView:(UITableView *)tableView;

- (void)reloadData:(void(^)(UILabel *titleLabel, UILabel *descLabel))handleBlock;

@end


