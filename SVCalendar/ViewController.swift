//
//  ViewController.swift
//  SVCalendar
//
//  Created by Canopas on 22/10/18.
//  Copyright © 2018 Canopas Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var adapter:SVCalendarAdapter!
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.sectionHeadersPinToVisibleBounds = true
        adapter = SVCalendarAdapter(collectionView, self, year: 2018, startMonth: 1, totalMonth: 12)
    }


}

extension ViewController : SVCalendarAdapterDelegate {
    func calendar(_ adapter: SVCalendarAdapter, didSelect option: SVCalendarAdapter.SelectionType) {
        
    }
}

