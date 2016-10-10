//
//  BaseCell.h
//  4s
//
//  Created by muxi on 15/3/11.
//  Copyright (c) 2015年 muxi. All rights reserved.
//  cell基类


#import <UIKit/UIKit.h>
#import "CoreListCellProtocol.h"
#import "CoreListTableViewController.h"

@interface CoreListTableViewCell : UITableViewCell<CoreListCellProtocol>

/** indexPath */
@property (nonatomic,weak) NSIndexPath *indexPath;
@property (nonatomic,weak) CoreListTableViewController *listVC;

/** 模型 */
@property (nonatomic,strong) CoreModel *model;




/** cell实例：必须从xib创建 */
+(CoreListTableViewCell *)dequeReuseCell:(UITableView *)tableView;


@end
