//
//  CoreListController.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "CoreModel+CoreListCompare.h"
#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+Main.h"
#import "MJRefresh.h"

@interface CoreListCommonVC ()




@end


@implementation CoreListCommonVC


-(NSUInteger)modelPageSize{
    
    if(_modelPageSize == 0){
        
        _modelPageSize = [[self listVCModelClass] CoreModel_PageSize];
    }
    
    return _modelPageSize;
}

-(void)setDataList:(NSArray *)dataList{
    
    _dataList=dataList;
    
    if(!self.needCompareData) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [CoreModel compareArr1:_dataList arr2:dataList resBlock:^(BOOL res) {
            
            if(!res && self.DataListChangedAction!=nil) self.DataListChangedAction();
        }];
    });
}



-(UIView *)back2TopView {

    
    if(_back2TopView == nil){
        
        _back2TopView = [[UIView alloc] init];
        
        CGFloat wh = 30;
        CGRect frame = CGRectMake(0, 0, wh, wh);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = frame;
        [btn setBackgroundImage:[UIImage imageNamed:@"CoreList.bundle/back_top"] forState:UIControlStateNormal];
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:frame];
        toolBar.barStyle = UIBarStyleDefault;
        [_back2TopView addSubview:toolBar];
        [_back2TopView addSubview:btn];
        
        //隐藏
        _back2TopView.alpha = 0;
        
        [btn addTarget:self action:@selector(back2Top) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_back2TopView];
        CGFloat marginBottom = 20;
        if(!self.hidesBottomBarWhenPushed && self.tabBarController != nil && !self.tabBarController.tabBar.hidden) {marginBottom += self.tabBarController.tabBar.bounds.size.height;}
        
        
        _back2TopView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"back2TopView": _back2TopView};
        
        NSArray *v_hor = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[back2TopView(==%@)]-20-|", @(wh)] options:0 metrics:nil views:views];
        NSArray *v_ver = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[back2TopView(==%@)]-%@-|", @(wh),@(marginBottom)] options:0 metrics:nil views:views];
        [self.view addConstraints:v_hor];[self.view addConstraints:v_ver];
        
        _back2TopView.layer.cornerRadius = wh/2;
        _back2TopView.layer.masksToBounds = YES;
        _back2TopView.clipsToBounds = YES;
    }
    
    return _back2TopView;
}


-(UIView *)emptyView{


    if(_emptyView == nil){
    
        CoreListMessageView *emptyView = [CoreListMessageView emptyViewWithImageName:@"CoreList.bundle/smile_failed" desc:@"暂无数据，单击获取" constant:0];
        
        _emptyView = emptyView;
        
        emptyView.viewType = CoreListMessageViewTypeEmpty;
        
        __weak typeof(self) weakSelf=self;
        
        emptyView.ClickBlock = ^{
            
            [weakSelf refreshData];
        };
    
    }
    
    return _emptyView;
}

-(UIView *)errorView{
    
    if(_errorView == nil){
    
        CoreListMessageView *errorView = [CoreListMessageView emptyViewWithImageName:@"CoreList.bundle/smile_failed" desc:@"加载失败，单击重试" constant:0];
        
        _errorView = errorView;
        
        errorView.viewType = CoreListMessageViewTypeError;
        
        __weak typeof(self) weakSelf=self;
        
        errorView.ClickBlock = ^{
            
            [weakSelf refreshData];
        };
    }
    
    return _errorView;
}

-(void)setAutoHideBars:(BOOL)autoHideBars{

    _autoHideBars = autoHideBars;
    
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0){
        
        self.navigationController.hidesBarsOnSwipe = autoHideBars;
    }
}


-(NSMutableDictionary *)taskDictM{

    if(_taskDictM == nil){
    
        _taskDictM = [NSMutableDictionary dictionary];
    }

    return _taskDictM;
}

-(void)dealloc {

    self.CoreListDidTrigerHeaderRefresh = nil;
    self.CoreListHeaderRefreshSuccessBlock = nil;
    self.CoreListHeaderRefreshSuccessBlock_HostObj = nil;
    self.CoreListDidClickBgViewBlock = nil;
}

@end
