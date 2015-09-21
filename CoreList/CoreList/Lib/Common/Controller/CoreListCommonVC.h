/*
 *  列表业务封装
 */

#import <UIKit/UIKit.h>
#import "ViewControllerListProtocol.h"


@interface CoreListCommonVC : UIViewController<ViewControllerListProtocol>

/** 数据数组 */
@property (nonatomic,strong) NSArray *dataList;

/** scrollView */
@property (nonatomic,strong) UIScrollView *scrollView;

/** 网络请求成功，但服务器抛出状态码错误的回调 */
@property (nonatomic,copy) void (^NetWorkErrorAction)();

/** 数据源有变化 */
@property (nonatomic,copy) void (^DataListChangedAction)();

@property (nonatomic,assign) BOOL isRefreshWhenViewDidAppeared;

@end
