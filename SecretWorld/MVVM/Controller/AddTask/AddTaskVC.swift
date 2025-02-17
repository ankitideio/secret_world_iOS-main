//
//  AddTaskVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 22/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import AlignedCollectionViewFlowLayout

class AddTaskVC: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var heightToolsVw: NSLayoutConstraint!
    @IBOutlet weak var heightSkillVw: NSLayoutConstraint!
    @IBOutlet weak var btnChooseCategory: UIButton!
    @IBOutlet weak var vwAddCategory: UIView!
    @IBOutlet weak var txtFldAddCategory: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwCollVwTools: UIView!
    @IBOutlet weak var vwAddTools: UIView!
    @IBOutlet weak var vwCollVwSkill: UIView!
    @IBOutlet weak var vwAddSkill: UIView!
    @IBOutlet weak var txtFldAddTools: UITextField!
    @IBOutlet weak var collVwTools: UICollectionView!
    @IBOutlet weak var collVwSkills: UICollectionView!
    @IBOutlet weak var txtFldOwnSkill: UITextField!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var btnTick: UIButton!
    @IBOutlet weak var txtFldTimeDuration: UITextField!
    @IBOutlet weak var txtFldTime: UITextField!
    @IBOutlet weak var txtFldDate: UITextField!
    @IBOutlet weak var txtFldUrgency: UITextField!
    @IBOutlet weak var txtFldAmount: UITextField!
    @IBOutlet weak var txtVwSafetyTips: IQTextView!
    @IBOutlet weak var txtVwInstruction: IQTextView!
    @IBOutlet weak var txtFldNoOfPerson: UITextField!
    @IBOutlet weak var lblTools: UILabel!
    @IBOutlet weak var dropDownTools: UIImageView!
    @IBOutlet weak var lblSkills: UILabel!
    @IBOutlet weak var dropDownSkills: UIImageView!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var dropDownPaymentMethod: UIImageView!
    @IBOutlet weak var dropDownPaymentTerm: UIImageView!
    @IBOutlet weak var lblPaymentTerms: UILabel!
    @IBOutlet weak var txtFldMap: UITextField!
    @IBOutlet weak var txtVwAddress: IQTextView!
    @IBOutlet weak var btnRemote: UIButton!
    @IBOutlet weak var btnOnSite: UIButton!
    @IBOutlet weak var imgVwTask: UIImageView!
    @IBOutlet weak var lblChooseExperience: UILabel!
    @IBOutlet weak var dropDownChooseExperience: UIImageView!
    @IBOutlet weak var dropDownCategory: UIImageView!
    @IBOutlet weak var lblChooseCategory: UILabel!
    @IBOutlet weak var txtVwDescription: IQTextView!
    @IBOutlet weak var txtFldTitle: UITextField!
    
    //MARK: - VARIABLES
    var selectGigType = "inMyLocation"
    var userGigDetail:GetUserGigData?
    var isComing  = true
    var isUploading = false
    var viewModel  = AddGigVM()
    var lat = Double()
    var long = Double()
    var bsuinessGigDetail:GetGigDetailData?
    var walletViewModel = PaymentVM()
    var walletAmount = 0
    var gigFees:Int?
    var selectedStartDate = ""
    var IsUserGig = false
    var serviceName = ""
    var serviceDuration = ""
    var experience = ""
    var paymentTerm = ""
    var paymentMethod = ""
    var callBack:(()->())?
    var arrGetCategories = [Skills]()
    var arrGetSkill = [Skills]()
    var offset = 1
    var limit = 20
    var isWorldwide = false
    var viewModelAuth = AuthVM()
    var paymentTerms = 0
    var paymentMethods = 0
    var isCancellation = 0
    var startDate:String?
    var startTime:String?
    var arrSkills = [Skills]()
    var arrTools = [String]()
    var categoryId:String = ""
    var arrSkillId = [String]()
    var gigId = ""
    var isDetailData = false
    var newPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

 
        uiSet()
    }
  
