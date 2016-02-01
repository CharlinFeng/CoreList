//
//  CoreListNeedRefreshNotiModel.m
//  CoreList
//
//  Created by 冯成林 on 16/2/1.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreListVCNeedRefreshNotiModel.h"

const NSString * CoreListVCNeedRefreshDataNoti = @"CoreListVCNeedRefreshDataNoti";

@implementation CoreListVCNeedRefreshNotiModel

+(instancetype)quickNotiModel:(Class)CoreListControllerClass vcIndex:(NSInteger)vcIndex{

    CoreListVCNeedRefreshNotiModel *m = [[CoreListVCNeedRefreshNotiModel alloc] init];

    m.CoreListControllerClass = CoreListControllerClass;
    m.vcIndex = vcIndex;
    return m;
}


@end
