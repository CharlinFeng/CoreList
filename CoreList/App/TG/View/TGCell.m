//
//  TGCell.m
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "TGCell.h"
#import "TGModel.h"

@interface TGCell ()

@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;


@end



@implementation TGCell

- (void)awakeFromNib {
    // Initialization code
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 2.5f;
}




-(void)dataFill:(TGModel *)tgModel{
    
    _idLabel.text = [NSString stringWithFormat:@"%@",@(tgModel.hostID)];
    
    _titleLabel.text = tgModel.title;
    
    _descLabel.text = tgModel.about;
    
    _contentLabel.text = tgModel.content;
    
    _typeLabel.text = [NSString stringWithFormat:@"%@",@(tgModel.type)];
}


@end
