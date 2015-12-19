//
//  CoreListCommonVC+ScrollView.m
//  CoreList
//
//  Created by 冯成林 on 15/12/19.
//  Copyright © 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC+ScrollView.h"
#import "UIViewController+ScrollingNavbar.h"
#import "CoreListCommonVC+BackBtn.h"

@interface CoreListCommonVC() <UIScrollViewDelegate>

@end


@implementation CoreListCommonVC (ScrollView)

-(void)scrollViewPrepare{

    self.scrollView.delegate = self;
}


-(void)navBarShow{
    [self showNavBarAnimated:YES];
}

-(void)navBarScroll_Enable{
    [self followScrollView:self.scrollView];
}

-(void)navBarScroll_Disable{
    [self stopFollowingScrollView];
}


-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    CGFloat offsetX = scrollView.contentOffset.y;
    
    if(offsetX >= 80){
        [self showBack2TopBtn];
    }else{
        [self dismissBack2TopBtn];
    }
    
}

@end
