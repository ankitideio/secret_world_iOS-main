//
//  PopupUserVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 20/01/25.
//

import UIKit

class PopupUserVC: UIViewController {
    
    @IBOutlet weak var heightCollVwImg: NSLayoutConstraint!
    @IBOutlet weak var topImgCollVw: NSLayoutConstraint!
    @IBOutlet weak var widthReviewBtn: NSLayoutConstraint!
    @IBOutlet weak var heightTblVw: NSLayoutConstraint!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imgVwPopUp: UIImageView!
    @IBOutlet weak var imgVwFill: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDataFound: UILabel!
    @IBOutlet weak var tblVwReview: CustomTableView!
    @IBOutlet weak var btnAddReview: UIButton!
    @IBOutlet weak var lblViewPopUp: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var collVwImages: UICollectionView!
    @IBOutlet weak var lblDescription: UILabel!
    
    var popupId:String?
    var arrReview = [PopUpReview]()
    private var popupDetailData:PopupDetailData?
    var viewModel = PopUpVM()
    private var fullText = ""
    private var isExpanded = false
    private var arrImages = [String]()
    private var heightDescription = 0
    private var reviewHeight = 0
    private var isReviewed = false
    var callBack:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getPopUpDetailApi()
    }
    override func viewWillLayoutSubviews() {
        self.heightTblVw.constant = self.tblVwReview.contentSize.height+10
      
    }
    func getPopUpDetailApi(){
        let nibNearBy = UINib(nibName: "ReviewTVC", bundle: nil)
        tblVwReview.register(nibNearBy, forCellReuseIdentifier: "ReviewTVC")
        viewModel.getPopupDetailApi(loader: true, popupId: popupId ?? "") { data in
            self.popupDetailData = data
            self.lblTitle.text = data?.name ?? ""
            self.imgVwPopUp.imageLoad(imageUrl: data?.businessLogo ?? "")
//            self.lblDescription.text = data?.description ?? ""
            self.lblOffer.text = data?.deals ?? ""
            self.lblLocation.text = data?.place ?? ""
            let startTime = self.convertUpdateDateString(data?.startDate ?? "")
            let endTime = self.convertUpdateDateString(data?.endDate ?? "")
            self.lblTime.text = "\(startTime ?? "") - \(endTime ?? "")"
            self.lblRating.text = "\(data?.rating ?? 0)"
            self.fullText = data?.description ?? ""
            self.arrImages = data?.productImages ?? []
            self.lblViewPopUp.text = "\(data?.hitCount ?? 0) people viewed this pop-up"
            self.lblDescription.appendReadmore(after: self.fullText, trailingContent: .readmore)
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
            for i in data?.reviews ?? []{
                if i.userId?.id ?? "" == Store.userId{
                  
                    self.btnAddReview.setTitle("Update Reviews", for: .normal)
                    self.widthReviewBtn.constant = 115
                    self.isReviewed = true
                }else{
                    self.isReviewed = false
                    self.btnAddReview.setTitle("Add Reviews", for: .normal)
                    self.widthReviewBtn.constant = 100
                }
            }
            if data?.productImages?.count ?? 0 > 0{
                self.heightCollVwImg.constant = 150
                self.topImgCollVw.constant = 20
                self.collVwImages.isHidden = false
            }else{
                self.heightCollVwImg.constant = 0
                self.topImgCollVw.constant = 0
                self.collVwImages.isHidden = true
            }
            self.tblVwReview.reloadData()
            self.collVwImages.reloadData()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        lblDescription.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleDescription() {
        isExpanded.toggle()
        if lblDescription.text?.contains("Read More") ?? false || lblDescription.text?.contains("Read Less") ?? false{
            if isExpanded {
                lblDescription.appendReadLess(after: fullText, trailingContent: .readless)
            } else {
                lblDescription.appendReadmore(after: fullText, trailingContent: .readmore)
            }
           
           
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
    @IBAction func actionAddReviews(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupReviewVC") as! PopupReviewVC
        vc.popupId = popupId ?? ""
        vc.popUpDetail = self.popupDetailData
        vc.isComing = self.isReviewed
        
        vc.callBack = {
            self.getPopUpDetailApi()
        }
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        callBack?()
    }
    @IBAction func actionLocation(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        vc.isComing = true
       
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionMessage(_ sender: UIButton) {
    }
    
    @IBAction func actionAddToItinerary(_ sender: UIButton) {
    }
}

extension PopupUserVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopuppImagesCVC", for: indexPath) as! PopuppImagesCVC
        cell.imgVwPopup.imageLoad(imageUrl: arrImages[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwImages.frame.width/1, height: 160)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension PopupUserVC:UITableViewDelegate,UITableViewDataSource{
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
       

        if arrReview[indexPath.row].userId?.id == Store.userId{
            cell.btnDelete.isHidden = false
          
            cell.btnDelete.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnDelete.addTarget(self, action: #selector(deleteReview), for: .touchUpInside)
            cell.btnDelete.tag = indexPath.row
        }else{
            cell.btnDelete.isHidden = true
        }
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
    
    @objc func deleteReview(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
        vc.isSelect = 4
        vc.reviewId = arrReview[sender.tag].id ?? ""
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack  = { message in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 10
                vc.message = message
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    self.getPopUpDetailApi()
                }
                self.navigationController?.present(vc, animated: false)
        }
        self.navigationController?.present(vc, animated: false)
    }
}
