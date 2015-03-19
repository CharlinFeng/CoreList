//
//  ListTVC.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "ShopListTVC.h"
#import "ShopModel.h"
#import "ShopListCell.h"

@interface ShopListTVC ()

@end

@implementation ShopListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"表格列表";
    
    //模型配置
    [self config];
    
    //去除多余的边线
//    self.tableView.tableFooterView=[[UIView alloc] init];
}

/**
 *  模型配置
 */
-(void)config{
    
    LTConfigModel *configModel=[[LTConfigModel alloc] init];
    //url
    NSString *url=@"http://218.244.141.72:8080/carnet/driver.php?m=Driver&c=User&a=test_fy";
    url=@"http://localhost/APPlist.php";
    configModel.url=url;
    //请求方式
    configModel.httpMethod=LTConfigModelHTTPMethodPOST;
    //模型类
    configModel.ModelClass=[ShopModel class];
    //cell类
    configModel.ViewForCellClass=[ShopListCell class];
    //标识
    configModel.lid=NSStringFromClass(self.class);
    //pageName
    configModel.pageName=@"p";
    //pageSizeName
    configModel.pageSizeName=@"pagesize";
    //起始页码
    configModel.pageStartValue=0;
    //行高
    configModel.rowHeight=100.0f;
    
    //是否安装刷新控件
    configModel.refreshControlType=LTConfigModelRefreshControlTypeBoth;
    
    //配置完毕
    self.configModel=configModel;
    
}



@end
