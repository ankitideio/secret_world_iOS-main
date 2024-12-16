//
//  AddGigVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 03/01/24.
//
import UIKit
class AddGigVC: UIViewController {
    @IBOutlet var imgVwTick: UIImageView!
    //MARK: - OUTLETS uploading-to-cloud-VWQJD1A1A0
    @IBOutlet var txtFldServicetype: UITextField!
    @IBOutlet var txtFldTastDuration: UITextField!
    @IBOutlet var txtFldSelectDate: UITextField!
    @IBOutlet var txtFldSelectTime: UITextField!
    @IBOutlet var imgVwUploadBtnGif: UIImageView!
    @IBOutlet var lblUploadImage: UILabel!
    @IBOutlet var btnUploadImg: UIButton!
    @IBOutlet var lblPlus: UILabel!
    @IBOutlet var lblUploadPhoto: UILabel!
    @IBOutlet var txtFldGigType: UITextField!
    @IBOutlet var btnCreateUpdate: UIButton!
    @IBOutlet var txtFldPaticipants: UITextField!
    @IBOutlet var viewOfAdddPhotoLbls: UIView!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var lblTitleScreen: UILabel!
    @IBOutlet var lblTxtvwCount: UILabel!
    @IBOutlet var txtVwAbout: UITextView!
    @IBOutlet var txtFldfee: UITextField!
    @IBOutlet var txtFldLocation: UITextField!
    @IBOutlet var txtFldTitle: UITextField!
    @IBOutlet var txtFldName: UITextField!
    @IBOutlet var imgVwUpload: UIImageView!
    
