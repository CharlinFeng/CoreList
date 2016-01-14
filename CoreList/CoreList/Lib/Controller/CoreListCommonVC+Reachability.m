//
//  CoreListCommonVC+Reachability.m
//  Yeah
//
//  Created by 冯成林 on 16/1/14.
//  Copyright © 2016年 冯成林. All rights reserved.
//

#import "CoreListCommonVC+Reachability.h"
#import "CoreStatus.h"
#import "MJRefresh.h"

@implementation CoreListCommonVC (Reachability)


-(void)reachabilityPrepare {

    Reachability *readchability=[Reachability reachabilityForInternetConnection];
    
    //记录
    self.readchability=readchability;
    
    //开始通知
    [readchability startNotifier];
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkStatusChange) name:kReachabilityChangedNotification object:readchability];
}


/** 网络状态变更 */
-(void)netWorkStatusChange{
    
    if([CoreStatus isNETWORKEnable]){
        
        [self.scrollView.mj_header endRefreshing];
        
    }
}

@end
