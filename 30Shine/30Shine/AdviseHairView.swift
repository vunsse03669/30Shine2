//
//  AdviseHairView.swift
//  30Shine
//
//  Created by Apple on 8/22/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire

class AdviseHairView: UIView {

    @IBOutlet weak var tbvProduct: UITableView!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func createView(parentView : UIView) -> AdviseHairView {
        let adviseView = NSBundle.mainBundle().loadNibNamed("", owner: self, options: nil) [0] as! AdviseHairView
        let frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.width)
        adviseView.frame = frame
        parentView.addSubview(adviseView)
        
        return adviseView
    }
    
    //MARK: config tableview
    func configTableView() {
        self.tbvProduct.registerNib(UINib.init(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        self.tbvProduct.rowHeight = 120
    }
    
    //MARK: config data
    func configData() {
    
    }
}
