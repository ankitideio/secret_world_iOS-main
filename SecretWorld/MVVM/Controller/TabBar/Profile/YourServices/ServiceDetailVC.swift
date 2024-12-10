//
//  ServiceDetailVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 04/01/24.
//

import UIKit
import FXExpandableLabel

class ServiceDetailVC: UIViewController,UIGestureRecognizerDelegate{
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var btnThreedot: UIButton!
    @IBOutlet var btnViewAllImgs: UIButton!
    
    @IBOutlet var tblVwTop: NSLayoutConstraint!
    @IBOutlet var lblReviewTitle: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var heightTblVwReview: NSLayoutConstraint!
    @IBOutlet var viewProvider: UIView!
    @IBOutlet var lblImgsCount: UILabel!
    @IBOutlet var lblImgCount: UILabel!
    @IBOutlet var widthBtnAddReview: NSLayoutConstraint!
    @IBOutlet var heightBtnAddReview: NSLayoutConstraint!
    @IBOutlet var heightViewServiceprovider: NSLayoutConstraint!
    @IBOutlet var lblService: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblNameServiceProvider: UILabel!
    @IBOutlet var imgVwServiceProvider: UIImageView!
    @IBOutlet var lblSubcategory: UILabel!
    @IBOutlet var imgVwProfile: UIImageView!
    @IBOutlet var lblAbout: ExpandableLabel!
    @IBOutlet var tblVwReview: UITableView!
    @IBOutlet var collvwGallary: UICollectionView!
    
