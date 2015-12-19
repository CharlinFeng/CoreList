//
//  CoreListController.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "CoreModel+Compare.h"
#import "CoreListCommonVC+ScrollView.h"

@interface CoreListCommonVC ()




@end


@implementation CoreListCommonVC


-(NSUInteger)modelPageSize{
    
    if(_modelPageSize == 0){
        
        _modelPageSize = [[self listVC_Model_Class] CoreModel_PageSize];
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

-(void)setShyNavBarOff:(BOOL)shyNavBarOff{

    _shyNavBarOff = shyNavBarOff;

    if(shyNavBarOff){
    
        [self navBarScroll_Disable];
    }
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

@end
