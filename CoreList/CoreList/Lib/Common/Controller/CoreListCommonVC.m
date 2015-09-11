//
//  CoreListController.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "CoreRefreshEntry.h"
#import "CoreModel.h"
#import "NSArray+CoreListExtend.h"
#import "CoreViewNetWorkStausManager.h"
#import "UIView+Masony.h"
#import "CoreModel+Cache.h"
#import "Masonry.h"

static NSString * const RefreshTypeKey = @"RefreshTypeKey";
const NSInteger TipsViewTag = 2015;

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

@end





@implementation CoreListCommonVC


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //控制器准备
    [self vcPrepare];
    
    if(self.isNeedFMDB){//需要缓存，直接请求数据
        [self headerRefreshAction];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //提示图层：没有数据才显示
    
    if(!self.hasData){
        
        [CoreViewNetWorkStausManager show:self.view type:CMTypeLoadingWithImage msg:@"努力加载中" subMsg:@"请稍等片刻" offsetY:0 failClickBlock:^{
            if (ListVCRefreshAddTypeBottomRefreshOnly != self.refreshType){
                
                [self headerRefreshAction];
            }
        }];
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
    
    //如果是无缓存模式，才需要做定期触发顶部刷新，而不是每次都跳到顶部刷新
    BOOL needFMDB = [[self listVC_Model_Class] CoreModel_NeedFMDB];

    if(!needFMDB){
        
        //取出上次时间
        NSString *key = [self listVC_Update_Delay_Key];
        NSTimeInterval duration = [self listVC_Update_Delay_Time];
        NSTimeInterval lastTime = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        BOOL needTriggerHeaderAction = lastTime + duration < now;
        
        //如果没有数据，直接请求
        if(!self.hasData){
            [self.scrollView headerSetState:CoreHeaderViewRefreshStateRefreshing];
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
            return;
        }
        
        if(needTriggerHeaderAction){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.scrollView headerSetState:CoreHeaderViewRefreshStateRefreshing];
            });
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];

        }
    }
    
    if(self.hasData){
        [CoreViewNetWorkStausManager dismiss:self.view animated:YES];
    }
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
    
    ListVCRefreshAddType type = [self listVC_RefreshType];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //标明刷新类型
    self.refreshType = ListVCRefreshActionTypeHeader;
    
    //页码复位
    self.page = [[self listVC_Model_Class] CoreModel_StartPage];
    
    //底部刷新控件复位
    [self.scrollView footerSetState:CoreFooterViewRefreshStateNormalForContinueDragUp];
    
    //找模型要获取
    [self fetchDataFromModel];
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
    
    NSLog(@"请求开始：%@",paramsM);
    
    NSDictionary *userInfo = @{RefreshTypeKey : @(self.refreshType)};

    [Model_Class selectWithParams:paramsM userInfo:userInfo beginBlock:^(BOOL isNetWorkRequest,BOOL needHUD){
        
        if(self.hasFooter && isNetWorkRequest) [self.scrollView footerSetState:CoreFooterViewRefreshStateRequesting];
        
    } successBlock:^(NSArray *models, CoreModelDataSourceType sourceType,NSDictionary *userInfo){
        
        
        if(CoreModelDataSourceHostType_Sqlite_Deprecated == sourceType) {
            
            NSLog(@"本地数据过期");
        }
        
        ListVCRefreshActionType refreshType = [[userInfo objectForKey:RefreshTypeKey] integerValue];
        
        if(ListVCRefreshActionTypeHeader == refreshType){ //顶部数据刷新成功
            
            //刷新成功：顶部
            [self refreshSuccess4Header:models];
            
            //处理指示视图状态
            [self handlestatusViewWithModels:models];
            
            //根据顶部刷新数据情况安装底部刷新控件
            [self footerRefreshAdd:models];
        }
        
        
        if(ListVCRefreshActionTypeFooter == refreshType){ //底部数据刷新成功
            
            [self refreshSuccess4Footer:models sourceType:sourceType];
            
            if(models.count ==0 && CoreModelDataSourceTypeSqlite == sourceType){
               
                [self.scrollView footerSetState:CoreFooterViewRefreshStateSuccessedResultNoMoreData];

            }
            
            //标明本地数据库没有数据了
            self.localDataNil = models.count ==0;
        }
        

        //标明刷新类型：这句一定要放在后面，因为在修改刷新状态为无之前，状态值还有用
        self.refreshType = ListVCRefreshActionTypeNone;
        
    } errorBlock:^(NSString *errorResult,NSDictionary *userInfo) {
    
        NSLog(@"%@",@(self.page));
        
        if(self.hasData){
            
            
            if(!self.hasFooter) return;
            
            if(self.localDataNil){
                
                [self.scrollView footerSetState:CoreFooterViewRefreshStateFailed];
            }
            
            //无缓存的情况
            if(!self.isNeedFMDB){
                
                [self.scrollView footerSetState:CoreFooterViewRefreshStateFailed];
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
        
        [CoreViewNetWorkStausManager show:self.view type:CMTypeError msg:@"注意" subMsg:@"网络数据丢失" offsetY:0 failClickBlock:^{
            [self showNetViewManager];
            [self headerRefreshAction];
        }];
    }];
}


/** 显示指示器 */
-(void)showNetViewManager{
    
    [CoreViewNetWorkStausManager show:self.view type:CMTypeLoadingWithImage msg:@"努力加载中" subMsg:@"请稍等片刻" offsetY:0 failClickBlock:^{
        if (ListVCRefreshAddTypeBottomRefreshOnly != self.refreshType){
            
            [self headerRefreshAction];
        }
    }];
}



/** 根据顶部刷新数据情况安装底部刷新控件 */
-(void)footerRefreshAdd:(NSArray *)models{
 
    NSUInteger count = models.count;
    
    if(count<=5){//不安装
        
    }else if (count >5 && count < self.modelPageSize){//安装，并将状态置为无数据
        
        [self footerRefreshAdd];
        
        [self.scrollView footerSetState:CoreFooterViewRefreshStateSuccessedResultNoMoreData];
        
    }else if (count >= self.modelPageSize){//正常安装
        
        [self footerRefreshAdd];
        
    }
    
    self.hasFooter = YES;
}





/** 刷新成功：顶部 */
-(void)refreshSuccess4Header:(NSArray *)models{
    
    [self.scrollView headerSetState:CoreHeaderViewRefreshStateSuccessedResultDataShowing];

    //存入数据
    self.dataList = models;
    
    //刷新数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
        [self.scrollView headerSetState:CoreHeaderViewRefreshStateNorMal];
    });
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

    
    if(count == 0){//新的一页一条数据也没有
        
        
        if(CoreModelDataSourceHostType_Sqlite_Nil == sourceType){
            
            //页码需要回退
            self.page -- ;
        }
        
        
        [self.scrollView footerSetState:CoreFooterViewRefreshStateSuccessedResultNoMoreData];
        
    }else if (count < pageSize){//有数据，但没有满载
        
        
        [self.scrollView footerSetState:CoreFooterViewRefreshStateSuccessedResultNoMoreData];
        
    }else if (count >= pageSize){//有数据，满载
        
        [self.scrollView footerSetState:CoreFooterViewRefreshStateSuccessedResultDataShowing];
        
    }
}