func uiSet(){
    print(Store.authKey)
    updateButtonStates(selectedButton: btnOnSite, deselectedButton: btnRemote)
    DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
        self.getSkillsApi(type: "Specialization")
        self.getCategoryApi(type: "Category")
    }
    let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
    collVwTools.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
    collVwSkills.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
    let alignedFlowLayoutCollVwDietry = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
    collVwTools.collectionViewLayout = alignedFlowLayoutCollVwDietry
    
    let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
    collVwSkills.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
    
    
    if let flowLayout = collVwTools.collectionViewLayout as? UICollectionViewFlowLayout {
        flowLayout.estimatedItemSize = CGSize(width: 0, height: 40)
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        
    }
    
    if let flowLayout1 = collVwSkills.collectionViewLayout as? UICollectionViewFlowLayout {
        flowLayout1.estimatedItemSize = CGSize(width: 0, height: 40)
        flowLayout1.itemSize = UICollectionViewFlowLayout.automaticSize
    }
    txtFldTitle.delegate = self
    setupDatePicker(for:txtFldDate, mode: .date, selector: #selector(startDateDonePressed))
    setupDatePicker(for: txtFldTime, mode: .time, selector: #selector(startTimeDonePressed))
    setupDatePicker(for: txtFldTimeDuration, mode: .countDownTimer, selector: #selector(timePickerDonePressed))
    if isComing == true{
//        getCommisionApi()
       
        lblTitle.text = "Add Task"
        btnCreate.setTitle("Create", for: .normal)
    }else{
        Store.AddGigImage = nil
        Store.AddGigDetail = nil
        lblTitle.text = "Edit Task"
        btnCreate.setTitle("Update", for: .normal)
        if self.isDetailData == false{
             newPrice = "\(userGigDetail?.gig?.price ?? 0)"
             serviceName = userGigDetail?.gig?.title ?? ""
             serviceDuration = userGigDetail?.gig?.serviceDuration ?? ""
             experience = userGigDetail?.gig?.experience ?? ""
             paymentTerm = "\(userGigDetail?.gig?.paymentTerms ?? 0)"
             paymentMethod = "\(userGigDetail?.gig?.paymentMethod ?? 0)"
            categoryId = userGigDetail?.gig?.category?.id ?? ""
            lat = userGigDetail?.gig?.lat ?? 0
            long = userGigDetail?.gig?.long ?? 0
            isCancellation = userGigDetail?.gig?.isCancellation ?? 0
            self.txtFldTitle.text = userGigDetail?.gig?.title ?? ""
            self.txtVwDescription.text = userGigDetail?.gig?.about ?? ""
            
            self.lblChooseCategory.text = userGigDetail?.gig?.category?.name ?? ""
            self.lblChooseCategory.textColor = .black
          
            self.lblChooseExperience.text = userGigDetail?.gig?.experience ?? ""
            self.lblChooseExperience.textColor = .black
            
            self.txtVwAddress.text = userGigDetail?.gig?.address ?? ""
            self.txtFldMap.text = userGigDetail?.gig?.place ?? ""
            self.txtFldAmount.text = "\(userGigDetail?.gig?.price ?? 0)"
//            self.txtFldDressCode.text = userGigDetail?.gig?.dressCode ?? ""
            self.txtVwSafetyTips.text = userGigDetail?.gig?.safetyTips ?? ""
            self.txtVwInstruction.text = userGigDetail?.gig?.description ?? ""
            self.txtFldTimeDuration.text = userGigDetail?.gig?.serviceDuration ?? ""
            self.imgVwTask.imageLoad(imageUrl: userGigDetail?.gig?.image ?? "")
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: userGigDetail?.gig?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd-MM-yyyy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.txtFldDate.text = formattedDate
            }
            if let time = isoDateFormatter.date(from: userGigDetail?.gig?.startTime ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "hh:mm a"
                let formattedDate = displayDateFormatter.string(from: time)
                self.txtFldTime.text = formattedDate
            }
            if userGigDetail?.gig?.paymentMethod == 0{
                lblPaymentMethod.text = "Online"
                lblPaymentMethod.textColor = .black
            }else{
                lblPaymentMethod.text = "Cash"
                lblPaymentMethod.textColor = .black
            }
            if userGigDetail?.gig?.paymentTerms == 0{
              
                lblPaymentTerms.text = "Fixed"
                lblPaymentTerms.textColor = .black
            }else{
             
                lblPaymentTerms.text = "Hourly"
                lblPaymentTerms.textColor = .black
            }
            if userGigDetail?.gig?.isCancellation == 1{
                btnTick.isSelected = true
            }else{
                btnTick.isSelected = false
            }
            txtFldNoOfPerson.text = userGigDetail?.gig?.totalParticipants ?? ""
            for i in arrSkills{
                self.arrSkillId.append(i.id)
            }
            for i in userGigDetail?.gig?.skills ?? []{
                arrGetSkill.append(Skills(id: i.id ?? "", name: i.name ?? ""))
            }
            if arrSkills.count>0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.heightSkillVw.constant = (self?.collVwSkills.contentSize.height ?? 0) + 10
                    self?.vwCollVwSkill.isHidden = false
                    self?.vwAddSkill.isHidden = true
                }
           }else{
               self.vwAddSkill.isHidden = true
            self.heightSkillVw.constant = 0
            self.vwCollVwSkill.isHidden = false
            }
          
            self.collVwSkills.reloadData()
            if arrTools.count>0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.heightToolsVw.constant = (self?.collVwTools.contentSize.height ?? 0) + 10
                    self?.vwCollVwTools.isHidden = false
                 
                }
           }else{
              
            self.heightSkillVw.constant = 0
            self.vwCollVwTools.isHidden = true
            }
            self.collVwTools.reloadData()
            if userGigDetail?.gig?.type == "worldwide"{
                selectGigType = "worldwide"
                btnRemote.backgroundColor = .app
                btnRemote.setTitleColor(.white, for: .normal)
                btnOnSite.backgroundColor = UIColor(hex: "#E7F3E6")
                btnOnSite.setTitleColor(.app, for: .normal)
            }else{
                selectGigType = "inMyLocation"
                btnOnSite.backgroundColor = .app
                btnOnSite.setTitleColor(.white, for: .normal)
                btnRemote.backgroundColor = UIColor(hex: "#E7F3E6")
                btnRemote.setTitleColor(.app, for: .normal)
            }
        }else{
            lat = bsuinessGigDetail?.lat ?? 0
            long = bsuinessGigDetail?.long ?? 0
            newPrice = "\(bsuinessGigDetail?.price ?? 0)"
            isCancellation = bsuinessGigDetail?.isCancellation ?? 0
             serviceName = bsuinessGigDetail?.title ?? ""
             serviceDuration = bsuinessGigDetail?.serviceDuration ?? ""
             experience = bsuinessGigDetail?.experience ?? ""
             paymentTerm = "\(bsuinessGigDetail?.paymentTerms ?? 0)"
             paymentMethod = "\(bsuinessGigDetail?.paymentMethod ?? 0)"
            categoryId = bsuinessGigDetail?.category?.id ?? ""
            self.txtFldTitle.text = bsuinessGigDetail?.title ?? ""
            self.txtVwDescription.text = bsuinessGigDetail?.about ?? ""
            self.lblChooseCategory.text = bsuinessGigDetail?.category?.name ?? ""
            self.lblChooseCategory.textColor = .black
          
            self.lblChooseExperience.text = bsuinessGigDetail?.experience ?? ""
            self.lblChooseExperience.textColor = .black
           
            self.txtVwAddress.text = bsuinessGigDetail?.address ?? ""
            self.txtFldMap.text = bsuinessGigDetail?.place ?? ""
            self.txtFldAmount.text = "\(bsuinessGigDetail?.price ?? 0)"
//            self.txtFldDressCode.text = bsuinessGigDetail?.dressCode ?? ""
            self.txtVwSafetyTips.text = bsuinessGigDetail?.safetyTips ?? ""
            self.txtVwInstruction.text = bsuinessGigDetail?.description ?? ""
            self.txtFldTimeDuration.text = bsuinessGigDetail?.serviceDuration ?? ""
            self.imgVwTask.imageLoad(imageUrl: bsuinessGigDetail?.image ?? "")
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: bsuinessGigDetail?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd-MM-yyyy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.txtFldDate.text = formattedDate
            }
            if let time = isoDateFormatter.date(from: bsuinessGigDetail?.startTime ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "hh:mm a"
                let formattedDate = displayDateFormatter.string(from: time)
                self.txtFldTime.text = formattedDate
            }
            if bsuinessGigDetail?.isCancellation == 1{
                btnTick.isSelected = true
            }else{
                btnTick.isSelected = false
            }
       
            if bsuinessGigDetail?.paymentMethod == 0{
                lblPaymentMethod.text = "Online"
                lblPaymentMethod.textColor = .black
            }else{
                lblPaymentMethod.text = "Cash"
                lblPaymentMethod.textColor = .black
            }
            if bsuinessGigDetail?.paymentTerms == 0{
              
                lblPaymentTerms.text = "Fixed"
                lblPaymentTerms.textColor = .black
            }else{
             
                lblPaymentTerms.text = "Hourly"
                lblPaymentTerms.textColor = .black
            }
            txtFldNoOfPerson.text = bsuinessGigDetail?.totalParticipants ?? ""
          
            for i in arrSkills{
                self.arrSkillId.append(i.id)
            }
            for i in userGigDetail?.gig?.skills ?? []{
                arrGetSkill.append(Skills(id: i.id ?? "", name: i.name ?? ""))
            }
            if arrSkills.count>0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.heightSkillVw.constant = (self?.collVwSkills.contentSize.height ?? 0) + 10
                    self?.vwCollVwSkill.isHidden = false
                    self?.vwAddSkill.isHidden = true
                }
           }else{
               self.vwAddSkill.isHidden = true
            self.heightSkillVw.constant = 0
            self.vwCollVwSkill.isHidden = false
            }
          
            self.collVwSkills.reloadData()
            if arrTools.count>0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.heightToolsVw.constant = (self?.collVwTools.contentSize.height ?? 0) + 10
                    self?.vwCollVwTools.isHidden = false
                 
                }
           }else{
              
            self.heightSkillVw.constant = 0
            self.vwCollVwTools.isHidden = true
            }
            self.collVwTools.reloadData()
            if bsuinessGigDetail?.type == "worldwide"{
                selectGigType = "worldwide"
                btnRemote.backgroundColor = .app
                btnRemote.setTitleColor(.white, for: .normal)
                btnOnSite.backgroundColor = UIColor(hex: "#E7F3E6")
                btnOnSite.setTitleColor(.app, for: .normal)
            }else{
                selectGigType = "inMyLocation"
                btnOnSite.backgroundColor = .app
                btnOnSite.setTitleColor(.white, for: .normal)
                btnRemote.backgroundColor = UIColor(hex: "#E7F3E6")
                btnRemote.setTitleColor(.app, for: .normal)
            }
            if bsuinessGigDetail?.isCancellation == 1{
               
            }
        }
      
    }
}
@objc func handleSwipe() {
    Store.AddGigImage = nil
    Store.AddGigDetail = nil
    if isComing{
        SceneDelegate().userRoot()
        callBack?()
    }else{
        self.navigationController?.popViewController(animated: true)
        callBack?()
    }

    }

