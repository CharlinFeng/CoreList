//
//  CoreListCommonVC+Task.h
//  CoreList
//
//  Created by 冯成林 on 16/4/6.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

@interface CoreListCommonVC (Task)

-(void)addTask:(NSURLSessionDataTask *)task forKey:(NSString *)url;

-(void)removeTask;

-(void)cancelAllTask;

@end
