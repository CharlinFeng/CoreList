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


-(void)dealloc{
    [self.scrollView  removeFromSuperview];
    self.scrollView = nil;
    [self navBarScroll_Disable];
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //viewDidAppearAction
    [self viewDidAppearAction];
}





/** viewDidLoadAction */
-(void)viewDidLoadAction{
    
    [self navBarShow];
    [self navBarScroll_Enable];
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //安装刷新控件
    ListVCRefreshAddType refreshType = [self listVC_RefreshType];
    
    if(ListVCRefreshAddTypeBottomRefreshOnly != refreshType) [self headerRefreshAdd];
    
    //设置代理
    if(self.scrollView.delegate == nil) self.scrollView.delegate = self;
    
    [self backBtnPrepare];
}


/** viewWillAppearAction */
-(void)viewWillAppearAction{
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //提示图层：没有数据才显示
    if(!self.hasData){[CoreIV showWithType:IVTypeLoad view:self.view msg:@"努力加载中" failClickBlock:nil];}
}



/** viewDidAppearAction */
-(void)viewDidAppearAction{
    
    if([self listVC_RefreshType] == ListVCRefreshAddTypeNeither) return;
    
    if(self.isRefreshWhenViewDidAppeared){
        
        if(![self.scrollView.mj_header isRefreshing]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self triggerHeaderRefreshing];
            });
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self triggerHeaderRefreshing];
            });
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
            
        }else{
            
            if(needTriggerHeaderAction){
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self triggerHeaderRefreshing];
                });
                
                //存入当前时间
                [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
            }
        }
    }
    
    if(self.hasData){[CoreIV dismissFromView:self.view animated:YES];}
}


@end
