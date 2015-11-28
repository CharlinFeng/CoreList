//
//  CoreListController.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "MJRefresh.h"
#import "CoreModel.h"
#import "NSArray+CoreListExtend.h"
#import "CoreIV.h"
#import "CoreModel+Cache.h"
#import "CoreModelConst.h"
#import "CoreModel+Compare.h"

static NSString * const RefreshTypeKey = @"RefreshTypeKey";

const NSInteger TipsViewTag = 2015;


#define HeaderRefreshing [self.scrollView.mj_header beginRefreshing];
#define FooterRefresEndWithMsg(str) [self.scrollView.mj_footer endRefreshingWithNoMoreData];[(MJRefreshAutoStateFooter *)self.scrollView.mj_footer setTitle:str forState:MJRefreshStateNoMoreData];

#define DismissNetView [CoreIV dismissFromView:self.view animated:YES];

@interface CoreListCommonVC ()<UIScrollViewDelegate>

/** 页码 */
@property (nonatomic,assign) NSUInteger page;

/** 刷新状态 */
@property (nonatomic,assign) ListVCRefreshActionType refreshType;

/** 是否有数据：影响提示视图显示 */
@property (nonatomic,assign) BOOL hasData;

/** 是否已经安装底部刷新控件 */
@property (nonatomic,assign) BOOL hasFooter;

/** 是否需要本地缓存 */
@property (nonatomic,assign) BOOL isNeedFMDB;

/** 模型定义的一页数据量 */
@property (nonatomic,assign) NSUInteger modelPageSize;

/** 返回顶部 */
@property (nonatomic,strong) UIButton *back2TopBtn;

/** 本地数据库没有数据了 */
@property (nonatomic,assign) BOOL localDataNil;

@property (nonatomic,assign) BOOL isRefreshData;


@end





@implementation CoreListCommonVC


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;

    [self.scrollView.mj_footer endRefreshingWithNoMoreData];
    
    //控制器准备
    [self vcPrepare];
    
}



-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //提示图层：没有数据才显示
    if(!self.hasData){
        
        [self showLoadNetView];
    }
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //视图显示时操作
    [self viewAppearAction];
}



/** 视图显示时操作 */
-(void)viewAppearAction{
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    if(self.isRefreshWhenViewDidAppeared){
        
        
        
        if(![self.scrollView.mj_header isRefreshing]){
            HeaderRefreshing
        }
        
    }else{
        
        //取出上次时间
        NSString *key = [self listVC_Update_Delay_Key];
        NSTimeInterval duration = [[self listVC_Model_Class] CoreModel_Duration];
        NSTimeInterval lastTime = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        BOOL needTriggerHeaderAction = lastTime + duration < now;
        
        //如果没有数据，直接请求
        if(!self.hasData){
            
            HeaderRefreshing
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
            
        }else{
            
            if(needTriggerHeaderAction){
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    HeaderRefreshing
                });
                
                //存入当前时间
                [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
            }
        }
    }
    
    if(self.hasData){DismissNetView}
}





/** 控制器准备 */
-(void)vcPrepare{
    
    //安装刷新控件
    ListVCRefreshAddType refreshType = [self listVC_RefreshType];
    
    if(ListVCRefreshAddTypeBottomRefreshOnly != refreshType) [self headerRefreshAdd];
    
    //设置代理
    if(self.scrollView.delegate == nil) self.scrollView.delegate = self;
}




/** 顶部刷新 */
-(void)headerRefreshAction{
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //标明刷新类型
    self.refreshType = ListVCRefreshActionTypeHeader;
    
    //页码复位
    self.page = [[self listVC_Model_Class] CoreModel_StartPage];
    
    //底部刷新控件复位
    [self.scrollView.mj_footer endRefreshing];
    
    //找模型要获取
    [self fetchDataFromModel];
    
    self.isRefreshData=YES;
}


/** 底部刷新 */
-(void)footerRefreshAction{
    
    //标明刷新类型
    self.refreshType = ListVCRefreshActionTypeFooter;
    
    //页码增加
    self.page ++;
    
    //找模型要获取
    [self fetchDataFromModel];
}

