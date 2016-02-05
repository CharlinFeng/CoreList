//
//  TGListCVC.swift
//  CoreList
//
//  Created by 冯成林 on 16/1/4.
//  Copyright © 2016年 muxi. All rights reserved.
//

import UIKit

class TGListCVC: CoreListCollectionViewController, CLWaterflowLayoutDelegate {


}

extension TGListCVC {

    /** 协议方法区 */
    /** 模型类 */
    override func listVC_Model_Class() -> AnyClass! {return TGModel.self}
    
    /** 视图类 */
    override func listVC_View_Cell_Class() -> AnyClass! {return TGCell.self}
    
    /** 自定义空视图 */
    override func listVC_StatusView_Empty() -> AnyObject! {
        return nil
    }
    
    /** 自定义错误视图 */
    override func listVC_StatusView_Error() -> AnyObject! {
        return nil
    }
    /** 请求参数 */
    override func listVC_Request_Params() -> [NSObject : AnyObject]! {return nil}

    /** 忽略参数 */
    override func listVC_Ignore_Params() -> [AnyObject]! {return nil}

    
    /** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
    override func listVC_Update_Delay_Key() -> String! {return "\(self.dynamicType)"}

    /** collectionView专有方法 */
    override func listVC_CollectionViewLayout() -> UICollectionViewLayout! {
        
        if !listVC_IsWaterFlowLayout() {
            
            return nil

        }else {
        
            let waterlayout = CLWaterflowLayout()
            
            waterlayout.delegate = self
            
            return waterlayout
        }
    }
    
    /** 是否为瀑布流布局 */
    override func listVC_IsWaterFlowLayout() -> Bool {return true}
    
    /** 瀑布流高度 */
    func waterflowLayout(waterflowLayout: CLWaterflowLayout!, heightForWidth width: CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let tgModel = dataList[indexPath.row] as! TGModel
        
        return tgModel.cellH
    }
}







