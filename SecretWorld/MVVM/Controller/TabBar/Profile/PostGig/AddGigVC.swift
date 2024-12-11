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
    @IBOutlet weak var imgVwFixed: UIImageView!
    @IBOutlet weak var imgVwHourly: UIImageView!
    @IBOutlet weak var imgVwCash: UIImageView!
    @IBOutlet weak var imgVwOther: UIImageView!
    
    //MARK: - VARIABLES
    var selectGigType = ""
    var userGigDetail:GetUserGigData?
    var isComing  = false
    var isUploading = false
    var viewModel  = AddGigVM()
    var lat = Double()
    var long = Double()
   // var gigType = "" //gigType = "worldwide" gigType = "inMyLocation"
    var gigDetail:GetGigDetailData?
    var walletViewModel = PaymentVM()
    var walletAmount = 0
    var gigFees:Int?
    var gigLocationType = 2
    var selectedStartDate = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        uiSet()
    }
    @objc func handleSwipe() {
        Store.AddGigImage = nil
        Store.AddGigDetail = nil
        if isComing{
            SceneDelegate().tabBarHomeRoot()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
            }
    func uiSet(){
        txtFldTitle.delegate = self
        if isComing == true{
            setupDatePicker(for:txtFldSelectDate, mode: .date, selector: #selector(startDateDonePressed))
            setupDatePicker(for: txtFldSelectTime, mode: .time, selector: #selector(startTimeDonePressed))
            setupDatePicker(for: txtFldTastDuration, mode: .countDownTimer, selector: #selector(timePickerDonePressed))
//            NotificationCenter.default.addObserver(self, selector: #selector(self.GigCreatedSuccessfullyAlert(notification:)), name: Notification.Name("gigCreated"), object: nil)
            getCommisionApi()
            lblTitleScreen.text = "Add Gig"
            if Store.GigImg == UIImage(named: "") || Store.GigImg == nil || Store.AddGigImage == UIImage(named: "") || Store.AddGigImage == nil{
                self.isUploading = false
                self.viewOfAdddPhotoLbls.isHidden = false
                self.btnDelete.isHidden = true
                lblPlus.isHidden = false
                lblUploadPhoto.isHidden = false
            }else{
                imgVwUpload.image = Store.AddGigImage
                self.isUploading = true
                self.viewOfAdddPhotoLbls.isHidden = true
                self.btnDelete.isHidden = true
                lblPlus.isHidden = true
                lblUploadPhoto.isHidden = true
            }
            txtFldLocation.text = Store.AddGigDetail?["location"] as? String ?? ""
            txtFldTitle.text = Store.AddGigDetail?["title"] as? String ?? ""
            lat = Store.AddGigDetail?["lat"] as? Double ?? 0
            long = Store.AddGigDetail?["long"] as? Double ?? 0
            txtFldPaticipants.text = Store.AddGigDetail?["participants"] as? String ?? ""
            txtFldGigType.text = Store.AddGigDetail?["type"] as? String ?? ""
            if Store.AddGigDetail?["type"] as? String ?? "" == "worldwide"{
                txtFldGigType.text = "Worldwide"
                selectGigType = "worldwide"
            }else if Store.AddGigDetail?["type"] as? String ?? "" == "inMyLocation"{
                txtFldGigType.text = "In My Location"
                selectGigType = "inMyLocation"
            }else{
                txtFldGigType.text = ""
                selectGigType = ""
            }
            txtFldfee.text = Store.AddGigDetail?["fees"] as? String ?? ""
            txtVwAbout.text = Store.AddGigDetail?["about"] as? String ?? ""
            if Store.role == "b_user"{
                txtFldName.text =  Store.BusinessUserDetail?["userName"] as? String ?? ""
            }else{
                txtFldName.text = Store.UserDetail?["userName"] as? String ?? ""
            }
            btnCreateUpdate.setTitle("Create", for: .normal)
        }else{
            
            Store.AddGigImage = nil
            Store.AddGigDetail = nil
            lblTitleScreen.text = "Edit Gig"
            btnCreateUpdate.setTitle("Update", for: .normal)
            if gigDetail?.image == "" ||  gigDetail?.image == nil{
                isUploading = false
                btnDelete.isHidden = true
                imgVwUpload.image = UIImage(named: "")
                lblPlus.isHidden = false
                lblUploadPhoto.isHidden = false
            }else{
                isUploading = true
                btnDelete.isHidden = true
                lblPlus.isHidden = true
                lblUploadPhoto.isHidden = true
                imgVwUpload.imageLoad(imageUrl: gigDetail?.image ?? "")
                Store.GigImg = imgVwUpload.image
            }
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
            updateTextField(txtFldTastDuration, datePicker: datePicker)
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
            
            // Split the duration into hours and minutes
            let timeComponents = durationString.split(separator: ":")
            if timeComponents.count == 2 {
                let hours = Int(timeComponents[0]) ?? 0
                let minutes = Int(timeComponents[1]) ?? 0
                
                // Create the string with hours and minutes
                var durationText = ""
                
                if hours > 0 {
                    durationText += "\(hours) hour" + (hours > 1 ? "s" : "") // Adding plural if needed
                }
                
                if minutes > 0 {
                    if !durationText.isEmpty {
                        durationText += " " // Adding "and" between hours and minutes
                    }
                    durationText += "\(minutes) min" // Singular "min"
                }
                
                textField.text = durationText
            }
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
                    self.lblUploadPhoto.isHidden = false
                    self.lblPlus.isHidden = false
                    self.imgVwUpload.image = UIImage(named: "")
                    self.imgVwUploadBtnGif.isHidden = false
                    self.imgVwTick.isHidden = true
                    //self.imgVwUploadBtnGif.image = UIImage(named: "uploading-to-cloud-VWQJD1A1A0")
                   // self.imgVwTick.image = UIImage(named: "")
                    self.isUploading = false
                    self.viewOfAdddPhotoLbls.isHidden = false
                    self.btnDelete.isHidden = true
                }else{
                    self.imgVwUploadBtnGif.isHidden = true
                    self.imgVwTick.isHidden = false
                    //self.imgVwTick.image = UIImage(named: "icon_donetick")
                    self.lblUploadPhoto.isHidden = true
                    self.lblPlus.isHidden = true
                    self.imgVwUpload.image = image
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
            ImagePicker().pickImage(self) { image in
                self.imgVwUploadBtnGif.isHidden = true
                self.imgVwTick.isHidden = false
//                self.imgVwUploadBtnGif.image = UIImage(named: "")
//                self.imgVwTick.image = UIImage(named: "icon_donetick")
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
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func actionFixed(_ sender: UIButton) {
        imgVwFixed.image = UIImage(named: "selectedGender")
        imgVwHourly.image = UIImage(named: "unselect 1")
    }
    @IBAction func actionHourly(_ sender: UIButton) {
        imgVwFixed.image = UIImage(named: "unselect 1")
        imgVwHourly.image = UIImage(named: "selectedGender")
    }
    @IBAction func actionCash(_ sender: UIButton) {
        imgVwCash.image = UIImage(named: "selectedGender")
        imgVwOther.image = UIImage(named: "unselect 1")
    }
    
    @IBAction func actionOther(_ sender: UIButton) {
        imgVwCash.image = UIImage(named: "unselect 1")
        imgVwOther.image = UIImage(named: "selectedGender")
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
//    @objc func GigCreatedSuccessfullyAlert(notification:Notification){
//        successAlert()
//    }
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
    func convertDateFormat(selectedDate: String) -> String? {
        // Define the input date format
        let inputDateFormat = "dd-MM-yyyy"
        // Define the output date format
        let outputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC timezone
        
        // Convert from input string to Date
        dateFormatter.dateFormat = inputDateFormat
        guard let date = dateFormatter.date(from: selectedDate) else {
            return nil
        }
        
        // Convert from Date to output string
        dateFormatter.dateFormat = outputDateFormat
        let iso8601String = dateFormatter.string(from: date)
        
        return iso8601String
    }

    @IBAction func actionCreate(_ sender: UIButton) {
        print("Current Gig Type: \(txtFldGigType.text ?? "")")
        print("select Gig Type: \(selectGigType)")
        
        print("selectedStartDate: \(txtFldSelectDate.text ?? "")")
        if let convertedDate = convertDateFormat(selectedDate: txtFldSelectDate.text ?? "") {
            print("Converted Date: \(convertedDate)")
            selectedStartDate = convertedDate
            
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
        }
//        else if txtVwAbout.text == ""{
//            showSwiftyAlert("", "Description of the gig is required", false)
//        }
        else{
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
                if Store.role == "b_user"{
                    if self.isComing == true{
                        isGigResponse = true
                        self.viewModel.checAddGig(price: Int(self.txtFldfee.text ?? "") ?? 0) { message in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
                            vc.titleText = message
                            vc.callBack = { [weak self] isPay in
                                             guard let self = self else { return }
                                if self.imgVwUpload.image == UIImage(named: ""){
                                    self.viewModel.AddGigApi(usertype: "business_user",
                                                             image: UIImageView(image: UIImage(named: "")),
                                                             name: self.txtFldName.text ?? "",
                                                             title: self.txtFldTitle.text ?? "",
                                                             serviceName: txtFldServicetype.text ?? "",
                                                             serviceDuration: txtFldTastDuration.text ?? "",
                                                             startDate:txtFldSelectDate.text ?? "",
                                                             place: self.txtFldLocation.text ?? "",
                                                             lat: self.lat,
                                                             long: self.long,
                                                             participants: self.txtFldPaticipants.text ?? "",
                                                             type: self.selectGigType,
                                                             price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                             about: self.txtVwAbout.text ?? "",
                                                             isImageNil: true) { data in
                                        Store.AddGigImage = nil
                                        Store.AddGigDetail = nil
                                        self.successAlert()
                                    }
                                }else{
                                    self.viewModel.AddGigApi(usertype: "business_user", image: self.imgVwUpload,
                                                             name: self.txtFldName.text ?? "",
                                                             title: self.txtFldTitle.text ?? "",
                                                             serviceName: txtFldServicetype.text ?? "",
                                                             serviceDuration: txtFldTastDuration.text ?? "",
                                                             startDate:txtFldSelectDate.text ?? "",
                                                             place: self.txtFldLocation.text ?? "",
                                                             lat: self.lat,
                                                             long: self.long,
                                                             participants: self.txtFldPaticipants.text ?? "",
                                                             type: self.selectGigType,
                                                             price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                             about: self.txtVwAbout.text ?? "",
                                                             isImageNil: false) { data in
                                        Store.AddGigImage = nil
                                        Store.AddGigDetail = nil
                                        self.successAlert()
//                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
//                                        vc.modalPresentationStyle = .overFullScreen
//                                        vc.callBack = {
//                                            Store.tabBarNotificationPosted = false
//                                            SceneDelegate().GigListVCRoot()
//                                        }
//                                        self.navigationController?.present(vc, animated: false)
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
                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
                                                            image: UIImageView(image: UIImage(named: "")),
                                                            name: self.txtFldName.text ?? "",
                                                            title: self.txtFldTitle.text ?? "",
                                                            serviceName: txtFldServicetype.text ?? "",
                                                            serviceDuration: txtFldTastDuration.text ?? "",
                                                            startDate:txtFldSelectDate.text ?? "",
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
                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
                                                            image: self.imgVwUpload,
                                                            name: self.txtFldName.text ?? "",
                                                            title: self.txtFldTitle.text ?? "",
                                                            serviceName: txtFldServicetype.text ?? "",
                                                            serviceDuration: txtFldTastDuration.text ?? "",
                                                            startDate:txtFldSelectDate.text ?? "",
                                                            place: self.txtFldLocation.text ?? "",
                                                            lat: self.lat, long: self.long,
                                                            type: selectGigType,
                                                            participants: self.txtFldPaticipants.text ?? "",
                                                            price: Int(self.txtFldfee.text ?? "") ?? 0,
                                                            about: self.txtVwAbout.text ?? "",
                                                            isImageNil: false) { message in
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
                                        self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", 
                                                                    image:UIImageView(image: UIImage(named: "")),
                                                                    name: self.txtFldName.text ?? "",
                                                                    title: self.txtFldTitle.text ?? "",
                                                                    serviceName: txtFldServicetype.text ?? "",
                                                                    serviceDuration: txtFldTastDuration.text ?? "",
                                                                    startDate:txtFldSelectDate.text ?? "",
                                                                    place: self.txtFldLocation.text ?? "",
                                                                    lat: self.lat, long: self.long,
                                                                    type: self.selectGigType,
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
                                        self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "",
                                                                    image: self.imgVwUpload,
                                                                    name: self.txtFldName.text ?? "",
                                                                    title: self.txtFldTitle.text ?? "",
                                                                    serviceName: txtFldServicetype.text ?? "",
                                                                    serviceDuration: txtFldTastDuration.text ?? "",
                                                                    startDate:txtFldSelectDate.text ?? "",
                                                                    place: self.txtFldLocation.text ?? "",
                                                                    lat: self.lat, long: self.long,
                                                                    type: self.selectGigType,
                                                                    participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
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
                }else{
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
                                self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                            serviceName: txtFldServicetype.text ?? "",
                                                            serviceDuration: txtFldTastDuration.text ?? "",
                                                            startDate:txtFldSelectDate.text ?? "",place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long,
                                                            type: selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: true) { message in
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
                                                            startDate:txtFldSelectDate.text ?? "",place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long, type: selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
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
                                        self.viewModel.UpdateGigApi(id: self.gigDetail?.id ?? "", image: UIImageView(image: UIImage(named: "")), name: self.txtFldName.text ?? "", title: self.txtFldTitle.text ?? "",
                                                                    serviceName: txtFldServicetype.text ?? "",
                                                                    serviceDuration: txtFldTastDuration.text ?? "",
                                                                    startDate:txtFldSelectDate.text ?? "",place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long, type: self.selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: true) { message in
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
                                                                    startDate:txtFldSelectDate.text ?? "",place: self.txtFldLocation.text ?? "", lat: self.lat, long: self.long, type: self.selectGigType, participants: self.txtFldPaticipants.text ?? "", price: Int(self.txtFldfee.text ?? "") ?? 0, about: self.txtVwAbout.text ?? "", isImageNil: false) { message in
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
