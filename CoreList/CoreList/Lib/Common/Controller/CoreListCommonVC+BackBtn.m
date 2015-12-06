//
//  CoreListCommonVC+BackBtn.m
//  CoreList
//
//  Created by 冯成林 on 15/12/6.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+BackBtn.h"

@implementation CoreListCommonVC (BackBtn)


/** 展示返回顶部按钮 */
-(void)showBack2TopBtn{
    
    [self animWithParam:1];
}


/** 隐藏返回顶部按钮 */
-(void)dismissBack2TopBtn{
    
    [self animWithParam:0];
}


/** 动画参数化 */
-(void)animWithParam:(CGFloat)alpha{
    
    if(self.back2TopBtn.alpha == alpha) return;
    
    [UIView animateWithDuration:.25f animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        self.back2TopBtn.alpha = alpha;
    }];
}


//-(UIButton *)back2TopBtn{
//    
//    if(_back2TopBtn == nil){
//        
//        _back2TopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_back2TopBtn setBackgroundImage:[UIImage imageNamed:@"CoreList.bundle/back_top"] forState:UIControlStateNormal];
//        
//        //隐藏
//        _back2TopBtn.alpha = 0;
//        
//        [_back2TopBtn addTarget:self action:@selector(back2Top) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_back2TopBtn];
//        
//        _back2TopBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        NSDictionary *views = @{@"back2TopBtn": _back2TopBtn};
//        
//        NSArray *v_hor = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[back2TopBtn(==40)]-20-|" options:0 metrics:nil views:views];
//        NSArray *v_ver = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[back2TopBtn(==40)]-60-|" options:0 metrics:nil views:views];
//        [self.view addConstraints:v_hor];[self.view addConstraints:v_ver];
//        
//        
//    }
//    
//    return _back2TopBtn;
//}


/** 返回顶部 */
-(void)back2Top{
    
    if([self.scrollView isKindOfClass:[UITableView class]]){//tableView
        
        UITableView *tableView = (UITableView *)self.scrollView;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else{
        
        
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}
@end
