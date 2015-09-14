#import "CoreModel.h"



@protocol CoreListCellProtocol <NSObject>

@optional

/** 数据填充 */
-(void)dataFill:(CoreModel *)coreModel;

@end
