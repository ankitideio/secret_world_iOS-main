//
//  EditProfileVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 26/12/23.
//
import UIKit
import IQKeyboardManagerSwift
import AlignedCollectionViewFlowLayout
class EditProfileVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var txtFldAddress: UITextField!
    @IBOutlet weak var vwAddress: UIView!
    @IBOutlet weak var txtFldCity: UITextField!
    @IBOutlet weak var vwCity: UIView!
    @IBOutlet weak var txtFldZipCode: UITextField!
    @IBOutlet weak var vwZipcode: UIView!
    @IBOutlet var heightCollVwDietry: NSLayoutConstraint!
    @IBOutlet var heightCollVwSpecil: NSLayoutConstraint!
    @IBOutlet var collVwSpecialization: UICollectionView!
    @IBOutlet var collVwDietry: UICollectionView!
    @IBOutlet var txtFldName: UITextField!
    @IBOutlet var txtFldPlace: UITextField!
    @IBOutlet var heightCollVwInterst: NSLayoutConstraint!
    @IBOutlet var txtFldDietry: UITextField!
    @IBOutlet var txtFldInterst: UITextField!
    @IBOutlet var lblTxtCount: UILabel!
    @IBOutlet var txtVwAbout: IQTextView!
    @IBOutlet var txtFldGender: UITextField!
    @IBOutlet var txtFldDateOfBirth: UITextField!
    @IBOutlet var imgVwProfile: UIImageView!
    @IBOutlet var collVwInterst: UICollectionView!
    //MARK: - VARIABLES
    var offset = 1
    var limit = 10
    var arrInterst = [Interest]()
    var arrDietry = [DietaryPreference]()
    var arrSpecialize = [Specialization]()
    var arrDietryId = [String]()
    var arrInterstId = [String]()
    var arrSpecilizeId = [String]()
    var viewModel = UserProfileVM()
    var countryShortName:String?
    var arrGetInterst = [Functions]()
    var arrGetDietry = [Functions]()
    var arrGetSpecialize = [Functions]()
    var viewModelAuth = AuthVM()
    var getUserDetail:UserProfile?
    var arrInterstName = [String]()
    var arrDietryName = [String]()
    var arrSpecializeName = [String]()
    var isSelectInterst = 0
    var isSelectDietary = 0
    var isSelectSpecilize = 0
    var callBack:(()->())?
    var lat = Double()
    var long = Double()
    var heightInterst = false
    var birthDate = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionViewHeight()
    }
    func updateCollectionViewHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let heightInterest = self.collVwInterst.collectionViewLayout.collectionViewContentSize.height
            if self.isSelectInterst == 0{
                if self.arrInterst.count == 0{
                    self.heightCollVwInterst.constant = 0
                }else if self.arrInterst.count == 1{
                    self.heightCollVwInterst.constant = 49
                }else{
                    self.heightCollVwInterst.constant = heightInterest+12
                }
            }else{
                if self.arrGetInterst.count == 0{
                    self.heightCollVwInterst.constant = 0
                }else if self.arrGetInterst.count == 1{
                    self.heightCollVwInterst.constant = 49
                }else{
                    self.heightCollVwInterst.constant = heightInterest+12
                }
            }
            let heightDietry = self.collVwDietry.collectionViewLayout.collectionViewContentSize.height
            if self.isSelectDietary == 0{
                if self.arrDietry.count == 0{
                    self.heightCollVwDietry.constant = 0
                }else if self.arrDietry.count == 1{
                    self.heightCollVwDietry.constant = 49
                }else{
                    self.heightCollVwDietry.constant = heightDietry+12
                }
            }else{
                if self.arrGetDietry.count == 0{
                    self.heightCollVwDietry.constant = 0
                }else if self.arrGetDietry.count == 1{
                    self.heightCollVwDietry.constant = 49
                }else{
                    self.heightCollVwDietry.constant = heightDietry+12
                }
            }
//            self.heightCollVwDietry.constant = heightDietry
            let heightSpelize = self.collVwSpecialization.collectionViewLayout.collectionViewContentSize.height
            if self.isSelectSpecilize == 0{
                if self.arrSpecialize.count == 0{
                    self.heightCollVwSpecil.constant = 0
                }else if self.arrSpecialize.count == 1{
                    self.heightCollVwSpecil.constant = 49
                }else{
                    self.heightCollVwSpecil.constant = heightSpelize+12
                }
            }else{
                if self.arrGetSpecialize.count == 0{
                    self.heightCollVwSpecil.constant = 0
                }else if self.arrGetSpecialize.count == 1{
                    self.heightCollVwSpecil.constant = 49
                }else{
                    self.heightCollVwSpecil.constant = heightSpelize+12
                }
            }
