//
//  EditBusinessProfileVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 04/01/24.
//

import UIKit
import IQKeyboardManagerSwift
import AlignedCollectionViewFlowLayout

class EditBusinessProfileVC: UIViewController{
    
    @IBOutlet var lblAboutTxtCount: UILabel!
    @IBOutlet var heightTblvw: NSLayoutConstraint!
    @IBOutlet var tblVwTiming: UITableView!
    @IBOutlet var heightCollVwSearchcat: NSLayoutConstraint!
    @IBOutlet var heightCollVwCategoy: NSLayoutConstraint!
    @IBOutlet var txtFldSearch: UITextField!
    @IBOutlet weak var imgVwCoverPhoto: UIImageView!
    
    @IBOutlet var lblTxtCount: UILabel!
    @IBOutlet var imgVwUpload: UIImageView!
    @IBOutlet var collvwSearchCate: UICollectionView!
    @IBOutlet var collvwCategory: UICollectionView!
    @IBOutlet var txtFldGender: UITextField!
    @IBOutlet var txtFldDOB: UITextField!
    @IBOutlet var txtFldName: UITextField!
    @IBOutlet var txtVwAbout: IQTextView!
    
    var arrDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var offset = 1
    var limit = 10
    var viewModel = AuthVM()
    var getBusinessUserDetail:GetBusinessUserDetail?
    var arrSearchService = [Servicelist]()
    var arrService = [Servicelist]()
    var arrServiceNames = [Service]()
    var isSelect = -1
    
    let dayPickerView = UIPickerView()
    var businessTimingData: [[String: String]] = [
        ["day":"","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"]
    ]
    
