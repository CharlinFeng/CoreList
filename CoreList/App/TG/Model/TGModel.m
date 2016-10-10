//
//  TGModel.m
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "TGModel.h"
#import "NSObject+MJKeyValue.h"

@implementation TGModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellH = 80 + arc4random_uniform(70);
    }
    return self;
}

/*
 *  协议方法区
 */
/** 接口地址 */
+(NSString *)CoreModel_UrlString{return @"http://112.74.106.149/wind/Htdoc/Index/test/theList";}




@end





