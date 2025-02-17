//
//  AddPopUpVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 24/01/24.
//
import UIKit
import IQKeyboardManagerSwift

struct Products {
    let name: String?
    let price: Int?
    let images:[String]?
    init(name: String?, price: Int?, images: [String]?) {
        self.name = name
        self.price = price
        self.images = images
    }
}
class AddPopUpVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - OUTLETS
    @IBOutlet weak var txtFldDealingOffer: UITextField!
    @IBOutlet weak var txtFldAvailability: UITextField!
    @IBOutlet weak var heightCollVw: NSLayoutConstraint!
    @IBOutlet var viewNoProduct: UIView!
    @IBOutlet var txtFldPopupType: UITextField!
    @IBOutlet var btnMarkerLogo: UIButton!
    @IBOutlet var imgVwMarkerLogo: UIImageView!
    @IBOutlet var btnCreate: UIButton!
    @IBOutlet var txtFldName: UITextField!
    @IBOutlet var txtFldLOcation: UITextField!
    @IBOutlet var btnPopupLogo: UIButton!
    @IBOutlet var imgVwPopupLogo: UIImageView!
   // @IBOutlet var heightVwNoProductlsit: NSLayoutConstraint!
    @IBOutlet var txtFldEndTime: UITextField!
    @IBOutlet var txtFldEndDate: UITextField!
    @IBOutlet var txtFldStartTime: UITextField!
    @IBOutlet var txtFldStartDate: UITextField!
    @IBOutlet var txtVwDescription: IQTextView!
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet weak var lblDescriptionCount: UILabel!
    @IBOutlet var colVwProducts: UICollectionView!
    //MARK: - VARIABLES
    var arrProducts = [Products]()
    var isUploadLogoImg = false
    var isUploadMarker = false
    var viewModel = PopUpVM()
    var viewModelUpload = UploadImageVM()
    var lat:Double?
    var long:Double?
    var selectedStartTime:String?
    var selectedEndTime:String?
    var selectedStartDate:String?
    var selectedEndDate:String?
    var currentTime:String?
    var currentDate:String?
    var isComing = false
    var arrEditProducts = [AddProducts]()
    var productImg = [""]
    var callBack:(()->())?
    var popupDetails:PopupDetailData?
    var popUptype = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    
    @objc func handleSwipe() {
               navigationController?.popViewController(animated: true)
           }
    
    func uiSet(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        txtFldStartDate.tag = 1
        txtFldEndDate.tag = 2
        txtFldStartTime.tag = 3
        txtFldEndTime.tag = 4
        let nibCollvw = UINib(nibName: "ProductsCVC", bundle: nil)
        colVwProducts.register(nibCollvw, forCellWithReuseIdentifier: "ProductsCVC")
        txtVwDescription.delegate = self
        
        if isComing == true{
            // Update promote business
            lblScreenTitle.text = "Edit Popup"
            btnCreate.setTitle("Update", for: .normal)
            btnPopupLogo.setImage(UIImage(named: ""), for: .normal)
            imgVwPopupLogo.imageLoad(imageUrl: popupDetails?.businessLogo ?? "")
            popUptype = popupDetails?.categoryType ?? 0
            txtFldDealingOffer.text = popupDetails?.deals ?? ""
        
            if popupDetails?.categoryType == 1{
                txtFldPopupType.text = "Food & drinks"
                
            }else if popupDetails?.categoryType == 2{
                txtFldPopupType.text = "Services"
            }else if popupDetails?.categoryType == 3{
                txtFldPopupType.text = "Crafts & goods"
            }else{
                txtFldPopupType.text = "Events"
            }

            txtFldName.text = popupDetails?.name ?? ""
            txtVwDescription.text = popupDetails?.description ?? ""
            txtFldLOcation.text = popupDetails?.place ?? ""
            arrEditProducts = popupDetails?.addProducts ?? []
            txtFldAvailability.text = "\(popupDetails?.availability ?? 0)"
            txtFldStartDate.text = convertDateString(popupDetails?.startDate ?? "")
            txtFldEndDate.text = convertDateString(popupDetails?.endDate ?? "")
            txtFldStartTime.text = convertTimeString(popupDetails?.startDate ?? "")
            txtFldEndTime.text = convertTimeString(popupDetails?.endDate ?? "")
            lat = popupDetails?.lat ?? 0.0
            long = popupDetails?.long ?? 0.0
            self.productImg.removeAll()
            if popupDetails?.productImages?.count ?? 0 > 0{
                
                self.productImg = popupDetails?.productImages ?? []
                self.productImg.insert("", at: 0)
            }else{
                self.productImg.insert("", at: 0)
            }
            if self.productImg.count == 2 || self.productImg.count == 1{
                self.heightCollVw.constant = 160
            }else if self.productImg.count == 3 || self.productImg.count == 4{
                self.heightCollVw.constant = 330
            }else{
                self.heightCollVw.constant = 490
            }
            colVwProducts.reloadData()
            arrEditProducts = popupDetails?.addProducts  ?? []
            viewNoProduct.isHidden = true
            colVwProducts.reloadData()
        }else{
            //add
            lblScreenTitle.text = "Add Popup"
            btnCreate.setTitle("Create", for: .normal)

        }
        setupDatePickers()
    }
    //MARK: - BUTTON ACTIONS
    
    @IBAction func actionChoosetype(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupTypeVC") as! PopupTypeVC
        vc.modalPresentationStyle = .overFullScreen
        vc.popUptype = popUptype
        vc.callBack = {[weak self] (type,category) in
            guard let self = self else { return }
            self.popUptype = type ?? 0
            self.txtFldPopupType.text = category
        }
        self.navigationController?.present(vc, animated: true)

    }
    @IBAction func actionUploadMarkerLogo(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddMarkerImageVC") as! AddMarkerImageVC
        vc.callBack = { image in
            if image == UIImage(named: "") || image == nil{
                self.btnMarkerLogo.setImage(UIImage(named: "Group25"), for: .normal)
            }else{
                self.btnMarkerLogo.setImage(UIImage(named: ""), for: .normal)
                self.imgVwMarkerLogo.image = image
            }
            
        }
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func openCamera() {
           if UIImagePickerController.isSourceTypeAvailable(.camera) {
               let imagePicker = UIImagePickerController()
               imagePicker.sourceType = .camera
               imagePicker.delegate = self
               imagePicker.allowsEditing = false
               self.present(imagePicker, animated: true, completion: nil)
           }
       }
    // MARK: - UIImagePickerControllerDelegate
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
         if let image = info[.originalImage] as? UIImage {
//             do {
//                 let processedImage = try BackgroundRemoval().removeBackground(image: image)
//                 
                    self.imgVwMarkerLogo.image = image
                     Store.MarkerLogo = image
                     self.btnMarkerLogo.setImage(UIImage(named: ""), for: .normal)
                     self.isUploadMarker = true
//                 
//             } catch {
//                 print("Error removing background: \(error.localizedDescription)")
//             }
         }
         picker.dismiss(animated: true, completion: nil)
     }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionUploadimg(_ sender: UIButton) {
        if isUploadLogoImg == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePhotoVC") as! ChangePhotoVC
            vc.isComing = 0
            vc.callBack = { [weak self] image in
                
                guard let self = self else { return }
                self.imgVwPopupLogo.image = image
                if Store.LogoImage == UIImage(named: "") || Store.LogoImage == nil{
                    self.btnPopupLogo.setImage(UIImage(named: "Group25"), for: .normal)
                    self.isUploadLogoImg = false
                }else{
                    self.btnPopupLogo.setImage(UIImage(named: ""), for: .normal)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            ImagePicker().pickImage(self) { image in
                self.imgVwPopupLogo.image = image
                Store.LogoImage = image
                self.btnPopupLogo.setImage(UIImage(named: ""), for: .normal)
                self.isUploadLogoImg = true
            }
        }
    }
    @IBAction func actionAddProduct(_ sender: UIButton) {
        txtFldName.resignFirstResponder()
        txtVwDescription.resignFirstResponder()
        txtFldStartDate.resignFirstResponder()
        txtFldEndDate.resignFirstResponder()
        txtFldStartTime.resignFirstResponder()
        txtFldEndTime.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddProductVC") as! AddProductVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = true
        vc.callBack = { productName,price,isEdit,productImages in
            print(productName.count)
            
            if self.isComing == true{
                
                self.uiSet()
                self.arrEditProducts.append(AddProducts(productName: productName, price: price, id: "", image: productImages))
                self.viewNoProduct.isHidden = true
                self.colVwProducts.isHidden = false
                self.colVwProducts.reloadData()
            }else{
                self.uiSet()
                
                self.arrProducts.append(Products(name: productName, price: price, images: productImages))
                self.viewNoProduct.isHidden = true
                self.colVwProducts.isHidden = false
                self.colVwProducts.reloadData()
            }
            
            
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionCreate(_ sender: UIButton) {
        productImg.remove(at: 0)
        if imgVwPopupLogo.image == UIImage(named: "") || imgVwPopupLogo.image == nil{
            showSwiftyAlert("", "No logo selected. Please choose an image to upload", false)
//        }else  if imgVwMarkerLogo.image == UIImage(named: "") || imgVwMarkerLogo.image == nil{
//            showSwiftyAlert("", "No marker logo selected. Please choose an image to upload", false)
        }else if txtFldName.text == ""{
            showSwiftyAlert("", "This field cannot be left blank. Provide your pop-up title.", false)
        }else if txtVwDescription.text == ""{
            showSwiftyAlert("", "Description of pop-up is required", false)
        
//        }else if arrProducts.isEmpty && arrEditProducts.isEmpty {
//            if isComing{
//                showSwiftyAlert("", "Add product", false)
//            } else {
//                showSwiftyAlert("", "Add product", false)
//            }
        }else if txtFldDealingOffer.text == ""{
            showSwiftyAlert("", "Please enter your deals.", false)
        }else if txtFldPopupType.text == ""{
            showSwiftyAlert("", "Please select your popup type.", false)
        }else if txtFldLOcation.text == ""{
            showSwiftyAlert("", "Please choose your location.", false)
        }else if txtFldStartDate.text == ""{
            showSwiftyAlert("", "Please select the start date.", false)
        }else if txtFldStartTime.text == ""{
            showSwiftyAlert("", "Please select the start time.", false)
        }else if txtFldEndDate.text == ""{
            showSwiftyAlert("", "Please select the end date.", false)
        }else if txtFldEndTime.text == ""{
            showSwiftyAlert("", " Please select the end time.", false)
//        }else if txtFldAvailability.text == ""{
//            showSwiftyAlert("", "Please enter your availability.", false)
//
        }else{
            let startDateTimeString = "\(txtFldStartDate.text ?? "") \(txtFldStartTime.text ?? "")"
            let endDateTimeString = "\(txtFldEndDate.text ?? "") \(txtFldEndTime.text ?? "")"
            let startDateTimeUTC = convertToUTC(from: startDateTimeString, with: "dd-MM-yyyy h:mm a") ?? ""
            let endDateTimeUTC = convertToUTC(from: endDateTimeString, with: "dd-MM-yyyy h:mm a") ?? ""
            print("Start Time UTC:", startDateTimeUTC)
            print("End Time UTC:", endDateTimeUTC)
                if isComing == true{
                  
                        viewModel.UpdatePopUpApi(id: popupDetails?.id ?? "",
                                                 usertype: "user", place: txtFldLOcation.text ?? "", storeType: popUptype, name: txtFldName.text ?? "", business_logo: imgVwPopupLogo, startDate: startDateTimeUTC, endDate: endDateTimeUTC, lat: lat ?? 0.0,long: long ?? 0.0,deals: txtFldDealingOffer.text ?? "", availability: Int(txtFldAvailability.text ?? "") ?? 0, description: txtVwDescription.text ?? "", categoryType: popUptype, arrImages: productImg){ message in
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                            vc.isSelect = 10
                            vc.message = message
                            myPopUpLat = self.lat ?? 0
                            myPopUpLong = self.long ?? 0
                            addPopUp = true
                            vc.callBack = {[weak self] in
                                guard let self = self else { return }
                             SceneDelegate().PopupListVCRoot()
                            }
                            vc.modalPresentationStyle = .overFullScreen
                            self.navigationController?.present(vc, animated: true)
                        }

                  
                }else{
                    //add
                    viewModel.AddPopUpApi(usertype: "user", place: txtFldLOcation.text ?? "", storeType: popUptype, name: txtFldName.text ?? "", business_logo: imgVwPopupLogo, startDate: startDateTimeUTC, endDate: endDateTimeUTC, lat: lat ?? 0.0,long: long ?? 0.0,deals: txtFldDealingOffer.text ?? "", availability: Int(txtFldAvailability.text ?? "") ?? 0, description: txtVwDescription.text ?? "", categoryType: popUptype, arrImages: productImg) { message in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.isSelect = 10
                        vc.message = message
                        myPopUpLat = self.lat ?? 0
                        myPopUpLong = self.long ?? 0
                        addPopUp = true
                        Store.tabBarNotificationPosted = false
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            SceneDelegate().userRoot()
                        }
                        vc.modalPresentationStyle = .overFullScreen
                        self.navigationController?.present(vc, animated: true)
                    }
                      
                }
            //}
        }
    }
    func convertToUTC(from dateString: String, with format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let localDateTime = dateFormatter.date(from: dateString) {
            let utcTimeZone = TimeZone(identifier: "UTC")
            dateFormatter.timeZone = utcTimeZone
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let utcDateTime = dateFormatter.string(from: localDateTime)
            return utcDateTime
        }
        return nil
    }
    @IBAction func actionLocation(_ sender: UIButton) {
        txtFldName.resignFirstResponder()
        txtVwDescription.resignFirstResponder()
        txtFldStartDate.resignFirstResponder()
        txtFldEndDate.resignFirstResponder()
        txtFldStartTime.resignFirstResponder()
        txtFldEndTime.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentLocationVC") as! CurrentLocationVC
        vc.isComing = false
        vc.latitude = lat
        vc.longitude = long
        vc.callBack = { [weak self] location in
            guard let self = self else { return }
            self.txtFldLOcation.text = location.placeName ?? ""
            self.lat = location.lat
            self.long = location.long
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    }

//MARK: - uitextfielddelegates
extension AddPopUpVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFldName{
            txtFldName.resignFirstResponder()
            txtVwDescription.becomeFirstResponder()
        }
        return true
    }
}
//MARK: - UITextViewDelegate
extension AddPopUpVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        lblDescriptionCount.text = "\(characterCount)/250"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
    }
}
//MARK: - Handle textfields datepicker
extension AddPopUpVC{
    func setupDatePickers() {
      setupDatePicker(for: txtFldStartDate, mode: .date, selector: #selector(startDateDonePressed))
      setupDatePicker(for: txtFldEndDate, mode: .date, selector: #selector(endDateDonePressed))
      setupDatePicker(for: txtFldStartTime, mode: .time, selector: #selector(startTimeDonePressed))
      setupDatePicker(for: txtFldEndTime, mode: .time, selector: #selector(endTimeDonePressed))
    }
  @objc func actionStartTime() {
    if let datePicker = txtFldStartTime.inputView as? UIDatePicker {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "h:mm a"
      selectedStartTime = dateFormatter.string(from: datePicker.date)
      let currentDate = Date()
      dateFormatter.dateFormat = "dd-MM-yyyy"
      let currentDateString = dateFormatter.string(from: currentDate)
      if txtFldStartDate.text == currentDateString {
        if datePicker.date < currentDate {
          datePicker.date = currentDate
          txtFldStartTime.text = nil
        } else {
          datePicker.minimumDate = currentDate
          txtFldStartTime.text = selectedStartTime
        }
      } else {
        datePicker.minimumDate = nil
        txtFldStartTime.text = selectedStartTime
      }
    }
  }
    func setupDatePicker(for textField: UITextField, mode: UIDatePicker.Mode, selector: Selector) {
      let datePicker = UIDatePicker()
      datePicker.datePickerMode = mode
      if #available(iOS 13.4, *) {
        datePicker.preferredDatePickerStyle = .wheels
      }
      datePicker.translatesAutoresizingMaskIntoConstraints = false
      textField.inputView = datePicker
        if textField == txtFldStartDate || textField == txtFldEndDate{
            datePicker.minimumDate = Date()
        }
      let toolbar = UIToolbar()
      toolbar.sizeToFit()
      let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: selector)
      // Add the flexible space item first and then the "Done" button
      toolbar.setItems([flexibleSpace, doneButton], animated: true)
      textField.inputAccessoryView = toolbar
      datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
      datePicker.tag = textField.tag
    }
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
      switch sender.tag {
      case 1:
        updateTextField(txtFldStartDate, datePicker: sender)
      case 2:
        updateTextField(txtFldEndDate, datePicker: sender)
      case 3:
        updateTextField(txtFldStartTime, datePicker: sender)
      case 4:
        updateTextField(txtFldEndTime, datePicker: sender)
      default:
        break
      }
    }
  func updateTextField(_ textField: UITextField, datePicker: UIDatePicker) {
    let dateFormatter = DateFormatter()
    if textField == txtFldStartDate || textField == txtFldEndDate {
      dateFormatter.dateFormat = "dd-MM-yyyy"
    } else if textField == txtFldStartTime || textField == txtFldEndTime {
      dateFormatter.dateFormat = "h:mm a"
    }
    textField.text = dateFormatter.string(from: datePicker.date)
    validateDateAndTime()
  }
    @objc func startDateDonePressed() {
      if let datePicker = txtFldStartDate.inputView as? UIDatePicker {
        updateTextField(txtFldStartDate, datePicker: datePicker)
      }
      txtFldStartDate.resignFirstResponder()
    }
    @objc func endDateDonePressed() {
      if let datePicker = txtFldEndDate.inputView as? UIDatePicker {
        updateTextField(txtFldEndDate, datePicker: datePicker)
      }
      txtFldEndDate.resignFirstResponder()
    }
  @objc func startTimeDonePressed() {
      if let datePicker = txtFldStartTime.inputView as? UIDatePicker {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "dd-MM-yyyy"
          let currentDate = dateFormatter.string(from: Date())
          let selectedStartDateText = txtFldStartDate.text ?? ""
          if selectedStartDateText == currentDate {
              datePicker.minimumDate = Date()
          } else {
              datePicker.minimumDate = nil
          }
          updateTextField(txtFldStartTime, datePicker: datePicker)
      }
      txtFldStartTime.resignFirstResponder()
  }
    @objc func endTimeDonePressed() {
      if let datePicker = txtFldEndTime.inputView as? UIDatePicker {
        updateTextField(txtFldEndTime, datePicker: datePicker)
      }
      txtFldEndTime.resignFirstResponder()
    }
  func validateDateAndTime() {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd-MM-yyyy"
      let currentDate = Date()
      // Validate start time
      if let datePicker = txtFldStartTime.inputView as? UIDatePicker {
          let selectedStartDateText = txtFldStartDate.text ?? ""
          if let selectedStartDate = dateFormatter.date(from: selectedStartDateText) {
              if Calendar.current.isDate(selectedStartDate, inSameDayAs: currentDate) {
                  datePicker.minimumDate = currentDate
                  let timeFormatter = DateFormatter()
                          timeFormatter.dateFormat = "h:mm a"
                  let currentTimeString = timeFormatter.string(from: currentDate)
                              print("Current Time: \(currentTimeString)")
                  if currentTimeString > txtFldStartTime.text ?? ""{
                      txtFldStartTime.text = ""
                  }
              } else {
                  
                  datePicker.minimumDate = nil
              }
          }
      }
      // Validate end time
      if let datePicker = txtFldEndTime.inputView as? UIDatePicker {
          let selectedEndDateText = txtFldEndDate.text ?? ""
          if let selectedEndDate = dateFormatter.date(from: selectedEndDateText) {
              if Calendar.current.isDate(selectedEndDate, inSameDayAs: currentDate) {
                  datePicker.minimumDate = currentDate
              } else {
                  
                  datePicker.minimumDate = nil
              }
          }
      }
      guard let startDateText = txtFldStartDate.text,
            let endDateText = txtFldEndDate.text,
            let startTimeText = txtFldStartTime.text,
            let endTimeText = txtFldEndTime.text else {
          return
      }
      guard let startDate = dateFormatter.date(from: startDateText),
            let endDate = dateFormatter.date(from: endDateText) else {
          return
      }
      if startDate == endDate {
          dateFormatter.dateFormat = "h:mm a"
          guard let startTime = dateFormatter.date(from: startTimeText),
                let endTime = dateFormatter.date(from: endTimeText) else {
              return
          }
          if endTime <= startTime {
              
              txtFldEndTime.text = ""
              showSwiftyAlert("", "Enter valid time.", false)
          }
      }else if startDate > endDate {
          
          txtFldEndDate.text = ""
          showSwiftyAlert("", "Enter valid date.", false)
      }
  }
  func convertDateString(_ dateString: String) -> String? {
      let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      if dateString.contains(".") {
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      } else {
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      }
      if let date = dateFormatter.date(from: dateString) {
          dateFormatter.dateFormat = "dd-MM-yyyy"
          return dateFormatter.string(from: date)
      }
      return nil
  }
  func convertTimeString(_ dateString: String) -> String? {
      let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      if dateString.contains(".") {
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      } else {
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      }
      if let date = dateFormatter.date(from: dateString) {
          dateFormatter.dateFormat = "h:mm a"
          return dateFormatter.string(from: date)
      }
      return nil
  }

}
//MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension AddPopUpVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
            if productImg.count > 0{
                return  productImg.count
            }else{
                return 1
            }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductsCVC", for: indexPath) as! ProductsCVC
        if indexPath.row == 0{
            cell.vwAddProduct.isHidden = false
        
            cell.imgVwDelete.isHidden = true
            cell.btnDelete.isHidden = true
            cell.imgVwProduct.isHidden = true
            cell.btnAddProduct.addTarget(self, action: #selector(addProductImg), for: .touchUpInside)
            cell.btnAddProduct.tag = 0
        }else{
            cell.vwAddProduct.isHidden = true
          
            cell.imgVwDelete.isHidden = false
            cell.btnDelete.isHidden = false
            cell.imgVwProduct.isHidden = false
//            cell.btnEdit.tag = indexPath.row
//            cell.btnEdit.addTarget(self, action: #selector(ActionEditProduct), for: .touchUpInside)
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(ActionDeleteProduct), for: .touchUpInside)
            cell.imgVwProduct.imageLoad(imageUrl: productImg[indexPath.row])

        }
     
    
        return cell
    }
    @objc func ActionDeleteProduct(sender: UIButton) {
        let indexToDelete = sender.tag
        if isComing == true{

            productImg.remove(at: indexToDelete)

            colVwProducts.reloadData()
        }else{

            productImg.remove(at: indexToDelete)

            if self.productImg.count == 2 || self.productImg.count == 1{
                self.heightCollVw.constant = 160
            }else if self.productImg.count == 3 || self.productImg.count == 4{
                self.heightCollVw.constant = 330
            }else{
                self.heightCollVw.constant = 490
            }
            colVwProducts.reloadData()
        }

    }
