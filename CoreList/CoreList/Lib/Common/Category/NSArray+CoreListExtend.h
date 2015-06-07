//
//  NSArray+CoreListExtend.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CoreListExtend)


/** 追加数据 */
-(NSArray *)appendArray:(NSArray *)newArray;

/** indexPathys计算 */
+(NSArray *)indexPathsWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count;



@end
