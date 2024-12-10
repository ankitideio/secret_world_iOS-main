//
//  CompleteSignupVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//

import UIKit
import CountryPickerView
import AlignedCollectionViewFlowLayout


class CompleteSignupVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet var heightCollVwSpecialize: NSLayoutConstraint!
    @IBOutlet var collVwSpecializ: UICollectionView!
    @IBOutlet var heightCollVwDietry: NSLayoutConstraint!
    @IBOutlet var collVwDietry: UICollectionView!
    @IBOutlet var heightCollVwInterst: NSLayoutConstraint!
    @IBOutlet var collVwInterst: UICollectionView!
    @IBOutlet var txtVwDescription: UITextView!
    @IBOutlet var lblTextCount: UILabel!
    @IBOutlet var txtFldPlace: UITextField!
    @IBOutlet var txtFldDietary: UITextField!
    @IBOutlet var txtFldIInterest: UITextField!
    @IBOutlet var txtFldSpecilization: UITextField!
    
    //MARK: - VARIABLES
    var offset = 1
    var limit = 10
    var arrInterst = [String]()
    var arrDietry = [String]()
    var arrSpecialize = [String]()
    var selectedCountry: String?
    var viewModel = AuthVM()
    var selectedInterstItemsId = [String]()
    var selectedDietryItemsId = [String]()
    var selectedSpecilizeItemsId = [String]()
    var signupDetail = [SignupModel]()
    var latitude = Double()
    var longitude = Double()
    var arrGetInterst = [Functions]()
    var arrGetDietry = [Functions]()
    var arrGetSpecialize = [Functions]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)

        uiSet()
    }
    @objc func handleSwipe() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BackPopPupVC") as! BackPopPupVC
        vc.modalPresentationStyle = .overFullScreen
        
        self.navigationController?.present(vc, animated: false)
         }

    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("Get"), object: nil)
        getFunctionApis()
        print("Store.autoLogin:-\(Store.autoLogin)")
    }
    
    @objc func methodOfReceivedNotification(notification:Notification){
        getFunctionApis()
    }
    
    func uiSet(){
        
        lblTextCount.text = "0/250"
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwInterst.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        collVwDietry.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        collVwSpecializ.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        
        let alignedFlowLayoutCollVwInterst = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwInterst.collectionViewLayout = alignedFlowLayoutCollVwInterst
        
        let alignedFlowLayoutCollVwDietry = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwDietry.collectionViewLayout = alignedFlowLayoutCollVwDietry
        
        let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwSpecializ.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
        
        
        if let flowLayout = collVwInterst.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
        }
        
        if let flowLayout1 = collVwDietry.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout1.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout1.itemSize = UICollectionViewFlowLayout.automaticSize
            collVwDietry.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
        
        if let flowLayout2 = collVwSpecializ.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout2.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout2.itemSize = UICollectionViewFlowLayout.automaticSize
            collVwSpecializ.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardWhileClick))
                      tapGesture.cancelsTouchesInView = false
                      view.addGestureRecognizer(tapGesture)
           }
           @objc func dismissKeyboardWhileClick() {
                  view.endEditing(true)
              }
    func getFunctionApis(){
        
        
        viewModel.UserFunstionsListApi(type: "Interests",offset:offset,limit: limit, search: "") { data in
            self.arrGetInterst.removeAll()
            self.arrGetInterst.append(contentsOf: data?.data ?? [])
            
        }
        
        viewModel.UserFunstionsListApi(type: "Dietary Preferences",offset:offset,limit: limit, search: "") { data in
            self.arrGetDietry.removeAll()
            self.arrGetDietry.append(contentsOf: data?.data ?? [])
            
        }
        
        viewModel.UserFunstionsListApi(type: "Specialization",offset:offset,limit: limit, search: "") { data in
            self.arrGetSpecialize.removeAll()
            self.arrGetSpecialize.append(contentsOf: data?.data ?? [])
            
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightInterest = self.collVwInterst.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwInterst.constant = heightInterest
        let heightDietry = self.collVwDietry.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwDietry.constant = heightDietry
        let heightSpelize = self.collVwSpecializ.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwSpecialize.constant = heightSpelize
        self.view.layoutIfNeeded()
      }
    func updateCollectionViewHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
          let heightInterest = self.collVwInterst.collectionViewLayout.collectionViewContentSize.height
          self.heightCollVwInterst.constant = heightInterest
          let heightDietry = self.collVwDietry.collectionViewLayout.collectionViewContentSize.height
          self.heightCollVwDietry.constant = heightDietry
          let heightSpelize = self.collVwSpecializ.collectionViewLayout.collectionViewContentSize.height
          self.heightCollVwSpecialize.constant = heightSpelize
          self.view.layoutIfNeeded()
        }
      }
    //MARK: - Button Actions
    @IBAction func actionSpecilize(_ sender: UIButton) {
        txtVwDescription.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.selectedItemsSpecialize = arrSpecialize
        vc.selectedSpecilizeItemsId = selectedSpecilizeItemsId
        vc.isComing = 3
        vc.arrSpeciasliz = arrGetSpecialize
        vc.callBack = { selectedRowss,ids in
            self.arrSpecialize.removeAll()
            self.arrSpecialize.append(contentsOf: selectedRowss )
            
            self.selectedSpecilizeItemsId.removeAll()
            self.selectedSpecilizeItemsId.append(contentsOf: ids )
            
            self.collVwSpecializ.reloadData()
            self.updateCollectionViewHeight()
            
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionInterst(_ sender: UIButton) {
        txtVwDescription.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.selectedItemsInterst = arrInterst
        vc.selectedInterstItemsId = selectedInterstItemsId
        vc.isComing = 0
        vc.arrInterst = arrGetInterst
        vc.offset = offset
        vc.limit = limit
        vc.callBack = { selectedRows,ids in
            self.arrInterst.removeAll()
            self.arrInterst.append(contentsOf: selectedRows )
            
            self.selectedInterstItemsId.removeAll()
            self.selectedInterstItemsId.append(contentsOf: ids )
            
            self.collVwInterst.reloadData()
            self.updateCollectionViewHeight()
            
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionPlace(_ sender: UIButton) {
        txtVwDescription.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryOriginVC") as! CountryOriginVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = 1
        vc.callBack = { countryName,shortname,arrSubCategory in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectCityVC") as! SelectCityVC
            vc.modalPresentationStyle = .overFullScreen
            vc.shortCityName = shortname
            vc.callBack = { selectCity,lat,long in
                self.latitude = lat ?? 0.0
                self.longitude = long ?? 0.0
                self.txtFldPlace.text = "\(selectCity ?? "")"
                
            }
            self.navigationController?.present(vc, animated: true)
        }
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func actionDietary(_ sender: UIButton) {
        txtVwDescription.resignFirstResponder()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DietarypreferencesVC") as! DietarypreferencesVC
        vc.modalPresentationStyle = .overFullScreen
        vc.selectedItemsDietry = arrDietry
        vc.selectedDietryItemsId = selectedDietryItemsId
        vc.isComing = 1
        vc.arrDietary = arrGetDietry
        vc.callBack = { selectedRow,ids in
            
            self.arrDietry.removeAll()
            self.arrDietry.append(contentsOf: selectedRow )
            
            self.selectedDietryItemsId.removeAll()
            self.selectedDietryItemsId.append(contentsOf: ids )
            
            self.collVwDietry.reloadData()
            self.updateCollectionViewHeight()
            
        }
        self.navigationController?.present(vc, animated: true)
        
    }
    @IBAction func actionBack(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BackPopPupVC") as! BackPopPupVC
        vc.modalPresentationStyle = .overFullScreen
        
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func actionSignup(_ sender: UIButton) {
        
        
        if txtVwDescription.text == ""{
            showSwiftyAlert("", "This field cannot be empty. Tell us a bit about yourself", false)
        }else if arrInterst.isEmpty{
            
            showSwiftyAlert("", "Please select at least one interest", false)
            
        }else if arrDietry.isEmpty{
            
            showSwiftyAlert("", "Please select your dietary preferences", false)
            
        }else if arrSpecialize.isEmpty{
            
            showSwiftyAlert("", "Please select your specialization", false)
            
        }else if txtFldPlace.text == ""{
            
            showSwiftyAlert("", "Please specify your place of origin to continue", false)
            
        }else{
            
            
            viewModel.signUpApi(about: txtVwDescription.text ?? "",
                                interests: selectedInterstItemsId,
                                specialization: selectedSpecilizeItemsId,
                                dietary: selectedDietryItemsId,
                                place: txtFldPlace.text ?? "",
                                lat: latitude,
                                long: longitude, deviceId: Store.deviceToken ?? "") { data in
                Store.autoLogin = data?.user?.profileStatus
                Store.userId = data?.user?.id ?? ""

                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreatAcSuccessVC") as! CreatAcSuccessVC
                vc.modalPresentationStyle = .overFullScreen
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
        
        
    }
    
    
    
}
//MARK: - UITextViewDelegate
extension CompleteSignupVC: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        let characterCount = textView.text.count
        lblTextCount.text = "\(characterCount)/250"
        
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 250
        
    }
}
//MARK: - UICollectionViewDelegate
extension CompleteSignupVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwInterst{
            return arrInterst.count
        }else if collectionView == collVwDietry{
            return arrDietry.count
        }else{
            return arrSpecialize.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwInterst{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrInterst[indexPath.row]
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteInterst), for: .touchUpInside)
            
            return cell
        }else if collectionView == collVwDietry{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrDietry[indexPath.row]
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteDietary), for: .touchUpInside)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrSpecialize[indexPath.row]
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteSpecialize), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func actionDeleteInterst(sender:UIButton){
        
        if sender.tag < arrInterst.count {
            arrInterst.remove(at: sender.tag)
            collVwInterst.reloadData()
            updateCollectionViewHeight()
        }
        
        if sender.tag < selectedInterstItemsId.count {
            selectedInterstItemsId.remove(at: sender.tag)
            collVwInterst.reloadData()
            updateCollectionViewHeight()
        }
        
    }
    @objc func actionDeleteDietary(sender:UIButton){
        if sender.tag < arrDietry.count {
            arrDietry.remove(at: sender.tag)
            
            collVwDietry.reloadData()
            updateCollectionViewHeight()
        }
        if sender.tag < selectedDietryItemsId.count {
            selectedDietryItemsId.remove(at: sender.tag)
            
            collVwDietry.reloadData()
            updateCollectionViewHeight()
        }
    }
    @objc func actionDeleteSpecialize(sender:UIButton){
        if sender.tag < arrSpecialize.count{
            arrSpecialize.remove(at: sender.tag)
            
            collVwSpecializ.reloadData()
            updateCollectionViewHeight()
        }
        if sender.tag < selectedSpecilizeItemsId.count{
            selectedSpecilizeItemsId.remove(at: sender.tag)
            
            collVwSpecializ.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    
    
    
    
}