//func getCommisionApi(){
//    walletViewModel.GetComissionApi{ data in
//        Store.commisionAmount = data?.result?.commission
//    }
//}

    private func updateButtonStates(selectedButton: UIButton, deselectedButton: UIButton) {
        selectedButton.backgroundColor = .app
        selectedButton.setTitleColor(.white, for: .normal)
        deselectedButton.backgroundColor = UIColor.white
        deselectedButton.borderCol = UIColor.app
        deselectedButton.borderWid = 1
        deselectedButton.setTitleColor(.app, for: .normal)
    }
    func combineDateAndTime(dateString: String, timeString: String) -> String? {
        // Define the input formats for date and time
        let dateInputFormat = "dd-MM-yyyy"
        let timeInputFormat = "hh:mm a"
        let outputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        // Create a date formatter for the date part
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
   
        
        // Parse the date
        dateFormatter.dateFormat = dateInputFormat
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        // Parse the time
        dateFormatter.dateFormat = timeInputFormat
        guard let time = dateFormatter.date(from: timeString) else { return nil }
        
        // Combine date and time using a UTC calendar
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
      
        
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
    
    func onFormatChanger(startDateTime: String) -> String? {
        // Define the input date format
        let inputFormat = DateFormatter()
        inputFormat.dateFormat = "dd-MM-yyyy hh:mm a"
        inputFormat.timeZone = TimeZone.current

        // Parse the input date string
        guard let date = inputFormat.date(from: startDateTime) else {
            return nil // Return nil if the input string cannot be parsed
        }

        // Define the output date format
        let outputFormat = DateFormatter()
        outputFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        outputFormat.timeZone = TimeZone(abbreviation: "UTC")

        // Format and return the converted date string
        return outputFormat.string(from: date)
    }
    
    func addUpdateGigApi(){
        guard let selectedDate = txtFldDate.text,
              let selectedTime = txtFldTime.text else {
            print("Date or time is missing.")
            return
        }
        
        if let combinedDate = combineDateAndTime(dateString: selectedDate, timeString: selectedTime) {
            print("Combined ISO 8601 Date: \(combinedDate)")
            startDate = combinedDate
        }
        if let combinedTime = combineDateAndTime(dateString: selectedDate, timeString: selectedTime) {
            print("Combined ISO 8601 Date: \(combinedTime)")
            startTime = combinedTime
        }
        let dateFormatted = onFormatChanger(startDateTime: "\(txtFldDate.text ?? "") \(txtFldTime.text ?? "")")

        if isComing == true{
            
            viewModel.AddNewGigApi(usertype: Store.role ?? "",
                                   image: imgVwTask,
                                   name: Store.UserDetail?["userName"] as? String ?? "",
                                   type: selectGigType,
                                   title: txtFldTitle.text ?? "",
                                   serviceName: "Haircut",
                                   serviceDuration: txtFldTimeDuration.text ?? "",
                                   startDate: dateFormatted ?? "",
                                   place:txtFldMap.text ?? "" ,
                                   lat: lat,
                                   long: long,
                                   participants: txtFldNoOfPerson.text ?? "",
                                   about: txtVwDescription.text ?? "",
                                   price: Int(txtFldAmount.text ?? "") ?? 0,
                                   gigId: gigId,
                                   experience: lblChooseExperience.text ?? "",
                                   address: txtVwAddress.text ?? "",
                                   paymentTerms: paymentTerms,
                                   paymentMethod: paymentMethods,
                                   category:categoryId,
                                   skills: arrSkillId,
                                   tools: arrTools,
                                   dressCode: "",
                                   personNeeded: Int(txtFldNoOfPerson.text ?? "") ?? 0,
                                   description: txtVwInstruction.text ?? "",
                                   safetyTips: txtVwSafetyTips.text ?? "",
                                   startTime: dateFormatted ?? "",
                                   isCancellation: isCancellation,
                                   isImageNil: false) { data in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    SceneDelegate().GigListVCRoot()

                }
                self.navigationController?.present(vc, animated: false)
                
            }
        }else{
            if txtFldAmount.text == newPrice{
                
            }else{
                
            }
            viewModel.UpdateNewGigApi(id:gigId, usertype: Store.role ?? "",
                                      image: imgVwTask,
                                   name: Store.UserDetail?["userName"] as? String ?? "",
                                   type: selectGigType,
                                   title: txtFldTitle.text ?? "",
                                   serviceName: "Haircut",
                                   serviceDuration: txtFldTimeDuration.text ?? "",
                                   startDate: dateFormatted ?? "",
                                   place:txtFldMap.text ?? "" ,
                                   lat: lat,
                                   long: long,
                                    participants: txtFldNoOfPerson.text ?? "",
                                   about: txtVwDescription.text ?? "",
                                   price: Int(txtFldAmount.text ?? "") ?? 0,
                                   gigId: gigId,
                                   experience: lblChooseExperience.text ?? "",
                                   address: txtVwAddress.text ?? "",
                                   paymentTerms: paymentTerms,
                                   paymentMethod: paymentMethods,
                                   category:categoryId,
                                   skills: arrSkillId,
                                   tools: arrTools,
                                   dressCode: "",
                                   personNeeded: Int(txtFldNoOfPerson.text ?? "") ?? 0,
                                      description: txtVwInstruction.text ?? "",
                                   safetyTips: txtVwSafetyTips.text ?? "",
                                   startTime: dateFormatted ?? "",
                                   isCancellation: isCancellation,
                                   isImageNil: false) { data in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    SceneDelegate().GigListVCRoot()
                   
                }
                self.navigationController?.present(vc, animated: false)
                
            }
        }
    }
    func getCategoryApi(type:String){
        viewModelAuth.UserFunstionsListApi(type: type,offset:offset,limit: limit, search: "") { data in
            self.arrGetCategories.removeAll()
            self.arrGetCategories.insert(Skills(id: "0", name: "Add Own Categories"), at: 0)
            for i in data?.data ?? []{
                self.arrGetCategories.append(Skills(id: i._id ?? "", name: i.name ?? ""))
            }
            
           
        }
    }
    func getSkillsApi(type:String){
        viewModelAuth.UserFunstionsListApi(type: type,offset:offset,limit: limit, search: "") { data in
            self.arrGetSkill.removeAll()
            self.arrGetSkill.insert(Skills(id: "0", name: "Add Own Skills"), at: 0)
            for i in data?.data ?? []{
                self.arrGetSkill.append(Skills(id: i._id ?? "", name: i.name ?? ""))
            }
         
           
        }
    }
    func showPopOver(type: String, sender: UIButton,height:CGFloat) {
        view.endEditing(true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "GigPopOversVC") as! GigPopOversVC
        vc.type = type
        vc.locationType = self.selectGigType
        if type == "category"{
            vc.arrGetCategories = arrGetCategories
        }else if type == "skills"{
            vc.arrGetSkills = arrGetSkill
        }
      
        vc.modalPresentationStyle = .popover
        vc.callBack = { [self] type,title,id in
            switch type {
                case "category":
                if title == "Add Own Categories"{
                    self.vwAddCategory.isHidden = false
                }else{
//                    btnChooseCategory.setTitle("\(title)", for: .normal)
//                    btnChooseCategory.setTitleColor(.black, for: .normal)
                    self.vwAddCategory.isHidden = true
                    self.lblChooseCategory.text = "\(title)"
                    self.lblChooseCategory.textColor = .black
                    categoryId = id
                }
                case "experience":
//                btnChooseExperience.setTitle("\(title)", for: .normal)
//                btnChooseExperience.setTitleColor(.black, for: .normal)
                lblChooseExperience.text = "\(title)"
                lblChooseExperience.textColor = .black
                experience = title
                case "payment":
                lblPaymentTerms.text = "\(title)"
                lblPaymentTerms.textColor = .black
              
                paymentTerm = title
              
                case "skills":
                if title == "Add Own Skills"{
                    self.vwAddSkill.isHidden = false
                }else{
                    self.vwAddSkill.isHidden = true
                    if arrSkills.contains(where: { $0.name == title }) {
                        showSwiftyAlert("", "Already added Skills.", false)
                    } else {
                        arrSkillId.insert(id, at: 0)
                        arrSkills.insert(Skills(id: id, name: title), at: 0)
                        collVwSkills.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.heightSkillVw.constant = self.collVwSkills.contentSize.height + 10
                            self.vwCollVwSkill.isHidden = false
                        }
                    }
                   
                }
              
                case "paymentMethod":
                if title == "Cash"{
                    paymentMethods = 1
                }else{
                    paymentMethods = 0
                }
            
                lblPaymentMethod.text = "\(title)"
                lblPaymentMethod.textColor = .black
                paymentMethod = title
                default:
                    break
                }
            
        }
        let popOver : UIPopoverPresentationController = vc.popoverPresentationController!
        popOver.sourceView = sender
        popOver.delegate = self
        popOver.permittedArrowDirections = .up
        vc.preferredContentSize = CGSize(width: btnChooseCategory.frame.size.width, height: height)
        self.present(vc, animated: false)

    }
    @IBAction func actionAddCategory(_ sender: UIButton) {
        if txtFldAddCategory.text?.trimWhiteSpace.isEmpty == true {
            showSwiftyAlert("", "Enter your task category", false)
        }else{
            viewModelAuth.CreateUserFunction(type: "Category", name: txtFldAddCategory.text ?? "") { data in
                self.getCategoryApi(type: "Category")
                self.txtFldAddCategory.text = ""
                self.categoryId = data?.data?._id ?? ""
                self.vwAddCategory.isHidden = true
    //            self.btnChooseCategory.setTitle(data?.data?.name ?? "", for: .normal)
    //            self.btnChooseCategory.setTitleColor(.black, for: .normal)
                self.lblChooseCategory.text = data?.data?.name ?? ""
                self.lblChooseCategory.textColor = .black
            }
        }

    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionAddSkills(_ sender: UIButton) {
        viewModelAuth.CreateUserFunction(type: "Specialization", name: txtFldOwnSkill.text ?? "") { data in
            self.getSkillsApi(type: "Specialization")
            self.txtFldOwnSkill.text = ""
            self.vwAddSkill.isHidden = true
           
            self.arrSkills.insert(Skills(id: data?.data?._id ?? "", name: data?.data?.name ?? ""), at: 0)
            self.collVwSkills.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heightSkillVw.constant = self.collVwSkills.contentSize.height + 10
                self.vwCollVwSkill.isHidden = false
            }
        }
    }
    @IBAction func actionTick(_ sender: UIButton) {
        view.endEditing(true)
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            isCancellation = 1
        }else{
            isCancellation = 0
        }
    }
    @IBAction func actionCreate(_ sender: UIButton) {
        view.endEditing(true)
     
        if txtFldTitle.text == ""{
            showSwiftyAlert("", "Please enter a title for your task", false)
        }else if txtVwDescription.text == ""{
            showSwiftyAlert("", "Please enter a description for your task", false)
        }else if categoryId == ""{
            showSwiftyAlert("", "Select a category", false)
        }else if experience == ""{
            showSwiftyAlert("", "Please select your experience", false)
        }else if txtVwAddress.text == ""{
            showSwiftyAlert("", "Please enter your address", false)
        }else if txtFldMap.text == ""{
            showSwiftyAlert("", "Please select your location", false)
        }else if paymentTerm == ""{
            showSwiftyAlert("", "Please select your payment term", false)
        }else if experience == ""{
            showSwiftyAlert("", "Please select your experience", false)
        }else if Int(txtFldAmount.text ?? "0") ?? 0 <= 0 {
            showSwiftyAlert("", "Please enter valid amount", false)
        }else if Int(txtFldAmount.text ?? "0") ?? 0 <= 19 {
            showSwiftyAlert("", "Please enter more than $20", false)
        }else if paymentMethod == ""{
            showSwiftyAlert("", "Please select your payment method", false)
        }else if arrSkills.isEmpty{
            showSwiftyAlert("", "Please select your skills", false)
        }else if arrTools.isEmpty{
            showSwiftyAlert("", "Please select your tools", false)
//        }else if txtFldDressCode.text == ""{
//            showSwiftyAlert("", "Please enter your dress code", false)
        }else if txtFldNoOfPerson.text == ""{
            showSwiftyAlert("", "Please enter the number of participants", false)
        }else if Int(txtFldNoOfPerson.text ?? "0") ?? 0 <= 0 {
            showSwiftyAlert("", "Please enter valid participants", false)
        }else if txtVwInstruction.text == ""{
            showSwiftyAlert("", "Please enter instructions", false)
        }else if txtVwSafetyTips.text == ""{
            showSwiftyAlert("", "Please enter safety tips", false)
        }else if txtFldDate.text == ""{
            showSwiftyAlert("", "Please select date", false)
        }else if txtFldTime.text == ""{
            showSwiftyAlert("", "Please select time", false)
        }else if txtFldTimeDuration.text == ""{
            showSwiftyAlert("", "Please select time duration", false)
        }else{
            if paymentMethods == 0{
                if isComing == true{
                    self.viewModel.checAddGig(price: Int(self.txtFldAmount.text ?? "") ?? 0) { message in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
                        
                        vc.titleText = message
                        vc.callBack = { [weak self] isPay in
                            guard let self = self else { return }
                            self.addUpdateGigApi()
                        }
                        
                        vc.modalPresentationStyle = .overFullScreen
                        self.navigationController?.present(vc, animated: false)
                    }
                }else{
                    if newPrice == txtFldAmount.text {
                        self.addUpdateGigApi()
                    }else{
                        self.viewModel.checAddGig(price: Int(self.txtFldAmount.text ?? "") ?? 0) { message in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformfeePopUpVC") as! PlatformfeePopUpVC
                            
                            vc.titleText = message
                            vc.callBack = { [weak self] isPay in
                                guard let self = self else { return }
                                self.addUpdateGigApi()
                            }
                            
                            vc.modalPresentationStyle = .overFullScreen
                            self.navigationController?.present(vc, animated: false)
                        }
                    }
                }
              
            }else{
                self.addUpdateGigApi()
            }
        }
    }
    @IBAction func actionPaymentMethod(_ sender: UIButton) {
        if selectGigType == "worldwide"{
            showPopOver(type: "paymentMethod", sender: sender, height: 50)
        }else{
            showPopOver(type: "paymentMethod", sender: sender, height: 100)
        }
    }
    
    @IBAction func actionTools(_ sender: UIButton) {
    }
    
    @IBAction func actionChooseSkill(_ sender: UIButton) {
        self.showPopOver(type: "skills", sender: sender, height: CGFloat(self.arrGetSkill.count*50))
    }
    @IBAction func actionPaymentTerm(_ sender: UIButton) {
        showPopOver(type: "payment", sender: sender, height: 100)
    }
    
    @IBAction func actionMap(_ sender: UIButton) {
        view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        vc.isComing = true
        vc.callBack = { [weak self] aboutLocation in
            guard let self = self else { return }
            self.txtFldMap.text = aboutLocation.placeName ?? ""
            self.lat = aboutLocation.lat ?? 0.0
            self.long = aboutLocation.long ?? 0.0
        }
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func actionRemote(_ sender: UIButton) {
        view.endEditing(true)
        lblPaymentMethod.text = "Choose Payment Method*"
        lblPaymentMethod.textColor = UIColor(hex: "#B9B9B9")
        selectGigType = "worldwide"
        updateButtonStates(selectedButton: btnRemote, deselectedButton: btnOnSite)
    }
    
    @IBAction func actionOnSite(_ sender: UIButton) {
        view.endEditing(true)
        lblPaymentMethod.text = "Choose Payment Method*"
        lblPaymentMethod.textColor = UIColor(hex: "#B9B9B9")
        updateButtonStates(selectedButton: btnOnSite, deselectedButton: btnRemote)
        selectGigType = "inMyLocation"
    }
    
    @IBAction func actionChooseCategory(_ sender: UIButton) {
        self.showPopOver(type: "category", sender: sender, height: CGFloat(self.arrGetCategories.count*50))
    }
    @IBAction func actionChooseExperience(_ sender: UIButton) {
        showPopOver(type: "experience", sender: sender, height: 200)
    }
    
    @IBAction func actionUplaodTaskImg(_ sender: UIButton) {
        view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectGigImageOptionVC") as! SelectGigImageOptionVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { index in
            if index == 1{
                self.dismiss(animated: true)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AIImageCreateVC") as! AIImageCreateVC
                vc.callBack = { image in
                    self.imgVwTask.image = image
                }
                self.navigationController?.pushViewController(vc, animated: true)
               
            }else if index == 2{
                self.dismiss(animated: true)
                ImagePicker().pickImage(self) { image in
                    self.imgVwTask.image = image
                }
            }else{
                self.dismiss(animated: true)
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionAddOwnTools(_ sender: UIButton) {
        if let toolName = txtFldAddTools.text?.trimmingCharacters(in: .whitespacesAndNewlines), !toolName.isEmpty {
            if !arrTools.contains(toolName) {
                arrTools.append(txtFldAddTools.text ?? "")
                txtFldAddTools.text = ""
                collVwTools.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.heightToolsVw.constant = self.collVwTools.contentSize.height + 10
                    self.vwCollVwTools.isHidden = false
                }
            }else{
                showSwiftyAlert("", "Already added Tools.", false)
            }
        }else{
            showSwiftyAlert("", "Enter tools name.", false)
        }
    }
}


   
//MARK: - UITextViewDelegate
extension AddTaskVC: UITextViewDelegate{
  
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        let acController = GMSAutocompleteViewController()
//        acController.delegate = self
//        present(acController, animated: true, completion: nil)
//    }
}
//MARK: - UITextFieldDelegate
extension AddTaskVC: UITextFieldDelegate {
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
//                txtFldTitle.resignFirstResponder()
//                txtFldPaticipants.becomeFirstResponder()
            }
            return true
        }
}
//MARK: - combineDateAndTime, date and time format
extension AddTaskVC{
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

    
}

