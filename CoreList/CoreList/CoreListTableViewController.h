//
//  CoreListTableViewController.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

@interface CoreListTableViewController : CoreListCommonVC<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;


@end
