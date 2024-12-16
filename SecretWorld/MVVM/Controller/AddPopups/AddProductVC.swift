//
//  AddProductVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 24/01/24.
//

import UIKit

class AddProductVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var collVwProductImgs: UICollectionView!
    @IBOutlet var viewUploadPhoto: UIView!
    @IBOutlet var btnDismiss: UIButton!
    @IBOutlet var lblScreenTitle: UILabel!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var viewBack: UIView!
    @IBOutlet var txtFldProductName: UITextField!
    @IBOutlet var txtFldPrice: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    //MARK: - variables
    var callBack:((_ productName:String,_ price:Int,_ isDelete:Bool,_ isEdit:Bool,_ images:[String])->())?
    var isComing = false
    var arrProducts = [Products]()
    var selectedIndex = 0
    var arrEditProducts = [AddProducts]()
    var viewModel = UploadImageVM()
    var arrProductsImages = [UIImage]()
    var isupload = false
    var arrImgsUrls:[String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        txtFldProductName.delegate = self
        txtFldPrice.delegate = self
        viewBack.layer.cornerRadius = 35
        viewBack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if isComing == true{
            lblScreenTitle.text = "Add Product"
            btnCancel.setTitle("Cancel", for: .normal)
            btnAdd.setTitle("Add", for: .normal)
            btnDismiss.isHidden = true
        }else{
            print(selectedIndex)
            lblScreenTitle.text = "Edit Product"
            btnCancel.setTitle("Delete", for: .normal)
            btnAdd.setTitle("Edit", for: .normal)
            btnDismiss.isHidden = false
            if arrEditProducts.count > 0{
                txtFldProductName.text = arrEditProducts[selectedIndex].productName ?? ""
                let price = arrEditProducts[selectedIndex].price ?? 0
                txtFldPrice.text = "\(price)"
            }
            if arrProducts.count > 0{
                txtFldProductName.text = arrProducts[selectedIndex].name ?? ""
                let price = arrProducts[selectedIndex].price ?? 0
                txtFldPrice.text = "\(price)"
            }
        }
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func actionUploadImage(_ sender: UIButton) {
        ImagePicker().pickImage(self) { image in
            self.arrProductsImages.append(image)
            self.viewModel.uploadImageApi(image: [image]) { data in
                self.arrImgsUrls?.append(contentsOf: data?.imageUrls ?? [])
                    self.collVwProductImgs.reloadData()
            }
          
            
        }

    }
    @IBAction func actionCancel(_ sender: UIButton) {
        if isComing == true{
            self.dismiss(animated: true)
         
        }else{
            self.dismiss(animated: true)
            self.callBack?("", 0, true, false, arrImgsUrls ?? [])
            
        }
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionAdd(_ sender: UIButton) {
        
        if txtFldProductName.text == "" {
            
            showSwiftyAlert("", "Please enter the product name", false)
            
        }else if txtFldPrice.text == "" {
            
            showSwiftyAlert("", "Please enter the product price", false)
            
        }else if Int(txtFldPrice.text ?? "0") ?? 0 <= 0 {
            
            showSwiftyAlert("", "Please enter valid product price", false)
            
        }else{
            if isComing == true{
                    self.dismiss(animated: true)
                    self.callBack?(self.txtFldProductName.text ?? "",
                                   Int(self.txtFldPrice.text ?? "") ?? 0,
                                   false, false, arrImgsUrls ?? [])
                
            }else{
                self.dismiss(animated: true)
                callBack?(txtFldProductName.text ?? "",
                          Int(txtFldPrice.text ?? "") ?? 0,
                          false, true, arrImgsUrls ?? [])
            }
            
            
        }
        
    }
}
//MARK: - UITextFieldDelegate
extension AddProductVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtFldProductName{
            // Define a character set of allowed characters (a-z, A-Z)
            let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
            
            // Check if the replacement string contains only allowed characters
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }else{
            let allowedCharacters = CharacterSet(charactersIn: "0123456789")
                    // Check if the replacement string contains only allowed characters
                    let characterSet = CharacterSet(charactersIn: string)
                    return allowedCharacters.isSuperset(of: characterSet)
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFldProductName.resignFirstResponder()
        txtFldPrice.becomeFirstResponder()
        return true
    }
}
//MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension AddProductVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrProductsImages.count > 0{
            return arrProductsImages.count
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImagesCVC", for: indexPath) as! ProductImagesCVC
        if arrProductsImages.count > 0{
            cell.contentView.layer.cornerRadius = 10
//            if let imageUrl = arrProductsImages[indexPath.row] as? String {
            cell.imgVwUpload.image = arrProductsImages[indexPath.row]
            //}
    }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwProductImgs.frame.size.width / 3, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Click on item at index: \(indexPath.item)")
        }
}

