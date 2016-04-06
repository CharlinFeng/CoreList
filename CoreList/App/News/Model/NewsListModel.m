//
//  NewsListModel.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NewsListModel.h"

@implementation NewsListModel


/** 数据请求地址 */
+(NSString *)CoreModel_UrlString{return @"http://120.25.157.128/test/Test/test_content";}

/** 是否需要本地缓存 */
+(BOOL)CoreModel_NeedFMDB{
    return NO;
}

@end
