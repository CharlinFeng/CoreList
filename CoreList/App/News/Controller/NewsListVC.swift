//
//  NewsListVC.swift
//  CoreList
//
//  Created by 冯成林 on 16/1/3.
//  Copyright © 2016年 muxi. All rights reserved.
//

import UIKit

class NewsListVC: CoreListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.autoHideBars = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = UIViewController()
        
        vc.view.backgroundColor = UIColor.whiteColor()
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

/** 协议方法区 */
extension NewsListVC {
    
    /** 模型类 */
    override func listVC_Model_Class() -> AnyClass {return NewsListModel.self}
    
    /** 视图类 */
    override func listVC_View_Cell_Class() -> AnyClass {return NewsListCell.self}
    
    override func listVC_RefreshType() -> ListVCRefreshAddType {
        return ListVCRefreshAddTypeBoth
    }
    
    /** 自定义空视图 */
    override func listVC_StatusView_Empty() -> AnyObject! {
        
//        return nil
        
        
//        let v = UIView()
//        v.backgroundColor = UIColor.blueColor()
//        return v
        
        return ["0","没有数据",60]
    }

    /** 自定义错误视图 */
    override func listVC_StatusView_Error() -> AnyObject! {
        
                return nil
        
        
//                let v = UIView()
//                v.backgroundColor = UIColor.redColor()
//                return v
        
//        return ["0","请求失败",60]
    }
    
    /** 参数 */
    override func listVC_Request_Params() -> [NSObject : AnyObject]! {return nil}
    
    /** 忽略参数 */
    override func listVC_Ignore_Params() -> [AnyObject]! {return nil}
    
    /** 无本地FMDB缓存的情况下，需要在ViewDidAppear中定期自动触发顶部刷新事件 */
    override func listVC_Update_Delay_Key() -> String! {return NSStringFromClass(self.dynamicType)}
}


