//
//  ShopListCell.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "ShopListCell.h"
#import "ShopModel.h"

@interface ShopListCell ()


@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;





@end




@implementation ShopListCell


/**
 *  cell的创建
 */
+(instancetype)cellPrepare{
    return [super cellPrepare];
}


-(void)dataFill{
    
    //模型转换
    ShopModel *shopModel=(ShopModel *)self.model;
    
    _indexLabel.text=[NSString stringWithFormat:@"%i",shopModel.hostID];
    
    _titleLabel.text=shopModel.title;
    
    _descLabel.text=shopModel.content;
}






@end
