//
//  CoreListEmptyView.h
//  CoreList
//
//  Created by 冯成林 on 16/2/5.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreListEmptyView : UIView

-(void)update:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

+(instancetype)emptyViewWithImageName:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

@end
