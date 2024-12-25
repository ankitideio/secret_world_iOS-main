//
//  AddReviewVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 25/12/23.
//

import UIKit
import IQKeyboardManagerSwift
import FloatRatingView
import AlignedCollectionViewFlowLayout

class AddReviewVC: UIViewController, FloatRatingViewDelegate {
    @IBOutlet var heightViewRating: NSLayoutConstraint!
    @IBOutlet var imgVwStar: UIImageView!
    @IBOutlet var lblTxtCount: UILabel!
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet var btnSubmitUpdate: UIButton!
    
    @IBOutlet weak var lblReviewDescription: UILabel!
    @IBOutlet var collVwCategory: UICollectionView!
    @IBOutlet var imgVwCameraIcon: UIImageView!
    @IBOutlet var ratingView: FloatRatingView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var uploadImg: UIImageView!
    @IBOutlet var txtVwReview: IQTextView!
    @IBOutlet var viewBack: UIView!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblPlace: UILabel!
    @IBOutlet var lblBusinessName: UILabel!
    
    var userDetail:UserDetailses?
    var callBack: (()->())?
    var viewModel = ExploreVM()
    var arrUserCategory:ServiceDetailsData?
    var isUpload = false
    var userGigDetail:GetUserGigData?
    var businessGigDetail:GetGigDetailData?
    var userId = ""
    var isComing = 0
    var viewModelGig = AddGigVM()
    var gigId = ""
    var serviceDetail:GetServiceDataaa?
    var isUpdateReview = false
    var reviewDetail:Review?
    var gigReview:Reviews?
    var serviceReview:ReviewService?
    var businessgigReview:ReviewGigBuser?
    var userToUserGigDetail:GetGigDetailData?
    var userToUserGigReview:ReviewGigBuser?
    var reviewsToParticipants:ReviewData?
    var isSelect = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwCategory.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        uiSet() 
        textViewDidChange(txtVwReview)
        ratingView.delegate = self
        bgView.layer.cornerRadius = 30
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwCategory.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
        
        
        if let flowLayout = collVwCategory.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 36)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
        }
        collVwCategory.reloadData()
        
    }
    func uiSet(){
        if isComing == 0{
            //from service deatail
            heightViewRating.constant = 30
            imgVwStar.isHidden = false
            lblPlace.text = serviceDetail?.user?.place ?? ""
            let rating = serviceDetail?.rating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            lblRating.text = "\(formattedRating) (\(serviceDetail?.reviews?.count ?? 0) Reviews)"
            lblBusinessName.text = serviceDetail?.serviceName ?? ""
            lblReviewDescription.text = "Your overall rating of this service"
            if isUpdateReview == false{
                lblScreenTitle.text = "Add Review"
                btnSubmitUpdate.setTitle("Submit", for: .normal)
            }else{
                lblScreenTitle.text = "Update Review"
                btnSubmitUpdate.setTitle("Update", for: .normal)
                txtVwReview.text = serviceReview?.comment ?? ""
                ratingView.rating = serviceReview?.starCount ?? 0
                uploadImg.imageLoad(imageUrl: serviceReview?.media ?? "")
            }
        }else if isComing == 1{
            //from business applied gig
            heightViewRating.constant = 0
            lblPlace.text = businessGigDetail?.place ?? ""
            imgVwStar.isHidden = true
            lblRating.text = ""
            lblBusinessName.text = businessGigDetail?.title ?? ""
            
            lblReviewDescription.text = "Your overall rating of this gig"
            if isUpdateReview == false{
                lblScreenTitle.text = "Add Review"
                btnSubmitUpdate.setTitle("Submit", for: .normal)
                
            }else{
                lblScreenTitle.text = "Update Review"
                btnSubmitUpdate.setTitle("Update", for: .normal)
                
                txtVwReview.text = reviewsToParticipants?.comment ?? ""
                
                ratingView.rating = reviewsToParticipants?.starCount ?? 0
                uploadImg.imageLoad(imageUrl: reviewsToParticipants?.media ?? "")
                
            }
        }else if isComing == 2{
            
            //from user apply gig
            heightViewRating.constant = 30
            lblPlace.text = userGigDetail?.gig?.place ?? ""
            lblRating.text = "\(userGigDetail?.rating ?? 0.0) (\(userGigDetail?.reviews?.count ?? 0) Reviews)"
            lblBusinessName.text = userGigDetail?.gig?.title ?? ""
            lblReviewDescription.text = "Your overall rating of this gig"
            
            if isUpdateReview == false{
                lblScreenTitle.text = "Add Review"
                btnSubmitUpdate.setTitle("Submit", for: .normal)
                
            }else{
                lblScreenTitle.text = "Update Review"
                btnSubmitUpdate.setTitle("Update", for: .normal)
                txtVwReview.text = gigReview?.comment ?? ""
                ratingView.rating = gigReview?.starCount ?? 0
                uploadImg.imageLoad(imageUrl: gigReview?.media ?? "")
                
            }
            
        }else if isComing == 5{
            
            //from user apply gig
            heightViewRating.constant = 0
            imgVwStar.isHidden = true
            lblPlace.text = userToUserGigDetail?.place ?? ""
            lblRating.text = ""
            lblBusinessName.text = userToUserGigDetail?.title ?? ""
            lblReviewDescription.text = "Your overall rating of this gig"
            if isUpdateReview == false{
                lblScreenTitle.text = "Add Review"
                btnSubmitUpdate.setTitle("Submit", for: .normal)
            }else{
                lblScreenTitle.text = "Update Review"
                btnSubmitUpdate.setTitle("Update", for: .normal)
                txtVwReview.text = userToUserGigReview?.comment ?? ""
                ratingView.rating = userToUserGigReview?.starCount ?? 0
                uploadImg.imageLoad(imageUrl: userToUserGigReview?.media ?? "")
                
            }
            
        }
        else{
            //from businesss detail
            heightViewRating.constant = 30
            imgVwStar.isHidden = false
            arrUserCategory =  Store.UserServiceDetailData
            lblPlace.text = arrUserCategory?.getBusinessDetails?.place ?? ""
            let rating = arrUserCategory?.getBusinessDetails?.rating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)

            lblRating.text = "\(formattedRating) (\(arrUserCategory?.getBusinessDetails?.ratingCount ?? 0) Reviews)"
            lblBusinessName.text = arrUserCategory?.getBusinessDetails?.businessname ?? ""
            lblReviewDescription.text = "Your overall rating for this business"
            
            if isUpdateReview == false{
                lblScreenTitle.text = "Add Review"
                btnSubmitUpdate.setTitle("Submit", for: .normal)
            }else{
                lblScreenTitle.text = "Update Review"
                btnSubmitUpdate.setTitle("Update", for: .normal)
                txtVwReview.text = reviewDetail?.comment ?? ""
                ratingView.rating = reviewDetail?.starCount ?? 0
                uploadImg.imageLoad(imageUrl: reviewDetail?.media ?? "")
            }
        }
        setupOverlayView()
    }
    func setupOverlayView() {
        viewBack = UIView(frame: self.view.bounds)
        viewBack.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        viewBack.addGestureRecognizer(tapGesture)
        self.view.insertSubview(viewBack, at: 0)
    }
    @objc func overlayTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionCross(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func actionSubmit(_ sender: UIButton) {
        let trimmedText = txtVwReview.text.trimmingCharacters(in: .whitespacesAndNewlines)
       if ratingView.rating == 0{
            showSwiftyAlert("", "Please select rating", false)
        }else{
            if isComing == 0{
                if isUpdateReview == false{
                    viewModel.AddServiceReviewApi(service_id: serviceDetail?.id ?? "",
                                                  media: uploadImg,
                                                  comment: trimmedText,
                                                  starCount: String(ratingView.rating), isUploading: isUpload) {
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }else{
                    viewModel.updateReviewApi(targetType: "service", targetId: serviceReview?.id ?? "", comment: trimmedText, starCount: String(ratingView.rating), media: uploadImg, isUploading: isUpload) { message in
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }
            }else if isComing == 1{
                //buser gig
                if isUpdateReview == false{
                    viewModel.AddGigReviewApi(gigId: gigId, businessUserId: userId,
                                              media: uploadImg,
                                              comment: trimmedText,
                                              starCount: String(ratingView.rating), reviewType: 1, isUploading: isUpload) {
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }else{
                    viewModel.updateReviewApi(targetType: "gig", targetId: reviewsToParticipants?.id ?? "", comment: trimmedText, starCount: String(ratingView.rating), media: uploadImg, isUploading: isUpload) { message in
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }
                
            }else if isComing == 2{
                //user gig
                if isUpdateReview == false{
                    viewModel.AddGigReviewApi(gigId: gigId, businessUserId: userId,
                                              media: uploadImg,
                                              comment: trimmedText,
                                              starCount: String(ratingView.rating), reviewType: 0, isUploading: isUpload) {
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }else{
                    viewModel.updateReviewApi(targetType: "gig", targetId: gigReview?.id ?? "", comment: trimmedText, starCount: String(ratingView.rating), media: uploadImg, isUploading: isUpload) { message in
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }
            }else if isComing == 5{
                //user gig
                if isUpdateReview == false{
                    viewModel.AddGigReviewApi(gigId: gigId, businessUserId: userId,
                                              media: uploadImg,
                                              comment: trimmedText,
                                              starCount: String(ratingView.rating), reviewType: 0, isUploading: isUpload) {
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }else{
                    viewModel.updateReviewApi(targetType: "gig", targetId: userToUserGigReview?.id ?? "", comment: trimmedText, starCount: String(ratingView.rating), media: uploadImg, isUploading: isUpload) { message in
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }
            }else{
                if isUpdateReview == false{
                    viewModel.AddBusinessReviewApi(businessUserId: arrUserCategory?.getBusinessDetails?.id ?? "",
                                                   media: uploadImg,
                                                   comment: trimmedText,
                                                   starCount: String(ratingView.rating), isUploading: isUpload) {
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }else{
                    viewModel.updateReviewApi(targetType: "business", targetId: reviewDetail?.id ?? "", comment: trimmedText, starCount: String(ratingView.rating), media: uploadImg, isUploading: isUpload) { message in
                        self.dismiss(animated: true)
                        self.callBack?()
                    }
                }
            }
        }
        
    }
    
    @IBAction func actionAddPhoto(_ sender: UIButton) {
        ImagePicker().pickImage(self) { image in
            self.uploadImg.image = image
            self.isUpload = true
        }
        
    }
    
    
}
//MARK: - UICollectionViewDelegate
extension AddReviewVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrUserCategory?.allservices?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
        cell.lblName.numberOfLines = 1
        if Store.role == "b_user"{
            cell.lblName.text = arrUserCategory?.allservices?[indexPath.item].userCategories?.categoryName ?? ""
        }else{
            cell.lblName.text = arrUserCategory?.allservices?[indexPath.item].userCategories?.categoryName ?? ""
        }
        
        cell.vwBg.cornerRadiusView = 4
        cell.widthBtnCross.constant = 0
        cell.lblName.textColor = .app
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collVwCategory.frame.size.width / 3, height: 30)
    }
}

//MARK: - UITextViewDelegate
extension AddReviewVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        let characterCount = textView.text.count
        lblTxtCount.text = "\(characterCount)/250"
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
        
    }
}
