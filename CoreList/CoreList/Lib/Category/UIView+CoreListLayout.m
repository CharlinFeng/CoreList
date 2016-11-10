//
//  UIView+CoreListLayout.m
//  CoreList
//
//  Created by 冯成林 on 15/11/28.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "UIView+CoreListLayout.h"

@implementation UIView (CoreListLayout)

-(void)autoLayoutFillSuperView {
    
    if(self.superview == nil) {return;}
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"v":self};
    
    NSArray *v_ver = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[v]-0-|" options:0 metrics:nil views:views];
    NSArray *h_hor = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:views];
    [self.superview addConstraints:v_ver];[self.superview addConstraints:h_hor];
}

-(void)autoLayoutFillSuperViewWithTopMargin:(CGFloat)topMargin{
    
    if(self.superview == nil) {return;}
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"v":self};
    NSDictionary *metrics = @{@"topMargin":@(topMargin)};
    NSArray *v_ver = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[v]-0-|" options:0 metrics:metrics views:views];
    NSArray *h_hor = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:metrics views:views];
    [self.superview addConstraints:v_ver];[self.superview addConstraints:h_hor];
}

@end
