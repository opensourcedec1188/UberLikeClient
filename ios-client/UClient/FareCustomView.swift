//
//  FareCustomView.swift
//  Ego
//
//  Created by Mahmoud Amer on 10/4/17.
//  Copyright © 2017 EasyTrip. All rights reserved.
//

import UIKit

class FareCustomView: UIView {

    @IBOutlet weak var CONTENTVIEW: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("FareCustomView", owner: self, options: nil)
        addSubview(CONTENTVIEW)
        CONTENTVIEW.frame = self.bounds
        
    }
    
}
