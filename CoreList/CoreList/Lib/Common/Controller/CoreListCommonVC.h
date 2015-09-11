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


-(void)showTipsWithTitle:(NSString *)title desc:(NSString *)desc offsetY:(CGFloat)offsetY clickBlock:(void(^)())clickBlock;

-(void)dismissTipsView;


/** 刷新页面数据 */
-(void)refreshData;



@end
