//
//  SeeAllTypeVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 14/02/25.
//

import UIKit

class SeeAllTypeVC: UIViewController {

    @IBOutlet weak var tblVwTask: UITableView!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var collVwPopup: UICollectionView!
    @IBOutlet weak var collVwBusiness: UICollectionView!
    
    var arrData = [FilteredItem]()
    var isSelect = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSet()
    }
    func uiSet(){
        let nibNearBy = UINib(nibName: "GigNearByTVC", bundle: nil)
        tblVwTask.register(nibNearBy, forCellReuseIdentifier: "GigNearByTVC")
        let nib = UINib(nibName: "StoreCVC", bundle: nil)
        collVwPopup.register(nib, forCellWithReuseIdentifier: "StoreCVC")
        let nibBusiness = UINib(nibName: "PopularServicesCVC", bundle: nil)
        collVwBusiness.register(nibBusiness, forCellWithReuseIdentifier: "PopularServicesCVC")
        if isSelect == 1{
            tblVwTask.isHidden = false
            collVwPopup.isHidden = true
            collVwBusiness.isHidden = true
            tblVwTask.reloadData()
            lblHeader.text = "Task list"
        }else if isSelect == 2{
            tblVwTask.isHidden = true
            collVwPopup.isHidden = true
            collVwBusiness.isHidden = false
            collVwBusiness.reloadData()
            lblHeader.text = "Buisness list"
        }else{
           
            tblVwTask.isHidden = true
            collVwPopup.isHidden = false
            collVwBusiness.isHidden = true
            collVwPopup.reloadData()
            lblHeader.text = "Popup list"
        }
    }

   
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - UICollectionViewDelegate
extension SeeAllTypeVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == collVwPopup{
            if arrData.count > 0{
                return arrData.count
            }else{
                return 0
            }
        }else{
            if arrData.count > 0{
                return arrData.count
            }else{
                return 0
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwBusiness{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularServicesCVC", for: indexPath) as! PopularServicesCVC
            cell.vwShadow.layer.masksToBounds = false
            cell.vwShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
            cell.vwShadow.layer.shadowOpacity = 0.44
            cell.vwShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.vwShadow.layer.shouldRasterize = true
            cell.vwShadow.layer.rasterizationScale = UIScreen.main.scale
            cell.isComing = true
            if arrData.count > 0{
                cell.indexpath = indexPath.row
//                if arrData[indexPath.row].categoryName?.count ?? 0 > 0{
//                    cell.arrCategories = arrData[indexPath.row].userservices ?? []
//                }
                cell.uiSet()
                let business = arrData[indexPath.row]
                let rating = business.UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
              
                cell.lblServiceName.text = business.businessname ?? ""
                cell.imgVwUser.imageLoad(imageUrl: business.profilePhoto ?? "")
                cell.lblAddress.text = business.place ?? ""
                if business.status == 2{
                    cell.imgVwBlueTick.isHidden = false
                }else{
                    cell.imgVwBlueTick.isHidden = true
                }
                var openingHoursFound = false
//                for openingHour in business.openingHours ?? [] {
//                    if openingHour.day == currentDay {
//                        openingHoursFound = true
//                        let startTime12 = convertTo12HourFormat(openingHour.starttime ?? "")
//                        let endTime12 = convertTo12HourFormat(openingHour.endtime ?? "")
//                        cell.lblTime.text = "\(startTime12) - \(endTime12)"
//                        break
//                    }
//                }
                if !openingHoursFound {
                    cell.lblTime.text = "Closed"
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCVC", for: indexPath) as! StoreCVC
            cell.viewShadow.layer.masksToBounds = false
            cell.viewShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
            cell.viewShadow.layer.shadowOpacity = 0.44
            cell.viewShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.viewShadow.layer.shouldRasterize = true
            cell.viewShadow.layer.rasterizationScale = UIScreen.main.scale
            if arrData.count > 0{
                cell.lblStoreName.text = arrData[indexPath.row].name ?? ""
                cell.imgVwStore.imageLoad(imageUrl: arrData[indexPath.row].businessLogo ?? "")
                cell.lblUserName.text = arrData[indexPath.row].user?.name ?? ""
                let rating = arrData[indexPath.row].UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
           
                 
                    if collectionView == collVwBusiness{
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutServicesVC") as! AboutServicesVC
                        vc.businessId = arrData[indexPath.row].id ?? ""
                        vc.businessIndex = indexPath.row
                        
                        Store.BusinessUserIdForReview = arrData[indexPath.row].id ?? ""
                       
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupUserVC") as! PopupUserVC
                        vc.popupId = arrData[indexPath.row].id ?? ""
                       
                        self.navigationController?.pushViewController(vc, animated: true)
                        //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
                        //                    vc.popupId = arrData[indexPath.row].id ?? ""
                        //                    vc.popupIndex = indexPath.row
                        //                    vc.callBack = { [weak self] index in
                        //                        guard let self = self else { return }
                        //                        self.animateZoomInOut()
                        //                        self.getStoreData()
                        //                    }
                        //                    self.navigationController?.pushViewController(vc, animated: true)
                    }
                
            
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      if collectionView == collVwBusiness{
            return CGSize(width: view.frame.size.width / 1-20, height: 100)
        }else{
            return CGSize(width: view.frame.size.width / 1-20, height: 100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      
            return 0
        
       
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       
            return 0
        
    }

 
}

//MARK: - TABLEVIEW DELEGATE AND DATASOURCE
extension SeeAllTypeVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataCount = arrData.count
//        tableView.isScrollEnabled = dataCount > 1
        return dataCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigNearByTVC", for: indexPath) as! GigNearByTVC
        if arrData.count > 0 {
       
            cell.lblName.text = arrData[indexPath.row].name
            cell.lblTitle.text = arrData[indexPath.row].title
            cell.lblPrice.text = "$\(arrData[indexPath.row].price ?? 0)"
            cell.lblAddress.text = arrData[indexPath.row].place ?? ""
            
            if let formattedDate = convertToDateFormat(arrData[indexPath.row].startDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", convertFormat:"dd MMM yyyy") {
                cell.lblDate.text = formattedDate
            } else {
                print("Invalid date format")
            }
            if let formattedDate = convertToDateFormat(arrData[indexPath.row].startDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", convertFormat:"h a") {
                cell.lblTime.text = formattedDate
            } else {
                print("Invalid date format")
            }
            print(arrData[indexPath.row].startDate ?? "")
            cell.viewShadow.applyShadow()
            let rating = arrData[indexPath.row].UserRating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            let reviewCount = arrData[indexPath.row].userRatingCount ?? 0
            if reviewCount > 1{
                cell.lblRatingReview.text = "\(formattedRating) \("(\(reviewCount) Reviews)")"
                let attributedText = NSMutableAttributedString(string: cell.lblRatingReview.text ?? "")
                if let range = cell.lblRatingReview.text?.range(of: "(\(reviewCount) Reviews)") {
                    let nsRange = NSRange(range, in: cell.lblRatingReview.text ?? "")
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.app, range: nsRange)
                }
                cell.lblRatingReview.attributedText = attributedText
            }else{
                cell.lblRatingReview.text = "\(formattedRating) \("(\(reviewCount) Review)")"
                let attributedText = NSMutableAttributedString(string: cell.lblRatingReview.text ?? "")
                if let range = cell.lblRatingReview.text?.range(of: "(\(reviewCount) Review)") {
                    let nsRange = NSRange(range, in: cell.lblRatingReview.text ?? "")
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.app, range: nsRange)
                }
                cell.lblRatingReview.attributedText = attributedText
            }
            if arrData[indexPath.row].image == "" || arrData[indexPath.row].image == nil{
                cell.imgVwGig.image = UIImage(named: "dummy")
            }else{
                cell.imgVwGig.imageLoad(imageUrl: arrData[indexPath.row].image ?? "")
            }

            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
            self.dismiss(animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
            if arrData.count > 0{
                vc.gigId = arrData[indexPath.row].id ?? ""
            }
           

            self.navigationController?.pushViewController(vc, animated: true)
    }
    func convertToDateFormat(_ dateString: String,dateFormat:String,convertFormat:String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = dateFormat
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = convertFormat
            outputFormatter.timeZone = TimeZone.current // Adjust as needed

            return outputFormatter.string(from: date)
        }
        return nil // Return nil if parsing fails
    }
}
