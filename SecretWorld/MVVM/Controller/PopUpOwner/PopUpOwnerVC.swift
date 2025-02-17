//
//  PopUpOwnerVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 20/01/25.
//

import UIKit

class PopUpOwnerVC: UIViewController {
    
    @IBOutlet weak var lblDataFound: UILabel!
    @IBOutlet weak var heightTblVw: NSLayoutConstraint!
    @IBOutlet weak var heightDescriptionVw: NSLayoutConstraint!
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var lblDateFound: UILabel!
    @IBOutlet weak var btnAddReview: UIButton!
    @IBOutlet weak var lblPeopleView: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var heightCollVw: NSLayoutConstraint!
    @IBOutlet weak var vwDetail: UIView!
    @IBOutlet weak var vwOffer: UIView!
    @IBOutlet weak var tblVwReview: CustomTableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var collVwImages: UICollectionView!
    @IBOutlet weak var vwDescription: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblUserCount: UILabel!
    @IBOutlet weak var imgVwCategory: UIImageView!
    @IBOutlet weak var imgVwTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgVwPopup: UIImageView!
    
    var popupId:String?
    var viewModel = PopUpVM()
    private var fullText = ""
    private var isExpanded = false
    var popupDetails:PopupDetailData?
    var callBack:(()->())?
    var arrReview = [PopUpReview]()
    private var heightDescription = 0
    private var reviewHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSet()
    }
    func uiSet() {
        // Existing UI setup code
        getPopUpDetailApi()
        vwDescription.layer.shadowColor = UIColor.black.cgColor
        vwDescription.layer.shadowOpacity = 0.2
        vwDescription.layer.shadowOffset = CGSize(width: 4, height: 4)
        vwDescription.layer.shadowRadius = 4
        vwDescription.layer.masksToBounds = false

        vwOffer.layer.shadowColor = UIColor.black.cgColor
        vwOffer.layer.shadowOpacity = 0.2
        vwOffer.layer.shadowOffset = CGSize(width: 4, height: 4)
        vwOffer.layer.shadowRadius = 4
        vwOffer.layer.masksToBounds = false

        vwDetail.layer.shadowColor = UIColor.black.cgColor
        vwDetail.layer.shadowOpacity = 0.2
        vwDetail.layer.shadowOffset = CGSize(width: 4, height: 4)
        vwDetail.layer.shadowRadius = 4
        vwDetail.layer.masksToBounds = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        lblDescription.addGestureRecognizer(tapGesture)
       
      
    }
    
    override func viewWillLayoutSubviews() {
        self.heightTblVw.constant = self.tblVwReview.contentSize.height+10
      
    }
    
    @objc private func toggleDescription() {
        isExpanded.toggle()
        if lblDescription.text?.contains("Read More") ?? false || lblDescription.text?.contains("Read Less") ?? false{
            if isExpanded {
                lblDescription.appendReadLess(after: fullText, trailingContent: .readless)
            } else {
                lblDescription.appendReadmore(after: fullText, trailingContent: .readmore)
            }
            
            // Update the label's frame and constraint
            lblDescription.sizeToFit()
            
            // Calculate the new height based on the label's content size
            let updatedHeight = lblDescription.intrinsicContentSize.height
            heightDescriptionVw.constant = updatedHeight + 30 // Adjust the extra padding as needed
            
            // Force layout updates
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
          }
       
    }
    
    func getPopUpDetailApi(){
        let nibNearBy = UINib(nibName: "ReviewTVC", bundle: nil)
        tblVwReview.register(nibNearBy, forCellReuseIdentifier: "ReviewTVC")
        viewModel.getPopupDetailApi(loader: true, popupId: popupId ?? "") { data in
            self.popupDetails = data
            self.lblTitle.text = data?.name ?? ""
            self.imgVwPopup.imageLoad(imageUrl: data?.businessLogo ?? "")
            self.lblParticipants.text = "\(data?.Requests ?? 0)/\(data?.availability ?? 0) participants"
            self.lblUserCount.text = "\(data?.Requests ?? 0)"
            self.lblPeopleView.text = "\(data?.hitCount ?? 0) people viewed this pop-up"
            self.lblOffer.text = data?.deals ?? ""
            self.lblAddress.text = data?.place ?? ""
            let startTime = self.convertUpdateDateString(data?.startDate ?? "")
            let endTime = self.convertUpdateDateString(data?.endDate ?? "")
            self.lblTime.text = "\(startTime ?? "") - \(endTime ?? "")"
            self.fullText = data?.description ?? ""
            
            self.lblDescription.appendReadmore(after: self.fullText, trailingContent: .readmore)
            self.lblDescription.sizeToFit()
            self.lblDescription.layoutIfNeeded()
            self.heightDescriptionVw.constant = self.lblDescription.frame.height+35
            print("Height----",self.heightDescriptionVw.constant)
            if (self.popupDetails?.productImages?.count == 1) || (self.popupDetails?.productImages?.count == 2){
                self.heightCollVw.constant = 100
            }else if (self.popupDetails?.productImages?.count == 3) || (self.popupDetails?.productImages?.count == 4){
                self.heightCollVw.constant = 200
            }else{
                self.heightCollVw.constant = 300
            }
            if data?.categoryType == 1{
                self.lblCategory.text = "Food & drinks"
            }else if data?.categoryType == 2{
                self.lblCategory.text = "Services"
            }else if data?.categoryType == 3{
                self.lblCategory.text = "Crafts & goods"
            }else{
                self.lblCategory.text = "Events"
            }
            self.arrReview = data?.reviews ?? []
            if data?.reviews?.count ?? 0 > 0{
                self.lblDataFound.isHidden = true
                
            }else{
                self.lblDataFound.isHidden = false
            }
            self.tblVwReview.reloadData()
            self.collVwImages.reloadData()
        }
    }
   
    func convertUpdateDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Define the possible date formats
        let possibleFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        
        // Attempt to parse the date using each format
        for format in possibleFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                // Format the parsed date into the desired output format
                dateFormatter.dateFormat = "hh:mm a"
                return dateFormatter.string(from: date)
            }
        }
    
        return nil
    }
    @IBAction func actionDelete(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
        vc.isSelect = 2
        vc.popupId = self.popupDetails?.id ?? ""
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack  = { message in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 10
                vc.message = message
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                    self.callBack?()
                }
                self.navigationController?.present(vc, animated: false)
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func actionEdit(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPopUpVC") as! AddPopUpVC
        vc.isComing = true
        vc.popupDetails = self.popupDetails
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionAddReview(_ sender: UIButton) {
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PopUpOwnerVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popupDetails?.productImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopuppImagesCVC", for: indexPath) as! PopuppImagesCVC
        let data = popupDetails?.productImages?[indexPath.row]
        cell.imgVwPopup.imageLoad(imageUrl: data ?? "")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwImages.frame.width/2-5, height: 90)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension PopUpOwnerVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
        cell.imgVwUser.imageLoad(imageUrl: arrReview[indexPath.row].userId?.profilePhoto ?? "")
        cell.lblName.text = arrReview[indexPath.row].userId?.name ?? ""
        cell.lblDescription.text = arrReview[indexPath.row].comment ?? ""
        cell.lblDescription.sizeToFit()
        let rating = arrReview[indexPath.row].starCount ?? 0
        let formattedRating = String(format: "%.1f", rating)
        cell.lblRating.text = "\(rating)"
        cell.ratingView.rating = Double(rating)
        heightDescription += Int(cell.lblDescription.frame.size.height)
        
        if arrReview[indexPath.row].media == "" || arrReview[indexPath.row].media == nil{
            cell.heightImgVw.constant = 0
            reviewHeight += Int(70 + CGFloat(self.heightDescription))
        }else{
            cell.heightImgVw.constant = 150
            reviewHeight += Int(220 + CGFloat(self.heightDescription))
            cell.imgVwReview.imageLoad(imageUrl: arrReview[indexPath.row].media ?? "")
        }
        
        let createdAt = arrReview[indexPath.row].updatedAt ?? ""
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
