//
//  EditServiceVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 04/01/24.
//

import UIKit
import IQKeyboardManagerSwift
import AlignedCollectionViewFlowLayout

class EditServiceVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var btnAddEdit: UIButton!
    @IBOutlet var heightCollVwSubCategories: NSLayoutConstraint!
    @IBOutlet var collVwSubCategory: UICollectionView!
    @IBOutlet var lblTextCount: UILabel!
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet var viewCategory: UIView!
    @IBOutlet var txtFldAmount: UITextField!
    @IBOutlet var txtFldCategory: UITextField!
    @IBOutlet var txtvwDescription: IQTextView!
    @IBOutlet var txtFldServicename: UITextField!
    @IBOutlet var txtFldName: UITextField!
    @IBOutlet var collvwImgs: UICollectionView!
    
    //MARK: - VARIABLES
    var arrServiceDetail:Servicess?
    var editServiceDetail:GetServiceDataaa?
    var offset = 1
    var limit = 0
    var viewModel = AddServiceVM()
    var arrSelectedCategories = [Userservices]()
    var isComing = false
    var arrUploadImgs = [Any]()
    var arrDeletedImgs = [Any]()
    var dictSelectedSubcategory = [String:Any]()
    var categoryIdd = String()
    var subCategoriesIds = [String]()
    var arrSubCategories = [Subcategorylist]()
    var arrSelectedData = [String:Any]()
    var isUploading = true
    var serviceId = ""
    var isGetCategories = false
    var callBack:(()->())?
    var arrEdit = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        Store.ServiceImg = nil
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        print("arrUploadImgs:-\(arrUploadImgs)")
        uiSet()
    }
    
    @objc func handleSwipe() {
        self.navigationController?.popViewController(animated: true)
        Store.SubCategoriesId = nil
          }
    func uiSet(){
        
        txtvwDescription.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        if isComing == true{
            getCategoryApi()
//            if let image = UIImage(named: "add25") {
//                arrUploadImgs.insert(image, at: 0)
//            }
            
            if subCategoriesIds.count > 0{
                heightCollVwSubCategories.constant = 36
            }else{
                heightCollVwSubCategories.constant = 0
            }
            
            lblScreenTitle.text = "Create a Service"
            viewCategory.isHidden = false
            collVwSubCategory.isHidden = false
            lblTextCount.text = "0/250"
            btnAddEdit.setTitle("Create Service", for: .normal)
            let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
            collVwSubCategory.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
            
            let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
            collVwSubCategory.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
            
            
            if let flowLayout = collVwSubCategory.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 0, height: 36)
                flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
                
            }
        }else{
            
//            if let image = UIImage(named: "add25") {
//                arrUploadImgs.append(image)
//            }
            
            for i in editServiceDetail?.serviceImages ?? []{
                arrUploadImgs.append(i)
               
            }
            let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
            collVwSubCategory.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
            lblScreenTitle.text = "Edit Service"
            btnAddEdit.setTitle("Update", for: .normal)
            viewCategory.isHidden = true
            collVwSubCategory.isHidden = true
            txtFldServicename.text = editServiceDetail?.serviceName ?? ""
            txtFldAmount.text = "\(editServiceDetail?.price ?? 0)"
            txtFldCategory.text = editServiceDetail?.userCategories?.categoryName ?? ""
            txtvwDescription.text = editServiceDetail?.description ?? ""
            let textViewTextCount = txtvwDescription.text.count
            print("Character count: \(textViewTextCount)")
            lblTextCount.text = "\(textViewTextCount)/250"
        }
        let alignedFlowLayoutCollVwInterst = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwSubCategory.collectionViewLayout = alignedFlowLayoutCollVwInterst
        if let flowLayout = collVwSubCategory.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 36)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightSubCat = self.collVwSubCategory.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwSubCategories.constant = heightSubCat
        self.view.layoutIfNeeded()
    }
    func updateCollectionViewHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let heightSubCat = self.collVwSubCategory.collectionViewLayout.collectionViewContentSize.height
            self.heightCollVwSubCategories.constant = heightSubCat
            self.view.layoutIfNeeded()
        }
    }
    func getCategoryApi(){
        viewModel.getSelectedeCtegoriesApi{ data in
            self.arrSelectedCategories = data?.userservice ?? []
            self.isGetCategories = true
            
        }
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func actionUploadImgs(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UploadPhotosVC") as! UploadPhotosVC
        if isComing == true{
            vc.arrUploadImgs = Store.ServiceImg ?? []
        }else{
            vc.arrUploadImgs = arrUploadImgs
        }
               vc.callBack = { arrImgs in
                   self.arrUploadImgs.removeAll()
                   if self.isComing{
                       self.uiSet()
                   }
                   self.arrUploadImgs.append(contentsOf: arrImgs)
                   self.collvwImgs.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func actionAddCategory(_ sender: UIButton) {
        if isGetCategories == true{
            txtFldServicename.resignFirstResponder()
            txtFldName.resignFirstResponder()
            txtvwDescription.resignFirstResponder()
            txtFldAmount.resignFirstResponder()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryOriginVC") as! CountryOriginVC
            vc.modalPresentationStyle = .overFullScreen
            vc.isComing = 0
            vc.arrCategories = arrSelectedCategories
            vc.callBack = { categoryId,categoryName,arrSubcategory in
                
                self.categoryIdd = categoryId ?? ""
                self.subCategoriesIds.removeAll()
                self.dictSelectedSubcategory.removeAll()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceSubCategiriesVC") as! ServiceSubCategiriesVC
                vc.modalPresentationStyle = .overFullScreen
                vc.categoryId = categoryId ?? ""
                vc.arrSubCategories = arrSubcategory ?? []
                vc.arrSearchSubCategories = arrSubcategory ?? []
                vc.selectedSubCategories = Store.SubCategoriesId ?? [:]
                vc.categoryName = categoryName ?? ""
                vc.callBack = { selectSubCategoryid,categoryName in
                    self.subCategoriesIds.removeAll()
                    self.dictSelectedSubcategory.removeAll()
                    self.txtFldCategory.text = categoryName
                    guard let selectCategoryid = selectSubCategoryid else {
                        print("No selected categories")
                        return
                    }
                    for (categoryId, categoryName) in selectCategoryid {
                        self.dictSelectedSubcategory[categoryId] = categoryName
                        print("Category ID: \(categoryId), Category Name: \(categoryName)")
                        self.subCategoriesIds.append(categoryId)
                        self.collVwSubCategory.reloadData()
                        
                    }
                    self.updateCollectionViewHeight()
                    print("selectCategoryid:-\(selectCategoryid)")
                    
                }
                self.navigationController?.present(vc, animated: true)
            }
            self.navigationController?.present(vc, animated: true)
        }
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        Store.SubCategoriesId = nil
    }
    
    
    @IBAction func actionCreate(_ sender: UIButton) {
        if isComing == true{
            if arrUploadImgs.count == 1{
                showSwiftyAlert("", "Upload service images", false)
            }else if txtFldServicename.text == ""{
                showSwiftyAlert("", "Enter service name", false)
            }else if txtvwDescription.text == ""{
                showSwiftyAlert("", "Enter service description", false)
            }else if categoryIdd.count == 0{
                showSwiftyAlert("", "Select service category", false)
            }else if txtFldAmount.text == ""{
                showSwiftyAlert("", "Enter service amount", false)
            }else if Int(txtFldAmount.text ?? "0") ?? 0 <= 0 {
                showSwiftyAlert("", "Enter valid service amount", false)
            }else{
                var catSubcatArr = [[String: Any]]()
                
                var subcategoryArray = [[String: String]]()
                for subcategoryId in subCategoriesIds {
                    subcategoryArray.append(["subcategory_id": subcategoryId])
                }
                let categoryDict: [String: Any] = [
                    "category_id": categoryIdd,
                    "subcategory": subcategoryArray
                ]
                catSubcatArr.append(categoryDict)
                
                var arrImage = [Any]()
                arrImage.append(contentsOf: arrUploadImgs)
                arrImage.remove(at: 0)
                
                viewModel.AddServiceApi(serviceName: txtFldServicename.text ?? "", price: txtFldAmount.text ?? "", description: txtvwDescription.text ?? "", serviceImage: arrImage, catSubcatArr: catSubcatArr) { data ,message in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isSelect = 10
                    vc.message = message
                    vc.callBack = {
                        Store.SubCategoriesId = nil
                        SceneDelegate().tabBarMenuVCRoot()
                    }
                    self.navigationController?.present(vc, animated: false)
                }
            }
        }else{
            if arrUploadImgs.count == 1{
                showSwiftyAlert("", "Upload service images", false)
            }else if txtFldServicename.text == ""{
                showSwiftyAlert("", "Enter service name", false)
            }else if txtvwDescription.text == ""{
                showSwiftyAlert("", "Enter service description", false)
            }else if txtFldAmount.text == ""{
                showSwiftyAlert("", "Enter service amount", false)
            }else if Int(txtFldAmount.text ?? "0") ?? 0 <= 0 {
                showSwiftyAlert("", "Enter valid service amount", false)
            }else{
                
                var arrImage = [Any]()
                arrImage.append(contentsOf: arrUploadImgs)
                arrImage.remove(at: 0)
                viewModel.EdiServiceApi(service_id: serviceId, serviceName: txtFldServicename.text ?? "", price: txtFldAmount.text ?? "", description: txtvwDescription.text ?? "", serviceImage: arrImage, deletedserviceImages: arrDeletedImgs) { message in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isSelect = 10
                    vc.message = message
                    vc.callBack = {
//                        SceneDelegate().tabBarMenuVCRoot()
                        self.navigationController?.popViewController(animated: true)
                        self.callBack?()
                    }
                    self.navigationController?.present(vc, animated: false)
                }
            }
        }
    }
}
//MARK: - UITextViewDelegate
extension EditServiceVC: UITextViewDelegate{
    
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
extension EditServiceVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collvwImgs{
            return  arrUploadImgs.count
        }else{
            return dictSelectedSubcategory.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collvwImgs{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditServiceCVC", for: indexPath) as! EditServiceCVC
                cell.lblUpload.isHidden = true
                cell.imgvwPlus.isHidden = true
                cell.imgvwPlus.image = nil
                let item = arrUploadImgs[indexPath.row]
                   if let imageUrl = item as? String {
                    cell.imgVwUpload.imageLoad(imageUrl: imageUrl)
                } else if let image = item as? UIImage {
                  cell.imgVwUpload.image = image
                }
                cell.btnDelete.tag = indexPath.row
                cell.btnDelete.addTarget(self, action: #selector(actionDelete), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.numberOfLines = 1
            let values = Array(dictSelectedSubcategory.values)
            cell.lblName.text = values[indexPath.item] as? String
            cell.vwBg.layer.cornerRadius = 18
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(actionDeleteSubCategory), for: .touchUpInside)
            return cell
        }
    }
    @objc func actionDeleteSubCategory(sender:UIButton){
        let indexToRemove = sender.tag
        let keys = Array(dictSelectedSubcategory.keys)
        if indexToRemove < keys.count {
            let keyToRemove = keys[indexToRemove]
            dictSelectedSubcategory.removeValue(forKey: keyToRemove)
            Store.SubCategoriesId?.removeValue(forKey: keyToRemove)
            if dictSelectedSubcategory.count == 0{
                txtFldCategory.text = ""
            }
            collVwSubCategory.reloadData()
            DispatchQueue.main.async {
                self.updateCollectionViewHeight()
                
            }
        }
    }
    @objc func actionDelete(sender:UIButton){
        if sender.tag < arrUploadImgs.count {
            let deletedItem = arrUploadImgs.remove(at: sender.tag)
            arrDeletedImgs.append(deletedItem)
            collvwImgs.reloadData()
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditServiceVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtFldAmount {
            let allowedCharacters = "0123456789"
            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
            let typedCharacterSet = CharacterSet(charactersIn: string)
            let isAllowed = allowedCharacterSet.isSuperset(of: typedCharacterSet)
            return isAllowed
            
        } else if textField == txtFldServicename {
                // Allow only a-z and A-Z
            let allowedCharacters = CharacterSet.letters.union(.whitespaces)
            let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
            }
        
        return true
    }
}
