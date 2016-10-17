//
//  NSString+Equal.h
//  CoreList
//
//  Created by 冯成林 on 15/9/11.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CoreListExtend)

@property (nonatomic,copy) NSString *host;

-(CGFloat)calTextHWithLeftMargin:(CGFloat)l rightMargin:(CGFloat)r fontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpacing;

@end
