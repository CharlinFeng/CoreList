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
#import "CoreListCommonVC+Refresh.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+BackBtn.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+Main.h"
#import "CoreListVCNeedRefreshNotiModel.h"
#import "UIView+CoreListLayout.h"
#import "CoreListCommonVC+Task.h"

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
    
    if(self.autoHideBars){
        
        self.autoHideBars = YES;
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.autoHideBars = NO;
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //viewDidAppearAction
    [self viewDidAppearAction];
}



/** viewDidLoadAction */
-(void)viewDidLoadAction{

    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
//    //监听通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if([self listVCRefreshType] == ListVCRefreshAddTypeNeither) return;

    //设置代理
    if(self.scrollView.delegate == nil) self.scrollView.delegate = self;
    
    [self backBtnPrepare];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshNoti:) name:CoreListVCNeedRefreshDataNoti object:nil];
    
    self.autoHideBars = NO;
    
    [self messageViewPrepare:YES];
    [self messageViewPrepare:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefreshNoti:) name:@"NavigationControllerWillPopNoti" object:nil];
}

-(void)NavigationControllerWillPopNoti:(NSNotification *)noti{

    __block BOOL needCancel = NO;
    
    if([self.navigationController.topViewController isKindOfClass:[self class]]){needCancel = YES;}
    
    [self.navigationController.topViewController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([vc isKindOfClass:[self class]]){needCancel = YES;}
    }];
    
    if(needCancel){[self cancelAllTask];}
}


-(void)messageViewPrepare:(BOOL)isEmptyView{
    
    id customObj = isEmptyView ? [self listVCStatusViewEmpty] : [self listVCStatusViewError];
    
    if (customObj != nil){
        
         __weak CoreListMessageView *messageView = isEmptyView ? self.emptyView : self.errorView;
        
        if([customObj isKindOfClass:[UIView class]]){
            
            messageView.isCustomMessageView = YES;
            [messageView.contentView addSubview:customObj];
            [customObj autoLayoutFillSuperView];
            
        }else{
            
            NSArray *array = (NSArray *)customObj;
            [messageView update:array[0] desc:array[1] constant:[array[2] floatValue]];
        }
    }
}



-(void)needRefreshNoti:(NSNotification *)noti{

    CoreListVCNeedRefreshNotiModel *m = noti.userInfo[CoreListVCNeedRefreshDataNoti];
    
    if(m==nil || ![m isKindOfClass:[CoreListVCNeedRefreshNotiModel class]]){return;}
    
    NSString *str_self_cls = NSStringFromClass([self class]);
    NSString *str_m_cls = NSStringFromClass(m.CoreListControllerClass);
    NSLog(@"%@,%@,%@",str_self_cls,str_m_cls,@(m.vcIndex));
    
    if(m.vcIndex == -1){self.needRefreshData = YES;return;}
    
    if([str_self_cls isEqualToString:str_m_cls] && self.coreListVCIndex == m.vcIndex){
        NSLog(@"需要刷新");
        self.needRefreshData = YES;
    }else{
        NSLog(@"不需要刷新");
    }
}

-(void)appEnterBackground:(NSNotification *)noti{
    
    self.fixApplicationEnterInsets = self.scrollView.contentInset;
    [self.scrollView.mj_header endRefreshing];
    self.needRefreshData = YES;
    //    [self removeHeaderRefreshControl];
}

-(void)appEnterForground:(NSNotification *)noti{
    
    if([self listVCRefreshType] != ListVCRefreshAddTypeBottomRefreshOnly){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentInset = self.fixApplicationEnterInsets;
            //            }];
            
            //            [self headerRefreshAdd];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self viewDidAppearAction];
    });
}




/** viewWillAppearAction */
-(void)viewWillAppearAction{
    
    self.isViewDidAppeare_CoreList = YES;
    
    if([self listVCRefreshType] == ListVCRefreshAddTypeNeither) return;
    
    //提示图层：没有数据才显示
//    if(!self.hasData){[CoreIV showWithType:IVTypeLoad view:self.view msg:nil failClickBlock:nil];}
    
    //取出上次时间
    NSString *key = [self listVCUpdateDelayKey];
    NSTimeInterval duration = [[self listVCModelClass] CoreModel_Duration];
    NSTimeInterval lastTime = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    BOOL needTriggerHeaderAction = lastTime + duration < now;

    //如果没有数据，直接请求
    if(!self.hasData){

        self.needRefreshData = YES;

        //存入当前时间
        [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];

    }else{

        if(needTriggerHeaderAction || self.needRefreshData){

            self.needRefreshData = YES;
            
            //存入当前时间
            [[NSUserDefaults standardUserDefaults] setDouble:now forKey:key];
        }
    }
}


/** viewDidAppearAction */
-(void)viewDidAppearAction{
    
    if(!self.isViewDidAppeare_CoreList){NSLog(@"CoreList的View未显示");return;}
    
    if(!self.notAdjustScrollViewInsets){
        
        UIEdgeInsets insets = self.originalScrollInsets;
        
        CGFloat bottom = 0;
        
        if(insets.top == 0 && self.navigationController != nil && !self.navigationController.navigationBarHidden){insets.top = self.navigationController.navigationBar.bounds.size.height + 20;}
        
        if(self.tabBarController != nil  && !self.tabBarController.tabBar.hidden ){ bottom = self.tabBarController.tabBar.bounds.size.height;}
        
        insets.bottom = bottom;
        
        self.originalScrollInsets = insets;
        
        self.isViewDidAppeare_CoreList = YES;
        
        self.notAdjustScrollViewInsets = YES;
    }
    
    self.scrollView.contentInset = self.originalScrollInsets;
    
    if([self listVCRefreshType] == ListVCRefreshAddTypeNeither) return;
    
    if(self.needRefreshData){
        
        if(self.scrollView.contentOffset.y != -64){
        
            [self back2Top];
            
//            [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.8];
            
            [self refreshData];
            
        }else{
            
            if(self.hasData) {
                
//                [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.25];
                [self refreshData];
                
            }else{
//                [self performSelector:@selector(refreshData) withObject:nil];
                [self refreshData];
            }
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    self.isViewDidAppeare_CoreList = NO;
}



-(void)dealloc{
    //    [self removeHeaderRefreshControl];
    //    [self removeFooterRefreshControl];
    //    [self.scrollView  removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.scrollView = nil;
    
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:[self listVCUpdateDelayKey]];
}

@end
