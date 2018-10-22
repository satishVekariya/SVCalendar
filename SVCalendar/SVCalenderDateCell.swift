//
//  SVCalenderDateCell.swift
//  SVCalendar
//
//  Created by Canopas on 22/10/18.
//  Copyright © 2018 Canopas Inc. All rights reserved.
//

import UIKit

class SVCalenderDateCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var topBorder: UIView!
    @IBOutlet weak var bottomBorder: UIView!
    @IBOutlet weak var leftBorder: UIView!
    @IBOutlet weak var rightBorder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func hideAllBorder() {
        topBorder.isHidden = true
        bottomBorder.isHidden = true
        leftBorder.isHidden = true
        rightBorder.isHidden = true
    }

}
