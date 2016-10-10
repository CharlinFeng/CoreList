//
//  CoreModel+CoreListCache.m
//  CoreList
//
//  Created by 冯成林 on 16/4/3.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreModel+CoreListCache.h"
#import "CoreModelProtocol.h"
#import "CoreModelConst.h"
#import "CoreModelType.h"
#import "CoreHttp.h"
#import "NSDictionary+Sqlite.h"
#import "NSObject+MJKeyValue.h"
#import "CoreStatus.h"

@implementation CoreModel (CoreListCache)


+(void)selectWithParams:(NSDictionary *)params ignoreParams:(NSArray *)ignoreParams userInfo:(NSDictionary *)userInfo beginBlock:(void(^)(BOOL isNetWorkRequest,BOOL needHUD, NSString *url, NSURLSessionDataTask *task))beginBlock successBlock:(void(^)(NSArray *models,CoreModelDataSourceType sourceType,NSDictionary *userInfo))successBlock errorBlock:(void(^)(NSString *errorResult,NSDictionary *userInfo))errorBlock{
    
    BOOL needFMDB = [self CoreModel_NeedFMDB];
    
    if(!needFMDB){

        
        NSString *url = [self CoreModel_UrlString];
        
        NSDictionary *requestParams = params;
        
        CoreModelHttpType httpType = [self CoreModel_HttpType];
        
        NSURLSessionDataTask *dataTask = nil;
        
        
        if(CoreModelHttpTypeGET == httpType){
            
            dataTask = [CoreHttp getUrl:url params:requestParams success:^(id obj) {
                
                [self hostWithouSqliteRequestHandleData:obj userInfo:userInfo successBlock:successBlock errorBlock:errorBlock];
                
            } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
                
                if(errorBlock != nil) errorBlock(errorMsg,userInfo);
            }];
            
        }else{
            
            dataTask = [CoreHttp postUrl:url params:requestParams success:^(id obj) {
                
                [self hostWithouSqliteRequestHandleData:obj userInfo:userInfo successBlock:successBlock errorBlock:errorBlock];
                
            } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
                
                if(errorBlock != nil) errorBlock(errorMsg,userInfo);
            }];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(beginBlock != nil) beginBlock(YES,YES, url, dataTask);
        });
        
    }else{
        
        BOOL isPageEnable = [self CoreModel_isPageEnable];
        
        NSString *where = nil;
        NSString *limit = nil;
        NSString *orderBy = nil;
        NSUInteger page = 0;
        
        NSMutableDictionary *paramsM=[NSMutableDictionary dictionaryWithDictionary:params];
        
        if(ignoreParams != nil && ignoreParams.count >0){
            [ignoreParams enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                [paramsM removeObjectForKey:key];
            }];
        }
        
        if(isPageEnable){
            
            NSString *pageKey = [self CoreModel_PageKey];
            
            NSString *pagesizeKey = [self CoreModel_PageSizeKey];
            
            page = [[params objectForKey:pageKey] integerValue];
            
            NSUInteger pagesize = [self CoreModel_PageSize];
            
            NSMutableDictionary *tempDictM = [NSMutableDictionary dictionaryWithDictionary:paramsM];
            
            [tempDictM removeObjectForKey:pageKey];
            
            [tempDictM removeObjectForKey:pagesizeKey];
            
            where = tempDictM.sqlWhere;
            
            orderBy = @"hostID desc";
            
            NSUInteger startPage = [self CoreModel_StartPage];
            
            limit = [NSString stringWithFormat:@"%@,%@",@((page - startPage) * pagesize),@(pagesize)];
            
        }else{
            
            where = paramsM.sqlWhere;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(beginBlock != nil) beginBlock(NO,NO, nil, nil);
        });
        
        [self selectWhere:where groupBy:nil orderBy:orderBy limit:limit selectResultsBlock:^(NSArray *model_sqlite_Array) {
            
            if(successBlock != nil) successBlock(model_sqlite_Array,CoreModelDataSourceTypeSqlite,userInfo);
            
            NSString *archiverTimeKey = [self modelName];
            
            if(isPageEnable){
                
                archiverTimeKey = [NSString stringWithFormat:@"%@%@",archiverTimeKey,@(page)];
            }
            
            NSTimeInterval lastRequestTime = [[NSUserDefaults standardUserDefaults] doubleForKey:archiverTimeKey];
            
            NSTimeInterval nowTime = [NSDate date].timeIntervalSince1970;
            
            BOOL needHUD = lastRequestTime <=0 || (lastRequestTime>0 && model_sqlite_Array.count == 0);
            
            BOOL needHttpRequest = nowTime - lastRequestTime >= [self CoreModel_Duration];
            
            if(!needHttpRequest) return;
            
            if(![CoreStatus isNetworkEnable]) return;
            
            NSString *url = [self CoreModel_UrlString];
            
            NSDictionary *requestParams = params;
            
            CoreModelHttpType httpType = [self CoreModel_HttpType];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(beginBlock != nil) beginBlock(YES,needHUD,nil, nil);
            });
            
            if(CoreModelHttpTypeGET == httpType){
                
                [CoreHttp getUrl:url params:requestParams success:^(id obj) {
                    
                    [self sqliteNeedHandleHttpDataObj:obj userInfo:userInfo successBlock:successBlock errorBlock:errorBlock model_sqlite_Array:model_sqlite_Array nowTime:nowTime archiverTimeKey:archiverTimeKey];
                    
                } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
                    
                    if(errorBlock != nil) errorBlock(errorMsg,userInfo);
                }];
                
            }else{
                
                [CoreHttp postUrl:url params:requestParams success:^(id obj) {
                    
                    [self sqliteNeedHandleHttpDataObj:obj userInfo:userInfo successBlock:successBlock errorBlock:errorBlock model_sqlite_Array:model_sqlite_Array nowTime:nowTime archiverTimeKey:archiverTimeKey];
                    
                } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
                    
                    if(errorBlock != nil) errorBlock(errorMsg,userInfo);
                    
                }];
            }
            
        }];
        
    }
}


