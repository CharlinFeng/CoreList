//
//  TGCell.m
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "TGCell.h"
#import "TGModel.h"
#import "UIView+Extend.h"

@interface TGCell ()

@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end



@implementation TGCell

- (void)awakeFromNib {
    // Initialization code
    [self setBorder:[UIColor lightGrayColor] width:.5f];
}



-(void)dataFill:(TGModel *)tgModel{
    
    _idLabel.text = [NSString stringWithFormat:@"%@",@(tgModel.hostID)];
    
    _titleLabel.text = tgModel.title;
    
    _descLabel.text = tgModel.about;
    
    _contentLabel.text = tgModel.content;
}


@end
