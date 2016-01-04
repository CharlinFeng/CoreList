//
//  CoreListCollectionViewController.m
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "CoreListCollectionViewController.h"
#import "CoreListCollectionViewCell.h"
#import "CoreListConst.h"
#import "UIView+CoreListLayout.h"


@interface CoreListCollectionViewController ()

@end

@implementation CoreListCollectionViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //控制器准备
    [self vcPreare];
}



/** 控制器准备 */
-(void)vcPreare{
    
    //设置背景色
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //注册cell
    [[self listVC_View_Cell_Class] registerNibForCollectionView:self.collectionView];
}





-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(self.dataList == nil) return 0;
    
    return self.dataList.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //取出复用cell
    CoreListCollectionViewCell *cell = [[self listVC_View_Cell_Class] dequeueReusableCellWithCollectionView:collectionView indexPath:indexPath];
    
    cell.model = self.dataList[indexPath.item];
    
    return cell;
}



/** collectionView */
-(UICollectionView *)collectionView{
    
    if(_collectionView == nil){
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self listVC_CollectionViewLayout];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        //设置数据库源
        _collectionView.dataSource = self;
        //设置代理
        _collectionView.delegate = self;
        
        [self.view addSubview:_collectionView];
        
        CGFloat topPadding = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        if(ios7x) _collectionView.contentInset = UIEdgeInsetsMake(topPadding, 0, 0, 0);
        _collectionView.contentOffset = CGPointMake(-topPadding, 0);
        
        [_collectionView autoLayoutFillSuperView];
    }
    
    return _collectionView;
}


/** 父类值填充 */
-(UIScrollView *)scrollView{
    
    return self.collectionView;
}








/** 刷新数据 */
-(void)reloadData{
    [self.collectionView reloadData];
}

/** 动态刷新 */
-(void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    
    [self reloadData];
}









/** 协议方法区 */


/** 刷新方式 */
-(ListVCRefreshAddType)listVC_RefreshType{
    return ListVCRefreshAddTypeBoth;
}


/** 模型类 */
-(Class)listVC_Model_Class{
    return nil;
}


/** 视图类 */
-(Class)listVC_View_Cell_Class{
    return nil;
}


/** 是否移除回到顶部按钮 */
-(BOOL)listVC_Remove_Back2Top_Button{
    return NO;
}




/** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
-(NSString *)listVC_Update_Delay_Key{
    return NSStringFromClass(self.class);
}


/** 无缓存定期更新周期 */
-(NSTimeInterval)listVC_Update_Delay_Time{
    return 10;
}

/** 是否关闭返回顶部功能 */
-(BOOL)removeBack2TopBtn{
    return NO;
}

/** collectionView专有方法 */
-(UICollectionViewLayout *)listVC_CollectionViewLayout{

    if([self listVC_IsWaterFlowLayout]){
        
        CLWaterflowLayout *waterlayout = [[CLWaterflowLayout alloc] init];
        
        waterlayout.delegate = self;
        
        return waterlayout;
    }
    return nil;
}

/** 是否为瀑布流布局 */
-(BOOL)listVC_IsWaterFlowLayout{
    return NO;
}


@end
