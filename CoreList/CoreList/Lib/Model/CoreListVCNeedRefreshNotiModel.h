//
//  CoreListNeedRefreshNotiModel.h
//  CoreList
//
//  Created by 冯成林 on 16/2/1.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString * CoreListVCNeedRefreshDataNoti;

@interface CoreListVCNeedRefreshNotiModel : NSObject

@property (nonatomic,assign) Class CoreListControllerClass;
@property (nonatomic,assign) NSInteger vcIndex;

+(instancetype)quickNotiModel:(Class)CoreListControllerClass vcIndex:(NSInteger)vcIndex;

@end
