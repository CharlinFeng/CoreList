//
//  CoreListCommonVC+ScrollView.m
//  CoreList
//
//  Created by 冯成林 on 15/12/19.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+ScrollView.h"
#import "CoreListCommonVC+BackBtn.h"

@interface CoreListCommonVC() <UIScrollViewDelegate>

@end


@implementation CoreListCommonVC (ScrollView)

-(void)scrollViewPrepare{

    self.scrollView.delegate = self;
}




-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    [self checkBackView:scrollView];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    [self checkBackView:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self checkBackView:scrollView];
}


-(void)checkBackView:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.y;
    
    if(offsetX >= 80){
        [self showBack2TopBtn];
    }else{
        [self dismissBack2TopBtn];
    }
}

@end
