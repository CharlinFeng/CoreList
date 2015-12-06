//
//  CoreListTableViewController.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListTableViewController.h"
#import "CoreListTableViewCell.h"
#import "CoreListConst.h"
#import "UIView+CoreListLayout.h"


@interface CoreListTableViewController ()

@end

@implementation CoreListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[[UIView alloc] init];
    self.tableView.rowHeight = 60;
}









/** tableView数据源方法区 */

/** 共有多少行 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.dataList == nil) return 0;
    
    return self.dataList.count;
}

/** cell */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    CoreListTableViewCell *cell = [[self listVC_View_Cell_Class] dequeReuseCell:tableView];
    
    NSInteger row = indexPath.row; if(row >= self.dataList.count) row = 0;
    
    //取出模型
    cell.model = self.dataList [row];
    
    return cell;
}





/** 刷新数据 */
-(void)reloadData{
    [self.tableView reloadData];
}


/** tableView */
-(UITableView *)tableView{
    
    if(_tableView == nil){
        
        _tableView = [[UITableView alloc] init];
        
        //设置数据源
        _tableView.dataSource = self;
        
        //设置代理
        _tableView.delegate = self;
        
        [self.view addSubview:_tableView];
        
        CGFloat topPadding = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        if(ios7x) _tableView.contentInset = UIEdgeInsetsMake(topPadding, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(-topPadding, 0);
        
        //添加约束
        [_tableView autoLayoutFillSuperView];
    }
    
    return _tableView;
}





/** 父类值填充 */
-(UIScrollView *)scrollView{
    
    return self.tableView;
}



@end
