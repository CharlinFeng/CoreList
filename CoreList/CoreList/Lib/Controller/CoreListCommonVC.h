/*
 *  列表业务封装
 */

#import <UIKit/UIKit.h>
#import "ViewControllerListProtocol.h"
#import "CoreListCommonVCProtocol.h"


@interface CoreListCommonVC : UIViewController<ViewControllerListProtocol, CoreListCommonVCProtocol>

/** 数据数组 */
@property (nonatomic,strong) NSArray *dataList;

/** scrollView */
@property (nonatomic,strong) UIScrollView *scrollView;

/** 网络请求成功，但服务器抛出状态码错误的回调 */
@property (nonatomic,copy) void (^NetWorkErrorAction)();

/** 数据源有变化 */
@property (nonatomic,copy) void (^DataListChangedAction)();

@property (nonatomic,assign) BOOL isRefreshWhenViewDidAppeared;

/** 关闭shyNavBar功能 */
@property (nonatomic,assign) BOOL shyNavBarOff;

@property (nonatomic,assign) BOOL needOffCoreIVWhenNoData;

@property (nonatomic,weak) UIView *emptyView, *errorView;


/** 分类访问接口 */

/** 页码 */
@property (nonatomic,assign) NSUInteger page;

/** 刷新状态 */
@property (nonatomic,assign) ListVCRefreshActionType refreshType;

@property (nonatomic,assign) BOOL isRefreshData;

/** 是否有数据：影响提示视图显示 */
@property (nonatomic,assign) BOOL hasData;

/** 是否已经安装底部刷新控件 */
@property (nonatomic,assign) BOOL hasFooter;

/** 是否需要本地缓存 */
@property (nonatomic,assign) BOOL isNeedFMDB;

/** 模型定义的一页数据量 */
@property (nonatomic,assign) NSUInteger modelPageSize;

/** 返回顶部 */
@property (nonatomic,strong) UIButton *back2TopBtn;

/** 本地数据库没有数据了 */
@property (nonatomic,assign) BOOL localDataNil;

@property (nonatomic,assign) BOOL needCompareData;

@end
