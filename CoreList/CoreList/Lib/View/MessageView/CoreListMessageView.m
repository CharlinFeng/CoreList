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

-(void)showInView:(UIView *)view viewType:(CoreListMessageViewType)viewType needMainTread:(BOOL)needMainTread{
    NSLog(@"来了几次？？？");
    __block BOOL hasMessageView = NO;
    
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"-----%@",NSStringFromClass([obj class]));
        if([obj isKindOfClass:[self class]]){
        
            CoreListMessageView *view_temp = obj;
            NSLog(@"viewType----%d",view_temp.viewType);
            if(view_temp.viewType == viewType){
            
                hasMessageView = YES;
                *stop = YES;
            }
        }
        
    }];
    
    if(hasMessageView){
    
        NSLog(@"已经有了");
        return;
    }else {
    
        NSLog(@"还没有发现");
    }
    

    if(needMainTread){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [view addSubview:self];
            self.alpha = 1;
        });
    }else{
    
        [view addSubview:self];
        self.alpha = 1;
    }

    [self autoLayoutFillSuperView];
}

-(void)dismiss:(BOOL)anim needMainTread:(BOOL)needMainTread{
    
    if(needMainTread){
    
        if(anim){
            
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                
                [self removeFromSuperview];
            }];
            
        }else{
            [self removeFromSuperview];
        }
        
    }else{
    
        if(anim){
            
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                
                [self removeFromSuperview];
            }];
            
        }else{
            [self removeFromSuperview];
        }
    }
}

- (IBAction)clickAction:(id)sender {
    
    [self dismiss:YES needMainTread:NO];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(self.ClickBlock != nil){self.ClickBlock();}
    });
}



@end
