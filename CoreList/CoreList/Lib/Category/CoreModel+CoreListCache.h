//
//  CoreModel+CoreListCache.h
//  CoreList
//
//  Created by 冯成林 on 16/4/3.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreModel.h"

@interface CoreModel (CoreListCache)

/** 此方法是第四季与第五季内容，并且是框架内部的系统级方法，你用不到 */
+(void)selectWithParams:(NSDictionary *)params ignoreParams:(NSArray *)ignoreParams userInfo:(NSDictionary *)userInfo beginBlock:(void(^)(BOOL isNetWorkRequest,BOOL needHUD, NSString *url, NSURLSessionDataTask *task))beginBlock successBlock:(void(^)(NSArray *models,CoreModelDataSourceType sourceType,NSDictionary *userInfo))successBlock errorBlock:(void(^)(NSString *errorResult,NSDictionary *userInfo))errorBlock;



@end
