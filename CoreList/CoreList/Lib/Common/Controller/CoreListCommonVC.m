//
//  CoreListController.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonVC.h"
#import "CoreModel+Compare.h"

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


@end
