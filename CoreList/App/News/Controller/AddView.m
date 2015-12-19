//
//  AddView.m
//  CoreList
//
//  Created by 冯成林 on 15/12/19.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "AddView.h"

@implementation AddView


+(instancetype)addView{

    return [[NSBundle mainBundle] loadNibNamed:@"AddView" owner:nil options:nil].firstObject;
}

- (IBAction)addAction:(id)sender {
    NSLog(@"点击添加");
}



@end
