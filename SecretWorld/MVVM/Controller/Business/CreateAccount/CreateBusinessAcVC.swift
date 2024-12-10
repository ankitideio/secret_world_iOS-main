//
//  CreateBusinessAcVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 25/12/23.
//
import UIKit
import IQKeyboardManagerSwift
import AlignedCollectionViewFlowLayout
class CreateBusinessAcVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var txtFldSearch: UITextField!
    @IBOutlet var heightCollVwSearch: NSLayoutConstraint!
    @IBOutlet var heightCollVwCategory: NSLayoutConstraint!
    @IBOutlet var txtFldBusinesName: UITextField!
    @IBOutlet var heightTblVwTiming: NSLayoutConstraint!
    @IBOutlet var tblVwTiming: UITableView!
    @IBOutlet var txtVwAbout: IQTextView!
    @IBOutlet var viewDottedBorderCover: RectangularDashedView!
    @IBOutlet var imgVwCover: UIImageView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var lblTxtCount: UILabel!
    @IBOutlet var imgVwUpload: UIImageView!
    @IBOutlet var lblUploadImg: UILabel!
    @IBOutlet var txtFldLocation: UITextField!
    @IBOutlet var collVwSearchCate: UICollectionView!
    @IBOutlet var viewDottedBusinessid: RectangularDashedView!
    @IBOutlet var collVwCategory: UICollectionView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    //MARK: - VARIABLES
    var offset = 1
    var limit = 10
    var isUploadCoverImage = false
    var isUploadBusinessIdImage = false
    var arrCategory = [String]()
    var arrCategoryId = [String]()
    var viewModel = AuthVM()
    var arrService = [Servicelist]()
    var arrSearchService = [Servicelist]()
    var selectedDay: String?
    let dayPickerView = UIPickerView()
    var latitude:Double?
    var longitude:Double?
    var selectedLocation:LocationData?
    var selectedDayIndex: Int?
    var arrSelectedSrviceId = [String]()
    var arrDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var isSelect = -1
    var businessTimingData: [[String: Any]] = [
        ["day":"","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"],
        ["day": "","starttime": "", "endtime": "","status": "0"]
    ]
    var obj = [BusinessTimingModel]()
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
    }
    @objc func handleSwipe() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BackPopPupVC") as! BackPopPupVC
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: false)
            }
    override func viewWillAppear(_ animated: Bool) {
        uiSet()
    }
    //MARK: - FUNCTIONS
    func uiSet(){
        Store.role = "b_user"
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwCategory.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        let nibNearBy = UINib(nibName: "BusinessTimingTVC", bundle: nil)
        tblVwTiming.register(nibNearBy, forCellReuseIdentifier: "BusinessTimingTVC")
        self.businessTimingData = []
        setTblviewHeight()
        let alignedFlowLayoutCollVwCategory = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwCategory.collectionViewLayout = alignedFlowLayoutCollVwCategory
        let customLayout = CustomCollectionViewFlowLayout()
            collVwSearchCate.collectionViewLayout = customLayout
//        let alignedFlowLayoutCollVwSearch = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
//        collVwSearchCate.collectionViewLayout = alignedFlowLayoutCollVwSearch
        if let flowLayout2 = collVwCategory.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout2.estimatedItemSize = CGSize(width: 0, height: 36)
            flowLayout2.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        getServiceApi(text: "")
       btnAdd.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 15)
        print("arrSelectedSrviceId.count:-\(arrSelectedSrviceId.count)")
        updateheightCollVwSelectedCategories()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardWhileClick))
                      tapGesture.cancelsTouchesInView = false
                      view.addGestureRecognizer(tapGesture)
           }
           @objc func dismissKeyboardWhileClick() {
                  view.endEditing(true)
              }
    func setTblviewHeight(){
        let maxRows = 7
        let maxTableHeight = CGFloat(maxRows * 75)
        heightTblVwTiming.constant = min(maxTableHeight, CGFloat(businessTimingData.count * 75))
        tblVwTiming.reloadData()
    }
    func getServiceApi(text:String){
        viewModel.GetServiceApi(offset: offset, limit: limit, search: text) { data in
            self.arrSearchService = data?.servicelist ?? []
            self.arrService = data?.servicelist ?? []
            self.collVwSearchCate.reloadData()
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
        self.collVwSearchCate.reloadData()
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func actionAddTiming(_ sender: UIButton) {
        businessTimingData.append(["day": "","starttime": "", "endtime": "", "status": 0])
           tblVwTiming.reloadData()
          setTblviewHeight()
    }
    @IBAction func actionUploadCoverPic(_ sender: UIButton) {
            if isUploadCoverImage == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePhotoVC") as! ChangePhotoVC
                vc.isComing = 2
                vc.callBack = { [weak self] image in
                    guard let self = self else { return }
                    self.imgVwCover.image = image
                    if Store.CoverImage == UIImage(named: "") || Store.CoverImage == nil{
                        self.isUploadCoverImage = false
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                ImagePicker().pickImage(self) { image in
                    self.imgVwCover.image = image
                    self.isUploadCoverImage = true
                    Store.CoverImage = image
                }
            }
    }
    @IBAction func actionUploadPhoto(_ sender: UIButton) {
        if isUploadBusinessIdImage == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePhotoVC") as! ChangePhotoVC
            vc.isComing = 1
            vc.callBack = { [weak self] image in
                guard let self = self else { return }
                self.imgVwUpload.image = image
                if Store.BusinessIdImage == UIImage(named: "") || Store.BusinessIdImage == nil{
                    self.isUploadBusinessIdImage = false
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            ImagePicker().pickImage(self) { image in
                self.imgVwUpload.image = image
                self.isUploadBusinessIdImage = true
                Store.BusinessIdImage = image
            }
        }
}
    @IBAction func actionLocation(_ sender: UIButton) {
        txtFldBusinesName.resignFirstResponder()
        txtVwAbout.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        vc.latitude = latitude
        vc.longitude = longitude
        vc.isComing = true
        vc.callBack = { [weak self] location in
            guard let self = self else { return }
            self.txtFldLocation.text = location.placeName ?? ""
            self.latitude = location.lat
            self.longitude = location.long
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BackPopPupVC") as! BackPopPupVC
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: false)
    }
    @IBAction func actionSignup(_ sender: UIButton) {
        if txtFldBusinesName.text == ""{
            showSwiftyAlert("", "Enter business name", false)
        }else if txtFldLocation.text == ""{
            showSwiftyAlert("", "Select your location", false)
        }else if imgVwUpload.image == UIImage(named: ""){
            showSwiftyAlert("", "Upload business id image", false)
        }else if imgVwCover.image == UIImage(named: ""){
            showSwiftyAlert("", "Upload cover image", false)
        }else if txtVwAbout.text == ""{
            showSwiftyAlert("", "Enter about your business", false)
        }else if arrSelectedSrviceId.isEmpty{
            showSwiftyAlert("", "Select service categories", false)
//        }else if businessTimingData.isEmpty {
//            showSwiftyAlert("", "Select your opening hours", false)
        }else{
            var servicesArray: [[String: String]] = []
            for serviceId in arrSelectedSrviceId {
                let serviceDict: [String: String] = ["id": serviceId]
                servicesArray.append(serviceDict)
            }
            print("servicesArray: \(servicesArray)")
            var hoursArrays = [[String: String]]()
            for businessTiming in businessTimingData {
                let day = businessTiming["day"] as? String ?? ""
                let startTime = businessTiming["starttime"] as? String ?? ""
                let endTime = businessTiming["endtime"] as? String ?? ""
                let status = businessTiming["status"] as? String ?? ""
                let startTime24Hour = convertTo24HourFormat(timeString: startTime) ?? ""
                let endTime24Hour = convertTo24HourFormat(timeString: endTime) ?? ""
                if day.isEmpty{
                               showSwiftyAlert("", "Select day", false)
                               return
                }else if startTime.isEmpty{
                               showSwiftyAlert("", "Select start time", false)
                               return
                }else if endTime.isEmpty{
                    showSwiftyAlert("", "Select end time", false)
                }
                let businessTimingDict: [String: String] = [
                    "day": day,
                    "starttime":startTime24Hour,
                    "endtime": endTime24Hour,
                    "status":  "1"
                ]
                hoursArrays.append(businessTimingDict)
            }
            print("businessTiming:--\(hoursArrays)")
            print("api calling:--")
            viewModel.CreateBusinessAccountApi(about: txtVwAbout.text ?? "", deviceId: Store.deviceToken ?? "",
                businessname: txtFldBusinesName.text ?? "",
                place: txtFldLocation.text ?? "",
                lat: latitude ?? 0.0,
                long: longitude ?? 0.0,
                business_id: imgVwUpload,
                cover_photo: imgVwCover,
                services: servicesArray,
                openinghours: hoursArrays) { data in
                Store.autoLogin = data?.user?.profileStatus
                Store.userId = data?.user?.id ?? ""
                Store.businessLatLong = ["lat":self.latitude ?? 0,"long":self.longitude ?? 0]
                DispatchQueue.main.async {
                    WebService.hideLoader()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreatAcSuccessVC") as! CreatAcSuccessVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
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
}
//MARK: - UICollectionViewDelegate
extension CreateBusinessAcVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwCategory{
            return arrCategory.count
        }else{
            return min(arrSearchService.count, 10)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwCategory{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrCategory[indexPath.row]
            cell.vwBg.layer.cornerRadius = 20
            cell.btnCross.setImage(UIImage(named: "crossred"), for: .normal)
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDelete), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCategoryCVC", for: indexPath) as! SearchCategoryCVC
            cell.lblName.text = arrSearchService[indexPath.row].name 
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(actionSelect), for: .touchUpInside)
            if arrCategory.contains(arrSearchService[indexPath.row].name ?? "") {
                cell.btnSelect.isSelected = true
                cell.btnSelect.backgroundColor = UIColor.app
            } else {
                cell.btnSelect.isSelected = false
                cell.btnSelect.backgroundColor = UIColor.white
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collVwSearchCate.frame.size.width - 16) / 2
        return CGSize(width: width, height: 36)
    }
    @objc func actionDelete(sender: UIButton) {
        let removedServiceId = arrSelectedSrviceId[sender.tag]
        arrCategory.remove(at: sender.tag)
        collVwCategory.reloadData()
        updateheightCollVwSelectedCategories()
        if let deselectedIndex = arrSearchService.firstIndex(where: { $0.id == removedServiceId }) {
            let indexPath = IndexPath(item: deselectedIndex, section: 0)
            if let cell = collVwSearchCate.cellForItem(at: indexPath) as? SearchCategoryCVC {
                cell.btnSelect.isSelected = false
                cell.btnSelect.backgroundColor = .clear
            }
        }
        arrSelectedSrviceId.remove(at: sender.tag)
        updateheightCollVwSelectedCategories()
    }
    @objc func actionSelect(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            let selectedServiceName = arrSearchService[sender.tag].name ?? ""
            let selectedSrviceId = arrSearchService[sender.tag].id ?? ""
            print("index:--\(sender.tag) \(selectedServiceName)")
                    if !arrCategory.contains(selectedServiceName) {
                        arrCategory.append(selectedServiceName)
                        arrSelectedSrviceId.append(selectedSrviceId)
                        print("arrCategoryId:--\(arrSelectedSrviceId)")
                        print("selectedServiceName:--\(arrCategory)")
                        sender.backgroundColor = UIColor.app
                        collVwCategory.reloadData()
                        updateheightCollVwSelectedCategories()
                    }
        }else{
                   let deselectedServiceName = arrSearchService[sender.tag].name ?? ""
                   let deselectedServiceId = arrSearchService[sender.tag].id ?? ""
            print("index:--\(sender.tag) \(deselectedServiceName)")
                   if let index = arrCategory.firstIndex(of: deselectedServiceName),
                      let index2 = arrSelectedSrviceId.firstIndex(of: deselectedServiceId) {
                       arrCategory.remove(at: index)
                       arrSelectedSrviceId.remove(at: index2)
                       print("deselectedServiceName:--\(arrCategory)")
                       print("deselectedServiceId:--\(arrSelectedSrviceId)")
                       sender.backgroundColor = UIColor.clear
                       collVwCategory.reloadData()
                       updateheightCollVwSelectedCategories()
                   }
               }
           }
    func updateheightCollVwSelectedCategories() {
        if arrSelectedSrviceId.isEmpty{
            heightCollVwCategory.constant = 0
        }else{
            let rowsSpeciliz = ceil(CGFloat(arrSelectedSrviceId.count) / 2)
            let newHeightSpeciliz = rowsSpeciliz * 37 + max(0, rowsSpeciliz - 1) * 8
            heightCollVwCategory.constant = newHeightSpeciliz
            collVwSearchCate.layoutIfNeeded()
        }
    }
    func updateheightCollVwSearchCategories() {
        if arrSearchService.count > 0 {
            let rowsSpeciliz = ceil(CGFloat(arrSearchService.count) / 2)
            let newHeightSpeciliz = rowsSpeciliz * 38 + max(0, rowsSpeciliz - 1) * 8
            heightCollVwSearch.constant = newHeightSpeciliz
            collVwSearchCate.layoutIfNeeded()
            self.lblNoDataFound.text = ""
        }else{
            heightCollVwSearch.constant = 70
            collVwSearchCate.layoutIfNeeded()
            self.lblNoDataFound.text = "Data not found!"
        }
    }
}
//MARK: - UITextViewDelegate
extension CreateBusinessAcVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
                lblTxtCount.text = "\(characterCount)/250"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
    }
}
// MARK: - Popup
extension CreateBusinessAcVC: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
  //UIPopoverPresentationControllerDelegate
  func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
  }
}
extension CreateBusinessAcVC: UIPickerViewDelegate,UIPickerViewDataSource {
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
                index != isSelect && (data["day"] as? String == selectedValue)
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
//MARK: -UITextFieldDelegate
extension CreateBusinessAcVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtFldSearch{
            let currentText = txtFldSearch.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            if newText.isEmpty {
                getServiceApi(text: "")
            } else {
                let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
                searchList(text: newString)
                getServiceApi(text: newString)
            }
            collVwSearchCate.reloadData()
        }
        return true
    }
}
//MARK: - UITableViewDelegate
extension CreateBusinessAcVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessTimingData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTimingTVC", for: indexPath) as! BusinessTimingTVC
           let sectionData = businessTimingData[indexPath.row]
           let startTime = sectionData["starttime"] as? String ?? ""
           let endTime = sectionData["endtime"] as? String ?? ""
           let day = sectionData["day"] as? String ?? ""
        var toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.app
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker(sender:)))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
           cell.txtFldStartTime.text = startTime
           cell.txtFldEndTime.text = endTime
           cell.txtFldDay.text = day
           cell.btnDelete.tag = indexPath.row
           cell.btnDelete.addTarget(self, action: #selector(actionDeleteTime), for: .touchUpInside)
           cell.txtFldDay.inputView = dayPickerView
           cell.txtFldDay.tag = indexPath.row
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
    @objc func donePicker(sender: UIBarButtonItem) {
        let selectedRow = dayPickerView.selectedRow(inComponent: 0)
        let selectedValue = arrDays[selectedRow]
        let isDayAlreadySelected = businessTimingData.enumerated().contains { index, data in
            index != isSelect && (data["day"] as! String == selectedValue)
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
    @objc func actionStartTimee(sender: UITextField){
        let indexx = isSelect
        print("Selected index: \(indexx)")
        let indexPath = IndexPath(row: indexx, section: 0)
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            if let datePicker = cell.txtFldStartTime.inputView as? UIDatePicker {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                businessTimingData[indexx]["starttime"] = dateFormatter.string(from: datePicker.date)
                businessTimingData[indexx]["status"] = 1
            }
            if let startTime = businessTimingData[indexx]["starttime"] as? String,
               let endTime = businessTimingData[indexx]["endtime"] as? String,
               !startTime.isEmpty && !endTime.isEmpty {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                if let start = dateFormatter.date(from: startTime),
                   let end = dateFormatter.date(from: endTime),
                   start >= end {
                    showSwiftyAlert("", "Start time not greater then the end time", false)
                }
                else{
                    cell.txtFldStartTime.resignFirstResponder()
                    cell.txtFldEndTime.becomeFirstResponder()
                    if indexx == 0{
                        self.obj.remove(at: 0)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 0)
                    }else if indexx == 1{
                        self.obj.remove(at: 1)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 1)
                    }else if indexx == 2{
                        self.obj.remove(at: 2)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 2)
                    }else if indexx == 3{
                        self.obj.remove(at: 3)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 3)
                    }else if indexx == 4{
                        self.obj.remove(at: 4)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 4)
                    }else if indexx == 5{
                        self.obj.remove(at: 5)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 5)
                    }else{
                        self.obj.remove(at: 6)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 6)
                    }
                    tblVwTiming.reloadData()
                }
            }else{
                cell.txtFldStartTime.resignFirstResponder()
                cell.txtFldEndTime.becomeFirstResponder()
                if indexx == 0{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 0)
                }else if indexx == 1{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 1)
                }else if indexx == 2{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 2)
                }else if indexx == 3{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endTime"]  as? String ?? "",status: "1"), at: 3)
                }else if indexx == 4{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 4)
                }else if indexx == 5{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 6)
                }
                tblVwTiming.reloadData()
            }
        }
   }
    @objc func actionEndTimee(sender: UITextField){
        let indexx = isSelect
        let indexPath = IndexPath(row: indexx, section: 0)
        if let cell = tblVwTiming.cellForRow(at: indexPath) as? BusinessTimingTVC {
            if let datePicker = cell.txtFldEndTime.inputView as? UIDatePicker {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                businessTimingData[indexx]["endtime"] = dateFormatter.string(from: datePicker.date)
                businessTimingData[indexx]["status"] = 1
            }
            if let startTime = businessTimingData[indexx]["starttime"] as? String,
               let endTime = businessTimingData[indexx]["endtime"] as? String,
               !startTime.isEmpty && !endTime.isEmpty {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                if let start = dateFormatter.date(from: startTime),
                   let end = dateFormatter.date(from: endTime),
                   start >= end {
                    showSwiftyAlert("", "End time not less then the start time", false)
                }
                else{
                    cell.txtFldEndTime.resignFirstResponder()
                    if indexx == 0{
                        self.obj.remove(at: 0)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 0)
                    }else if indexx == 1{
                        self.obj.remove(at: 1)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 1)
                    }else if indexx == 2{
                        self.obj.remove(at: 2)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endTime"] as? String ?? "",status: "1"), at: 2)
                    }else if indexx == 3{
                        self.obj.remove(at: 3)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 3)
                    }else if indexx == 4{
                        self.obj.remove(at: 4)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 4)
                    }else if indexx == 5{
                        self.obj.remove(at: 5)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 5)
                    }else{
                        self.obj.remove(at: 6)
                        self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 6)
                    }
                    tblVwTiming.reloadData()
                }
            }else{
                cell.txtFldEndTime.resignFirstResponder()
                if indexx == 0{
                    self.obj.remove(at: 0)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 0)
                }else if indexx == 1{
                    self.obj.remove(at: 1)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 1)
                }else if indexx == 2{
                    self.obj.remove(at: 2)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 2)
                }else if indexx == 3{
                    self.obj.remove(at: 3)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 3)
                }else if indexx == 4{
                    self.obj.remove(at: 4)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"]  as? String ?? "",status: "1"), at: 4)
                }else if indexx == 5{
                    self.obj.remove(at: 5)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 5)
                }else{
                    self.obj.remove(at: 6)
                    self.obj.insert(BusinessTimingModel(day: businessTimingData[indexx]["day"] as? String ?? "",starttime: businessTimingData[indexx]["starttime"] as? String ?? "",endtime: businessTimingData[indexx]["endtime"] as? String ?? "",status: "1"), at: 6)
                }
                tblVwTiming.reloadData()
            }
        }
      }
    @objc func actionDeleteTime(sender:UIButton){
        isSelect = sender.tag
        print("isSelect:--\(isSelect)")
        businessTimingData.remove(at: isSelect)
        setTblviewHeight()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return  75
    }
}
class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        var newAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            let newAttribute = attribute.copy() as! UICollectionViewLayoutAttributes
            if newAttribute.indexPath.item >= 2 {
                let previousAttribute = newAttributes.last
                let previousFrame = previousAttribute?.frame ?? .zero
                let currentFrame = newAttribute.frame
                if previousFrame.maxY == currentFrame.minY {
                    newAttribute.frame.origin.x = previousFrame.origin.x
                }
            }
            newAttributes.append(newAttribute)
        }
        return newAttributes
    }
}
