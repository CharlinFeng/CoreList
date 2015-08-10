//
//  NewsListModel.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "BaseModel.h"

@interface NewsListModel : BaseModel

@property (nonatomic,copy) NSString *title,*about,*content;

@property (nonatomic,assign) NSInteger type;

@end
