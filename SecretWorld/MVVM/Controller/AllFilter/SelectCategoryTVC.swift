//
//  SelectCategoryTVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 09/01/25.
//

import UIKit

class SelectCategoryTVC: UITableViewCell {

    @IBOutlet weak var heightCategoryVw: NSLayoutConstraint!
    @IBOutlet weak var collVwCategory: UICollectionView!

    var type = 0
    var section = 0
    var dataSource: [String] = []
    var taskTypeData: [Int] = []
    var distanceData: [Int] = []
    var taskDurationData: [Int] = []
    var payoutRangeData: [Int] = []
    var urgencyData: [Int] = []
    var spotsData: [Int] = []
    var callBack0:((_ data:[Int])->())?
    var callBack1:((_ data:[Int])->())?
    var callBack2:((_ data:[Int])->())?
    var callBack3:((_ data:[Int])->())?
    var callBack4:((_ data:[Int])->())?
    var callBack5:((_ data:[Int])->())?
    
    var callBackCategory:((_ data:[Int])->())?
    var callBackDateTime:((_ data:[Int])->())?
    var callBackAvailability:((_ data:[Int])->())?
    var callBackRatingReview:((_ data:[Int])->())?
    
    var callBackBusinessCategory:((_ data:[Int])->())?
    var callBackDealOffer:((_ data:[Int])->())?
    var callBackHours:((_ data:[Int])->())?
    var callBackCustomerRating:((_ data:[Int])->())?
    var callBackSpeacialFeature:((_ data:[Int])->())?
    
    var categoryData:[Int] = []
    var dateTimeData:[Int] = []
    var avaibilityData:[Int] = []
    var ratingReviewData:[Int] = []
    
    var businessCategoryData:[Int] = []
    var dealsOfferData:[Int] = []
    var hoursData:[Int] = []
    var customerRatingData:[Int] = []
    var speacialFeatureData:[Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "SelectCategoryCVC", bundle: nil)
        collVwCategory.register(nib, forCellWithReuseIdentifier: "SelectCategoryCVC")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func uiSet(for section: Int,type:Int) {
        self.section = section
        // Assign data based on the section
        if type == 1{
            switch section {
            case 0:
    
                dataSource = ["Quick help", "Skilled tasks", "Collaborative tasks"]
                heightCategoryVw.constant = 70
            case 1:
                dataSource = ["Within 5 miles", "Within 15 miles", "Remote"]
                heightCategoryVw.constant = 70
            case 2:
                dataSource = ["Short", "Medium","Long"]
                heightCategoryVw.constant = 70
            case 3:
                dataSource = ["Short", "Medium","Long"]
                heightCategoryVw.constant = 70
            case 4:
                dataSource = ["Scheduled task", "Same day","Immediate (within 2 hours)"]
               
                heightCategoryVw.constant = 70
            case 5:
                dataSource = ["Solo tasks", "Group tasks"]
                heightCategoryVw.constant = 35
            default:
                dataSource = []
            }
        }else if type == 2{
            switch section {
            case 0:
                dataSource = ["Food & drinks", "Services", "Crafts & goods", "Events"]
                heightCategoryVw.constant = 70
            case 1:
                dataSource = ["Happening now", "Today", "This week"]
                heightCategoryVw.constant = 70
            case 2:
                dataSource = ["Open slots", "Fully booked"]
                heightCategoryVw.constant = 35
            case 3:
                dataSource = ["Most Popular", "Recently reviewed"]
                heightCategoryVw.constant = 35
            default:
                dataSource = []
            }
        }else{
            switch section {
            case 0:
                dataSource = ["Restaurants", "Retail", "Beauty & wellness", "Events"]
                heightCategoryVw.constant = 70
            case 1:
                dataSource = ["Discount", "Buy-one-get-one", "Loyalty programs"]
                heightCategoryVw.constant = 70
            case 2:
                dataSource = ["Open now", "Open later today","All businesses"]
                heightCategoryVw.constant = 70
            case 3:
                dataSource = ["Highest rated", "Most reviewed"]
                heightCategoryVw.constant = 35
            case 4:
                dataSource = ["Kid-friendly", "Vegan","Vegetarian","Pet-friendly"]
                heightCategoryVw.constant = 70
            default:
                dataSource = []
            }
        }
      
        collVwCategory.delegate = self
        collVwCategory.dataSource = self
        collVwCategory.reloadData()
    }
 
}

