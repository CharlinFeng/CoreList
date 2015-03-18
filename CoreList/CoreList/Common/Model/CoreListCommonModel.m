//
//  CoreListCommonModel.m
//  CoreListMVC
//
//  Created by muxi on 15/3/12.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "CoreListCommonModel.h"

@implementation CoreListCommonModel



+(NSDictionary *)replacedKeyFromPropertyName{
    return @{@"hostID":@"id"};
}






/**
 *  数据处理
 *
 *  @param obj 原始数据
 *
 *  @return 数组
 */
+(NSArray *)modelPrepare:(id)obj{
    return obj;
}



/**
 *  模型数组校验
 */
+(BOOL)check:(NSArray *)models{
    
    if(models==nil || models.count==0){
        NSLog(@"当前数据为空：当前模型为：%@",NSStringFromClass(self));
        return NO;
    }
    
    for (CoreListCommonModel *model in models) {
        
        if([model isKindOfClass:self]) continue;
        
        NSLog(@"\n当前数组里面装的不是%@模型，\n数组内容为：%@",NSStringFromClass(self),models);
        
        return NO;
    }
    
    return YES;
}




@end
