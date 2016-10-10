//
//  TGCell.swift
//  CoreList
//
//  Created by 冯成林 on 16/1/4.
//  Copyright © 2016年 muxi. All rights reserved.
//

import UIKit


class TGCell: CoreListCollectionViewCell {

    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var tgTitleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    static var rid: String = "TGCell"
}

extension TGCell {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.borderColor = UIColor.grayColor().CGColor
        layer.borderWidth = 0.5
    }
    
    override class func dequeueReusableCellWithCollectionView(collectionView: UICollectionView!, indexPath: NSIndexPath!) -> TGCell! {
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(rid, forIndexPath: indexPath) as! TGCell
    }
    
    override func dataFill(coreModel: CoreModel!) {
        
        let tgModel = coreModel as! TGModel
        
        idLabel.text = "\(tgModel.hostID)"
        
        tgTitleLabel.text = tgModel.title;
        
        contentLabel.text = tgModel.content;
        
        typeLabel.text = "\(tgModel.score)"
    }
}