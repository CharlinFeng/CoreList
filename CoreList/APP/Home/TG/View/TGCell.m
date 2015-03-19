//
//  TGCell.m
//  CoreListMVC
//
//  Created by 沐汐 on 15-3-11.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "TGCell.h"
#import "TGModel.h"

@interface TGCell ()

@property (strong, nonatomic) IBOutlet UILabel *noLabel;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *descLabel;



@end



@implementation TGCell



-(void)dataFill{
    
    //模型转换
    TGModel *tgModel=(TGModel *)self.model;
    
    self.noLabel.text=[NSString stringWithFormat:@"%i",tgModel.hostID];
    
    self.titleLabel.text=tgModel.title;
    
    self.descLabel.text=tgModel.content;
    
}





@end
