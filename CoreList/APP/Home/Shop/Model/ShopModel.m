//
//  ShopModel.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "ShopModel.h"

@implementation ShopModel


+(NSArray *)modelPrepare:(id)obj{
    NSArray *dA=obj[@"data"][@"data"];
    return dA;
}






@end
