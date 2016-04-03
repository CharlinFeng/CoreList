//
//  CoreModel+CoreListCompare.h
//  CoreList
//
//  Created by 冯成林 on 16/4/3.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreModel.h"

@interface CoreModel (CoreListCompare)

+(void)compareArr1:(NSArray *)arr1 arr2:(NSArray *)arr2 resBlock:(void(^)(BOOL res))resBlock;

@end