    var isLabelExpanded = false
    var viewModel = AddServiceVM()
    var serviceId = String()
    var arrServiceDetail:Servicess?
    var arrImgs = [String]()
    var arrReview = [ReviewService]()
    var userServiceDetail:GetServiceDataaa?
    var businessServiceDetail:GetServiceDetailDataa?
    var heightDescription = 0
    var reviewHeight = 0
    var phoneNumber: Int?
    var providerId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        let nibNearBy = UINib(nibName: "ReviewTVC", bundle: nil)
        tblVwReview.register(nibNearBy, forCellReuseIdentifier: "ReviewTVC")
        tblVwReview.estimatedRowHeight = 100
        uiSet()
        
    }
    @objc func handleSwipe() {
              navigationController?.popViewController(animated: true)
          }
    override func viewWillLayoutSubviews() {
        if self.arrReview.count > 0{
            self.heightTblVwReview.constant = self.tblVwReview.contentSize.height+10
            
        }else{
            self.heightTblVwReview.constant = 100
            
        }
    }
    func uiSet(){
        tblVwReview.estimatedRowHeight = 100
        tblVwReview.rowHeight = UITableView.automaticDimension
        if Store.role == "b_user"{
            btnThreedot.isHidden = false
            viewProvider.isHidden = true
            heightBtnAddReview.constant = 0
            widthBtnAddReview.constant = 0
            lblAbout.numberOfLines = 5
            
        }else{
            lblReviewTitle.isHidden = false
            btnThreedot.isHidden = true
            viewProvider.isHidden = false
            heightBtnAddReview.constant = 25
            widthBtnAddReview.constant = 100
            lblAbout.numberOfLines = 5
            
        }
        getUserServiceDetailApi()
    }
    
    func getUserServiceDetailApi(){
        viewModel.GetServiceDetailUserSideApi(service_id: serviceId) { data in
            Store.ServiceId = self.serviceId
            self.userServiceDetail = data
            self.arrReview = data?.reviews ?? []
                if self.arrReview.count > 0{
                    self.lblNoData.isHidden = true
                }else{
                    self.lblNoData.isHidden = false
                    
                }
            self.phoneNumber = data?.user?.mobile ?? 0
            self.lblName.text = data?.user?.name ?? ""
            self.lblNameServiceProvider.text = data?.user?.name ?? ""
            self.imgVwServiceProvider.imageLoad(imageUrl: data?.user?.profilePhoto ?? "")
            self.lblLocation.text = data?.user?.place ?? ""
            let rating = data?.rating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            if data?.reviews?.count ?? 0 > 1{
                self.lblRating.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Reviews)"
            }else{
                self.lblRating.text = "\(formattedRating) (\(data?.reviews?.count ?? 0) Review)"
            }
            
            self.lblPrice.text = " $\(data?.price ?? 0)"
            self.lblService.text = data?.serviceName ?? ""
            self.lblAbout.text = data?.description ?? ""
            if data?.serviceImages?.count ?? 0 > 0{
                self.arrImgs = data?.serviceImages ?? []
                self.lblImgCount.text = "Gallery(\(self.arrImgs.count))"
                if data?.serviceImages?.count ?? 0 > 0{
                    self.imgVwProfile.imageLoad(imageUrl: data?.serviceImages?[0] ?? "")
                }
            }
            if let userCategories = data?.userCategories {
                let subcategoryNames = userCategories.userSubCategories?.compactMap { $0.subcategoryName } ?? []
                let joinedSubcategories = subcategoryNames.joined(separator: " , ")
                self.lblSubcategory.text = "\(data?.userCategories?.categoryName ?? "") / \(joinedSubcategories)"
            }
            if self.arrImgs.count > 2{
                self.btnViewAllImgs.isHidden = false
            }else{
                self.btnViewAllImgs.isHidden = true
            }
            self.collvwGallary.reloadData()
            self.tblVwReview.reloadData()
            self.tblVwReview.invalidateIntrinsicContentSize()
        }
    }
    @IBAction func actionServiceProviderProfile(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
        vc.businessId = Store.UserServiceDetailData?.getBusinessDetails?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionThreeDot(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesMoreOptionsVC") as! ServicesMoreOptionsVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { isSelect in
            
            if isSelect == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditServiceVC") as! EditServiceVC
                vc.arrServiceDetail = self.arrServiceDetail
                vc.editServiceDetail = self.userServiceDetail
                vc.serviceId = self.userServiceDetail?.id ?? ""
                vc.callBack = {
                    self.uiSet()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
                vc.isSelect = 1
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: false)
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionAddReview(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = 0
        vc.serviceDetail = userServiceDetail
        for (index, review) in arrReview.enumerated() {
            if Store.userId == review.user?.id ?? ""{
                vc.isUpdateReview = true
                vc.serviceReview = review
                break
            }
        }
        vc.callBack = {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
            vc.modalPresentationStyle = .overFullScreen
            vc.callBack = {
                self.getUserServiceDetailApi()
            }
            self.navigationController?.present(vc, animated: false)
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionAllGallary(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GallaryImagesVC") as! GallaryImagesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = false
        vc.arrServiceImgs = arrImgs
        vc.callBack = { index in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
            vc.index = index
            vc.arrImage = self.arrImgs
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionMessage(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
        vc.receiverId = Store.recevrID ?? ""
        vc.isAbout = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionCall(_ sender: UIButton) {
        let numberUrl = URL(string: "tel://\(phoneNumber ?? 0)")!
        if UIApplication.shared.canOpenURL(numberUrl) {
            UIApplication.shared.open(numberUrl)
        }
    }
    
}
//MARK: - UICollectionViewDelegate
extension ServiceDetailVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(arrImgs.count,2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GallaryImgsCVC", for: indexPath) as! GallaryImgsCVC
        cell.imgVwService.imageLoad(imageUrl: arrImgs[indexPath.row])
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
        vc.arrImage = self.arrImgs
        self.navigationController?.pushViewController(vc, animated: true)
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePhotoVC") as! ChangePhotoVC
//        vc.isComing = 7
//        vc.img = arrImgs[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collvwGallary.frame.size.width / 2 - 5, height: 130)
    }
}

//MARK: -UITableViewDelegate
extension ServiceDetailVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
        
        cell.imgVwUser.imageLoad(imageUrl: arrReview[indexPath.row].user?.profilePhoto ?? "")
        cell.lblName.text = arrReview[indexPath.row].user?.name ?? ""
        cell.lblDescription.text = arrReview[indexPath.row].comment ?? ""
        cell.ratingView.rating = arrReview[indexPath.row].starCount ?? 0.0
        cell.lblRating.text = "\(arrReview[indexPath.row].starCount ?? 0.0)"
        cell.lblDescription.sizeToFit()
        heightDescription += Int(cell.lblDescription.frame.size.height)
        let createdAt = arrReview[indexPath.row].createdAt ?? ""
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
        if arrReview[indexPath.row].media == "" || arrReview[indexPath.row].media == nil{
            cell.heightImgVw.constant = 0
            reviewHeight += Int(70 + CGFloat(self.heightDescription))
        }else{
            cell.heightImgVw.constant = 150
            reviewHeight += Int(220 + CGFloat(self.heightDescription))
            cell.imgVwReview.imageLoad(imageUrl: arrReview[indexPath.row].media ?? "")
        }
        
        return cell
    }
    
   
}

