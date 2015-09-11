//
//  TGModel.h
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreModel.h"

@interface TGModel : CoreModel

@property (nonatomic,copy) NSString *title,*about,*content;

@property (nonatomic,assign) NSInteger type;

@end
