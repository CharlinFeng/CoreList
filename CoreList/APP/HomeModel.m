//
//  HomeModel.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel


+(instancetype)modelWithName:(NSString *)name VCClass:(Class)VCClass{
    
    HomeModel *homeModel=[[HomeModel alloc] init];
    
    homeModel.name=name;
    
    homeModel.VCClass=VCClass;
    
    return homeModel;
}


@end