+(void)sqliteNeedHandleHttpDataObj:(id)obj userInfo:(NSDictionary *)userInfo successBlock:(void(^)(id modelData,CoreModelDataSourceType sourceType,NSDictionary *userInfo))successBlock errorBlock:(void(^)(NSString *errorResult,NSDictionary *userInfo))errorBlock model_sqlite_Array:(NSArray *)model_sqlite_Array nowTime:(NSTimeInterval)nowTime archiverTimeKey:(NSString *)archiverTimeKey{
    
    NSString *errorResult = [self CoreModel_parseErrorData:obj];
    
    if(errorResult != nil){ if(errorBlock != nil) errorBlock(errorResult,userInfo); return;}
    
    id modelData = [self hostDataHandle:obj];
    
    if(CoreModelDeBug) NSLog(@"写入数据库");
    
    CoreModelDataSourceType sourceType = CoreModelDataSourceHostType_Sqlite_Deprecated;
    
    if(model_sqlite_Array == nil || model_sqlite_Array.count ==0){
        sourceType = CoreModelDataSourceHostType_Sqlite_Nil;
    }
    
    if(successBlock !=nil ) successBlock(modelData,sourceType,userInfo);
    
    [self saveDirect:modelData resBlock:nil];
    
    [[NSUserDefaults standardUserDefaults] setDouble:nowTime forKey:archiverTimeKey];
}


+(void)hostWithouSqliteRequestHandleData:(id)obj userInfo:(NSDictionary *)userInfo successBlock:(void(^)(id modelData,CoreModelDataSourceType sourceType,NSDictionary *userInfo))successBlock errorBlock:(void(^)(NSString *errorResult,NSDictionary *userInfo))errorBlock{
    
    NSString *errorResult = [self CoreModel_parseErrorData:obj];
    
    if(errorResult != nil){ if(errorBlock != nil) errorBlock(errorResult,userInfo); return;}
    
    id modelData = [self hostDataHandle:obj];
    
    if(successBlock !=nil ) successBlock(modelData,CoreModelDataSourceHostType_Sqlite_Nil,userInfo);
}




+(id)hostDataHandle:(id)obj{
    
    id modelData = nil;
    
    id userfullHostData = [self CoreModel_findUsefullData:obj];
    
    CoreModelHostDataType dataType = [self CoreModel_hostDataType];
    
    if(CoreModelHostDataTypeModelSingle == dataType){
        
        CoreModel *CoreModel = [self mj_objectWithKeyValues:userfullHostData];
        
        modelData = @[CoreModel];
        
    }else if (CoreModelHostDataTypeModelArray == dataType){
        
        NSArray *CoreModelArray = [self mj_objectArrayWithKeyValuesArray:userfullHostData];
        
        modelData = CoreModelArray;
    }
    
    return modelData;
}


@end
