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

extension NewsListCell {
    
    
    
    override class func dequeReuseCell(tableView: UITableView!) -> CoreListTableViewCell!{
        
        var cell: CoreListTableViewCell! = tableView.dequeueReusableCellWithIdentifier(rid) as? CoreListTableViewCell
        
        if cell == nil {cell = NSBundle.mainBundle().loadNibNamed(rid, owner: nil, options: nil).first as! CoreListTableViewCell}
        
        return cell!
    }
    
    
    
    override func dataFill(coreModel: CoreModel!) {
        
        let model = coreModel as! NewsListModel
    
        idLabel.text = "\(model.hostID)"
        
        titleLabel.text = model.title;
        
        descLabel.text = model.about;
        
        contentLabel.text = model.content;
        
        typeLabel.text = "\(model.type)"
        
    }
}