//MARK: - Handle textfiled datepicker
extension AddTaskVC{
    func combineDateAndTime() -> String? {
        guard let dateText = txtFldDate.text,
              let timeText = txtFldTime.text else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        
        let combinedText = "\(dateText) \(timeText)"
        if let combinedDate = dateFormatter.date(from: combinedText) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return isoFormatter.string(from: combinedDate)
        }
        return nil
    }
    @objc func startTimeDonePressed() {
        if let datePicker = txtFldTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let currentDate = dateFormatter.string(from: Date())
            let selectedStartDateText = txtFldDate.text ?? ""
            if selectedStartDateText == currentDate {
                datePicker.minimumDate = Date()
            } else {
                datePicker.minimumDate = nil
            }
            updateTextField(txtFldTime, datePicker: datePicker)
        }
        txtFldTime.resignFirstResponder()
    }

    @objc func startDateDonePressed() {
        if let datePicker = txtFldDate.inputView as? UIDatePicker {
            updateTextField(txtFldDate, datePicker: datePicker)
        }
        txtFldDate.resignFirstResponder()
    }
    @objc func timePickerDonePressed() {
        if let datePicker = txtFldTimeDuration.inputView as? UIDatePicker {
            // Format and validate the service duration
            if let formattedDuration = formatServiceDuration(for: datePicker.date) {
                txtFldTimeDuration.text = formattedDuration
            }
        }
        txtFldTimeDuration.resignFirstResponder()
    }
    func setupDatePicker(for textField: UITextField, mode: UIDatePicker.Mode, selector: Selector) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        if datePicker.datePickerMode == .date{
            datePicker.minimumDate = Date()
        }else if datePicker.datePickerMode == .time{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let currentDate = dateFormatter.string(from: Date())
            if currentDate == txtFldDate.text {
                datePicker.minimumDate = Date()
            }
        }
       
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
            updateTextField(txtFldDate, datePicker: sender)
        case 2:
            updateTextField(txtFldTime, datePicker: sender)
        case 3:
            updateTextField(txtFldTimeDuration, datePicker: sender)
        default:
            break
        }
    }

    func updateTextField(_ textField: UITextField, datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        if textField == txtFldDate {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            textField.text = dateFormatter.string(from: datePicker.date)
        } else if textField == txtFldTime {
            dateFormatter.dateFormat = "hh:mm a"
            textField.text = dateFormatter.string(from: datePicker.date)
        } else if textField == txtFldTimeDuration {
            // Use 24-hour format to capture the duration in hours and minutes
                   dateFormatter.dateFormat = "HH:mm"
                   let durationString = dateFormatter.string(from: datePicker.date)
                   // Ensure the format is "<HH:MM> hours"
                   textField.text = "\(durationString) hours"
            
        }
    }

}
// MARK: - Popup
extension AddTaskVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
}