    //MARK: - VARIABLES
    var selectGigType = ""
    var userGigDetail:GetUserGigData?
    var isComing  = false
    var isUploading = false
    var viewModel  = AddGigVM()
    var lat = Double()
    var long = Double()
    var gigDetail:GetGigDetailData?
    var walletViewModel = PaymentVM()
    var walletAmount = 0
    var gigFees:Int?
    var gigLocationType = 2
    var selectedStartDate = ""
    var usergigDetail:GetUserGigData?
    var IsUserGig = false
    var serviceName = ""
    var serviceDuration = ""
    var callBack:(()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        txtFldTitle.delegate = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        setupDatePicker(for:txtFldSelectDate, mode: .date, selector: #selector(startDateDonePressed))
        setupDatePicker(for: txtFldSelectTime, mode: .time, selector: #selector(startTimeDonePressed))
        setupDatePicker(for: txtFldTastDuration, mode: .countDownTimer, selector: #selector(timePickerDonePressed))
        if isComing == true{
            getCommisionApi()
            if let gifImageView = UIImageView.fromGif(frame: imgVwUploadBtnGif.bounds, resourceName: "upload") {
                // Assign the animation images to the IBOutlet
                imgVwUploadBtnGif.animationImages = gifImageView.animationImages
                imgVwUploadBtnGif.animationDuration = gifImageView.animationDuration
                imgVwUploadBtnGif.startAnimating()
            } else {
                print("Failed to load GIF")
            }

            lblTitleScreen.text = "Add Gig"
            if Store.GigImg == UIImage(named: "") || Store.GigImg == nil || Store.AddGigImage == UIImage(named: "") || Store.AddGigImage == nil{
                isUploading = false
                viewOfAdddPhotoLbls.isHidden = false
                btnDelete.isHidden = true
                lblPlus.isHidden = false
                lblUploadPhoto.isHidden = false
            }else{
                imgVwUpload.image = Store.AddGigImage
                isUploading = true
                viewOfAdddPhotoLbls.isHidden = true
                btnDelete.isHidden = true
                lblPlus.isHidden = true
                lblUploadPhoto.isHidden = true
            }
//            txtFldLocation.text = Store.AddGigDetail?["location"] as? String ?? ""
//            txtFldTitle.text = Store.AddGigDetail?["title"] as? String ?? ""
//            lat = Store.AddGigDetail?["lat"] as? Double ?? 0
//            long = Store.AddGigDetail?["long"] as? Double ?? 0
//            txtFldPaticipants.text = Store.AddGigDetail?["participants"] as? String ?? ""
//            txtFldGigType.text = Store.AddGigDetail?["type"] as? String ?? ""
//            if Store.AddGigDetail?["type"] as? String ?? "" == "worldwide"{
//                txtFldGigType.text = "Worldwide"
//                selectGigType = "worldwide"
//            }else if Store.AddGigDetail?["type"] as? String ?? "" == "inMyLocation"{
//                txtFldGigType.text = "In My Location"
//                selectGigType = "inMyLocation"
//            }else{
//                txtFldGigType.text = ""
//                selectGigType = ""
//            }
//            txtFldfee.text = Store.AddGigDetail?["fees"] as? String ?? ""
//            txtVwAbout.text = Store.AddGigDetail?["about"] as? String ?? ""
//            if Store.role == "b_user"{
//                txtFldName.text =  Store.BusinessUserDetail?["userName"] as? String ?? ""
//            }else{
//                txtFldName.text = Store.UserDetail?["userName"] as? String ?? ""
//            }
            btnCreateUpdate.setTitle("Create", for: .normal)
        }else{
            Store.AddGigImage = nil
            Store.AddGigDetail = nil
            lblTitleScreen.text = "Edit Gig"
            btnCreateUpdate.setTitle("Update", for: .normal)
            
            if IsUserGig{
                
                if usergigDetail?.gig?.image == "" ||  usergigDetail?.gig?.image == nil{
                    isUploading = false
                    btnDelete.isHidden = true
                    imgVwUpload.image = UIImage(named: "")
                    lblPlus.isHidden = false
                    lblUploadPhoto.isHidden = false
                    imgVwUploadBtnGif.isHidden = false
                    imgVwTick.isHidden = true
                    if let gifImageView = UIImageView.fromGif(frame: imgVwUploadBtnGif.bounds, resourceName: "upload") {
                        // Assign the animation images to the IBOutlet
                        imgVwUploadBtnGif.animationImages = gifImageView.animationImages
                        imgVwUploadBtnGif.animationDuration = gifImageView.animationDuration
                        imgVwUploadBtnGif.startAnimating()
                    } else {
                        print("Failed to load GIF")
                    }
                    
                }else{
                    imgVwUploadBtnGif.isHidden = true
                    imgVwTick.isHidden = false
                    isUploading = true
                    btnDelete.isHidden = true
                    lblPlus.isHidden = true
                    lblUploadPhoto.isHidden = true
                    imgVwUpload.imageLoad(imageUrl: usergigDetail?.gig?.image ?? "")
                    Store.GigImg = imgVwUpload.image
                }
                let iso8601String = usergigDetail?.gig?.startDate ?? ""
                let result = formatDateAndTime(from: iso8601String)
                if let date = result.formattedDate, let time = result.formattedTime {
                    txtFldSelectDate.text = date
                    txtFldSelectTime.text = time
                }
                
                txtFldTastDuration.text = usergigDetail?.gig?.serviceDuration ?? ""
                txtFldServicetype.text = usergigDetail?.gig?.serviceName ?? ""
                txtFldName.text = usergigDetail?.gig?.user?.name ?? ""
                txtVwAbout.text = usergigDetail?.gig?.about ?? ""
                txtFldLocation.text = usergigDetail?.gig?.place ?? ""
                txtFldPaticipants.text = "\(usergigDetail?.gig?.participants ?? "")"
                txtFldTitle.text = usergigDetail?.gig?.title ?? ""
                txtFldfee.text = "\(usergigDetail?.gig?.price ?? 0)"
                gigFees = usergigDetail?.gig?.price ?? 0
                textViewDidChange(self.txtVwAbout)
                lat = usergigDetail?.gig?.lat ?? 0.0
                long = usergigDetail?.gig?.long ?? 0.0
                if usergigDetail?.gig?.type == "worldwide"{
                    gigLocationType = 0
                    txtFldGigType.text = "Worldwide"
                    selectGigType = "worldwide"
                }else{
                    gigLocationType = 1
                    txtFldGigType.text = "In My Location"
                    selectGigType = "inMyLocation"
                }
            }else{
                if gigDetail?.image == "" ||  gigDetail?.image == nil{
                    isUploading = false
                    btnDelete.isHidden = true
                    imgVwUpload.image = UIImage(named: "")
                    lblPlus.isHidden = false
                    lblUploadPhoto.isHidden = false
                    imgVwUploadBtnGif.isHidden = false
                    imgVwTick.isHidden = true
                    if let gifImageView = UIImageView.fromGif(frame: imgVwUploadBtnGif.bounds, resourceName: "upload") {
                        // Assign the animation images to the IBOutlet
                        imgVwUploadBtnGif.animationImages = gifImageView.animationImages
                        imgVwUploadBtnGif.animationDuration = gifImageView.animationDuration
                        imgVwUploadBtnGif.startAnimating()
                    } else {
                        print("Failed to load GIF")
                    }
                    
                }else{
                    imgVwUploadBtnGif.isHidden = true
                    imgVwTick.isHidden = false
                    isUploading = true
                    btnDelete.isHidden = true
                    lblPlus.isHidden = true
                    lblUploadPhoto.isHidden = true
                    imgVwUpload.imageLoad(imageUrl: gigDetail?.image ?? "")
                    Store.GigImg = imgVwUpload.image
                }
                let iso8601String = gigDetail?.startDate ?? ""
                let result = formatDateAndTime(from: iso8601String)
                if let date = result.formattedDate, let time = result.formattedTime {
                    txtFldSelectDate.text = date
                    txtFldSelectTime.text = time
                }
                
                txtFldTastDuration.text = gigDetail?.serviceDuration ?? ""
                txtFldServicetype.text = gigDetail?.serviceName ?? ""
                txtFldName.text = gigDetail?.user?.name ?? ""
                txtVwAbout.text = gigDetail?.about ?? ""
                txtFldLocation.text = gigDetail?.place ?? ""
                txtFldPaticipants.text = "\(gigDetail?.participants ?? "")"
                txtFldTitle.text = gigDetail?.title ?? ""
                txtFldfee.text = "\(gigDetail?.price ?? 0)"
                gigFees = gigDetail?.price ?? 0
                textViewDidChange(self.txtVwAbout)
                lat = gigDetail?.lat ?? 0.0
                long = gigDetail?.long ?? 0.0
                if gigDetail?.type == "worldwide"{
                    gigLocationType = 0
                    txtFldGigType.text = "Worldwide"
                    selectGigType = "worldwide"
                }else{
                    gigLocationType = 1
                    txtFldGigType.text = "In My Location"
                    selectGigType = "inMyLocation"
                }
            }
        }
    }
    @objc func handleSwipe() {
        Store.AddGigImage = nil
        Store.AddGigDetail = nil
        if isComing{
            SceneDelegate().tabBarHomeRoot()
            callBack?()
        }else{
            self.navigationController?.popViewController(animated: true)
            callBack?()
        }

        }

    func getCommisionApi(){
        walletViewModel.GetComissionApi{ data in
            Store.commisionAmount = data?.result?.commission
        }
    }
    func dismissKeyboard(){
        txtFldName.resignFirstResponder()
        txtFldTitle.resignFirstResponder()
        txtFldPaticipants.resignFirstResponder()
        txtFldfee.resignFirstResponder()
        txtVwAbout.resignFirstResponder()
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func actionGigType(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigTypeVC") as! GigTypeVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = true
        vc.gigType = gigLocationType
        vc.callBack = { [weak self] type in
            guard let self = self else { return }
            self.gigLocationType = type
            //gigType  0 = "worldwide" gigType 1 = "inMyLocation"
            if type == 0{
                self.txtFldGigType.text = "Worldwide"
                self.selectGigType = "worldwide"
            }else if type == 1{
                self.txtFldGigType.text = "In My Location"
                self.selectGigType = "inMyLocation"
            }else{
                self.txtFldGigType.text = ""
                self.selectGigType = ""
            }
        }
        self.present(vc, animated: true)
    }
    @IBAction func actionUploadPic(_ sender: UIButton) {
        
        if isUploading == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePhotoVC") as! ChangePhotoVC
            vc.isComing = 4
            vc.callBack = { [weak self] image in
                guard let self = self else { return }
                if Store.GigImg == UIImage(named: "") || Store.GigImg == nil{
                    self.lblUploadPhoto.text = "Upload Image"
                    self.lblUploadPhoto.isHidden = false
                    self.lblPlus.isHidden = false
                    self.imgVwUpload.image = UIImage(named: "")
                    self.imgVwUploadBtnGif.isHidden = false
                    self.imgVwTick.isHidden = true
                    self.isUploading = false
                    self.viewOfAdddPhotoLbls.isHidden = false
                    self.btnDelete.isHidden = true
                }else{
                    self.lblUploadPhoto.text = "Uploaded Image"
                    self.imgVwUploadBtnGif.isHidden = true
                    self.imgVwTick.isHidden = false
                    self.lblUploadPhoto.isHidden = true
                    self.lblPlus.isHidden = true
                    self.imgVwUpload.image = image
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
            ImagePicker().pickImage(self) { image in
                self.lblUploadPhoto.text = "Uploaded Image"
                self.imgVwUploadBtnGif.isHidden = true
                self.imgVwTick.isHidden = false
                self.imgVwUpload.image = image
                self.isUploading = true
                Store.GigImg = image
                self.viewOfAdddPhotoLbls.isHidden = true
                self.btnDelete.isHidden = true
            }
        }
    }
    @IBAction func actionBack(_ sender: UIButton) {
        Store.AddGigImage = nil
        Store.AddGigDetail = nil
        if isComing{
            SceneDelegate().tabBarHomeRoot()
            callBack?()
        }else{
            self.navigationController?.popViewController(animated: true)
            callBack?()
        }
    }
    @IBAction func actionDelete(_ sender: UIButton) {
        isUploading = false
        viewOfAdddPhotoLbls.isHidden = false
        btnDelete.isHidden = true
        imgVwUpload.image = UIImage(named: "")
        lblUploadPhoto.isHidden = false
        lblPlus.isHidden = false
    }
    @IBAction func actionLocation(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        Store.AddGigImage = imgVwUpload.image
        Store.AddGigDetail = ["title":txtFldTitle.text ?? "",
                              "lat":lat,
                              "long":long,
                              "location":txtFldLocation.text ?? "",
                              "participants":txtFldPaticipants.text ?? "",
                              "type":selectGigType,
                              "fees":txtFldfee.text ?? "",
                              "about":txtVwAbout.text ?? ""]
        vc.isComing = true
        vc.callBack = { [weak self] aboutLocation in
            guard let self = self else { return }
            self.txtFldLocation.text = aboutLocation.placeName ?? ""
            self.lat = aboutLocation.lat ?? 0.0
            self.long = aboutLocation.long ?? 0.0
            Store.AddGigDetail = ["location":self.txtFldLocation.text ?? "",
                                  "lat":self.lat,
                                  "long":self.long]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func successAlert(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = {[weak self] in
            guard let self = self else { return }
            Store.tabBarNotificationPosted = false
            SceneDelegate().GigListVCRoot()
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func actionCreate(_ sender: UIButton) {
        if let selectedDate = txtFldSelectDate.text,
           let selectedTime = txtFldSelectTime.text,
           let combinedDate = combineDateAndTime(dateString: selectedDate, timeString: selectedTime) {
            print("Combined ISO 8601 Date: \(combinedDate)")
            selectedStartDate = combinedDate
        }
        
        if txtFldName.text == ""{
            showSwiftyAlert("", "Please enter user name", false)
        }else if txtFldTitle.text == ""{
            showSwiftyAlert("", "Please enter a title for your gig", false)
        }else if txtFldServicetype.text == ""{
            showSwiftyAlert("", "Please enter service type", false)
        }else if txtFldLocation.text == ""{
            showSwiftyAlert("", "Please select your location", false)
        }else if txtFldPaticipants.text == ""{
            showSwiftyAlert("", "Please enter the number of participants", false)
        }else if Int(txtFldPaticipants.text ?? "0") ?? 0 <= 0 {
            showSwiftyAlert("", "Please enter valid gig participants", false)
        }else if txtFldTastDuration.text == ""{
            showSwiftyAlert("", "Please select task duration", false)
        }else if txtFldSelectDate.text == ""{
            showSwiftyAlert("", "Please select date", false)
        }else if txtFldSelectTime.text == ""{
            showSwiftyAlert("", "Please select time", false)
        }else if txtFldGigType.text == ""{
            showSwiftyAlert("", "Please select gig type", false)
        }else if txtFldfee.text == ""{
            showSwiftyAlert("", "Please enter the fee amount", false)
        }else if Int(txtFldfee.text ?? "0") ?? 0 <= 0 {
            showSwiftyAlert("", "Please enter valid fee amount", false)
        }else if Int(txtFldfee.text ?? "0") ?? 0 <= 19 {
            showSwiftyAlert("", "Please enter more than $20", false)
        }else{
            Store.AddGigImage = imgVwUpload.image
            Store.AddGigDetail = ["title":txtFldTitle.text ?? "",
                                  "lat":lat,
                                  "long":long,
                                  "location":txtFldLocation.text ?? "",
                                  "participants":txtFldPaticipants.text ?? "",
                                  "type":selectGigType,
                                  "fees":txtFldfee.text ?? "",
                                  "about":txtVwAbout.text ?? ""]
                print("Stored AddGigDetail: \(String(describing: Store.AddGigDetail))")
            if let feeText = txtFldfee.text, let fee = Int(feeText) {
                let tenPercent = fee * 10 / 100
                Store.GigFees = tenPercent
            }
//                if Store.role == "b_user"{
//                    if self.isComing == true{
//                        isGigResponse = true
//                        self.viewModel.checAddGig(price: Int(self.txtFldfee.text ?? "") ?? 0) { message in
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
//                            vc.titleText = message
//                            vc.callBack = { [weak self] isPay in
//                                             guard let self = self else { return }
//                                if self.imgVwUpload.image == UIImage(named: ""){
//                                    self.viewModel.AddGigApi(usertype: "business_user",
//                                                             image: UIImageView(image: UIImage(named: "")),
//                                                             name: self.txtFldName.text ?? "",
//                                                             title: self.txtFldTitle.text ?? "",
//                                                             serviceName: txtFldServicetype.text ?? "",
//                                                             serviceDuration: txtFldTastDuration.text ?? "",
//                                                             startDate:txtFldSelectDate.text ?? "",
//                                                             place: self.txtFldLocation.text ?? "",
//                                                             lat: self.lat,
//                                                             long: self.long,
//                                                             participants: self.txtFldPaticipants.text ?? "",
//                                                             type: self.selectGigType,
//                                                             price: Int(self.txtFldfee.text ?? "") ?? 0,
//                                                             about: self.txtVwAbout.text ?? "",
//                                                             isImageNil: true) { data in
//                                        Store.AddGigImage = nil
//                                        Store.AddGigDetail = nil
//                                        self.successAlert()
//                                    }
//                                }else{
//                                    self.viewModel.AddGigApi(usertype: "business_user", image: self.imgVwUpload,
//                                                             name: self.txtFldName.text ?? "",
//                                                             title: self.txtFldTitle.text ?? "",
//                                                             serviceName: txtFldServicetype.text ?? "",
//                                                             serviceDuration: txtFldTastDuration.text ?? "",
//                                                             startDate:txtFldSelectDate.text ?? "",
//                                                             place: self.txtFldLocation.text ?? "",
//                                                             lat: self.lat,
//                                                             long: self.long,
//                                                             participants: self.txtFldPaticipants.text ?? "",
//                                                             type: self.selectGigType,
//                                                             price: Int(self.txtFldfee.text ?? "") ?? 0,
//                                                             about: self.txtVwAbout.text ?? "",
//                                                             isImageNil: false) { data in
//                                        Store.AddGigImage = nil
//                                        Store.AddGigDetail = nil
//                                        self.successAlert()
////                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
////                                        vc.modalPresentationStyle = .overFullScreen
////                                        vc.callBack = {
////                                            Store.tabBarNotificationPosted = false
////                                            SceneDelegate().GigListVCRoot()
////                                        }
////                                        self.navigationController?.present(vc, animated: false)
//                                    }
//                                }
//                            }
//                            vc.modalPresentationStyle = .overFullScreen
//                            self.navigationController?.present(vc, animated: false)
//                        }
//                    }else{
//                        if "\(gigFees ?? 0)" == txtFldfee.text ?? ""{
//                            print("equal")
//                            if self.imgVwUpload.image == UIImage(named: ""){
//                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
//                                                            image: UIImageView(image: UIImage(named: "")),
//                                                            name: self.txtFldName.text ?? "",
//                                                            title: self.txtFldTitle.text ?? "",
//                                                            serviceName: txtFldServicetype.text ?? "",
//                                                            serviceDuration: txtFldTastDuration.text ?? "",
//                                                            startDate:txtFldSelectDate.text ?? "",
//                                                            place: self.txtFldLocation.text ?? "",
//                                                            lat: self.lat, long: self.long,
//                                                            type: selectGigType,
//                                                            participants: self.txtFldPaticipants.text ?? "",
//                                                            price: Int(self.txtFldfee.text ?? "") ?? 0,
//                                                            about: self.txtVwAbout.text ?? "",
//                                                            isImageNil: true) { message in
//                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
//                                    vc.modalPresentationStyle = .overFullScreen
//                                    vc.isSelect = 10
//                                    vc.message = message
//                                    vc.callBack = {[weak self] in
//                                        guard let self = self else { return }
//                                        SceneDelegate().GigListVCRoot()
//                                    }
//                                    self.navigationController?.present(vc, animated: false)
//                                }
//                            }else{
//                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
//                                                            image: self.imgVwUpload,
//                                                            name: self.txtFldName.text ?? "",
//                                                            title: self.txtFldTitle.text ?? "",
//                                                            serviceName: txtFldServicetype.text ?? "",
//                                                            serviceDuration: txtFldTastDuration.text ?? "",
//                                                            startDate:txtFldSelectDate.text ?? "",
//                                                            place: self.txtFldLocation.text ?? "",
//                                                            lat: self.lat, long: self.long,
//                                                            type: selectGigType,
//                                                            participants: self.txtFldPaticipants.text ?? "",
//                                                            price: Int(self.txtFldfee.text ?? "") ?? 0,
//                                                            about: self.txtVwAbout.text ?? "",
//                                                            isImageNil: false) { message in
//                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
//                                vc.modalPresentationStyle = .overFullScreen
//                                vc.isSelect = 10
//                                vc.message = message
//                                vc.callBack = {[weak self] in
//                                    guard let self = self else { return }
//                                    SceneDelegate().GigListVCRoot()
//                                }
//                                self.navigationController?.present(vc, animated: false)
//                            }
//                        }
//                        }else{
//                            print("not equal")
//                            self.viewModel.checUpdateGig(gigId: self.gigDetail?.id ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0) { message in
//                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
//                                if let gigFees = self.gigFees,
//                                   let feeValue = Int(self.txtFldfee.text ?? ""),
//                                   gigFees > feeValue {
//                                    vc.isAmountLess = true
//                                }else{
//                                    vc.isAmountLess = false
//                                }
//
//                                vc.titleText = message
//                                vc.callBack = { [weak self] isPay in
//                                    guard let self = self else { return }
//                                    if self.imgVwUpload.image == UIImage(named: ""){
//                                        self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", 
//                                                                    image:UIImageView(image: UIImage(named: "")),
//                                                                    name: self.txtFldName.text ?? "",
//                                                                    title: self.txtFldTitle.text ?? "",
//                                                                    serviceName: txtFldServicetype.text ?? "",
//                                                                    serviceDuration: txtFldTastDuration.text ?? "",
//                                                                    startDate:txtFldSelectDate.text ?? "",
//                                                                    place: self.txtFldLocation.text ?? "",
//                                                                    lat: self.lat, long: self.long,
//                                                                    type: self.selectGigType,
//                                                                    participants: self.txtFldPaticipants.text ?? "",
//                                                                    price: Int(self.txtFldfee.text ?? "") ?? 0,
//                                                                    about: self.txtVwAbout.text ?? "",
//                                                                    isImageNil: true) { message in
//                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
//                                            vc.modalPresentationStyle = .overFullScreen
//                                            vc.isSelect = 10
//                                            vc.message = message
//                                            vc.callBack = {[weak self] in
//                                                guard let self = self else { return }
//                                                SceneDelegate().GigListVCRoot()
//                                            }
//                                            self.navigationController?.present(vc, animated: false)
//                                        }
//                                    }else{
//                                        self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
//                                                                    image: self.imgVwUpload,
//                                                                    name: self.txtFldName.text ?? "",
//                                                                    title: self.txtFldTitle.text ?? "",
//                                                                    serviceName: txtFldServicetype.text ?? "",
//                                                                    serviceDuration: txtFldTastDuration.text ?? "",
//                                                                    startDate:txtFldSelectDate.text ?? "",
//                                                                    place: self.txtFldLocation.text ?? "",
//                                                                    lat: self.lat, long: self.long,
//                                                                    type: self.selectGigType,
//                                                                    participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
//                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
//                                        vc.modalPresentationStyle = .overFullScreen
//                                        vc.isSelect = 10
//                                        vc.message = message
//                                        vc.callBack = {[weak self] in
//                                            guard let self = self else { return }
//                                            SceneDelegate().GigListVCRoot()
//                                        }
//                                        self.navigationController?.present(vc, animated: false)
//                                    }
//                                }
//                                }
//                                    vc.modalPresentationStyle = .overFullScreen
//                                    self.navigationController?.present(vc, animated: false)
//                            }
//                        }
//                    }
//                }else{
                    if self.isComing == true{
                        isGigResponse = true
                        self.viewModel.checAddGig(price: Int(self.txtFldfee.text ?? "") ?? 0) { message in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
                            
                            vc.titleText = message
                            vc.callBack = { [weak self] isPay in
                                guard let self = self else { return }
                                    if self.imgVwUpload.image == UIImage(named: ""){
                                        self.viewModel.AddGigApi(usertype: "user",
                                                                 image: UIImageView(image: UIImage(named: "")),
                                                                 name: self.txtFldName.text ?? "",
                                                                 title: self.txtFldTitle.text ?? "",
                                                                 serviceName: txtFldServicetype.text ?? "",
                                                                 serviceDuration: txtFldTastDuration.text ?? "",
                                                                 startDate:selectedStartDate,
                                                                 place: self.txtFldLocation.text ?? "",
                                                                 lat: self.lat,
                                                                 long: self.long,
                                                                 participants: self.txtFldPaticipants.text ?? "",
                                                                 type: self.selectGigType,
                                                                 price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                                 about: self.txtVwAbout.text ?? "",
                                                                 isImageNil: true){ data in
                                            
                                                Store.AddGigImage = nil
                                                Store.AddGigDetail = nil
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
                                                vc.modalPresentationStyle = .overFullScreen
                                                vc.callBack = {[weak self] in
                                                    guard let self = self else { return }
                                                    Store.tabBarNotificationPosted = false
                                                    SceneDelegate().GigListVCRoot()
                                                }
                                                self.navigationController?.present(vc, animated: false)
                                            }
                                
                                }else{
                                    
                                    self.viewModel.AddGigApi(usertype: "user",
                                                             image: self.imgVwUpload,
                                                             name: self.txtFldName.text ?? "",
                                                             title: self.txtFldTitle.text ?? "",
                                                             serviceName: txtFldServicetype.text ?? "",
                                                             serviceDuration: txtFldTastDuration.text ?? "",
                                                             startDate:selectedStartDate,
                                                             place: self.txtFldLocation.text ?? "",
                                                             lat: self.lat, long: self.long,
                                                             participants: self.txtFldPaticipants.text ?? "",
                                                             type: self.selectGigType,
                                                             price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                             about: self.txtVwAbout.text ?? "", isImageNil: false){ data in
                                        
                                        Store.AddGigImage = nil
                                        Store.AddGigDetail = nil
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
                                        vc.modalPresentationStyle = .overFullScreen
                                        vc.callBack = {[weak self] in
                                            guard let self = self else { return }
                                            Store.tabBarNotificationPosted = false
                                            SceneDelegate().GigListVCRoot()
                                        }
                                        self.navigationController?.present(vc, animated: false)
                                    }
                                }
                            }
                            vc.modalPresentationStyle = .overFullScreen
                            self.navigationController?.present(vc, animated: false)
                        }
                    }else{
                        
                        if "\(gigFees ?? 0)" == txtFldfee.text ?? ""{
                            print("equal")
                            if self.imgVwUpload.image == UIImage(named: ""){
                                if IsUserGig{
                                    self.viewModel.UpdateGigApi(id: self.usergigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                serviceName: txtFldServicetype.text ?? "",
                                                                serviceDuration: txtFldTastDuration.text ?? "",
                                                                startDate:selectedStartDate,
                                                                place: self.txtFldLocation.text ?? "",
                                                                lat: self.lat, long: self.long,
                                                                type: selectGigType,
                                                                participants: self.txtFldPaticipants.text ?? "",
                                                                price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                                about: self.txtVwAbout.text ?? "",
                                                                isImageNil: true) { message in
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                        vc.modalPresentationStyle = .overFullScreen
                                        vc.isSelect = 10
                                        vc.message = message
                                        vc.callBack = {[weak self] in
                                            guard let self = self else { return }
                                            SceneDelegate().GigListVCRoot()
                                        }
                                        self.navigationController?.present(vc, animated: false)
                                    }
                                }else{
                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                            serviceName: txtFldServicetype.text ?? "",
                                                            serviceDuration: txtFldTastDuration.text ?? "",
                                                            startDate:selectedStartDate,
                                                            place: self.txtFldLocation.text ?? "",
                                                            lat: self.lat, long: self.long,
                                                            type: selectGigType,
                                                            participants: self.txtFldPaticipants.text ?? "",
                                                            price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                            about: self.txtVwAbout.text ?? "",
                                                            isImageNil: true) { message in
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                    vc.modalPresentationStyle = .overFullScreen
                                    vc.isSelect = 10
                                    vc.message = message
                                    vc.callBack = {[weak self] in
                                        guard let self = self else { return }
                                        SceneDelegate().GigListVCRoot()
                                    }
                                    self.navigationController?.present(vc, animated: false)
                                }
                            }
                            }else{
                                if IsUserGig{
                                    self.viewModel.UpdateGigApi(id: self.usergigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                serviceName: txtFldServicetype.text ?? "",
                                                                serviceDuration: txtFldTastDuration.text ?? "",
                                                                startDate:selectedStartDate,
                                                                place: self.txtFldLocation.text ?? "",
                                                                lat: self.lat, long: self.long,
                                                                type: selectGigType,
                                                                participants: self.txtFldPaticipants.text ?? "",
                                                                price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                                about: self.txtVwAbout.text ?? "",
                                                                isImageNil: true) { message in
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                        vc.modalPresentationStyle = .overFullScreen
                                        vc.isSelect = 10
                                        vc.message = message
                                        vc.callBack = {[weak self] in
                                            guard let self = self else { return }
                                            SceneDelegate().GigListVCRoot()
                                        }
                                        self.navigationController?.present(vc, animated: false)
                                    }
                                }else{
                                    self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: self.imgVwUpload, name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                serviceName: txtFldServicetype.text ?? "",
                                                                serviceDuration: txtFldTastDuration.text ?? "",
                                                                startDate:selectedStartDate,
                                                                place: self.txtFldLocation.text ?? "",
                                                                lat: self.lat, long: self.long,
                                                                type: selectGigType,
                                                                participants: self.txtFldPaticipants.text ?? "",
                                                                price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                        vc.modalPresentationStyle = .overFullScreen
                                        vc.isSelect = 10
                                        vc.message = message
                                        vc.callBack = {[weak self] in
                                            guard let self = self else { return }
                                            SceneDelegate().GigListVCRoot()
                                        }
                                        self.navigationController?.present(vc, animated: false)
                                    }
                                }
                            }
                        }else{
                            print("not equal")
                            self.viewModel.checUpdateGig(gigId: self.gigDetail?.id ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0) { message in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
                                if let gigFees = self.gigFees,
                                   let feeValue = Int(self.txtFldfee.text ?? ""),
                                   gigFees > feeValue {
                                    vc.isAmountLess = true
                                }else{
                                    vc.isAmountLess = false
                                }
                                vc.titleText = message
                                vc.callBack = { [weak self] isPay in
                                    guard let self = self else { return }
                                    if self.imgVwUpload.image == UIImage(named: ""){
                                        if IsUserGig{
                                            self.viewModel.UpdateGigApi(id: self.usergigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                        serviceName: txtFldServicetype.text ?? "",
                                                                        serviceDuration: txtFldTastDuration.text ?? "",
                                                                        startDate:selectedStartDate,
                                                                        place: self.txtFldLocation.text ?? "",
                                                                        lat: self.lat, long: self.long,
                                                                        type: selectGigType,
                                                                        participants: self.txtFldPaticipants.text ?? "",
                                                                        price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                                        about: self.txtVwAbout.text ?? "",
                                                                        isImageNil: true) { message in
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                                vc.modalPresentationStyle = .overFullScreen
                                                vc.isSelect = 10
                                                vc.message = message
                                                vc.callBack = {[weak self] in
                                                    guard let self = self else { return }
                                                    SceneDelegate().GigListVCRoot()
                                                }
                                                self.navigationController?.present(vc, animated: false)
                                            }
                                        }else{
                                            self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                        serviceName: txtFldServicetype.text ?? "",
                                                                        serviceDuration: txtFldTastDuration.text ?? "",
                                                                        startDate:selectedStartDate,
                                                                        place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long, type: self.selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: true) { message in
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                                vc.modalPresentationStyle = .overFullScreen
                                                vc.isSelect = 10
                                                vc.message = message
                                                vc.callBack = {[weak self] in
                                                    guard let self = self else { return }
                                                    SceneDelegate().GigListVCRoot()
                                                }
                                                self.navigationController?.present(vc, animated: false)
                                            }
                                        }
                                    }else{
                                        if IsUserGig{
                                            self.viewModel.UpdateGigApi(id: self.usergigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                        serviceName: txtFldServicetype.text ?? "",
                                                                        serviceDuration: txtFldTastDuration.text ?? "",
                                                                        startDate:selectedStartDate,
                                                                        place: self.txtFldLocation.text ?? "",
                                                                        lat: self.lat, long: self.long,
                                                                        type: selectGigType,
                                                                        participants: self.txtFldPaticipants.text ?? "",
                                                                        price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                                        about: self.txtVwAbout.text ?? "",
                                                                        isImageNil: true) { message in
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                                vc.modalPresentationStyle = .overFullScreen
                                                vc.isSelect = 10
                                                vc.message = message
                                                vc.callBack = {[weak self] in
                                                    guard let self = self else { return }
                                                    SceneDelegate().GigListVCRoot()
                                                }
                                                self.navigationController?.present(vc, animated: false)
                                            }
                                        }else{
                                            self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: self.imgVwUpload, name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                        serviceName: txtFldServicetype.text ?? "",
                                                                        serviceDuration: txtFldTastDuration.text ?? "",
                                                                        startDate:selectedStartDate,
                                                                        place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long, type: self.selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                                vc.modalPresentationStyle = .overFullScreen
                                                vc.isSelect = 10
                                                vc.message = message
                                                vc.callBack = {[weak self] in
                                                    guard let self = self else { return }
                                                    SceneDelegate().GigListVCRoot()
                                                }
                                                self.navigationController?.present(vc, animated: false)
                                            }
                                        }
                                    }
                                    vc.modalPresentationStyle = .overFullScreen
                                    self.navigationController?.present(vc, animated: false)
                                }
                            }
                        }
                    }
                }
            }
    //}
}
//MARK: - UITextViewDelegate
extension AddGigVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        lblTxtvwCount.text = "\(characterCount)/250"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
    }
}
//MARK: - UITextFieldDelegate
extension AddGigVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the text field is `txtFldTitle`
        if textField == txtFldTitle {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 40
        }
        // For other text fields, return true to allow changes
        return true
    }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == txtFldTitle{
                txtFldTitle.resignFirstResponder()
                txtFldPaticipants.becomeFirstResponder()
            }
            return true
        }
}
//MARK: - combineDateAndTime, date and time format
extension AddGigVC{
    func formatServiceDuration(for duration: Date) -> String? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: duration)
        guard let hours = components.hour, let minutes = components.minute else { return nil }
        // Ensure duration is within the valid range
        if hours == 0 && minutes < 1 {
            return nil // Minimum "00:01 hours"
        } else if hours > 24 || (hours == 24 && minutes > 0) {
            return nil // Maximum "24:00 hours"
        }
        
        // Format the duration
        return String(format: "%02d:%02d hours", hours, minutes)
    }
    func formatDateAndTime(from iso8601String: String) -> (formattedDate: String?, formattedTime: String?) {
        // Define the input and output formats
        let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateOutputFormat = "dd-MM-yyyy"
        let timeOutputFormat = "hh:mm a"
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC timezone
        dateFormatter.dateFormat = inputDateFormat
        
        // Parse the ISO 8601 string into a Date object
        guard let date = dateFormatter.date(from: iso8601String) else {
            return (nil, nil) // Return nil if parsing fails
        }
        
        // Format the date into the desired formats
        dateFormatter.dateFormat = dateOutputFormat
        let formattedDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = timeOutputFormat
        let formattedTime = dateFormatter.string(from: date)
        
        return (formattedDate, formattedTime)
    }

    func combineDateAndTime(dateString: String, timeString: String) -> String? {
        // Define the input formats for date and time
        let dateInputFormat = "dd-MM-yyyy"
        let timeInputFormat = "hh:mm a"
        let outputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        // Create a date formatter for the date part
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Parse the date
        dateFormatter.dateFormat = dateInputFormat
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        // Parse the time
        dateFormatter.dateFormat = timeInputFormat
        guard let time = dateFormatter.date(from: timeString) else { return nil }
        
        // Combine date and time
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // Create the combined date
        guard let combinedDate = calendar.date(from: dateComponents) else { return nil }
        
        // Format the combined date into the output format
        dateFormatter.dateFormat = outputDateFormat
        let iso8601String = dateFormatter.string(from: combinedDate)
        return iso8601String
    }
}

