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


-(CGFloat)calTextHWithLeftMargin:(CGFloat)l rightMargin:(CGFloat)r fontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpacing{
    
    CGFloat maxW = [UIScreen mainScreen].bounds.size.width - l - r;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    CGFloat contentH = [self boundingRectWithSize:CGSizeMake(maxW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
    
    return contentH;
}

@end
