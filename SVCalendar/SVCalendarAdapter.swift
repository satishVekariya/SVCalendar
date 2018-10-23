//
//  SVCalendarAdapter.swift
//  SVCalendar
//
//  Created by Canopas on 22/10/18.
//  Copyright © 2018 Canopas Inc. All rights reserved.
//

import UIKit

protocol SVCalendarAdapterDelegate: class {
    func calendar(_ adapter: SVCalendarAdapter, didSelect option: SVCalendarAdapter.SelectionType)
}

class SVCalendarAdapter: NSObject {
    let CELL_DATE = "dateCell"
    let CELL_HEADER = "headerView"
    
    enum SelectionType {
        case Date(Date)
    }
    
    let collectionView:UICollectionView
    weak var delegate:SVCalendarAdapterDelegate!
    fileprivate(set) open var startYear: Int
    fileprivate(set) open var endYear: Int
    let startMonth:Int
    let totalMonth:Int
    var startDate:Date {
        return Date(year: startYear, month: startMonth, day: 1)
    }
    
    init(_ collectionView:UICollectionView, _ delegate:SVCalendarAdapterDelegate, year:Int, startMonth:Int, totalMonth:Int) {
        self.collectionView = collectionView
        self.delegate = delegate
        self.startYear = year
        self.endYear = year
        self.startMonth = min(startMonth, 12)
        self.totalMonth = totalMonth
        
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib.init(nibName: "SVCalenderDateCell", bundle: .main), forCellWithReuseIdentifier: CELL_DATE)
        collectionView.register(UINib.init(nibName: "SVCalenderHeaderView", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CELL_HEADER)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension SVCalendarAdapter: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if startYear > endYear {
            return 0
        }
        return totalMonth
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDayOfMonth = startDate.dateByAddingMonths(section)
        let addingPrefixDaysWithMonthDyas = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - Calendar.current.firstWeekday )
        let addingSuffixDays = addingPrefixDaysWithMonthDyas % 7
        var totalNumber  = addingPrefixDaysWithMonthDyas
        if addingSuffixDays != 0 {
            totalNumber = totalNumber + (7 - addingSuffixDays)
        }
        
        return totalNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_DATE, for: indexPath) as! SVCalenderDateCell
        let firstDayOfThisMonth = startDate.dateByAddingMonths(indexPath.section)
        let prefixDays = ( firstDayOfThisMonth.weekday() - Calendar.current.firstWeekday)
    
        if indexPath.row >= prefixDays {
            let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
            let nextMonthFirstDay = firstDayOfThisMonth.dateByAddingDays(firstDayOfThisMonth.numberOfDaysInMonth()-1)
            if currentDate > nextMonthFirstDay {
                cell.textLabel.text = nil
                cell.leftBorder.isHidden = currentDate.day() != 1
                cell.rightBorder.isHidden = true
            } else {
                cell.textLabel.text = "\(currentDate.day())"
                cell.textLabel.textColor = currentDate.isSunday() ? UIColor.red : UIColor.purple
                cell.leftBorder.isHidden = false
                cell.rightBorder.isHidden = !currentDate.isSaturday()
            }
        } else {
            cell.textLabel.text = nil
            cell.leftBorder.isHidden = true
            cell.rightBorder.isHidden = true
        }
        
        let lastIndex = collectionView.numberOfItems(inSection: indexPath.section)
        let isLastRow = ((lastIndex - 7)...lastIndex).contains(indexPath.row)
        cell.topBorder.isHidden = false
        cell.bottomBorder.isHidden = !isLastRow
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CELL_HEADER, for: indexPath) as! SVCalenderHeaderView
        let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
        view.monthLabel.text = firstDayOfMonth.monthNameFull()
        return view
    }
}

extension SVCalendarAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let cellWidth = collectionView.frame.width - sectionInset.left - sectionInset.right
        return CGSize(width: cellWidth/7, height: cellWidth/7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionInset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
        let cellWidth = collectionView.frame.width - sectionInset.left - sectionInset.right
        return CGSize(width: cellWidth, height: 44)
    }
    
    
}

extension SVCalendarAdapter {
    static func getCurrentYear() -> Int {
        return Date().year()
    }
    
    static func getCurrentMonth() -> Int {
        return Date().month()
    }
}

fileprivate extension Date {
    init(year : Int, month : Int, day : Int) {
        
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        self = calendar.date(from: dateComponent)!
    }
    func weekday() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.weekday, from: self)
        return dateComponent.weekday!
    }
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let days = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return days.length
    }
    
    func dateByAddingMonths(_ months : Int ) -> Date {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.month = months
        return (calendar as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options.matchNextTime)!
    }
    
    func dateByAddingDays(_ days : Int ) -> Date {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = days
        return (calendar as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options.matchNextTime)!
    }
    
    func day() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.day, from: self)
        return dateComponent.day!
    }
    
    func isSaturday() -> Bool {
        return (self.getWeekday() == 7)
    }
    
    func isSunday() -> Bool {
        return getWeekday() == 1
    }
    
    func getWeekday() -> Int {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components( .weekday, from: self).weekday!
    }
    
    func monthNameFull() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        return dateFormatter.string(from: self)
    }
    
    func month() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.month, from: self)
        return dateComponent.month!
    }
    
    func year() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.year, from: self)
        return dateComponent.year!
    }
    
    static func ==(lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedSame
    }
    
    static func <(lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }
    
    static func >(lhs: Date, rhs: Date) -> Bool {
        return rhs.compare(lhs) == ComparisonResult.orderedAscending
    }
}
