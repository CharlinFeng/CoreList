//
//  CoreListCollectionViewController.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListCommonVC.h"

@interface CoreListCollectionViewController : CoreListCommonVC<UICollectionViewDataSource,UICollectionViewDelegate>


@property (nonatomic,strong) UICollectionView *collectionView;



@end
