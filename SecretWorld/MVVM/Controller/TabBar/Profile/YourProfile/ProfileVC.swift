//
//  ProfileVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//

import UIKit

//MARK: - PROFILEDATA

struct ProfileData{
    let title:String?
    let img:String?
    init(title: String?, img: String?) {
        self.title = title
        self.img = img
    }
}
class ProfileVC: UIViewController {
    //MARK: - OUTLEST
    @IBOutlet var lblName: UILabel!
    @IBOutlet var heightTblvw: NSLayoutConstraint!
    @IBOutlet var imgVwProfile: UIImageView!
    @IBOutlet var tblVwProfile: UITableView!
    
    //MARK: - VARIABLES
    var arrProfile = [ProfileData]()
    var viewModel = UserProfileVM()
    var viewModelBusiness = BusinessProfileVM()
    var arrInterst = [Interest]()
    var arrDietry = [DietaryPreference]()
    var arrSpecialize = [Specialization]()
    var businessUserProfile:[UserProfiles]?
    var openingHour:[OpeningHourr]?
    var isUserParticipantsList = false
    var viewModelBank = PaymentVM()
    var arrBank = [BankAccountDetailData]()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("role"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateProfileImgAndName(notification:)), name: Notification.Name("UpdateUserName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GetBankCount(notification:)), name: Notification.Name("ForBank"), object: nil)
        uiSet()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getBankApi()
    }
    @objc func GetBankCount(notification: Notification) {
       getBankApi()
    }
    func getBankApi(){
        
        WebService.hideLoader()
        viewModelBank.getBankDetailsApi { data in
            self.arrBank = data?.data ?? []
        }

    }

    @objc func UpdateProfileImgAndName(notification: Notification) {
        uiSet()
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        uiSet()
    }
    
    func uiSet(){
        
        
        arrProfile.removeAll()
        
        print("role:--\(Store.role ?? "")")
        if Store.role == "b_user"{
            lblName.text =  Store.BusinessUserDetail?["userName"] as? String ?? ""
            imgVwProfile.imageLoad(imageUrl: Store.BusinessUserDetail?["profileImage"] as? String ?? "")
            arrProfile.append(ProfileData(title: "Your profile", img: "profl"))
            arrProfile.append(ProfileData(title: "Change phone number", img: "Change phone number"))
            arrProfile.append(ProfileData(title: "Your Services", img: "YourService"))
            arrProfile.append(ProfileData(title: "Your Task", img: "adService"))
            arrProfile.append(ProfileData(title: "Help Center", img: "Help Center"))
            arrProfile.append(ProfileData(title: "Verify Promo Code", img: "VerifyPromo"))
           // arrProfile.append(ProfileData(title: "Popups", img: "popup"))
            arrProfile.append(ProfileData(title: "Analytics", img: "analysis"))
            arrProfile.append(ProfileData(title: "Bank", img: "bank"))
            arrProfile.append(ProfileData(title: "Transaction History", img: "history"))
            arrProfile.append(ProfileData(title: "Wallet", img: "wallet"))
            arrProfile.append(ProfileData(title: "Contact us", img: "Contact us"))
            arrProfile.append(ProfileData(title: "About us", img: "About us"))
            arrProfile.append(ProfileData(title: "Privacy Policy", img: "Privacy Policy"))
            arrProfile.append(ProfileData(title: "Logout", img: "Logout"))
            heightTblvw.constant = CGFloat(arrProfile.count*70)
        }else{
            
            lblName.text =  Store.UserDetail?["userName"] as? String ?? ""
            imgVwProfile.imageLoad(imageUrl: Store.UserDetail?["profileImage"] as? String ?? "")
            arrProfile.append(ProfileData(title: "Your profile", img: "profl"))
            arrProfile.append(ProfileData(title: "Change phone number", img: "Change phone number"))
            arrProfile.append(ProfileData(title: "Applied Task", img: "adService"))
            arrProfile.append(ProfileData(title: "Posted Task", img: "Posted Gig"))
            arrProfile.append(ProfileData(title: "Promo Codes", img: "promoo"))
            arrProfile.append(ProfileData(title: "Popups", img: "popup"))
            arrProfile.append(ProfileData(title: "Analytics", img: "analysis"))
            arrProfile.append(ProfileData(title: "Bank", img: "bank"))
            arrProfile.append(ProfileData(title: "Transaction History", img: "history"))
            arrProfile.append(ProfileData(title: "Wallet", img: "wallet"))
            arrProfile.append(ProfileData(title: "Help Center", img: "Help Center"))
            arrProfile.append(ProfileData(title: "Contact us", img: "Contact us"))
            arrProfile.append(ProfileData(title: "About us", img: "About us"))
            arrProfile.append(ProfileData(title: "Privacy Policy", img: "Privacy Policy"))
            arrProfile.append(ProfileData(title: "Logout", img: "Logout"))
            heightTblvw.constant = CGFloat(arrProfile.count*70)
        }
        tblVwProfile.reloadData()
    }
    
}
//MARK: - TABLEVIEW DELEGATE AND DATASOURCE

extension ProfileVC: UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrProfile.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as! ProfileTVC
        cell.imgVwTitle.image = UIImage(named: arrProfile[indexPath.row].img ?? "")
        cell.lbltitle.text = arrProfile[indexPath.row].title ?? ""
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //business
        if Store.role == "b_user"{
            switch indexPath.row {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            case 2:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyServicesVC") as! MyServicesVC
                vc.isSelect = 1
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 3:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 2
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 4:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HelpCenterVC") as! HelpCenterVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 5:
                let vc = storyboard?.instantiateViewController(withIdentifier: "VerifyPromoVC") as! VerifyPromoVC
                navigationController?.pushViewController(vc, animated: true)
                
            case 6:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 7:
                if arrBank.count > 0{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BankVC") as! BankVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddBankVC") as! AddBankVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            case 8:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 9:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 10:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            case 11:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
                vc.isComing = false
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            case 12:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 13:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogOutVC") as! LogOutVC
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: false)
                
            default:
                
                break
            }
            
        }else{
            //User
            
            switch indexPath.row {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewVC") as! ProfileViewVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            case 2:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 1
                Store.isUserParticipantsList = false
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 3:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 2
                Store.isUserParticipantsList = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 4:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodeVC") as! PromoCodeVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 5:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpListVC") as! PopUpListVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 6:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 7:
                if arrBank.count > 0{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BankVC") as! BankVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddBankVC") as! AddBankVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 8:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 9:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 10:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HelpCenterVC") as! HelpCenterVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 11:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 12:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
                vc.isComing = false
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 13:
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as! PrivacyPolicyVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 14:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogOutVC") as! LogOutVC
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: false)
                
            default:
                
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