/** 找模型要获取 */
-(void)fetchDataFromModel{
    
    if(ListVCRefreshActionTypeNone == self.refreshType) {
        
        NSLog(@"错误：刷新类型错误");
        
        return;
    }
    
    Class Model_Class = [self listVC_Model_Class];
    
    //当前页码信息：p,每页数据量信息：pageSize
    NSMutableDictionary *paramsM = [NSMutableDictionary dictionary];
  
    [paramsM addEntriesFromDictionary:@{[Model_Class CoreModel_PageKey] : @(self.page),[Model_Class CoreModel_PageSizeKey] : @([Model_Class CoreModel_PageSize])}];
    
    if ([self listVC_Request_Params] != nil) [paramsM addEntriesFromDictionary:[self listVC_Request_Params]];
    
    NSDictionary *userInfo = @{RefreshTypeKey : @(self.refreshType)};
    
    NSArray *ignoreParams = [self listVC_Ignore_Params];

    [Model_Class selectWithParams:paramsM ignoreParams:ignoreParams userInfo:userInfo beginBlock:^(BOOL isNetWorkRequest,BOOL needHUD){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.hasFooter && isNetWorkRequest) [self.scrollView.mj_footer beginRefreshing];
        });
        
    } successBlock:^(NSArray *models, CoreModelDataSourceType sourceType,NSDictionary *userInfo){
        
        DismissNetView
        
        ListVCRefreshActionType refreshType = [[userInfo objectForKey:RefreshTypeKey] integerValue];
        
        if(ListVCRefreshActionTypeHeader == refreshType){ //顶部数据刷新成功
            
            //刷新成功：顶部
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshSuccess4Header:models];
            });
            
            if(sourceType != CoreModelDataSourceTypeSqlite){
                
                //处理指示视图状态
                [self handlestatusViewWithModels:models];
            }
            
            if(!self.hasData && models.count==0){
                [self showErrorNetViewWithMsg:@"加载失败，点击重试" failClickBlock:^{
                    [self showLoadNetView];
                    [self headerRefreshAction];
                }];
                
            }else{
                
                //根据顶部刷新数据情况安装底部刷新控件
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self footerRefreshAdd:models];
                });
            }
        }
        
        if(ListVCRefreshActionTypeFooter == refreshType){ //底部数据刷新成功
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshSuccess4Footer:models sourceType:sourceType];
            });
            
            if(models.count ==0 && CoreModelDataSourceTypeSqlite == sourceType){
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    FooterRefresEndWithMsg(@"没有更多数据了")
                });

            }
            
            //标明本地数据库没有数据了
            self.localDataNil = models.count ==0;
        }
        

        //标明刷新类型：这句一定要放在后面，因为在修改刷新状态为无之前，状态值还有用
        self.refreshType = ListVCRefreshActionTypeNone;
        
    } errorBlock:^(NSString *errorResult,NSDictionary *userInfo) {
        
        if(errorResult != nil && ![errorResult isEqualToString:NetWorkError]){ //网络请求成功，但服务器抛出错误
            
            __weak typeof(self) weakSelf=self;
            
            DismissNetView
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self showErrorNetViewWithMsg:@"操作失败" failClickBlock:^{
 
                    if(weakSelf.NetWorkErrorAction != nil) weakSelf.NetWorkErrorAction();
                    
                }];
            });
            
            return;
        }
        
    
        if(self.hasData){
            
            
            if(!self.hasFooter) return;
            
            if(self.localDataNil){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    FooterRefresEndWithMsg(@"数据加载失败")
                });
            }
            
            //无缓存的情况
            if(!self.isNeedFMDB){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    FooterRefresEndWithMsg(@"数据加载失败")
                });
                
                //页码回退
                self.page -- ;
            }
            
            //有缓存的情况
            if(ListVCRefreshActionTypeHeader != self.refreshType && self.localDataNil){
                //页码回退
                self.page -- ;
            }
            
            
            return;
        }
        
        //标明刷新类型
        self.refreshType = ListVCRefreshActionTypeNone;
        
        [CoreIV showWithType:IVTypeError view:self.view msg:@"加载失败，点击重试" failClickBlock:^{
            
            [self showLoadNetView];
            [self headerRefreshAction];
        }];
    }];
}


/** 显示指示器 */
-(void)showLoadNetView{
    
    [CoreIV showWithType:IVTypeLoad view:self.view msg:nil failClickBlock:nil];
}

-(void)showErrorNetViewWithMsg:(NSString *)msg failClickBlock:(void(^)())failClickBlock{
    [CoreIV showWithType:IVTypeError view:self.view msg:msg failClickBlock:failClickBlock];
}


/** 根据顶部刷新数据情况安装底部刷新控件 */
-(void)footerRefreshAdd:(NSArray *)models{
    
    [self footerRefreshAdd];
    
    NSUInteger count = models.count;
    
    if(count<=5){//不安装
        FooterRefresEndWithMsg(@"没有更多数据了")
        
    }else if (count >5 && count < self.modelPageSize){//安装，并将状态置为无数据
        
        FooterRefresEndWithMsg(@"没有更多数据了")
        
    }else if (count >= self.modelPageSize){//正常安装
        
//        [self footerRefreshAdd];
    }
    
    self.hasFooter = YES;
}





/** 刷新成功：顶部 */
-(void)refreshSuccess4Header:(NSArray *)models{
    
    [self.scrollView.mj_header endRefreshing];

    //存入数据
    self.dataList = models;
    
    //刷新数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
    
    self.isRefreshData=NO;
}