//            self.heightCollVwSpecil.constant = heightSpelize
            self.view.layoutIfNeeded()
        }
    }
    func uiSet(){
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwInterst.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        collVwDietry.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        collVwSpecialization.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        let alignedFlowLayoutCollVwInterst = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwInterst.collectionViewLayout = alignedFlowLayoutCollVwInterst
        let alignedFlowLayoutCollVwDietry = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwDietry.collectionViewLayout = alignedFlowLayoutCollVwDietry
        let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwSpecialization.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
        setupAlignedFlowLayout(for: collVwInterst)
        setupAlignedFlowLayout(for: collVwDietry)
        setupAlignedFlowLayout(for: collVwSpecialization)
        setupFlowLayout(for: collVwInterst)
        setupFlowLayout(for: collVwDietry)
        setupFlowLayout(for: collVwSpecialization)
        getFunctionApis()
        getUserDetails()
        print("isSelectDietary:--\(self.isSelectDietary)")
        print("isSelectInterst:--\(self.isSelectInterst)")
        print("isSelectSpecilize:--\(self.isSelectSpecilize)")
    }
    func getUserDetails(){
        self.txtVwAbout.text = getUserDetail?.about ?? ""
        self.textViewDidChange(self.txtVwAbout)
        self.txtFldName.text = getUserDetail?.name ?? ""
        self.txtFldGender.text = getUserDetail?.gender ?? ""
        self.txtFldDateOfBirth.text = getUserDetail?.dob ?? ""
        self.txtFldPlace.text = getUserDetail?.place ?? ""
        self.imgVwProfile.imageLoad(imageUrl: getUserDetail?.profilePhoto ?? "")
        Store.UserProfileViewImage = UIImage(named: getUserDetail?.profilePhoto ?? "")
        self.convertDateBirth(date: getUserDetail?.dob ?? "")
        self.arrDietry.append(contentsOf: getUserDetail?.Dietary ?? [])
        for i in getUserDetail?.Dietary ?? [] {
            if let functionId = i._id {
                self.arrDietryId.append(functionId)
            }
        }
        self.arrInterst.append(contentsOf: getUserDetail?.Interests ?? [])
        for i in getUserDetail?.Interests ?? [] {
            if let functionId = i._id {
                self.arrInterstId.append(functionId)
            }
        }
        self.arrSpecialize.append(contentsOf: getUserDetail?.Specialization ?? [])
        for i in getUserDetail?.Specialization ?? [] {
            if let functionId = i._id {
                self.arrSpecilizeId.append(functionId)
            }
        }
        self.collVwDietry.reloadData()
        self.collVwInterst.reloadData()
        self.collVwSpecialization.reloadData()
        self.updateCollectionViewHeight()
    }
    func convertDateBirth(date:String){
        let dateFormatterInput = DateFormatter()
        dateFormatterInput.dateFormat = "dd-MM-yyyy"
        if let date = dateFormatterInput.date(from: date) {
            let dateFormatterOutput = DateFormatter()
            dateFormatterOutput.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatterOutput.string(from: date)
            self.birthDate = formattedDate
        } else {
            print("Invalid date format")
        }
    }
    func getFunctionApis(){
        getinterstApi()
        getDietaryApi()
        getSpecializationApi()
    }
    func getinterstApi(){
        viewModelAuth.UserFunstionsListApi(type: "Interests",offset:offset,limit: limit, search: "") { data in
            self.arrGetInterst.removeAll()
            self.arrGetInterst.append(contentsOf: data?.data ?? [])
        }
    }
    func getDietaryApi(){
        viewModelAuth.UserFunstionsListApi(type: "Dietary Preferences",offset:offset,limit: limit, search: "") { data in
            self.arrGetDietry.removeAll()
            self.arrGetDietry.append(contentsOf: data?.data ?? [])
        }
    }
    func getSpecializationApi(){
        viewModelAuth.UserFunstionsListApi(type: "Specialization",offset:offset,limit: limit, search: "") { data in
            self.arrGetSpecialize.removeAll()
            self.arrGetSpecialize.append(contentsOf: data?.data ?? [])
        }
    }
    func setupFlowLayout(for collectionView: UICollectionView) {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            collectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
    }
    func setupAlignedFlowLayout(for collectionView: UICollectionView) {
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collectionView.collectionViewLayout = alignedFlowLayout
    }
    func dismissKeyboard(){
        txtFldName.resignFirstResponder()
        txtVwAbout.resignFirstResponder()
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func actionProfilePic(_ sender: UIButton) {
    }
    @IBAction func actionDateOfBirth(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { date in
            self.txtFldDateOfBirth.text = date
            self.birthDate = date ?? ""
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionUpdate(_ sender: UIButton) {
        if imgVwProfile.image == UIImage(named: ""){
            showSwiftyAlert("", "Upload profile image", false)
        }else if txtFldName.text == ""{
            showSwiftyAlert("", "Enter your name", false)
        }else if txtFldDateOfBirth.text == ""{
            showSwiftyAlert("", "Enter your date of birth", false)
        }else if txtVwAbout.text == ""{
            showSwiftyAlert("", "Enter about you", false)
//        }else if arrInterstId.isEmpty{
//            showSwiftyAlert("", "Select interest", false)
//        }else if arrDietryId.isEmpty{
//            showSwiftyAlert("", "Select dietary prefrence", false)
        }else if arrSpecilizeId.isEmpty{
            showSwiftyAlert("", "Select specialization", false)
        }else if txtFldPlace.text == ""{
            showSwiftyAlert("", "Select place", false)
        }else{
            viewModel.UpdateUserProfileApi(name: txtFldName.text ?? "", about: txtVwAbout.text ?? "", dob: self.birthDate, gender: txtFldGender.text ?? "", place: txtFldPlace.text ?? "",lat:lat , long: long , profile_photo: imgVwProfile, interests: arrInterstId, specialization: arrSpecilizeId,dietary: arrDietryId) {
                showSwiftyAlert("", "Profile updated successfully", true)
                self.navigationController?.popViewController(animated: true)
                self.callBack?()
            }
        }
    }
    @IBAction func actionPlace(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryOriginVC") as! CountryOriginVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = 1
        vc.callBack = { cityName,short,arrSubCategory in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectCityVC") as! SelectCityVC
            vc.modalPresentationStyle = .overFullScreen
            vc.cityName = cityName
            vc.shortCityName = short
            vc.callBack = { selectCity,lat,long,zipCode,country,placeName in
                self.txtFldPlace.text = country
                self.lat = lat ?? 0.0
                self.long = long ?? 0.0
                self.vwZipcode.isHidden = false
                self.vwAddress.isHidden = false
                self.vwCity.isHidden = false
                self.txtFldAddress.text = placeName
                self.txtFldCity.text = selectCity
                self.txtFldZipCode.text = zipCode
            }
            self.navigationController?.present(vc, animated: true)
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionInterst(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.arrInterst = arrGetInterst
        vc.isComing = 0
        vc.selectedInterstItemsId = arrInterstId
        if isSelectInterst == 0{
            vc.selectedItemsInterst =  arrInterst.map { $0.name ?? "" }
        }else{
            vc.selectedItemsInterst = arrInterstName
        }
        vc.callBack = { selectedRowsName,ids in
            self.arrInterstId.removeAll()
            self.arrInterstName.removeAll()
            self.isSelectInterst = 1
            self.arrInterstId.append(contentsOf: ids)
            self.arrInterstName.append(contentsOf: selectedRowsName)
            self.collVwInterst.reloadData()
            self.updateCollectionViewHeight()
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionDietry(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = 1
        vc.arrDietary = arrGetDietry
        vc.selectedDietryItemsId = arrDietryId
        if isSelectDietary == 0{
            vc.selectedItemsDietry =  arrDietry.map { $0.name ?? "" }
        }else{
            vc.selectedItemsDietry =  arrDietryName
        }
        vc.callBack = { selectedRow,ids in
            self.arrDietryId.removeAll()
            self.arrDietryName.removeAll()
            self.isSelectDietary = 1
            self.arrDietryId.append(contentsOf: ids)
            self.arrDietryName.append(contentsOf: selectedRow)
            self.collVwDietry.reloadData()
            self.updateCollectionViewHeight()
//            self.updateheightCollVwDietry()
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionSpecilization(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = 3
        vc.selectedSpecilizeItemsId = arrSpecilizeId
        vc.arrSpeciasliz = arrGetSpecialize
        if isSelectSpecilize == 0 {
            vc.selectedItemsSpecialize =  arrSpecialize.map { $0.name ?? "" }
        }else{
            vc.selectedItemsSpecialize =  arrSpecializeName
        }
        vc.callBack = { selectedRowss,ids in
            self.arrSpecilizeId.removeAll()
            self.arrSpecializeName.removeAll()
            self.isSelectSpecilize = 1
            self.arrSpecilizeId.append(contentsOf: ids)
            self.arrSpecializeName.append(contentsOf: selectedRowss)
            self.collVwSpecialization.reloadData()
//            self.updateheightCollVwSpecialize()
            self.updateCollectionViewHeight()
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionGender(_ sender: UIButton) {
        dismissKeyboard()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GenderVC") as! GenderVC
        vc.modalPresentationStyle = .overFullScreen
        vc.genderTxt = txtFldGender.text
        vc.callBack = { gender in
            self.txtFldGender.text = gender
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionUpload(_ sender: UIButton) {
        ImagePicker().pickImage(self) { image in
            self.imgVwProfile.image = image
        }
    }
}
//MARK: - UITextViewDelegate
extension EditProfileVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        lblTxtCount.text = "\(characterCount)/250"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
    }
}
//MARK: - UICollectionViewDelegate
extension EditProfileVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwInterst{
            if isSelectInterst == 0{
                return arrInterst.count
            }else{
                return arrInterstName.count
            }
        }else if collectionView == collVwDietry{
            if isSelectDietary == 0{
                return arrDietry.count
            }else{
                return arrDietryName.count
            }
        }else{
            if isSelectSpecilize == 0{
                return arrSpecialize.count
            }else{
                return arrSpecializeName.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwInterst{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            if isSelectInterst == 0{
                cell.lblName.text = arrInterst[indexPath.row].name ?? ""
            }else{
                cell.lblName.text = arrInterstName[indexPath.row]
            }
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteInterst), for: .touchUpInside)
            return cell
        }else if collectionView == collVwDietry{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            if isSelectDietary == 0{
                cell.lblName.text = arrDietry[indexPath.row].name ?? ""
            }else{
                cell.lblName.text = arrDietryName[indexPath.row]
            }
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteDietary), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            if isSelectSpecilize == 0{
                cell.lblName.text = arrSpecialize[indexPath.row].name ?? ""
            }else{
                cell.lblName.text = arrSpecializeName[indexPath.row]
            }
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteSpecialize), for: .touchUpInside)
            return cell
        }
    }
    @objc func actionDeleteInterst(sender:UIButton){
        if isSelectInterst == 0{
            if sender.tag < arrInterst.count {
                arrInterst.remove(at: sender.tag)
            }
            if sender.tag < arrInterstId.count {
                arrInterstId.remove(at: sender.tag)
            }
        }else{
            if sender.tag < arrInterstName.count {
                arrInterstName.remove(at: sender.tag)
            }
            if sender.tag < arrInterstId.count {
                arrInterstId.remove(at: sender.tag)
            }
        }
        collVwInterst.reloadData()
        updateCollectionViewHeight()
    }
    @objc func actionDeleteDietary(sender:UIButton){
        if isSelectDietary == 0{
            if sender.tag < arrDietry.count {
                arrDietry.remove(at: sender.tag)
            }
            if sender.tag < arrDietryId.count {
                arrDietryId.remove(at: sender.tag)
            }
        }else{
            if sender.tag < arrDietryName.count {
                arrDietryName.remove(at: sender.tag)
            }
            if sender.tag < arrDietryId.count {
                arrDietryId.remove(at: sender.tag)
            }
        }
        collVwDietry.reloadData()
        updateCollectionViewHeight()
    }
    @objc func actionDeleteSpecialize(sender:UIButton){
        if isSelectSpecilize == 0{
            if sender.tag < arrSpecialize.count {
                arrSpecialize.remove(at: sender.tag)
            }
            if sender.tag < arrSpecilizeId.count {
                arrSpecilizeId.remove(at: sender.tag)
            }
        }else{
            if sender.tag < arrSpecializeName.count {
                arrSpecializeName.remove(at: sender.tag)
            }
            if sender.tag < arrSpecilizeId.count {
                arrSpecilizeId.remove(at: sender.tag)
            }
        }
        collVwSpecialization.reloadData()
        updateCollectionViewHeight()
    }
}
