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

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic,assign) BOOL isCustomMessageView;

-(void)update:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

+(instancetype)emptyViewWithImageName:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant;

-(void)showInView:(UIView *)view viewType:(CoreListMessageViewType)viewType topMargin:(CGFloat)topMargin;
+(void)dismissFromView:(UIView *)sv;


@end