/** 刷新成功：底部 */
-(void)refreshSuccess4Footer:(NSArray *)models sourceType:(CoreModelDataSourceType)sourceType{
    
    NSUInteger count = models.count;
    
    NSUInteger pageSize = self.modelPageSize;
    
    NSArray *indexPaths = [NSArray indexPathsWithStartIndex:self.dataList.count count:count];
    
    //存入数据
    if(self.dataList == nil){//第一次没有数据
        
        //对nil无法发消息
        self.dataList = models;
        
    }else{
        
        self.dataList = [self.dataList appendArray:models];
    }
    
    if(models != nil && indexPaths != nil && self.dataList != nil){
        
        //刷新数据
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //这里有个崩溃，先这样解决
            if(self.dataList.count <= self.modelPageSize){
                [self reloadData];return ;
            }
            /** 动态刷新 */
            [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            
        });
    }

    if(count < pageSize){//新的一页数据不足pagesize
        
        if(CoreModelDataSourceHostType_Sqlite_Nil == sourceType){
            
            //页码需要回退
            self.page -- ;
        }
        
        FooterRefresEndWithMsg(@"没有更多数据了")

    }else if (count >= pageSize){//有数据，满载
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.scrollView.mj_footer endRefreshing];
        });
    }
}






-(void)handlestatusViewWithModels:(NSArray *)models{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSUInteger count = models.count;
        
        if(models == nil || count == 0){//没有数据
            
            [self showNoDataView];
            
        }else{//有数据，隐藏
            
            DismissNetView
            
            self.hasData = YES;
        }
    });
    
}


-(void)showNoDataView{
    [self showErrorNetViewWithMsg:@"暂无数据" failClickBlock:nil];
}


-(NSUInteger)modelPageSize{
    
    if(_modelPageSize == 0){
        
        _modelPageSize = [[self listVC_Model_Class] CoreModel_PageSize];
    }
    
    return _modelPageSize;
}







/** 安装刷新控件：顶部刷新控件 */
-(void)headerRefreshAdd{
    
    //添加顶部刷新控件
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.scrollView.mj_header == nil) {
            self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAction)];
        }
    });
}


/** 安装刷新控件：顶部刷新控件 */
-(void)footerRefreshAdd{
    
    //添加底部刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.scrollView.mj_footer == nil) {
            self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)];
        }
    });
    
}


-(BOOL)isNeedFMDB{
    
    return [[self listVC_Model_Class] CoreModel_NeedFMDB];
}


-(UIButton *)back2TopBtn{
    
    if(_back2TopBtn == nil){
        
        _back2TopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_back2TopBtn setBackgroundImage:[UIImage imageNamed:@"CoreList.bundle/back_top"] forState:UIControlStateNormal];
        
        //隐藏
        _back2TopBtn.alpha = 0;
        
        [_back2TopBtn addTarget:self action:@selector(back2Top) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_back2TopBtn];
        
        _back2TopBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"back2TopBtn": _back2TopBtn};
        
        NSArray *v_hor = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[back2TopBtn(==40)]-20-|" options:0 metrics:nil views:views];
        NSArray *v_ver = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[back2TopBtn(==40)]-60-|" options:0 metrics:nil views:views];
        [self.view addConstraints:v_hor];[self.view addConstraints:v_ver];

        
    }
    
    return _back2TopBtn;
}


/** 返回顶部 */
-(void)back2Top{
    
    if([self.scrollView isKindOfClass:[UITableView class]]){//tableView
        
        UITableView *tableView = (UITableView *)self.scrollView;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else{
        
        
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if([self removeBack2TopBtn]) return;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if(offsetY >=600){ //显示
        
        [self showBack2TopBtn];
        
    }else{ //隐藏
        
        [self dismissBack2TopBtn];
    }
}


/** 展示返回顶部按钮 */
-(void)showBack2TopBtn{
    
    [self animWithParam:1];
}


/** 隐藏返回顶部按钮 */
-(void)dismissBack2TopBtn{
    
    [self animWithParam:0];
}


/** 动画参数化 */
-(void)animWithParam:(CGFloat)alpha{
    
    if(self.back2TopBtn.alpha == alpha) return;
    
    [UIView animateWithDuration:.25f animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        self.back2TopBtn.alpha = alpha;
    }];
}



/** 刷新页面数据 */
-(void)refreshData{
    
    HeaderRefreshing
}


-(void)setDataList:(NSArray *)dataList{
    
    [CoreModel compareArr1:_dataList arr2:dataList resBlock:^(BOOL res) {
        
        if(!res && self.DataListChangedAction!=nil) self.DataListChangedAction();
    }];

    _dataList=dataList;
}



-(void)dealloc{
    [self.scrollView  removeFromSuperview];
    self.scrollView = nil;
}

@end
