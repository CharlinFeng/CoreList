//
//  CoreListEmptyView.m
//  CoreList
//
//  Created by 冯成林 on 16/2/5.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreListEmptyView.h"

@interface CoreListEmptyView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTMC;
@end


@implementation CoreListEmptyView

+(instancetype)emptyViewWithImageName:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant{

    CoreListEmptyView *emptyView = [[NSBundle mainBundle] loadNibNamed:@"CoreListEmptyView" owner:nil options:nil].firstObject;

    [emptyView update:imageName desc:desc constant:constant];
    
    return emptyView;
}


-(void)update:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant{

    self.imageV.image = [UIImage imageNamed:imageName];
    
    self.descLabel.text = desc;
    
    self.labelTMC.constant = constant;
}

@end
