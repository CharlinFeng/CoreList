//
//  TGLIstCVC.m
//  CoreList
//
//  Created by 成林 on 15/6/7.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import "TGLIstCVC.h"
#import "TGModel.h"
#import "TGCell.h"

@interface TGLIstCVC ()<CLWaterflowLayoutDelegate>

@end

@implementation TGLIstCVC

- (void)viewDidLoad {

    [super viewDidLoad];
    
}


/** 协议方法区 */


/** 刷新方式 */
-(ListVCRefreshAddType)listVC_RefreshType{
    return ListVCRefreshAddTypeBoth;
}


/** 模型类 */
-(Class)listVC_Model_Class{
    return [TGModel class];
}


/** 视图类 */
-(Class)listVC_View_Cell_Class{
    return [TGCell class];
}

/** 请求参数 */
-(NSDictionary *)listVC_Request_Params{
    return nil;
    return @{@"mobile":@"13540033473",@"user":@"admin"};
}

/** 忽略参数 */
-(NSArray *)listVC_Ignore_Params{
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


/** 是否关闭返回顶部功能 */
-(BOOL)removeBack2TopBtn{
    return NO;
}


///** collectionView专有方法 */
//-(UICollectionViewLayout *)listVC_CollectionViewLayout{
//    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    
//    layout.itemSize = CGSizeMake(100, 100);
//    
//    layout.minimumInteritemSpacing = 5;
//    
//    layout.minimumLineSpacing = 5;
//    
//    return layout;
//}

/** 是否为瀑布流布局 */
-(BOOL)listVC_IsWaterFlowLayout{
    return YES;
}


-(CGFloat)waterflowLayout:(CLWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath{

    return [self.dataList[indexPath.row] cellH];
}

@end
