//
//  ViewControllerListProtocol.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//
#import "CoreListType.h"

@protocol ViewControllerListProtocol <NSObject>





-(void)showTipsWithTitle:(NSString *)title desc:(NSString *)desc offsetY:(CGFloat)offsetY clickBlock:(void(^)())clickBlock;

-(void)dismissTipsView;

/** 刷新页面数据 */
-(void)refreshData;







@required

/** 协议方法区 */


/** 刷新方式 */
-(ListVCRefreshAddType)listVC_RefreshType;


/** 模型类 */
-(Class)listVC_Model_Class;


/** 视图类 */
-(Class)listVC_View_Cell_Class;


/** 请求参数 */
-(NSDictionary *)listVC_Request_Params;


/** 忽略参数 */
-(NSArray *)listVC_Ignore_Params;





@optional

/** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
-(NSString *)listVC_Update_Delay_Key;



/** 数据方法区 */

/** 刷新数据 */
-(void)reloadData;


/** collectionView专有方法 */
-(UICollectionViewLayout *)listVC_CollectionViewLayout;

@end