//MARK: - Handle textfiled datepicker
extension AddGigVC{
    @objc func startTimeDonePressed() {
        if let datePicker = txtFldSelectTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let currentDate = dateFormatter.string(from: Date())
            let selectedStartDateText = txtFldSelectDate.text ?? ""
            if selectedStartDateText == currentDate {
                datePicker.minimumDate = Date()
            } else {
                datePicker.minimumDate = nil
            }
            updateTextField(txtFldSelectTime, datePicker: datePicker)
        }
        txtFldSelectTime.resignFirstResponder()
    }

    @objc func startDateDonePressed() {
        if let datePicker = txtFldSelectDate.inputView as? UIDatePicker {
            updateTextField(txtFldSelectDate, datePicker: datePicker)
        }
        txtFldSelectDate.resignFirstResponder()
    }
    @objc func timePickerDonePressed() {
        if let datePicker = txtFldTastDuration.inputView as? UIDatePicker {
            // Format and validate the service duration
            if let formattedDuration = formatServiceDuration(for: datePicker.date) {
                txtFldTastDuration.text = formattedDuration
            }
        }
        txtFldTastDuration.resignFirstResponder()
    }
    func setupDatePicker(for textField: UITextField, mode: UIDatePicker.Mode, selector: Selector) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: selector)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.tag = textField.tag
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        switch sender.tag {
        case 1:
            updateTextField(txtFldSelectDate, datePicker: sender)
        case 2:
            updateTextField(txtFldSelectTime, datePicker: sender)
        case 3:
            updateTextField(txtFldTastDuration, datePicker: sender)
        default:
            break
        }
    }

    func updateTextField(_ textField: UITextField, datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        if textField == txtFldSelectDate {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            textField.text = dateFormatter.string(from: datePicker.date)
        } else if textField == txtFldSelectTime {
            dateFormatter.dateFormat = "hh:mm a"
            textField.text = dateFormatter.string(from: datePicker.date)
        } else if textField == txtFldTastDuration {
            // Use 24-hour format to capture the duration in hours and minutes
                   dateFormatter.dateFormat = "HH:mm"
                   let durationString = dateFormatter.string(from: datePicker.date)
                   // Ensure the format is "<HH:MM> hours"
                   textField.text = "\(durationString) hours"
            
        }
    }

}