//MARK: - GMSAutocompleteViewControllerDelegate
extension AddTaskVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
       
        if place.coordinate.latitude.description.count != 0 {
            self.lat = place.coordinate.latitude
        }
        if place.coordinate.longitude.description.count != 0 {
            self.long = place.coordinate.longitude
        }
        //    txtFldSearch.text = place.formattedAddress
        txtVwAddress.text = place.formattedAddress
        txtVwAddress.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension AddTaskVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwSkills{
            return arrSkills.count
        }else{
            return arrTools.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwSkills{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrSkills[indexPath.row].name
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteSkill), for: .touchUpInside)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrTools[indexPath.row]
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteTool), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func actionDeleteSkill(sender:UIButton){
        print("deleteskill")
          arrSkills.remove(at: sender.tag)
          arrSkillId.remove(at: sender.tag)
          collVwSkills.reloadData()

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
              guard let self = self else { return }
              self.heightSkillVw.constant = self.collVwSkills.contentSize.height + 10
          }

          if arrSkills.isEmpty {
              vwCollVwSkill.isHidden = true
              self.heightSkillVw.constant = 0
          }
       
    }
    @objc func actionDeleteTool(sender:UIButton){
        print("deletetool")
        arrTools.remove(at: sender.tag)
        collVwTools.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.heightToolsVw.constant = self.collVwTools.contentSize.height + 10
        }

        if arrTools.isEmpty {
            vwCollVwTools.isHidden = true
            self.heightToolsVw.constant = 0
        }
    }
}
