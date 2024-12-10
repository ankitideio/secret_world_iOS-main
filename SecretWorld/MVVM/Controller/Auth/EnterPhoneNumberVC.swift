//
//  EnterPhoneNumberVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 21/12/23.
//

import UIKit
import CountryPickerView


class EnterPhoneNumberVC: UIViewController {
    // MARK: - OUTLETS
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var lblTitleWhtsUrNumber: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var countryPickerVw: CountryPickerView!
    @IBOutlet var txtFldMobileNumber: UITextField!
    
    // MARK: - variables
    var isComing = false
    var viewModel = AuthVM()
    let countriesPhoneNumbers: [(country: String, digits: Int)] = [
        ("Afghanistan", 9),
        ("Albania", 8),
        ("Algeria", 9),
        ("Andorra", 6),
        ("Angola", 9),
        ("Argentina", 10),
        ("Armenia", 8),
        ("Australia", 9),
        ("Austria", 10),
        ("Azerbaijan", 9),
        ("Bahamas", 7),
        ("Bahrain", 8),
        ("Bangladesh", 10),
        ("Barbados", 7),
        ("Belarus", 9),
        ("Belgium", 9),
        ("Belize", 7),
        ("Benin", 8),
        ("Bhutan", 8),
        ("Bolivia", 8),
        ("Bosnia and Herzegovina", 8),
        ("Botswana", 7),
        ("Brazil", 11),
        ("Brunei", 7),
        ("Bulgaria", 9),
        ("Burkina Faso", 8),
        ("Burundi", 8),
        ("Cabo Verde", 7),
        ("Cambodia", 9),
        ("Cameroon", 9),
        ("Canada", 10),
        ("Central African Republic", 8),
        ("Chad", 8),
        ("Chile", 9),
        ("China", 11),
        ("Colombia", 10),
        ("Comoros", 7),
        ("Congo (Republic)", 9),
        ("Congo (Democratic Republic)", 9),
        ("Costa Rica", 8),
        ("Croatia", 9),
        ("Cuba", 8),
        ("Cyprus", 8),
        ("Czech Republic", 9),
        ("Denmark", 8),
        ("Djibouti", 8),
        ("Dominica", 7),
        ("Dominican Republic", 10),
        ("Ecuador", 9),
        ("Egypt", 10),
        ("El Salvador", 8),
        ("Equatorial Guinea", 9),
        ("Eritrea", 7),
        ("Estonia", 8),
        ("Eswatini", 8),
        ("Ethiopia", 9),
        ("Fiji", 7),
        ("Finland", 10),
        ("France", 9),
        ("Gabon", 7),
        ("Gambia", 7),
        ("Georgia", 9),
        ("Germany", 11),
        ("Ghana", 9),
        ("Greece", 10),
        ("Grenada", 7),
        ("Guatemala", 8),
        ("Guinea", 9),
        ("Guinea-Bissau", 7),
        ("Guyana", 7),
        ("Haiti", 8),
        ("Honduras", 8),
        ("Hungary", 9),
        ("Iceland", 7),
        ("India", 10),
        ("Indonesia", 12),
        ("Iran", 10),
        ("Iraq", 10),
        ("Ireland", 9),
        ("Israel", 9),
        ("Italy", 10),
        ("Ivory Coast", 10),
        ("Jamaica", 7),
        ("Japan", 10),
        ("Jordan", 9),
        ("Kazakhstan", 10),
        ("Kenya", 10),
        ("Kiribati", 5),
        ("Kuwait", 8),
        ("Kyrgyzstan", 9),
        ("Laos", 9),
        ("Latvia", 8),
        ("Lebanon", 8),
        ("Lesotho", 8),
        ("Liberia", 8),
        ("Libya", 9),
        ("Liechtenstein", 7),
        ("Lithuania", 8),
        ("Luxembourg", 9),
        ("Madagascar", 9),
        ("Malawi", 7),
        ("Malaysia", 9),
        ("Maldives", 7),
        ("Mali", 8),
        ("Malta", 8),
        ("Marshall Islands", 7),
        ("Mauritania", 8),
        ("Mauritius", 7),
        ("Mexico", 10),
        ("Micronesia", 7),
        ("Moldova", 8),
        ("Monaco", 8),
        ("Mongolia", 8),
        ("Montenegro", 8),
        ("Morocco", 9),
        ("Mozambique", 9),
        ("Myanmar", 9),
        ("Namibia", 9),
        ("Nauru", 7),
        ("Nepal", 10),
        ("Netherlands", 9),
        ("New Zealand", 10),
        ("Nicaragua", 8),
        ("Niger", 8),
        ("Nigeria", 10),
        ("North Macedonia", 8),
        ("Norway", 8),
        ("Oman", 8),
        ("Pakistan", 10),
        ("Palau", 7),
        ("Palestine", 9),
        ("Panama", 8),
        ("Papua New Guinea", 8),
        ("Paraguay", 9),
        ("Peru", 9),
        ("Philippines", 10),
        ("Poland", 9),
        ("Portugal", 9),
        ("Qatar", 8),
        ("Romania", 9),
        ("Russia", 10),
        ("Rwanda", 9),
        ("Saint Kitts and Nevis", 7),
        ("Saint Lucia", 7),
        ("Saint Vincent and the Grenadines", 7),
        ("Samoa", 5),
        ("San Marino", 9),
        ("Sao Tome and Principe", 7),
        ("Saudi Arabia", 9),
        ("Senegal", 9),
        ("Serbia", 9),
        ("Seychelles", 7),
        ("Sierra Leone", 8),
        ("Singapore", 8),
        ("Slovakia", 9),
        ("Slovenia", 8),
        ("Solomon Islands", 7),
        ("Somalia", 8),
        ("South Africa", 9),
        ("South Korea", 10),
        ("South Sudan", 9),
        ("Spain", 9),
        ("Sri Lanka", 10),
        ("Sudan", 9),
        ("Suriname", 7),
        ("Sweden", 9),
        ("Switzerland", 9),
        ("Syria", 9),
        ("Taiwan", 9),
        ("Tajikistan", 9),
        ("Tanzania", 9),
        ("Thailand", 9),
        ("Timor-Leste", 7),
        ("Togo", 8),
        ("Tonga", 5),
        ("Trinidad and Tobago", 7),
        ("Tunisia", 8),
        ("Turkey", 10),
        ("Turkmenistan", 8),
        ("Tuvalu", 5),
        ("Uganda", 9),
        ("Ukraine", 9),
        ("United Arab Emirates", 9),
        ("United Kingdom", 10),
        ("United States", 10),
        ("Uruguay", 8),
        ("Uzbekistan", 9),
        ("Vanuatu", 7),
        ("Venezuela", 10),
        ("Vietnam", 9),
        ("Yemen", 9),
        ("Zambia", 9),
        ("Zimbabwe", 9)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                   swipeRight.direction = .right
                   view.addGestureRecognizer(swipeRight)
         uiSet()
    }
    @objc func handleSwipe() {
             navigationController?.popViewController(animated: true)
         }
    func uiSet(){
        countryPickerVw.delegate = self
        
        countryPickerVw.showCountryCodeInView = false
        if let digits = digits(for: countryPickerVw.selectedCountry.name) {
            txtFldMobileNumber.maxLength = digits
        }
        if isComing == true{
            lblTitle.text = "Change phone number"
            lblTitleWhtsUrNumber.text = "What is your new phone number? "
            lblSubtitle.text = "Enter your new phone number and we will send you a verification code"
            txtFldMobileNumber.placeholder = "Enter new phone number"
            lblPhoneNumber.text = "New Phone Number"
        }else{
            lblPhoneNumber.text = "Phone Number"
            txtFldMobileNumber.placeholder = "Enter your phone number"
            lblTitle.text = "Verification"
            lblTitleWhtsUrNumber.text = "What is your phone number?"
            lblSubtitle.text = "Enter your phone number and we will send you a verification code"
           
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardWhileClick))
                      tapGesture.cancelsTouchesInView = false
                      view.addGestureRecognizer(tapGesture)
           }
           @objc func dismissKeyboardWhileClick() {
                  view.endEditing(true)
              }
    
    // MARK: - BUTTON ACTIONS
    
    @IBAction func actionCountryPicker(_ sender: UIButton) {
        countryPickerVw.showCountriesList(from: self)
        
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        guard let phoneNumber = txtFldMobileNumber.text, !phoneNumber.isEmpty else {
            showSwiftyAlert("", "Enter your phone number", false)
            return
        }
        
        guard let countryDigits = digits(for: countryPickerVw.selectedCountry.name) else {
//            showSwiftyAlert("", "Unable to validate phone number", false)
            return
        }
        
        if phoneNumber.count < countryDigits {
            showSwiftyAlert("", "Enter a valid phone number", false)
            return
        }
            if isComing == true{
                isOtpInvalid = true
                viewModel.ChangeMobileNumberApi(mobile: txtFldMobileNumber.text ?? "", countrycode: countryPickerVw.selectedCountry.phoneCode){ data in
                    
                    showSwiftyAlert("", "Enter otp : \(data?.otp ?? "")", true)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPhoneNumberVC") as! VerifyPhoneNumberVC
                    vc.isComing = self.isComing
                    vc.phoneNumber = "\(self.txtFldMobileNumber.text ?? "")"
                    vc.countryCode = "\(self.countryPickerVw.selectedCountry.phoneCode)"
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                viewModel.SendMobileVerificationOtp(mobile: txtFldMobileNumber.text ?? "",
                                                    countrycode: countryPickerVw.selectedCountry.phoneCode,
                                                    deviceType: "IOS",
                                                    deviceId: Store.deviceToken ?? "") { data in
                    
                    showSwiftyAlert("", "Enter otp : \(data?.otp ?? "")", true)
                    Store.role = data?.newUser?.usertype ?? ""
                    
                    if Store.role == "b_user"{
                        Store.BusinessUserDetail = ["userName":data?.newUser?.name ?? "",
                                                    "profileImage":data?.newUser?.profilePhoto ?? "","userId":data?.newUser?.id ?? ""]
                        
                        if let profilePhoto = data?.newUser?.profilePhoto  as? UIImage {
                            Store.LogoImage = profilePhoto
                        }
                        Store.businessLatLong = ["lat":data?.newUser?.latitude ?? 0,"long":data?.newUser?.longitude ?? 0]
                    }else{
                        
                        Store.UserDetail = ["userName":data?.newUser?.name ?? "",
                                            "profileImage":data?.newUser?.profilePhoto ?? "","userId":data?.newUser?.id ?? ""]
                        
                        if let profilePhoto = data?.newUser?.profilePhoto  as? UIImage {
                            Store.LogoImage = profilePhoto
                        }
                        
                        print("imGE----",data?.newUser?.profilePhoto ?? "")
                        
                    }
                
                    Store.userId = data?.newUser?.id ?? ""
                   
                    Store.userLatLong = ["lat":data?.newUser?.latitude ?? 0,"long":data?.newUser?.longitude ?? 0]
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPhoneNumberVC") as! VerifyPhoneNumberVC
                        vc.isComing = self.isComing
                        vc.phoneNumber = "\(self.txtFldMobileNumber.text ?? "")"
                        vc.countryCode = "\(self.countryPickerVw.selectedCountry.phoneCode)"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            }
        
        
    }

//MARK: - CountryPickerViewDelegate
extension EnterPhoneNumberVC:CountryPickerViewDelegate{
    func digits(for countryName: String) -> Int? {
        for (country, digits) in countriesPhoneNumbers {
            if country == countryName {
                return digits
            }
        }
        return nil  // Return nil if country name is not found
    }

    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: CPVCountry){
        if let digits = digits(for: countryPickerVw.selectedCountry.name) {
            txtFldMobileNumber.maxLength = digits
            txtFldMobileNumber.text = ""
            txtFldMobileNumber.resignFirstResponder()
            view.endEditing(true)
        }
    }
    
}
