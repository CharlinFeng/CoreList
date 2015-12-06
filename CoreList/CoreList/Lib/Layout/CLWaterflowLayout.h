//
//  CoreListCollectionViewController.h
//  CoreList
//
//  Created by 成林 on 15/6/5.
//  Copyright (c) 2015年 muxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLWaterflowLayout;

@protocol CLWaterflowLayoutDelegate <NSObject>

- (CGFloat)waterflowLayout:(CLWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath;

@end

@interface CLWaterflowLayout : UICollectionViewLayout

@property (nonatomic, assign) UIEdgeInsets sectionInset;

/** 每一列之间的间距 */
@property (nonatomic, assign) CGFloat columnMargin;

/** 每一行之间的间距 */
@property (nonatomic, assign) CGFloat rowMargin;

/** 显示多少列 */
@property (nonatomic, assign) int columnsCount;

@property (nonatomic, weak) id<CLWaterflowLayoutDelegate> delegate;

@end
