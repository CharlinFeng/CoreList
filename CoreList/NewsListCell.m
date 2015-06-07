//
//  NewsListCell.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "NewsListCell.h"
#import "NewsListModel.h"

@interface NewsListCell ()

@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;





@end



@implementation NewsListCell

-(void)dataFill:(NewsListModel *)newsListModel{
    
    _idLabel.text = [NSString stringWithFormat:@"%@",@(newsListModel.hostID)];
    
    _titleLabel.text = newsListModel.title;
    
    _descLabel.text = newsListModel.about;
    
    _contentLabel.text = newsListModel.content;
}

















@end
