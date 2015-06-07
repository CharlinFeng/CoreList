//
//  CoreListTableViewController.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListTableViewController.h"
#import "UIView+Masony.h"
#import "BaseTableViewCell.h"
#import "UIDevice+Extend.h"





@interface CoreListTableViewController ()

@end

@implementation CoreListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}









/** tableView数据源方法区 */

/** 共有多少行 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(self.dataList == nil) return 0;
    
    return self.dataList.count;
}

/** cell */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    BaseTableViewCell *cell = [[self listVC_View_Cell_Class] cellFromTableView:tableView];
    
    //取出模型
    cell.baseModel = self.dataList [indexPath.row];
    
    return cell;
}


/** cellH */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat cellH = [self listVC_CellH4IndexPath:indexPath];
    
    return cellH;
}




/** 刷新数据 */
-(void)reloadData{
    [self.tableView reloadData];
}

/** 动态刷新 */
-(void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{

    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
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
        [_tableView masViewAddConstraintMakeEqualSuperViewWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    return _tableView;
}





/** 父类值填充 */
-(UIScrollView *)scrollView{
    
    return self.tableView;
}



@end
