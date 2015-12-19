//
//  CoreListCommonVC+Data.h
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

#define debug NSLog(@"%@",[NSThread currentThread]);

@interface CoreListCommonVC (Data)

/** 找模型要获取 */
-(void)fetchDataFromModel;


-(void)dismissCustomView_EmptyView_ErrorView;

@end
