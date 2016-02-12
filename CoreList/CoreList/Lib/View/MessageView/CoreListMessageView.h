//
//  CoreListMessageView.h
//  CoreList
//
//  Created by 冯成林 on 16/2/5.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{

    CoreListMessageViewTypeNone,
    CoreListMessageViewTypeEmpty,
    CoreListMessageViewTypeError
    
} CoreListMessageViewType;

@interface CoreListMessageView : UIView

@property (nonatomic,copy) void (^ClickBlock)();

@property (nonatomic,assign) CoreListMessageViewType viewType;

-(void)update:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

+(instancetype)emptyViewWithImageName:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

-(void)showInView:(UIView *)view viewType:(CoreListMessageViewType)viewType needMainTread:(BOOL)needMainTread;
-(void)dismiss:(BOOL)anim needMainTread:(BOOL)needMainTread;

@end
