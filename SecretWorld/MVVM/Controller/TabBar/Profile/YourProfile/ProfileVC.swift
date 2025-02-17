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
    @IBOutlet weak var lblPromo: UILabel!
    @IBOutlet weak var imgVwPromo: UIImageView!
    @IBOutlet weak var btmScrollVw: NSLayoutConstraint!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblMobilenumber: UILabel!
    @IBOutlet var heightTblvw: NSLayoutConstraint!
    @IBOutlet var imgVwProfile: UIImageView!
    @IBOutlet var tblVwProfile: UITableView!
    @IBOutlet weak var btnChangePhone: UIButton!
    
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
    let deviceHasNotch = UIApplication.shared.hasNotch
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("role"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.UpdateProfileImgAndName(notification:)), name: Notification.Name("UpdateUserName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GetBankCount(notification:)), name: Notification.Name("ForBank"), object: nil)
        uiSet()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                btmScrollVw.constant = 58
            }else{
                btmScrollVw.constant = 48
            }
        }else{
            btmScrollVw.constant = -80
        }
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
        btnChangePhone.underline()
        print("role:--\(Store.role ?? "")")
        print("DAta---",Store.UserDetail)
        if Store.role == "b_user"{
            lblName.text =  Store.BusinessUserDetail?["userName"] as? String ?? ""
            lblMobilenumber.text =  "\(Store.BusinessUserDetail?["countryCode"] as? String ?? "") \(Store.BusinessUserDetail?["mobile"] as? Int ?? 0)"
            imgVwProfile.imageLoad(imageUrl: Store.BusinessUserDetail?["profileImage"] as? String ?? "")
            arrProfile.append(ProfileData(title: "Your Task", img: "Posted Gig"))
            arrProfile.append(ProfileData(title: "Your Services", img: "YourService"))
            arrProfile.append(ProfileData(title: "Analytics", img: "analysis"))
            arrProfile.append(ProfileData(title: "Info and Support", img: "info"))
            imgVwPromo.image = UIImage(named: "promoo")
            lblPromo.text = "Special offers"
            heightTblvw.constant = CGFloat(arrProfile.count*70)
        }else{
            
            lblName.text =  Store.UserDetail?["userName"] as? String ?? ""
            lblMobilenumber.text =  "\(Store.UserDetail?["countryCode"] as? String ?? "") \(Store.UserDetail?["mobile"] as? Int ?? 0)"
            imgVwProfile.imageLoad(imageUrl: Store.UserDetail?["profileImage"] as? String ?? "")
            arrProfile.append(ProfileData(title: "Your Task", img: "Posted Gig"))
            arrProfile.append(ProfileData(title: "Applied Task", img: "adService"))
            arrProfile.append(ProfileData(title: "Popups", img: "popup"))
            arrProfile.append(ProfileData(title: "Info and Support", img: "info"))
            heightTblvw.constant = CGFloat(arrProfile.count*70)
            imgVwPromo.image = UIImage(named: "promocode")
            lblPromo.text = "Promo codes"
        }
        tblVwProfile.reloadData()
    }
    //MARK: - IBAction
    @IBAction func actionProfile(_ sender: UIButton) {
        if Store.role == "b_user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            vc.isComing = true
            self.navigationController?.pushViewController(vc, animated: true)

        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewVC") as! ProfileViewVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func actionLogout(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogOutVC") as! LogOutVC
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: false)

    }
    @IBAction func actionFinance(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoAndSupportVC") as! InfoAndSupportVC
        vc.isComing = false
        vc.arrBank = self.arrBank
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionPromocode(_ sender: UIButton) {
        if Store.role == "b_user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodeVC") as! PromoCodeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    @IBAction func actionChnagephoneNumber(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
        vc.isComing = true
        self.navigationController?.pushViewController(vc, animated: true)
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
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 2
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyServicesVC") as! MyServicesVC
                vc.isSelect = 1
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoAndSupportVC") as! InfoAndSupportVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            
        }else{
            //User
            switch indexPath.row {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 2
                Store.isUserParticipantsList = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                vc.isComing = 1
                Store.isUserParticipantsList = false
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpListVC") as! PopUpListVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoAndSupportVC") as! InfoAndSupportVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
