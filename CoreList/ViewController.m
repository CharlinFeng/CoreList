//
//  ViewController.m
//  CoreList
//
//  Created by muxi on 15/3/18.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "ViewController.h"
#import "CoreList-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)showTableViewListVC:(id)sender {
    
    NewsListVC *newsListVC  = [[NewsListVC alloc] init];
//    newsListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newsListVC animated:YES];
}


- (IBAction)showCollectionViewListVC:(id)sender {
    
    TGListCVC *tgListCVC = [[TGListCVC alloc] init];
    
    [self.navigationController pushViewController:tgListCVC animated:YES];
}






@end
