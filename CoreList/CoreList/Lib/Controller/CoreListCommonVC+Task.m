//
//  CoreListCommonVC+Task.m
//  CoreList
//
//  Created by 冯成林 on 16/4/6.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreListCommonVC+Task.h"
#import "CoreModelProtocol.h"


@implementation CoreListCommonVC (Task)

-(void)addTask:(NSURLSessionDataTask *)task forKey:(NSString *)url{
    
    //记录task
    if(url != nil && task != nil){
        
        NSString *url_forCorelistWithPage = [NSString stringWithFormat:@"%@_%@",url,@(self.page)];
        
        self.taskDictM[url_forCorelistWithPage] = task;
        NSLog(@"记录：%@,%@",url_forCorelistWithPage,task);
    }
}


-(void)removeTask{

    Class Model_Class = [self listVC_Model_Class];
    
    //清除task
    NSString *url = [Model_Class CoreModel_UrlString];
    
    NSString *url_forCorelistWithPage = [NSString stringWithFormat:@"%@_%@",url,@(self.page)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.taskDictM removeObjectForKey:url_forCorelistWithPage];
        
        NSLog(@"移除：%@",url_forCorelistWithPage);
    });
}

-(void)cancelAllTask{

    if(self.taskDictM.count == 0){return;}
    
    [self.taskDictM enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, NSURLSessionDataTask *_Nonnull task, BOOL * _Nonnull stop) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [task cancel];
        });
    }];
}

@end
