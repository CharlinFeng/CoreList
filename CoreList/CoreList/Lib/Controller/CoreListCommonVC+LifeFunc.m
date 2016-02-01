//
//  CoreListCommonVC+LifeFunc.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+LifeFunc.h"
#import "CoreListCommonVCProtocol.h"
#import "MJRefresh.h"
#import "CoreModel.h"
#import "CoreIV.h"
#import "CoreListCommonVC+Refresh.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+BackBtn.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+Main.h"
#import "CoreListVCNeedRefreshNotiModel.h"

@interface CoreListCommonVC ()<UIScrollViewDelegate>

@end

@implementation CoreListCommonVC (LifeFunc)


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    /** viewDidLoadAction */
    [self viewDidLoadAction];
}



-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    /** viewWillAppearAction */
    [self viewWillAppearAction];
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self navBarShow];
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //viewDidAppearAction
    [self viewDidAppearAction];
}



/** viewDidLoadAction */
-(void)viewDidLoadAction{

    self.emptyView = [self listVC_StatusView_Empty];
    self.errorView = [self listVC_StatusView_Error];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self navBarShow];
    [self navBarScroll_Enable];
    
    //默认关闭shyNavBar
    self.shyNavBarOff = YES;
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;

    //设置代理
    if(self.scrollView.delegate == nil) self.scrollView.delegate = self;
    
    [self backBtnPrepare];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshNoti:) name:CoreListVCNeedRefreshDataNoti object:nil];
    
}

-(void)needRefreshNoti:(NSNotification *)noti{

    CoreListVCNeedRefreshNotiModel *m = noti.userInfo[CoreListVCNeedRefreshDataNoti];
    
    if(m==nil || ![m isKindOfClass:[CoreListVCNeedRefreshNotiModel class]]){return;}
    
    NSString *str_self_cls = NSStringFromClass([self class]);
    NSString *str_m_cls = NSStringFromClass(m.CoreListControllerClass);
    NSLog(@"%@,%@,%@",str_self_cls,str_m_cls,@(m.vcIndex));
    if([str_self_cls isEqualToString:str_m_cls] && self.coreListVCIndex == m.vcIndex){
        NSLog(@"需要刷新");
        self.needRefreshData = YES;
    }else{
        NSLog(@"不需要刷新");
    }
}

-(void)appEnterBackground:(NSNotification *)noti{
    
    self.fixApplicationEnterInsets = self.scrollView.contentInset;
    
    //    [self removeHeaderRefreshControl];
}

-(void)appEnterForground:(NSNotification *)noti{
    
    if([self listVC_RefreshType] != ListVCRefreshAddTypeBottomRefreshOnly){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentInset = self.fixApplicationEnterInsets;
            //            }];
            
            //            [self headerRefreshAdd];
        });
    }
}




/** viewWillAppearAction */
-(void)viewWillAppearAction{
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //提示图层：没有数据才显示
    if(!self.hasData){[CoreIV showWithType:IVTypeLoad view:self.view msg:nil failClickBlock:nil];}
}



/** viewDidAppearAction */
-(void)viewDidAppearAction{
    
    if(!self.isViewDidAppeare && !self.notAdjustScrollViewInsets){
        
        self.isViewDidAppeare = YES;
        
        UIEdgeInsets insets = self.originalScrollInsets;
        
        CGFloat bottom = MJRefreshFooterHeight;
        
        if(insets.top == 0 && self.navigationController != nil && !self.navigationController.navigationBarHidden){insets.top = self.navigationController.navigationBar.bounds.size.height + 20;}
        
        if(self.tabBarController != nil  && !self.tabBarController.tabBar.hidden ){ bottom += self.tabBarController.tabBar.bounds.size.height;NSLog(@"--------tabBarController:%@",@(bottom));}
        
        insets.bottom += bottom;
        
        self.originalScrollInsets = insets;
    }
    
    
    self.scrollView.contentInset = self.originalScrollInsets;
    
    
    NSLog(@"----------%@",NSStringFromUIEdgeInsets(self.scrollView.contentInset));
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //取出上次时间
    NSString *key = [self listVC_Update_Delay_Key];
    NSTimeInterval duration = [[self listVC_Model_Class] CoreModel_Duration];
    NSTimeInterval lastTime = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    BOOL needTriggerHeaderAction = lastTime + duration < now;
    
    //如果没有数据，直接请求
    if(!self.hasData){
        
        if(self.delayLoadDuration > 0 || self.needRefreshData){
            
            [self performSelector:@selector(refreshDataInMainThead:) withObject:@(NO) afterDelay:0.25];
            
        }else{
            
            [self refreshDataInMainThead:NO];
        }
        
        //存入当前时间
        [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
        
    }else{
        
        if(needTriggerHeaderAction || self.needRefreshData){
            
            [self performSelector:@selector(refreshDataInMainThead:) withObject:@(NO) afterDelay:1.0];
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
        }
    }
    
    
    if(self.hasData){[CoreIV dismissFromView:self.view animated:YES];}
}



-(void)dealloc{
    //    [self removeHeaderRefreshControl];
    //    [self removeFooterRefreshControl];
    //    [self.scrollView  removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self navBarScroll_Disable];
    self.scrollView = nil;
    
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:[self listVC_Update_Delay_Key]];
}

@end
