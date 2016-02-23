//
//  CoreListCommonVC+Main.h
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

@interface CoreListCommonVC (Main)

/** 刷新页面数据 */
-(void)refreshData;

/** 刷新数据_不通过刷新控件 */
-(void)refreshData_WithoutRefreshControl;

@end