    var obj = [BusinessTimingModel]()
    var arrGetServices = [Service]()
    var arrSelectedSrviceId = [String]()
    var arrSelectedService = [String]()
    var viewModelProfile = BusinessProfileVM()
    var callBack:(()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        self.obj.removeAll()
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        self.obj.append(BusinessTimingModel(day: "",starttime: "",endtime: "",status: "0"))
        
        
        uiSet()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardWhileClick))
               tapGesture.cancelsTouchesInView = false
               view.addGestureRecognizer(tapGesture)
    }
    @objc func handleSwipe() {
                navigationController?.popViewController(animated: true)
            }
    @objc func dismissKeyboardWhileClick() {
           view.endEditing(true)
       }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightInterest = self.collvwCategory.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwCategoy.constant = heightInterest
        self.view.layoutIfNeeded()
    }
    func updateCollectionViewHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let heightInterest = self.collvwCategory.collectionViewLayout.collectionViewContentSize.height
            self.heightCollVwCategoy.constant = heightInterest
            self.view.layoutIfNeeded()
        }
    }
    func uiSet(){
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        let nibCollvw = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collvwCategory.register(nibCollvw, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        
        
        let alignedFlowLayoutCollVwCategory = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collvwCategory.collectionViewLayout = alignedFlowLayoutCollVwCategory
        
        if let flowLayout2 = collvwCategory.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout2.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout2.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        if let flowLayout2 = collvwSearchCate.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout2.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout2.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        let nibNearBy = UINib(nibName: "BusinessTimingTVC", bundle: nil)
        tblVwTiming.register(nibNearBy, forCellReuseIdentifier: "BusinessTimingTVC")
        
        let customLayout = CustomCollectionViewFlowLayout()
        collvwSearchCate.collectionViewLayout = customLayout
        getServiceApi(text: "")
        
        getUserDetail()
        
        
    }
    func setTblviewHeight(){
        let maxRows = 7
        let maxTableHeight = CGFloat(maxRows * 75)
        heightTblvw.constant = min(maxTableHeight, CGFloat(businessTimingData.count * 75))
        tblVwTiming.reloadData()
    }
    func getServiceApi(text:String){
        viewModel.GetServiceApi(offset: offset, limit: limit, search: text) { data in
            self.arrSearchService = data?.servicelist ?? []
            self.arrService = data?.servicelist ?? []
            
            self.collvwSearchCate.reloadData()
            self.updateheightCollVwSearchCategories()
        }
    }
    func searchList(text: String) {
        self.arrService = self.arrSearchService.filter { value in
            if let name = value.name {
                return name.lowercased().contains(text.lowercased())
            } else {
                return false
            }
        }
        if text == "" {
            self.arrService = self.arrSearchService
        }
        self.collvwSearchCate.reloadData()
    }
    
    func getUserDetail(){
        txtFldName.text = getBusinessUserDetail?.userProfile?.name ?? ""
        txtFldDOB.text = getBusinessUserDetail?.userProfile?.dob ?? ""
        txtFldGender.text = getBusinessUserDetail?.userProfile?.gender ?? ""
        txtVwAbout.text = getBusinessUserDetail?.userProfile?.about ?? ""
        textViewDidChange(txtVwAbout)
        imgVwUpload.imageLoad(imageUrl: getBusinessUserDetail?.userProfile?.profilePhoto ?? "")
        imgVwCoverPhoto.imageLoad(imageUrl: getBusinessUserDetail?.userProfile?.coverPhoto ?? "")
        self.businessTimingData.removeAll()
        
        if getBusinessUserDetail?.userProfile?.openingHours?.count ?? 0 > 0{
            for openingHour in getBusinessUserDetail?.userProfile?.openingHours ?? []{
                
                self.businessTimingData.append(["day":openingHour.day ?? "","starttime": convertTo12HourFormat(timeString: openingHour.starttime ?? "") ?? "", "endtime": convertTo12HourFormat(timeString: openingHour.endtime ?? "") ?? "", "status": "1"])
                
                print("businessTimingData")
                
            }
            
        }else{
            self.businessTimingData = [["day": "","starttime": "", "endtime": "", "status": "0"]]
            
        }
        setTblviewHeight()
        
        for servicess in getBusinessUserDetail?.userProfile?.services ?? []{
            arrSelectedService.append(servicess.name ?? "")
            arrSelectedSrviceId.append(servicess.id ?? "")
            
            collvwCategory.reloadData()
            updateCollectionViewHeight()
        }
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
    
    func convertTo24HourFormat(timeString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    @IBAction func actionCoverPhoto(_ sender: UIButton) {
        ImagePicker().pickImage(self) { image in
            
            self.imgVwCoverPhoto.image = image
            
            
        }
    }
    @IBAction func actionUpload(_ sender: UIButton) {
        ImagePicker().pickImage(self) { image in
            
            self.imgVwUpload.image = image
            
            
        }
    }
    @IBAction func actionEdit(_ sender: UIButton) {
      
        
        if imgVwUpload.image == UIImage(named: ""){
            
            showSwiftyAlert("", "Upload profile image", false)
            
        }else if txtFldName.text == ""{
            
            showSwiftyAlert("", "Enter your business name", false)
            
        }else if txtFldDOB.text == ""{
            
            showSwiftyAlert("", "Select your business establish date", false)
            
        }else if txtVwAbout.text == ""{
            
            showSwiftyAlert("", "Enter about your business", false)
            
        }else if imgVwCoverPhoto.image == UIImage(named: ""){
            
            showSwiftyAlert("", "Upload cover image", false)
            
        }else if arrSelectedService.isEmpty{
            
            showSwiftyAlert("", "Select service categories", false)
            
        }else if businessTimingData.isEmpty{
            
            showSwiftyAlert("", "Add opening hours", false)
            
        }else{
            
            let dictionaryArray = arrSelectedSrviceId.map { id in
                return ["id": id]
            }
            var hoursArrays = [[String: String]]()
            
            for businessTiming in businessTimingData {
                let day = businessTiming["day"] ?? ""
                let startTime = businessTiming["starttime"]  ?? ""
                let endTime = businessTiming["endtime"] ?? ""
                let status = businessTiming["status"] ?? ""
                
                let startTime24Hour = convertTo24HourFormat(timeString: startTime) ?? ""
                let endTime24Hour = convertTo24HourFormat(timeString: endTime) ?? ""
                
                print(businessTimingData.count)
                
                if day.isEmpty{
                    showSwiftyAlert("", "Select day", false)
                    return
                }else if startTime.isEmpty{
                    showSwiftyAlert("", "Select start time", false)
                    return
                }else if endTime.isEmpty{
                    showSwiftyAlert("", "Select end time", false)
                }else{
                    
                    let businessTimingDict: [String: String] = [
                        "day": day,
                        "starttime":startTime24Hour,
                        "endtime": endTime24Hour,
                        "status":  "1"
                    ]
                    
                    hoursArrays.append(businessTimingDict)
                    
                    print(hoursArrays)
                    viewModelProfile.updateBusinessProfile(name: txtFldName.text ?? "", dob: txtFldDOB.text ?? "", about: txtVwAbout.text ?? "", gender: "", profilePhoto: imgVwUpload, coverPhoto: imgVwCoverPhoto, services: dictionaryArray, openingHour: hoursArrays) { message in
                        showSwiftyAlert("", message ?? "", true)
//                        SceneDelegate().BusinessProfileVCRoot()
                        self.navigationController?.popViewController(animated: true)
                        self.callBack?()
                    }
                }
            }
        }
    }
    func dismissKeyboard(){
        txtFldName.resignFirstResponder()
        txtFldSearch.resignFirstResponder()
        txtVwAbout.resignFirstResponder()
        
    }
    @IBAction func actionAddHour(_ sender: UIButton) {
        dismissKeyboard()
        
        businessTimingData.append(["day": "","starttime": "", "endtime": "", "status": "0"])
        tblVwTiming.reloadData()
        
        setTblviewHeight()
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actiondateofbirth(_ sender: UIButton) {
        dismissKeyboard()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { [weak self] date in
            guard let self = self else { return }
            self.txtFldDOB.text = date
        }
        self.navigationController?.present(vc, animated: true)
    }
    
        
    
    @IBAction func actionGender(_ sender: UIButton) {
        dismissKeyboard()
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GenderVC") as! GenderVC
        vc.modalPresentationStyle = .overFullScreen
        vc.genderTxt = txtFldGender.text ?? ""
        vc.callBack = { [weak self] gender in
            guard let self = self else { return }
            
            self.txtFldGender.text = gender
            
        }
        
        self.navigationController?.present(vc, animated: true)
        
    }
    
}
//MARK: - UICollectionViewDelegate
extension EditBusinessProfileVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collvwCategory{
            return arrSelectedService.count
        }else{
            return arrSearchService.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collvwCategory{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrSelectedService[indexPath.row]
            cell.vwBg.layer.cornerRadius = 20
            cell.btnCross.setImage(UIImage(named: "crossred"), for: .normal)
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDelete), for: .touchUpInside)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCVC", for: indexPath) as! SearchCVC
            cell.lblName.text = arrSearchService[indexPath.row].name ?? ""
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(actionSelect), for: .touchUpInside)
            if arrSelectedSrviceId.contains(where: { $0 == arrSearchService[indexPath.row].id }) {
                cell.btnSelect.isSelected = true
                cell.btnSelect.backgroundColor = .app
            }else{
                cell.btnSelect.isSelected = false
                cell.btnSelect.backgroundColor = .clear
            }
            return cell
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collvwSearchCate.frame.size.width - 16) / 2
        return CGSize(width: width, height: 36)
    }
    @objc func actionDelete(sender: UIButton) {
        let removedServiceId = arrSelectedSrviceId[sender.tag]
        arrSelectedService.remove(at: sender.tag)
        arrSelectedSrviceId.remove(at: sender.tag)
        
        if let deselectedIndex = arrSearchService.firstIndex(where: { $0.id == removedServiceId }) {
            let indexPath = IndexPath(item: deselectedIndex, section: 0)
            if let cell = collvwSearchCate.cellForItem(at: indexPath) as? SearchCategoryCVC {
                cell.btnSelect.isSelected = false
                cell.btnSelect.backgroundColor = .clear
            }
        }
        collvwCategory.reloadData()
        collvwSearchCate.reloadData()
        updateCollectionViewHeight()
        updateheightCollVwSearchCategories()
    }
    @objc func actionSelect(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            
            
            let selectedServiceName = arrSearchService[sender.tag].name ?? ""
            let selectedSrviceId = arrSearchService[sender.tag].id ?? ""
            if !arrSelectedService.contains(selectedServiceName) {
                arrSelectedService.append(selectedServiceName)
                arrSelectedSrviceId.append(selectedSrviceId)
                print("arrCategoryId:--\(arrSelectedSrviceId)")
                print("selectedServiceName:--\(arrSelectedService)")
                sender.backgroundColor = UIColor.app
                collvwCategory.reloadData()
                
                updateCollectionViewHeight()
            }
        }else{
            
            let deselectedServiceName = arrSearchService[sender.tag].name ?? ""
            let deselectedServiceId = arrSearchService[sender.tag].id ?? ""
            if let index = arrSelectedService.firstIndex(of: deselectedServiceName),
               let index2 = arrSelectedSrviceId.firstIndex(of: deselectedServiceId) {
                arrSelectedService.remove(at: index)
                arrSelectedSrviceId.remove(at: index2)
                print("deselectedServiceName:--\(arrSelectedService)")
                print("deselectedServiceId:--\(arrSelectedSrviceId)")
                sender.backgroundColor = UIColor.clear
                collvwCategory.reloadData()
                updateCollectionViewHeight()
            }
        }
    }
    func updateheightCollVwSearchCategories() {
        
        let rowsSpeciliz = ceil(CGFloat(arrSearchService.count) / 2)
        let newHeightSpeciliz = rowsSpeciliz * 37 + max(0, rowsSpeciliz - 1) * 8
        heightCollVwSearchcat.constant = newHeightSpeciliz
        collvwSearchCate.layoutIfNeeded()
    }
}
//MARK: - UITextFieldDelegate
extension EditBusinessProfileVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = txtFldSearch.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.isEmpty {
            