extension SelectCategoryTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCategoryCVC", for: indexPath) as! SelectCategoryCVC
        cell.lblCategory.text = dataSource[indexPath.row]
       
        if type == 1{
            if section == 0{
                let storeData = Store.filterData?["taskType"] as? [Int] ?? []
                print("storeData----",Store.filterData?["taskType"] as? [Int] ?? [])
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    taskTypeData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            }else if section == 1{
                let storeData = Store.taskMiles
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    distanceData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            }else if section == 2{
                let storeData = Store.filterData?["taskDuration"] as? [Int] ?? []
                print("storeData1----",Store.filterData?["taskDuration"] as? [Int] ?? [])
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    taskDurationData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            }else if section == 3{
                let storeData = Store.filterData?["payoutRange"] as? [Int] ?? []
                print("storeData2----",Store.filterData?["payoutRange"] as? [Int] ?? [])
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    payoutRangeData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            }else if section == 5{
                let storeData = Store.filterData?["spotLeft"] as? [Int] ?? []
                print("storeData3----",Store.filterData?["spotLeft"] as? [Int] ?? [])
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    spotsData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            }else if section == 4{
                let storeData = Store.filterData?["urgency"] as? [Int] ?? []
                print("storeData4----",Store.filterData?["urgency"] as? [Int] ?? [])
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    urgencyData = Store.filterData?["urgency"] as? [Int] ?? []
                }else{
                    cell.btnTick.isSelected = false
                }
            }
        }else if type == 2{
            switch section{
            case 0:
                let storeData = Store.filterDataPopUp?["category"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    categoryData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 1:
                let storeData = Store.filterDataPopUp?["dateAndTime"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    dateTimeData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 2:
                let storeData = Store.filterDataPopUp?["availiability"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    avaibilityData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 3:
                let storeData = Store.filterDataPopUp?["ratingAndReviews"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    ratingReviewData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            default:
                break
            }
        }else{
            switch section{
            case 0:
                let storeData = Store.filterDataBusiness?["category"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    businessCategoryData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 1:
                let storeData = Store.filterDataBusiness?["dealsAndOffer"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    dealsOfferData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 2:
                let storeData = Store.filterDataBusiness?["hours"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    hoursData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 3:
                let storeData = Store.filterDataBusiness?["customerRatings"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    customerRatingData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            case 4:
                let storeData = Store.filterDataBusiness?["specialFeature"] as? [Int] ?? []
               
                if storeData.contains(indexPath.row+1){
                    cell.btnTick.isSelected = true
                    speacialFeatureData.append(indexPath.row+1)
                }else{
                    cell.btnTick.isSelected = false
                }
            default:
                break
            }
        }
       
        cell.btnTick.addTarget(self, action: #selector(tickUntick), for: .touchUpInside)
        cell.btnTick.tag = indexPath.row
        return cell
    }

    @objc func tickUntick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
          let index = sender.tag
          let section = self.section
        if type == 1{
            switch section {
            case 0:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    taskTypeData.append(selectedItem) // Add the item to the taskTypeDat
                } else {
                    if let itemIndex = taskTypeData.firstIndex(of: selectedItem) {
                        taskTypeData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack0?(taskTypeData)
                
            case 1:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    distanceData.append(selectedItem) // Add the item to the taskTypeData
                } else {
                    if let itemIndex = distanceData.firstIndex(of: selectedItem) {
                        distanceData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack1?(distanceData)
                
            case 2:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    taskDurationData.append(selectedItem) // Add the item to the taskTypeData
                } else {
                    if let itemIndex = taskDurationData.firstIndex(of: selectedItem) {
                        taskDurationData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack2?(taskDurationData)
            case 3:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    payoutRangeData.append(selectedItem) // Add the item to the taskTypeData
                } else {
                    if let itemIndex = payoutRangeData.firstIndex(of: selectedItem) {
                        payoutRangeData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack3?(payoutRangeData)
                
            case 4:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    urgencyData.append(selectedItem) // Add the item to the taskTypeData
                } else {
                    if let itemIndex = urgencyData.firstIndex(of: selectedItem) {
                        urgencyData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack4?(urgencyData)
            case 5:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    spotsData.append(selectedItem) // Add the item to the taskTypeData
                } else {
                    if let itemIndex = spotsData.firstIndex(of: selectedItem) {
                        spotsData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
                callBack5?(spotsData)
                
            default:
                break
            }
        }else if type == 2{
            switch section {
            
            case 0:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    categoryData.append(selectedItem) // Add the item to the taskTypeDat
                } else {
                    if let itemIndex = categoryData.firstIndex(of: selectedItem) {
                        categoryData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
               
                callBackCategory?(categoryData)
                
            case 1:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    dateTimeData.append(selectedItem) // Add the item to the taskTypeDat
                } else {
                    if let itemIndex = dateTimeData.firstIndex(of: selectedItem) {
                        dateTimeData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
               
                callBackDateTime?(dateTimeData)
            case 2:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    avaibilityData.append(selectedItem) // Add the item to the taskTypeDat
                } else {
                    if let itemIndex = avaibilityData.firstIndex(of: selectedItem) {
                        avaibilityData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
               
                callBackAvailability?(avaibilityData)
                
            case 3:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    ratingReviewData.append(selectedItem) // Add the item to the taskTypeDat
                } else {
                    if let itemIndex = ratingReviewData.firstIndex(of: selectedItem) {
                        ratingReviewData.remove(at: itemIndex) // Remove the item safely from taskTypeData
                    }
                }
             
                callBackRatingReview?(ratingReviewData)
          
            default:
                break
            }
        }else{
            switch section {
            
            case 0:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    businessCategoryData.append(selectedItem)
                } else {
                    if let itemIndex = businessCategoryData.firstIndex(of: selectedItem) {
                        businessCategoryData.remove(at: itemIndex)
                    }
                }
               
                callBackBusinessCategory?(businessCategoryData)
                
            case 1:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    dealsOfferData.append(selectedItem)
                } else {
                    if let itemIndex = dealsOfferData.firstIndex(of: selectedItem) {
                        dealsOfferData.remove(at: itemIndex)
                    }
                }
               
                callBackDealOffer?(dealsOfferData)
                
            case 2:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    hoursData.append(selectedItem)
                } else {
                    if let itemIndex = hoursData.firstIndex(of: selectedItem) {
                        hoursData.remove(at: itemIndex)
                    }
                }
               
                callBackHours?(hoursData)
            case 3:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    customerRatingData.append(selectedItem)
                } else {
                    if let itemIndex = customerRatingData.firstIndex(of: selectedItem) {
                        customerRatingData.remove(at: itemIndex)
                    }
                }
               
                callBackCustomerRating?(customerRatingData)
            case 4:
                let selectedItem = (sender.tag+1)
                
                if sender.isSelected {
                    speacialFeatureData.append(selectedItem)
                } else {
                    if let itemIndex = speacialFeatureData.firstIndex(of: selectedItem) {
                        speacialFeatureData.remove(at: itemIndex)
                    }
                }
               
                callBackSpeacialFeature?(speacialFeatureData)
            default:
                break
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwCategory.frame.width / 2, height: 30)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

