//
//  HomeModel.h
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) Class VCClass;


+(instancetype)modelWithName:(NSString *)name VCClass:(Class)VCClass;

@end
