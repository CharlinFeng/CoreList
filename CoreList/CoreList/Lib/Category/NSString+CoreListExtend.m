//
//  NSString+Equal.m
//  CoreList
//
//  Created by 冯成林 on 15/9/11.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NSString+CoreListExtend.h"

@implementation NSString (CoreListExtend)


-(NSString *)host {

    return [NSString stringWithFormat:@"%@%@",@"",self];
}


-(BOOL)isEqual:(id)object{
    return [self isEqualToString:object];
}



@end