@objc func ActionEditProduct(sender: UIButton) {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddProductVC") as! AddProductVC
    vc.modalPresentationStyle = .overFullScreen
    vc.isComing = false
    vc.selectedIndex = sender.tag
//    vc.arrProducts = arrProducts
    
    vc.callBack = { [weak self] productName, price,isEdit,productImages in
                    guard let self = self else { return }
        if self.isComing == true{
                self.arrEditProducts[sender.tag] = AddProducts(productName: productName, price: price, id: "", image: productImages)
            
        }else{
                self.arrProducts[sender.tag] = Products(name: productName, price: price, images: productImages)
            }
        
        self.colVwProducts.reloadData()
    }
    self.navigationController?.present(vc, animated: true)
}

    @objc func addProductImg(sender:UIButton){
        if self.productImg.count < 6 {
        ImagePicker().pickImage(self) { image in
            self.viewModelUpload.uploadProductImagesApi(Images: image) { data in
              
                    self.productImg.insert(data?.imageUrls?[0] ?? "", at: 1)
                    if self.productImg.count == 2 || self.productImg.count == 1{
                        self.heightCollVw.constant = 160
                    }else if self.productImg.count == 3 || self.productImg.count == 4{
                        self.heightCollVw.constant = 330
                    }else{
                        self.heightCollVw.constant = 490
                    }
                    self.colVwProducts.reloadData()
               
            }
           
          
        }
        }else{
            showSwiftyAlert("", "Upload maximum 5 Images", false)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.productImg.count == 1{
            return CGSize(width: colVwProducts.frame.size.width/1, height: 160)
        }else{
            return CGSize(width: colVwProducts.frame.size.width/2-5 , height: 160)
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}




