//
//  CoreListCommonVC+BackBtn.h
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

@interface CoreListCommonVC (BackBtn)

-(void)backBtnPrepare;

/** 展示返回顶部按钮 */
-(void)showBack2TopBtn;

/** 隐藏返回顶部按钮 */
-(void)dismissBack2TopBtn;

@end
