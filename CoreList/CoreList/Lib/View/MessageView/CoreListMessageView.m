//
//  CoreListMessageView.m
//  CoreList
//
//  Created by 冯成林 on 16/2/5.
//  Copyright © 2016年 muxi. All rights reserved.
//

#import "CoreListMessageView.h"
#import "UIView+CoreListLayout.h"

@interface CoreListMessageView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTMC;



@end


@implementation CoreListMessageView

+(instancetype)emptyViewWithImageName:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant{

    CoreListMessageView *emptyView = [[NSBundle mainBundle] loadNibNamed:@"CoreListMessageView" owner:nil options:nil].firstObject;

    [emptyView update:imageName desc:desc constant:constant];
    
    return emptyView;
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
}

-(void)update:(NSString *)imageName desc:(NSString *)desc constant:(CGFloat)constant{

    self.imageV.image = [UIImage imageNamed:imageName];
    
    self.descLabel.text = desc;
    
    self.labelTMC.constant = constant;
}

-(void)showInView:(UIView *)view viewType:(CoreListMessageViewType)viewType{
    
    if([NSThread isMainThread]){
        [CoreListMessageView dismissFromView:view];
        [view addSubview:self];
        self.alpha = 1;
        [self autoLayoutFillSuperView];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CoreListMessageView dismissFromView:view];
            [view addSubview:self];
            self.alpha = 1;
            [self autoLayoutFillSuperView];
        });
    }
}


+(void)dismissFromView:(UIView *)sv{

    BOOL isMainThread = [NSThread isMainThread];
    
    if(isMainThread){
        
        [sv.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if([subview isKindOfClass:[CoreListMessageView class]]){
                
                [subview removeFromSuperview];
            }
        }];
        
    }else{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [sv.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if([subview isKindOfClass:[CoreListMessageView class]]){
                    
                    [subview removeFromSuperview];
                }
            }];
        });
    }
}

- (IBAction)clickAction:(id)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(self.ClickBlock != nil){self.ClickBlock();}
    });
}



@end
