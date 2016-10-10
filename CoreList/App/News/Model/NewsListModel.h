//
//  NewsListModel.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListModel.h"

@interface NewsListModel : CoreListModel

@property (nonatomic,copy) NSString *title,*content;

@property (nonatomic,assign) NSInteger score;

@end
