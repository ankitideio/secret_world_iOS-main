//
//  BusinessProfileVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 03/01/24.
//

import UIKit
import AlignedCollectionViewFlowLayout
import FXExpandableLabel

class BusinessProfileVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var lblPopupCount: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var scrollVw: UIScrollView!
    @IBOutlet var lblReviewTitle: UILabel!
    @IBOutlet var heightCollvVw: NSLayoutConstraint!
    @IBOutlet var heightTblVwReview: NSLayoutConstraint!
    @IBOutlet var lblGigsCount: UILabel!
    @IBOutlet var lblServicesCount: UILabel!
    @IBOutlet var lblReviewCount: UILabel!
    @IBOutlet var lblDateOfBirth: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblPlace: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgVwProfile: UIImageView!
    @IBOutlet var tblVwreviews: UITableView!
    @IBOutlet weak var lblAbout: UILabel!
    
    @IBOutlet var collVwtags: UICollectionView!
    @IBOutlet var tblVwOpeningHour: UITableView!
    
    
    var arrReviews = [Reviewwe]()
    var isLabelExpanded = false
    var businessUserProfile:[UserProfiles]?
    var openingHour:[OpeningHourr]?
    var viewModelBusiness = BusinessProfileVM()
    var getBusinessUserDetail:GetBusinessUserDetail?
    var obj = [BusinessTimingModel]()
    var totalHeight = 0
    var arrGetServices = [Service]()
    let refreshControl = UIRefreshControl()
    var isComing = false
    var businessId:String?
    var textAbout = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        uiSet()
    }
    @objc func handleSwipe() {
              navigationController?.popViewController(animated: true)
          }

    func getBusinessUserProfileApiFromBusinessSide(loader:Bool){
        viewModelBusiness.GetBusinessUserProfile(id: "",loader: loader){ data in
            WebService.hideLoader()
            self.getBusinessUserDetail = data
            self.arrReviews = data?.reviews ?? []
            
            if data?.reviews?.count ?? 0 > 0{
                self.lblReviewTitle.isHidden = false
            }else{
                self.lblReviewTitle.isHidden = true
            }
            self.lblPopupCount.text = "\(data?.postedPopup ?? 0)"
            self.lblGigsCount.text = "\(data?.gigCount ?? 0)"
            self.lblServicesCount.text = "\(data?.serviceCount ?? 0)"
            self.arrGetServices = data?.userProfile?.services ?? []
            self.lblName.text = data?.userProfile?.businessname ?? ""
//            self.lblAbout.text = data?.userProfile?.about ?? ""
            self.textAbout = data?.userProfile?.about ?? ""
            self.lblAbout.numberOfLines = 2
            self.lblAbout.appendReadmore(after: self.textAbout, trailingContent: .readmore)
            self.lblAbout.sizeToFit()
            self.lblPlace.text = data?.userProfile?.place ?? ""
            Store.BusinessUserDetail = ["userName":data?.userProfile?.name ?? "",
                                        "profileImage":data?.userProfile?.profilePhoto ?? "","userId":data?.userProfile?.id ?? ""]
            NotificationCenter.default.post(name: Notification.Name("UpdateUserName"), object: nil)
            let rating = data?.UserRating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            if data?.reviews?.count ?? 0 > 1{
                self.lblReviewCount.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Reviews)"
            }else{
                self.lblReviewCount.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Review)"
            }

            self.lblGender.text = data?.userProfile?.name ?? ""
            
            let dateString = data?.userProfile?.dob ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "MMM-dd-yyyy"
                let newDateString = dateFormatter.string(from: date)
                self.lblDateOfBirth.text = newDateString
            }
            self.imgVwProfile.imageLoad(imageUrl: data?.userProfile?.profilePhoto ?? "")
            
            
            for i in data?.userProfile?.openingHours ?? []{
                if i.day == "Monday"{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 0)
                }else if i.day == "Tuesday"{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 1)
                }else if i.day == "Wednesday"{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 2)
                }else if i.day == "Thursday"{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 3)
                }else if i.day == "Friday"{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 4)
                }else if i.day == "Saturday"{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 6)
                }
                
                self.tblVwOpeningHour.reloadData()
            }
            self.collVwtags.reloadData()
            self.tblVwreviews.reloadData()
            self.tblVwreviews.invalidateIntrinsicContentSize()
            self.updateheightCollVw()
        }
    }
    func getBusinessUserProfileFromUserSide(loader:Bool,businessId:String){
        viewModelBusiness.GetBusinessUserProfile(id: businessId,loader: loader){ data in
            WebService.hideLoader()
            self.getBusinessUserDetail = data
            self.arrReviews = data?.reviews ?? []
            
            if data?.reviews?.count ?? 0 > 0{
                self.lblReviewTitle.isHidden = false
            }else{
                self.lblReviewTitle.isHidden = true
            }
            self.lblPopupCount.text = "\(data?.postedPopup ?? 0)"
            self.lblGigsCount.text = "\(data?.gigCount ?? 0)"
            self.lblServicesCount.text = "\(data?.serviceCount ?? 0)"
            self.arrGetServices = data?.userProfile?.services ?? []
            self.lblName.text = data?.userProfile?.businessname ?? ""
            self.lblAbout.text = data?.userProfile?.about ?? ""
            self.lblPlace.text = data?.userProfile?.place ?? ""
            Store.BusinessUserDetail = ["userName":data?.userProfile?.name ?? "",
                                        "profileImage":data?.userProfile?.profilePhoto ?? ""]
            NotificationCenter.default.post(name: Notification.Name("UpdateUserName"), object: nil)
            let rating = data?.UserRating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            if data?.reviews?.count ?? 0 > 1{
                self.lblReviewCount.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Reviews)"
            }else{
                self.lblReviewCount.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Review)"
            }
            
            self.lblGender.text = data?.userProfile?.name ?? ""
            let date = data?.userProfile?.dob ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-yyyy"
            let dateFormat = dateFormatter.date(from: date)
            let dob = dateFormatter.string(from: dateFormat ?? Date())
            self.lblDateOfBirth.text = dob
            self.imgVwProfile.imageLoad(imageUrl: data?.userProfile?.profilePhoto ?? "")
            
            
            for i in data?.userProfile?.openingHours ?? []{
                if i.day == "Monday"{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 0)
                }else if i.day == "Tuesday"{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 1)
                }else if i.day == "Wednesday"{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 2)
                }else if i.day == "Thursday"{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 3)
                }else if i.day == "Friday"{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 4)
                }else if i.day == "Saturday"{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: i.day ?? "",starttime: i.starttime ?? "",endtime: i.endtime ?? "",status: "1"), at: 6)
                }
                
                self.tblVwOpeningHour.reloadData()
            }
            self.collVwtags.reloadData()
            self.tblVwreviews.reloadData()
            self.tblVwreviews.invalidateIntrinsicContentSize()
            self.updateheightCollVw()
        }
    }
     
    override func viewWillLayoutSubviews() {
        self.heightTblVwReview.constant = self.tblVwreviews.contentSize.height+20
        
        print("ReviewHeight------",self.heightTblVwReview.constant)
       
    }
    func uiSet(){
        obj.insert(BusinessTimingModel(day: "Monday",starttime: "",endtime: "",status: "0"), at: 0)
        obj.insert(BusinessTimingModel(day: "Tuesday",starttime: "",endtime: "",status: "0"), at: 1)
        obj.insert(BusinessTimingModel(day: "Wednesday",starttime: "",endtime: "",status: "0"), at: 2)
        obj.insert(BusinessTimingModel(day: "Thursday",starttime: "",endtime: "",status: "0"), at: 3)
        obj.insert(BusinessTimingModel(day: "Friday",starttime: "",endtime: "",status: "0"), at: 4)
        obj.insert(BusinessTimingModel(day: "Saturday",starttime: "",endtime: "",status: "0"), at: 5)
        obj.insert(BusinessTimingModel(day: "Sunday",starttime: "",endtime: "",status: "0"), at: 6)
        lblAbout.numberOfLines = 5
        
        print("role\(Store.role ?? "")")
        let nib = UINib(nibName: "ReviewTVC", bundle: nil)
        tblVwreviews.register(nib, forCellReuseIdentifier: "ReviewTVC")
        let nib2 = UINib(nibName: "BusinessHourTVC", bundle: nil)
        tblVwOpeningHour.register(nib2, forCellReuseIdentifier: "BusinessHourTVC")
        let nibCollvw = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwtags.register(nibCollvw, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        tblVwreviews.estimatedRowHeight = 120
        let alignedFlowLayoutCollVwInterst = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwtags.collectionViewLayout = alignedFlowLayoutCollVwInterst
        
        if let flowLayout = collVwtags.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 36)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
        }
        if isComing == true{
            btnEdit.isHidden = false
            getBusinessUserProfileApiFromBusinessSide(loader: true)
           
        }else{
            btnEdit.isHidden = true
            getBusinessUserProfileFromUserSide(loader: true, businessId: businessId ?? "")
            
        }
        addTapGestureToLabel()
    }
    
    func convertTo12HourFormat(timeString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    func addTapGestureToLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        lblAbout.isUserInteractionEnabled = true
        lblAbout.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = lblAbout.text else { return }

              let readmore = (text as NSString).range(of: TrailingContent.readmore.text)
              let readless = (text as NSString).range(of: TrailingContent.readless.text)
              if gesture.didTap(label: lblAbout, inRange: readmore) {
                  lblAbout.appendReadLess(after: textAbout, trailingContent: .readless)
              } else if  gesture.didTap(label: lblAbout, inRange: readless) {
                  lblAbout.appendReadmore(after: textAbout, trailingContent: .readmore)
              } else { return }
    }
    
    @IBAction func actionEdit(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditBusinessProfileVC") as! EditBusinessProfileVC
        vc.getBusinessUserDetail = getBusinessUserDetail
        vc.obj = obj
        vc.arrGetServices = arrGetServices
        vc.callBack = {[weak self] in
            guard let self = self else { return }
                WebService.hideLoader()
                    self.getBusinessUserProfileApiFromBusinessSide(loader: false)
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
//        if isComing == true{
//            SceneDelegate().tabBarProfileRoot()
//        }else{
            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    @IBAction func actionServices(_ sender: UIButton) {
        if isComing == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyServicesVC") as! MyServicesVC
            vc.isSelect = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func actionGigs(_ sender: UIButton) {
        if isComing == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
            vc.isComing = 2
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func actionPopups(_ sender: UIButton) {
        if isComing == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpListVC") as! PopUpListVC
            vc.isComing = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: -UITableViewDelegate
extension BusinessProfileVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblVwOpeningHour{
            return  obj.count
        }else{
            return arrReviews.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblVwOpeningHour {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessHourTVC", for: indexPath) as! BusinessHourTVC
            
            let day = obj[indexPath.row].day
            cell.lblday.text = day.capitalized
            
            
            if obj[indexPath.row].status == "1"{
                let startTime24 = obj[indexPath.row].starttime
                let endTime24 = obj[indexPath.row].endtime
                
                let startTime12 = convertTo12HourFormat(startTime24)
                let endTime12 = convertTo12HourFormat(endTime24)
                cell.lblTime.text = "\(startTime12) - \(endTime12)"
                cell.lblTime.textColor = UIColor( red: 91 / 255.0,green: 91 / 255.0,blue: 91 / 255.0,alpha: 1.0)
            }else{
                cell.lblTime.text = "Closed"
                cell.lblTime.textColor = UIColor( red: CGFloat(0xFF) / 255.0,green: CGFloat(0x3B) / 255.0,blue: CGFloat(0x3B) / 255.0,alpha: 1.0)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
           
            cell.lblName.text = arrReviews[indexPath.row].userID?.name ?? ""
            cell.lblDescription.text = arrReviews[indexPath.row].comment ?? ""
            
            let rating = arrReviews[indexPath.row].starCount ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            cell.lblRating.text = formattedRating
            cell.ratingView.rating = Double(arrReviews[indexPath.row].starCount ?? 0)
            cell.imgVwUser.imageLoad(imageUrl: arrReviews[indexPath.row].userID?.profilePhoto ?? "")
            cell.lblDescription.sizeToFit()
            if arrReviews[indexPath.row].media == "" || arrReviews[indexPath.row].media == nil{
                cell.heightImgVw.constant = 0
                totalHeight += 115 + Int(cell.lblDescription.frame.height)
            }else{
                cell.heightImgVw.constant = 150
                totalHeight += 250 + Int(cell.lblDescription.frame.height)
                cell.imgVwReview.imageLoad(imageUrl: arrReviews[indexPath.row].media ?? "")
            }
            heightTblVwReview.constant = CGFloat(totalHeight)
            let createdAt = arrReviews[indexPath.row].createdAt ?? ""
                let timeAgoString = createdAt.timeAgoSinceDate()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let createdDate = dateFormatter.date(from: createdAt) {
                    let timeDifference = Date().timeIntervalSince(createdDate)
                    if timeDifference < 60 {
                        cell.lblTime.text = "Just now"
                    } else {
                        cell.lblTime.text = "\(timeAgoString) Ago"
                    }
                } else {
                    cell.lblTime.text = "\(timeAgoString) Ago"
                }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblVwOpeningHour{
            return  35
        }else{
            return  UITableView.automaticDimension
        }
        
        
    }
    
    
}
//MARK: - UICollectionViewDelegate
extension BusinessProfileVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrGetServices.count > 0{
            return arrGetServices.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
        if arrGetServices.count > 0{
            cell.lblName.text = arrGetServices[indexPath.row].name ?? ""
        }
        cell.vwBg.layer.cornerRadius = 20
        cell.widthBtnCross.constant = 0
        cell.lblName.textColor = .app
        cell.vwBg.layer.cornerRadius = 4
        return cell
        
        
        
    }
    func updateheightCollVw() {
        
        let rowsSpeciliz = ceil(CGFloat(arrGetServices.count) / 3.0)
        let newHeightSpeciliz = rowsSpeciliz * 36 + max(0, rowsSpeciliz - 1) * 8
        heightCollvVw.constant = newHeightSpeciliz
        
    }
    
}
extension BusinessProfileVC {
    func convertTo12HourFormat(_ time24: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date24 = dateFormatter.date(from: time24) {
            dateFormatter.dateFormat = "h:mm a"
            let time12 = dateFormatter.string(from: date24)
            return time12
        }
        
        return ""
    }
}