-(void)handlestatusViewWithModels:(NSArray *)models{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSUInteger count = models.count;
        
        if(models == nil || count == 0){//没有数据
            
            [CoreViewNetWorkStausManager show:self.view type:CMTypeNormalMsgWithImage msg:@"没有数据" subMsg:@"过一会再来看看吧" offsetY:0 failClickBlock:nil];
            
        }else{//有数据，隐藏
            
            [CoreViewNetWorkStausManager dismiss:self.view animated:YES];
            
            self.hasData = YES;
        }
    });
    
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
    [self.scrollView removeHeader];
    [self.scrollView addHeaderWithTarget:self action:@selector(headerRefreshAction)];
}


/** 安装刷新控件：顶部刷新控件 */
-(void)footerRefreshAdd{
    //添加底部刷新
    [self.scrollView addFooterWithTarget:self action:@selector(footerRefreshAction)];
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
        
        //添加约束
        [_back2TopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.height.mas_equalTo(40);
            make.right.equalTo(self.view.mas_right).with.offset(-20);
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-60);
        }];
        
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



-(void)showTipsWithTitle:(NSString *)title desc:(NSString *)desc offsetY:(CGFloat)offsetY clickBlock:(void(^)())clickBlock{
    
    [self dismissTipsView];
    
    UIView *tipsView = [[UIView alloc] init];
    tipsView.tag = TipsViewTag;
    [self.view addSubview:tipsView];
    [tipsView masViewAddConstraintMakeEqualSuperViewWithInsets:UIEdgeInsetsZero];
    [CoreViewNetWorkStausManager show:tipsView type:CMTypeError msg:title subMsg:desc offsetY:offsetY failClickBlock:^{
        if(clickBlock!=nil) clickBlock();
    }];
}


-(void)dismissTipsView{
    
    UIView *tipsView = [self.view viewWithTag:TipsViewTag];
    
    [CoreViewNetWorkStausManager dismiss:tipsView animated:YES];
    
    [tipsView removeFromSuperview];
}


/** 刷新页面数据 */
-(void)refreshData{
    
    [self.scrollView headerSetState:CoreHeaderViewRefreshStateRefreshing];
}



-(void)dealloc{
    [self.scrollView  removeFromSuperview];
    self.scrollView = nil;
}








/** 协议方法区 */


/** 刷新方式 */
-(ListVCRefreshAddType)listVC_RefreshType{
    return ListVCRefreshAddTypeBoth;
}


/** 模型类 */
-(Class)listVC_Model_Class{
    return nil;
}


/** 视图类 */
-(Class)listVC_View_Cell_Class{
    return nil;
}

/** 请求参数 */
-(NSDictionary *)listVC_Request_Params{
    return nil;
}


/** 是否移除回到顶部按钮 */
-(BOOL)listVC_Remove_Back2Top_Button{
    return NO;
}


/** tableViewController */
/** cell的行高：tableViewController专用 */
-(CGFloat)listVC_CellH4IndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

/** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
-(NSString *)listVC_Update_Delay_Key{
    return nil;
}


/** 无缓存定期更新周期 */
-(NSTimeInterval)listVC_Update_Delay_Time{
    return 0;
}

/** 是否关闭返回顶部功能 */
-(BOOL)removeBack2TopBtn{
    return NO;
}



@end
