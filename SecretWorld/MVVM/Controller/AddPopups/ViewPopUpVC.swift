//
//  ViewPopUpVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 25/01/24.
//

import UIKit

class ViewPopUpVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var scrollVw: UIScrollView!
    @IBOutlet var viewScrolBack: UIView!
    @IBOutlet var lblEndTime: UILabel!
    @IBOutlet var lblStartTime: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var heightTblvw: NSLayoutConstraint!
    @IBOutlet var lblEndDate: UILabel!
    @IBOutlet var lblStartDate: UILabel!
    @IBOutlet var tblVwList: UITableView!
    @IBOutlet var btnProductCount: UIButton!
    @IBOutlet var btnRequest: UIButton!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var imgVwUser: UIImageView!
    @IBOutlet var viewBack: UIView!
    
    var callBack:((_ type:Int?)->())?
    var viewMOdel = PopUpVM()
    var arrProductList = [AddProductz]()
    var arrProductLists = [AddProducts]()
    var popupType:Int?
    var arrPopups = [Popup]()
    var selectedIndex = -1
    var isComingNotification:Bool = false
    var popupId:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        viewBack.layer.cornerRadius = 35
        viewBack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewScrolBack.layer.cornerRadius = 35
        viewScrolBack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollVw.layer.cornerRadius = 35
        scrollVw.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let nibNearBy = UINib(nibName: "ProductListTVC", bundle: nil)
        tblVwList.register(nibNearBy, forCellReuseIdentifier: "ProductListTVC")
        tblVwList.showsVerticalScrollIndicator = false
        getPopupDetail()
        if popupType == 0{
            btnEdit.isHidden = false
        }else{
            btnEdit.isHidden = true
        }
        
    }
    func getPopupDetail(){
        if isComingNotification == false{
            if arrPopups[selectedIndex].requests ?? 0 > 0{
                self.btnRequest.setTitle("\(arrPopups[selectedIndex].requests ?? 0) new requests", for: .normal)
            }else{
                self.btnRequest.setTitle("No requests", for: .normal)
            }
            self.btnProductCount.setTitle("\(arrPopups[selectedIndex].addProducts?.count ?? 0)", for: .normal)
            self.imgVwUser.imageLoad(imageUrl: arrPopups[selectedIndex].businessLogo ?? "")
            
            if let startDate = arrPopups[selectedIndex].startDate{
                self.lblStartDate.text = convertDateString(startDate)
            }
            if let endDate = arrPopups[selectedIndex].endDate{
                self.lblEndDate.text = convertDateString(endDate)
            }
            if let startDateString = arrPopups[selectedIndex].startDate, let formattedStartDate = convertTimeString(startDateString) {
                self.lblStartTime.text = formattedStartDate
            }
            
            if let endDateString = arrPopups[selectedIndex].endDate, let formattedEndDate = convertTimeString(endDateString) {
                self.lblEndTime.text = formattedEndDate
            }
            
            //        if let startDateString = arrPopups[selectedIndex].startDate, let formattedStartDate = formatDate(startDateString) {
            //            self.lblStartTime.text = formattedStartDate
            //        }
            //
            //        if let endDateString = arrPopups[selectedIndex].endDate, let formattedEndDate = formatDate(endDateString) {
            //            self.lblEndTime.text = formattedEndDate
            //        }
            self.lblDescription.text = arrPopups[selectedIndex].description ?? ""
            self.lblLocation.text = arrPopups[selectedIndex].place ?? ""
            self.arrProductList = arrPopups[selectedIndex].addProducts ?? []
            self.heightTblvw.constant = CGFloat(self.arrProductList.count*50)
            self.tblVwList.reloadData()
        }else{
            viewMOdel.getPopupDetailApi(loader: false, popupId: popupId) { data in
              
                if data?.Requests == 0{
                    self.btnRequest.setTitle("No requests", for: .normal)
                }else if data?.Requests == 1{
                    self.btnRequest.setTitle("\(data?.Requests ?? 0) New request", for: .normal)
                }else{
                    self.btnRequest.setTitle("\(data?.Requests ?? 0) new requests", for: .normal)
                }
                self.btnProductCount.setTitle("\(data?.addProducts?.count ?? 0)", for: .normal)
                self.imgVwUser.imageLoad(imageUrl: data?.businessLogo ?? "")
                
                if let startDate = data?.startDate{
                    self.lblStartDate.text = self.convertDateString(startDate)
                }
                if let endDate = data?.endDate{
                    self.lblEndDate.text = self.convertDateString(endDate)
                }
                if let startDateString = data?.startDate, let formattedStartDate = self.convertTimeString(startDateString) {
                    self.lblStartTime.text = formattedStartDate
                }
                
                if let endDateString = data?.endDate, let formattedEndDate = self.convertTimeString(endDateString) {
                    self.lblEndTime.text = formattedEndDate
                }
             
                self.lblDescription.text = data?.description ?? ""
                self.lblLocation.text = data?.place ?? ""
                self.arrProductLists = data?.addProducts ?? []
                self.heightTblvw.constant = CGFloat(self.arrProductLists.count*50)
                self.tblVwList.reloadData()
            }
        }
    }
    func formatDate(_ dateString: String, fromFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toFormat: String = "hh:mm a", fromTimeZone: TimeZone = TimeZone(abbreviation: "UTC")!, toTimeZone: TimeZone = TimeZone.current) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = fromTimeZone
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = toFormat
            displayFormatter.timeZone = toTimeZone
            return displayFormatter.string(from: date)
        }
        return nil
    }
    func convertTimeString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if dateString.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }

    func convertDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if dateString.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.string(from: date)
        }
        return nil
    }

    
    //MARK: - BUTTON ACTIONS
    @IBAction func actionProductCount(_ sender: UIButton) {
    }
    @IBAction func actionRequest(_ sender: UIButton) {
        self.dismiss(animated: true)
        callBack?(1)
        
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
        
        
    }
    @IBAction func actionEdit(_ sender: UIButton) {
        self.dismiss(animated: true)
        callBack?(0)
    }
    
}
//MARK: - UITableViewDelegate
extension ViewPopUpVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isComingNotification == true{
            return  arrProductLists.count
        }else{
            return  arrProductList.count
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListTVC", for: indexPath) as! ProductListTVC
        if isComingNotification == true{
            cell.widthEditBtn.constant = 0
            cell.lblProductName.text = "\(indexPath.row + 1). \(arrProductLists[indexPath.row].productName ?? "")"
            cell.lblPrice.text = "$\(arrProductLists[indexPath.row].price ?? 0)"
        }else{
            cell.widthEditBtn.constant = 0
            cell.lblProductName.text = "\(indexPath.row + 1). \(arrProductList[indexPath.row].productName ?? "")"
            cell.lblPrice.text = "$\(arrProductList[indexPath.row].price ?? 0)"
        }
     
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  50
        
    }
    
}