            getServiceApi(text: "")
            
        } else {
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            searchList(text: newString)
            getServiceApi(text: newString)
        }
        
        collvwSearchCate.reloadData()
        return true
    }
}
//MARK: - UITextViewDelegate
extension EditBusinessProfileVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        let characterCount = textView.text.count
        lblAboutTxtCount.text = "\(characterCount)/250"
        
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
        
    }
    
}
// MARK: - Popup
extension EditBusinessProfileVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
    }
}

//MARK: - UITableViewDelegate
extension EditBusinessProfileVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessTimingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTimingTVC", for: indexPath) as! BusinessTimingTVC
        
        let sectionData = businessTimingData[indexPath.row]
        let startTime = sectionData["starttime"] ?? ""
        let endTime = sectionData["endtime"] ?? ""
        let day = sectionData["day"] ?? ""
        
        
        cell.txtFldStartTime.text = startTime
        cell.txtFldEndTime.text = endTime
        cell.txtFldDay.text = day
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(actionDeleteTime), for: .touchUpInside)
        var toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.app
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker(sender:)))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
        

        cell.txtFldDay.inputView = dayPickerView
        cell.txtFldDay.inputAccessoryView = toolBar
        cell.txtFldDay.tag = indexPath.row
        cell.txtFldStartTime.setInputViewDatePickerAccount(target: self, selector: #selector(actionStartTimee), isSelectType: "startTime")
        cell.txtFldEndTime.setInputViewDatePickerAccount(target: self, selector: #selector(actionEndTimee), isSelectType: "endTime")
        cell.indexxPathh = indexPath.row
        cell.uiSet()
        cell.callBack = { [weak self] indexPath in
            guard let self = self else { return }
            self.isSelect = indexPath
        }
        
        return cell
    }
    


    @objc func actionStartTimee(sender: UITextField){
        dismissKeyboard()
        let indexx = isSelect
        
        
        print("Selected index: \(indexx)")
        
        let indexPath = IndexPath(row: indexx, section: 0)
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            if let datePicker = cell.txtFldStartTime.inputView as? UIDatePicker {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                businessTimingData[indexx]["starttime"] = dateFormatter.string(from: datePicker.date)
                businessTimingData[indexx]["status"] = "1"
                
            }
            if let startTime = businessTimingData[indexx]["starttime"],
               let endTime = businessTimingData[indexx]["endtime"],
               !startTime.isEmpty && !endTime.isEmpty {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                if let start = dateFormatter.date(from: startTime),
                   let end = dateFormatter.date(from: endTime),
                   start >= end {
                    cell.txtFldStartTime.text = ""
                    businessTimingData[indexx]["starttime"] = nil
                    cell.txtFldEndTime.resignFirstResponder()
                    cell.txtFldStartTime.becomeFirstResponder()
                    showSwiftyAlert("", "Start time not greater then the end time", false)
                }else{
                    cell.txtFldStartTime.resignFirstResponder()
                    cell.txtFldEndTime.becomeFirstResponder()
                    if indexx == 0{
                        
                        self.obj.remove(at: 0)
                        self.obj.insert(BusinessTimingModel(day: obj[indexx].day,starttime:  obj[indexx].starttime,endtime: obj[indexx].endtime,status: "0"), at: 0)
                    }else if indexx == 1{
                        self.obj.remove(at: 1)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "0"), at: 1)
                        
                    }else if indexx == 2{
                        self.obj.remove(at: 2)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 2)
                    }else if indexx == 3{
                        self.obj.remove(at: 3)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 3)
                    }else if indexx == 4{
                        self.obj.remove(at: 4)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 4)
                    }else if indexx == 5{
                        self.obj.remove(at: 5)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 5)
                    }else{
                        self.obj.remove(at: 6)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 6)
                    }
                    tblVwTiming.reloadData()
                }
            }else{
                cell.txtFldStartTime.resignFirstResponder()
                cell.txtFldEndTime.becomeFirstResponder()
                if indexx == 0{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 0)
                }else if indexx == 1{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 1)
                }else if indexx == 2{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 2)
                }else if indexx == 3{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endTime"] ?? "",status: "1"), at: 3)
                }else if indexx == 4{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 4)
                }else if indexx == 5{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 6)
                }
                tblVwTiming.reloadData()
            }
        }
    }
    
    
    @objc func actionEndTimee(sender: UITextField){
        dismissKeyboard()
        let indexx = isSelect
        let indexPath = IndexPath(row: indexx, section: 0)
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            if let datePicker = cell.txtFldEndTime.inputView as? UIDatePicker {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                businessTimingData[indexx]["endtime"] = dateFormatter.string(from: datePicker.date)
                businessTimingData[indexx]["status"] = "1"
                
            }
            if let startTime = businessTimingData[indexx]["starttime"],
               let endTime = businessTimingData[indexx]["endtime"],
               !startTime.isEmpty && !endTime.isEmpty {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                if let start = dateFormatter.date(from: startTime),
                   let end = dateFormatter.date(from: endTime),
                   start >= end {
                    cell.txtFldEndTime.text = ""
                    businessTimingData[indexx]["endtime"] = nil
                    cell.txtFldStartTime.resignFirstResponder()
                    cell.txtFldEndTime.becomeFirstResponder()
                    showSwiftyAlert("", "End time not less then the start time", false)
                }else{
                    cell.txtFldEndTime.resignFirstResponder()
                    if indexx == 0{
                        self.obj.remove(at: 0)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 0)
                    }else if indexx == 1{
                        self.obj.remove(at: 1)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 1)
                    }else if indexx == 2{
                        self.obj.remove(at: 2)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endTime"] ?? "",status: "1"), at: 2)
                    }else if indexx == 3{
                        self.obj.remove(at: 3)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"]  ?? "",status: "1"), at: 3)
                    }else if indexx == 4{
                        self.obj.remove(at: 4)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"]  ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 4)
                    }else if indexx == 5{
                        self.obj.remove(at: 5)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"]  ?? "",starttime: businessTimingData[indexx]["starttime"]  ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 5)
                    }else{
                        self.obj.remove(at: 6)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 6)
                    }
                    
                    tblVwTiming.reloadData()
                }
            }else{
                cell.txtFldEndTime.resignFirstResponder()
                if indexx == 0{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 0)
                }else if indexx == 1{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 1)
                }else if indexx == 2{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 2)
                }else if indexx == 3{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 3)
                }else if indexx == 4{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 4)
                }else if indexx == 5{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] ?? "",starttime: businessTimingData[indexx]["starttime"] ?? "",endtime: businessTimingData[indexx]["endtime"] ?? "",status: "1"), at: 6)
                }
                
                tblVwTiming.reloadData()
            }
        }
    }
    
    @objc func actionDeleteTime(sender:UIButton){
        dismissKeyboard()
       
        
        isSelect = sender.tag
        
        print("isSelect:--\(isSelect)")
        businessTimingData.remove(at: isSelect)
        
        setTblviewHeight()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  75
        
    }
    @objc func donePicker(sender: UIBarButtonItem) {

        let selectedRow = dayPickerView.selectedRow(inComponent: 0)
        
        let selectedValue = arrDays[selectedRow]
        let isDayAlreadySelected = businessTimingData.enumerated().contains { index, data in
            index != isSelect && (data["day"] == selectedValue)
        }
        
        if isDayAlreadySelected {
            showSwiftyAlert("", "\(selectedValue) already selected", false)
            view.endEditing(true)
            return
        }
        let indexPath = IndexPath(row: isSelect, section: 0)
        
        businessTimingData[isSelect]["day"] = selectedValue
        
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            cell.txtFldDay.text = selectedValue
            view.endEditing(true)
        }
        
        print("Selected: \(selectedValue)")
    }

}
extension EditBusinessProfileVC: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrDays.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrDays[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = arrDays[row]
        
        
        guard isSelect >= 0, isSelect < businessTimingData.count else {
            return
        }
        
        
        let isDayAlreadySelected = businessTimingData.enumerated().contains { index, data in
            index != isSelect && (data["day"] == selectedValue)
        }
        
        if isDayAlreadySelected {
            showSwiftyAlert("", "\(selectedValue) already selected", false)
            return
        }
        let indexPath = IndexPath(row: isSelect, section: 0)
        
        businessTimingData[isSelect]["day"] = selectedValue
        
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            cell.txtFldDay.text = selectedValue
            
        }
        
        print("Selected: \(selectedValue)")
    }
   
}
