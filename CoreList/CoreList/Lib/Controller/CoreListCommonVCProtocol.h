//
//  CoreListCommonVCProtocol.h
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CoreListCommonVCProtocol <NSObject>

/** 是否有数据：影响提示视图显示 */
@property (nonatomic, assign, readonly) BOOL hasData;




/** 安装刷新控件：顶部刷新控件 */
-(void)headerRefreshAdd;




@end
