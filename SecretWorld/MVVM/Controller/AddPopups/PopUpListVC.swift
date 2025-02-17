//
//  PopUpListVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 24/01/24.
//

import UIKit

class PopUpListVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet var tblVwList: UITableView!
    @IBOutlet var collVwType: UICollectionView!
    
    @IBOutlet var lblNoData: UILabel!
    //MARK: - VARIABLES
    var arrType = ["Upcoming","Ongoing","Completed"]
    var selectedIndexPath: IndexPath? = IndexPath(item: 0, section: 0)
    var viewModel = PopUpVM()
    var offset = 1
    var limit = 10
    var type = 0
    var arrPopups = [Popup]()
    var isComing = false
    var popupType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    
    func uiSet(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        let nibNearBy = UINib(nibName: "PopUpListTVC", bundle: nil)
        tblVwList.register(nibNearBy, forCellReuseIdentifier: "PopUpListTVC")
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwType.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        tblVwList.showsVerticalScrollIndicator = false
        GetPopupsListApi(typee: popupType)

    }
    @objc func handleSwipe() {
        if isComing == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            SceneDelegate().tabBarProfileRoot()
        }
            }
    func GetPopupsListApi(typee:Int){
        viewModel.getPopupListApi(offset: offset, limit: limit, type: typee) { data in
            self.arrPopups = data?.popups ?? []
            if self.arrPopups.count > 0{
                self.lblNoData.isHidden = true
            }else{
                self.lblNoData.isHidden = false
            }
            self.tblVwList.reloadData()
            self.collVwType.reloadData()
        }
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func actionBack(_ sender: UIButton) {
        if isComing == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            SceneDelegate().tabBarProfileRoot()
        }
        
    }
    
}
//MARK: -UITableViewDelegate
extension PopUpListVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrPopups.count > 0{
            return  arrPopups.count
        }else{
            return  0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpListTVC", for: indexPath) as! PopUpListTVC
        
        cell.viewBack.layer.masksToBounds = false
        cell.viewBack.layer.shadowColor = UIColor.black.cgColor
        cell.viewBack.layer.shadowOpacity = 0.1
        cell.viewBack.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.viewBack.layer.shouldRasterize = true
        cell.viewBack.layer.rasterizationScale = UIScreen.main.scale
        cell.imgVwPopup.imageLoad(imageUrl: arrPopups[indexPath.row].businessLogo ?? "")
        cell.lblLocation.text = arrPopups[indexPath.row].place ?? ""
//        if let productCount = arrPopups[indexPath.row].addProducts?.count {
//            let countString = "\(arrPopups[indexPath.row].name ?? "") (\(productCount))"
//            let attributedString = NSMutableAttributedString(string: countString)
//            let countRange = (countString as NSString).range(of: "(\(productCount))")
//            attributedString.addAttribute(.foregroundColor, value: UIColor.app, range: countRange)
//            cell.lblProductCount.attributedText = attributedString
//        } else {
//            cell.lblProductCount.text = "List of products (0)"
//            cell.lblProductCount.textColor = UIColor.black
//        }
        cell.lblProductCount.text = arrPopups[indexPath.row].name ?? ""
          cell.lblProductCount.textColor = UIColor.black
        if let startDateString = arrPopups[indexPath.row].startDate,
           let convertedStartDate = convertDateString(startDateString) {
            let attributedText = NSMutableAttributedString()
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            let regularAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.gray
            ]
            
            attributedText.append(NSAttributedString(string: "Start date: ", attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: convertedStartDate, attributes: regularAttributes))
            
            cell.lblStartDate.attributedText = attributedText
        } else {
            if let startDateString = arrPopups[indexPath.row].startDate,
               let convertedStartDate = convertUpdateDateString(startDateString) {
                let attributedText = NSMutableAttributedString()
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 11),
                    .foregroundColor: UIColor.black
                ]
                let regularAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.gray
                ]
                
                attributedText.append(NSAttributedString(string: "Start date: ", attributes: boldAttributes))
                attributedText.append(NSAttributedString(string: convertedStartDate, attributes: regularAttributes))
                
                cell.lblStartDate.attributedText = attributedText
            }
        }

        if let endDateString = arrPopups[indexPath.row].endDate,
           let convertedEndDate = convertDateString(endDateString) {
            let attributedText = NSMutableAttributedString()
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            let regularAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.gray
            ]
            
            attributedText.append(NSAttributedString(string: "End date: ", attributes: boldAttributes))
            attributedText.append(NSAttributedString(string: convertedEndDate, attributes: regularAttributes))
            
            cell.lblEndDate.attributedText = attributedText
        } else {
            if let endDateString = arrPopups[indexPath.row].endDate,
               let convertedEndDate = convertUpdateDateString(endDateString) {
                let attributedText = NSMutableAttributedString()
                let boldAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 11),
                    .foregroundColor: UIColor.black
                ]
                let regularAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.gray
                ]
                
                attributedText.append(NSAttributedString(string: "End date: ", attributes: boldAttributes))
                attributedText.append(NSAttributedString(string: convertedEndDate, attributes: regularAttributes))
                
                cell.lblEndDate.attributedText = attributedText
            }
        }
        return cell
        
    }
    func convertDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd-MM-yyyy,hh:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func convertUpdateDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd-MM-yyyy,hh:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if arrPopups.count > 0{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpOwnerVC") as! PopUpOwnerVC
            vc.popupId = arrPopups[indexPath.row].id ?? ""
            vc.callBack = {
                self.GetPopupsListApi(typee: self.popupType)
            }
            self.navigationController?.pushViewController(vc, animated: true)
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
//            vc.modalPresentationStyle = .overFullScreen
//            vc.popupId = arrPopups[indexPath.row].id ?? ""
//            vc.isComing = true
//            vc.callBack = { [weak self] index in
//                guard let self = self else { return }
//                self.GetPopupsListApi(typee: self.popupType)
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
//    {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPopUpVC") as! ViewPopUpVC
//        vc.modalPresentationStyle = .overFullScreen
//        vc.arrPopups = arrPopups
//        vc.popupType = popupType
//        vc.selectedIndex = indexPath.row
//        vc.callBack = { type in
//            if type == 0{
//                //edit
//                
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesMoreOptionsVC") as! ServicesMoreOptionsVC
//                vc.modalPresentationStyle = .overFullScreen
//                vc.callBack = { isSelect in
//                    
//                    if isSelect == true{
//                        
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPopUpVC") as! AddPopUpVC
//                        vc.isComing = true
//                        vc.popupIndex = indexPath.row
//                        vc.arrPopups = self.arrPopups
//                        self.navigationController?.pushViewController(vc, animated: true)
//                        
//                    }else{
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
//                        vc.isSelect = 2
//                        vc.popupId = self.arrPopups[indexPath.row].id ?? ""
//                        vc.modalPresentationStyle = .overFullScreen
//                        vc.callBack  = { message in
//                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
//                                vc.modalPresentationStyle = .overFullScreen
//                                vc.isSelect = 10
//                                vc.message = message
//                                vc.callBack = {
//                                    self.GetPopupsListApi(typee: self.popupType)
//                                }
//                                self.navigationController?.present(vc, animated: false)
//                            
//                        }
//                        self.navigationController?.present(vc, animated: false)
//                    }
//                }
//                self.navigationController?.present(vc, animated: true)
//                
//            }else{
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserParticipantsListVC") as! UserParticipantsListVC
//                vc.isComing = 1
//                vc.popupId = self.arrPopups[indexPath.row].id ?? ""
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            
//        }
//        self.navigationController?.present(vc, animated: true)
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
//MARK: - UICollectionViewDelegate
extension PopUpListVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
        cell.lblName.text = arrType[indexPath.row]
        cell.widthBtnCross.constant = 0
        cell.vwBg.layer.cornerRadius = 22
        cell.btnCross.isHidden = true
        cell.vwBg.backgroundColor = .clear
        cell.vwBg.borderWid = 1
        cell.vwBg.borderCol = .app
        
        if selectedIndexPath == indexPath {
            cell.vwBg.backgroundColor = UIColor(
                red: CGFloat(0xF1) / 255.0,
                green: CGFloat(0xF8) / 255.0,
                blue: CGFloat(0xF0) / 255.0,
                alpha: 1.0
            )
            cell.lblName.textColor = .app
        } else {
            cell.vwBg.backgroundColor = .clear
            cell.lblName.textColor = UIColor(
                red: CGFloat(0x63) / 255.0,
                green: CGFloat(0x63) / 255.0,
                blue: CGFloat(0x63) / 255.0,
                alpha: 1.0
            )
        }
        return cell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwType.frame.size.width / 3 - 7, height: 44)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if indexPath.row == 0{
            popupType = 0
            lblScreenTitle.text = "Upcoming Popups"
            GetPopupsListApi(typee: popupType)
        }else if indexPath.row == 1{
            popupType = 1
            lblScreenTitle.text = "Ongoing Popups"
            GetPopupsListApi(typee: popupType)
        }else{
            popupType = 2
            lblScreenTitle.text = "Completed Popups"
            GetPopupsListApi(typee: popupType)
        }
        // Deselect previous selection
        if let selectedIndexPath = selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? BusinessCategoryCVC {
            cell.vwBg.backgroundColor = .clear
            cell.lblName.textColor = UIColor(
                red: CGFloat(0x63) / 255.0,
                green: CGFloat(0x63) / 255.0,
                blue: CGFloat(0x63) / 255.0,
                alpha: 1.0
            )
        }
        
        // Select the current cell
        let cell = collectionView.cellForItem(at: indexPath) as! BusinessCategoryCVC
        cell.vwBg.backgroundColor = UIColor(
            red: CGFloat(0xF1) / 255.0,
            green: CGFloat(0xF8) / 255.0,
            blue: CGFloat(0xF0) / 255.0,
            alpha: 1.0
        )
        cell.lblName.textColor = .app
        selectedIndexPath = indexPath
    }
    
}


