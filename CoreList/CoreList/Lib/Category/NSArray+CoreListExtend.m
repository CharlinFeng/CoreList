//
//  NSArray+CoreListExtend.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSArray+CoreListExtend.h"
#import <UIKit/UIKit.h>
#import "CoreModel.h"

@implementation NSArray (CoreListExtend)

/** 追加数据 */
-(NSArray *)appendArray:(NSArray *)newArray{
    
    //异常处理
    if(newArray == nil || newArray.count ==0) return self;
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self];
    
    NSArray *arrMHostIDArr = [arrM valueForKeyPath:@"hostID"];

    [newArray enumerateObjectsUsingBlock:^(CoreModel *m, NSUInteger idx, BOOL *stop) {

        if(![arrMHostIDArr containsObject:@(m.hostID)]){
            [arrM addObject:m];
        }
    }];

    return arrM;
}


/** indexPathys计算 */
+(NSArray *)indexPathsWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count{
    
    if(count == 0) return nil;
    
    NSMutableArray *indexPathsM = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = startIndex; i<startIndex + count; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        [indexPathsM addObject:indexPath];
    }
    
    return indexPathsM;
}


@end
