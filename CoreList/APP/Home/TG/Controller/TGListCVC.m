//
//  ListCVC.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "TGListCVC.h"
#import "TGCell.h"
#import "TGModel.h"


@interface TGListCVC ()

@end

@implementation TGListCVC

static NSString * const reuseIdentifier = @"Cell";


- (instancetype)init
{
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize=CGSizeMake(100, 100);
    layout.minimumLineSpacing=10;
    layout.minimumInteritemSpacing=10;
    layout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
    
    
    
    //注册cell
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"九宫格列表";
    [self.collectionView  registerNib:[UINib nibWithNibName:@"TGCell" bundle:nil] forCellWithReuseIdentifier:@"TGCell"];
    
    self.collectionView.backgroundColor=[UIColor whiteColor];
    
    //模型配置
    [self config];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    
    
}

-(void)next{
    
    UIViewController *vc=[[UIViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    configModel.httpMethod=LTConfigModelHTTPMethodGET;
    //模型类
    configModel.ModelClass=[TGModel class];
    //cell类
    configModel.ViewForCellClass=[TGCell class];
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
    //每页数量
    configModel.pageSize=18;
    
    //是否安装顶部刷新控件
    configModel.refreshControlType=LTConfigModelRefreshControlTypeBoth;
    
    //配置完毕
    self.configModel=configModel;
    
}


@end
