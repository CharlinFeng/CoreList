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















@end
