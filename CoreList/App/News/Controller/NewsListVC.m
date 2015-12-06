//
//  NewsListVC.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NewsListVC.h"
#import "NewsListModel.h"
#import "NewsListCell.h"




@interface NewsListVC ()


@end

@implementation NewsListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.NetWorkErrorAction = ^{
        
        NSLog(@"错误处理");
    };
    
    self.tableView.rowHeight = 60;
//
    
//    self.shyNavBarOff = YES;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIViewController *vc = [[UIViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}



/** 协议方法区 */


/** 刷新方式 */
-(ListVCRefreshAddType)listVC_RefreshType{

    return ListVCRefreshAddTypeBoth;
}


/** 模型类 */
-(Class)listVC_Model_Class{
    return [NewsListModel class];
}


/** 视图类 */
-(Class)listVC_View_Cell_Class{
    return [NewsListCell class];
}

/** 请求参数 */
-(NSDictionary *)listVC_Request_Params{
    return nil;
    return @{@"mobile":@"13540033473",@"user":@"admin"};
}

/** 忽略参数 */
-(NSArray *)listVC_Ignore_Params{
    return nil;
}

/** 是否移除回到顶部按钮 */
-(BOOL)listVC_Remove_Back2Top_Button{
    return NO;
}


/** tableViewController */
/** cell的行高：tableViewController专用 */
-(CGFloat)listVC_CellH4IndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

/** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
-(NSString *)listVC_Update_Delay_Key{
    return NSStringFromClass([self class]);
}


/** 是否关闭返回顶部功能 */
-(BOOL)removeBack2TopBtn{
    return NO;
}

@end
