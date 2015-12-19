//
//  ErrorView.m
//  CoreList
//
//  Created by 冯成林 on 15/12/19.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "ErrorView.h"

@interface ErrorView ()

@property (nonatomic,copy) void (^ClickAction)();

@end

@implementation ErrorView

+(instancetype)errorViewWithClickAction:(void(^)())clickAction{

    ErrorView *errorView = [[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:nil options:nil].firstObject;
    
    errorView.ClickAction = clickAction;

    return errorView;
}

- (IBAction)clickAction:(id)sender {
    
    if(self.ClickAction != nil) {self.ClickAction();}
}



@end
