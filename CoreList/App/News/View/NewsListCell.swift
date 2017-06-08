//
//  NewsListCell.swift
//  CoreList
//
//  Created by 冯成林 on 16/1/3.
//  Copyright © 2016年 muxi. All rights reserved.
//

import UIKit

class NewsListCell: CoreListTableViewCell {

    @IBOutlet weak var idLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    static let rid : String = "NewsListCell"

    
}



//extension NewsListCell {
//    
//    
//    
//    override class func dequeReuse(_ tableView: UITableView!) -> CoreListTableViewCell!{
//        
//        var cell: CoreListTableViewCell! = tableView.dequeueReusableCell(withIdentifier: rid) as? CoreListTableViewCell
//        
//        if cell == nil {cell = Bundle.main.loadNibNamed(rid, owner: nil, options: nil)?.first as! CoreListTableViewCell}
//        
//        return cell!
//    }
//    
//    
//    
//    override func dataFill(_ coreModel: CoreModel!) {
//        
//        let model = coreModel as! NewsListModel
//    
//        idLabel.text = "\(model.hostID)"
//        
//        titleLabel.text = model.title;
//
//        contentLabel.text = model.content;
//        
//        typeLabel.text = "\(model.score)"
//        
//    }
//}
