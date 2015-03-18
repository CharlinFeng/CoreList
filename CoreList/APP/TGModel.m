//
//  TGModel.m
//  CoreListMVC
//
//  Created by muxi on 15/3/12.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "TGModel.h"

@implementation TGModel

+(NSArray *)modelPrepare:(id)obj{
    NSArray *dA=obj[@"data"][@"data"];
    return dA;
}



@end
