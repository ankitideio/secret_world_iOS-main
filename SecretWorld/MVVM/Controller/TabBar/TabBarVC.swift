//
//  TabBarVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//
import UIKit

class TabBarVC: UIViewController{
    //MARK: - OUTLETS
    
    @IBOutlet weak var btnItinerary: UIButton!
    @IBOutlet weak var lblItinerary: UILabel!
    @IBOutlet weak var vwItinerary: UIView!
    @IBOutlet var bottomImmgVwImgAppIcon: NSLayoutConstraint!
    @IBOutlet var imgVwAppIcon: UIImageView!
    @IBOutlet var lblBusiness: UILabel!
    @IBOutlet var lblGig: UILabel!
    @IBOutlet var lblStore: UILabel!
    @IBOutlet var imgVwBusiness: UIImageView!
    @IBOutlet var imgVwGig: UIImageView!
    @IBOutlet var imgVwStore: UIImageView!
    @IBOutlet var btnBusiness: UIButton!
    @IBOutlet var btnGig: UIButton!
    @IBOutlet var btnStore: UIButton!
    @IBOutlet var viewBusiness: UIView!
    @IBOutlet var viewStore: UIView!
    @IBOutlet var viewGig: UIView!
    @IBOutlet var stackVwBtns: UIStackView!
    @IBOutlet var viewExplore: UIView!
    @IBOutlet var viewMenu: UIView!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var lblMenu: UILabel!
    @IBOutlet var btnAddService: UIButton!
    @IBOutlet var lblHome: UILabel!
    @IBOutlet var lblExplore: UILabel!
    @IBOutlet var lblChat: UILabel!
    @IBOutlet var lblProfile: UILabel!
    @IBOutlet var viewShadow: UIView!
    @IBOutlet var viewBackProfile: UIView!
    @IBOutlet var viewBackHome: UIView!
    @IBOutlet var stackVw: UIStackView!
    @IBOutlet var btnHome: UIButton!
    @IBOutlet var btnExplore: UIButton!
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var scrollVw: UIScrollView!
    @IBOutlet weak var heightBottomVw: NSLayoutConstraint!
    @IBOutlet var topShadowView: NSLayoutConstraint!
    
    //MARK: - VARIABLES
    var selectedButtonTag: Int = 0
    var viewModel = AuthVM()
    var isStatus = 0
    var isGigType = true
//    var isStoreType = true
//    var isBusinessType = true

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        uiSet()
        viewModel.verificationStatus { data in
            self.isStatus = data?.verificationStatus ?? 0
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.touchMap(notification:)), name: Notification.Name("touchMap"), object: nil)
        }
        
    }
    func uiSet(){
        let deviceHasNotch = UIApplication.shared.hasNotch
            if deviceHasNotch{
                if UIDevice.current.hasDynamicIsland {
                    heightBottomVw.constant = 114
                    topShadowView.constant = -68
                    }else{
                    heightBottomVw.constant = 104
                    topShadowView.constant = -58
                }
            
            }else{
              heightBottomVw.constant = 80
              topShadowView.constant = -80
            }
        viewShadow.layer.cornerRadius = 15
        viewShadow.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewShadow.layer.shadowRadius = 16
        viewShadow.layer.shadowOpacity = 0.25
        if Store.role == "b_user"{
            viewExplore.isHidden = true
            viewMenu.isHidden = false
            vwItinerary.isHidden = true
        }else{
            vwItinerary.isHidden = false
            viewExplore.isHidden = true
            viewMenu.isHidden = true
        }
        switch selectedButtonTag {
        case 1:
            homeSetup()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.homeSetup()
            }
        case 2:
//            exploreSetup()
            itinerarySetup()
        case 3:
            bookmarkSetup()
        case 4:
            chatSetup()
        case 5:
            profileSetup()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.profileSetup()
            }
        case 6:
            menuSetup()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.menuSetup()
            }
        default:
            break
        }
    }
    //MARK: - BUTTON ACTIONS
    func HideStackViewBtns(){
        // Hide stack view with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.stackVwBtns.transform = CGAffineTransform(translationX: 0, y: 200)
            self.stackVwBtns.alpha = 0
        }, completion: { _ in
            self.stackVwBtns.isHidden = true
            self.zoomHomeIcon(isZoomedIn: false)
        })

    }
    @IBAction func actionAddService(_ sender: UIButton) {
        sender.isEnabled = false
        viewModel.verificationStatus { data in
            self.isStatus = data?.verificationStatus ?? 0
            if self.isStatus == 0{
                sender.isEnabled = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 0
                vc.callBack = {[weak self] in
                    
                    guard let self = self else { return }
                    self.viewModel.verificationStatus { data in
                        self.isStatus = data?.verificationStatus ?? 0
                    }
                }
                self.navigationController?.present(vc, animated: false)
            }else if self.isStatus == 1{
                sender.isEnabled = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 5
                vc.callBack = {[weak self] in
                    
                    guard let self = self else { return }
                    self.viewModel.verificationStatus { data in
                        self.isStatus = data?.verificationStatus ?? 0
                    }
                }
                self.navigationController?.present(vc, animated: false)
            }else{
                sender.isEnabled = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditServiceVC") as! EditServiceVC
                vc.isComing = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func actionAdd(_ sender: UIButton) {
        
        if Store.role == "user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectServiceTypeVC") as! SelectServiceTypeVC
            vc.modalPresentationStyle = .overFullScreen
            vc.callBack = { [weak self] type in
                
                guard let self = self else { return }
                self.viewModel.verificationStatus{ data in
                    self.isStatus = data?.verificationStatus ?? 0
                    if self.isStatus == 0{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        if type == true{
                            vc.isSelect = 6
                        }else{
                            vc.isSelect = 3
                        }
                        vc.callBack = {[weak self] in
                            
                            guard let self = self else { return }
                            self.viewModel.verificationStatus{ data in
                                self.isStatus = data?.verificationStatus ?? 0
                            }
                        }
                        self.navigationController?.present(vc, animated: false)
                    }else if self.isStatus == 1{
                        //gig //popup
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 5
                        vc.callBack = {[weak self] in
                            
                            guard let self = self else { return }
                            self.viewModel.verificationStatus{ data in
                                self.isStatus = data?.verificationStatus ?? 0
                            }
                        }
                        self.navigationController?.present(vc, animated: false)
                    }else{
                        if type == true{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPopUpVC") as! AddPopUpVC
                            vc.isComing = false
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGigAddVC") as! NewGigAddVC
                            vc.isComing = true
                            vc.callBack = {
                                self.uiSet()
                            }
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            self.navigationController?.present(vc, animated: true)
        }else{
                self.viewModel.verificationStatus{ data in
                    self.isStatus = data?.verificationStatus ?? 0
                    if self.isStatus == 0{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 25
                        vc.callBack = {[weak self] in
                            
                            guard let self = self else { return }
                            self.viewModel.verificationStatus{ data in
                                self.isStatus = data?.verificationStatus ?? 0
                            }
                        }
                        self.navigationController?.present(vc, animated: false)
                    }else if self.isStatus == 1{
                        //gig //popup
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 5
                        vc.callBack = {[weak self] in
                            
                            guard let self = self else { return }
                            self.viewModel.verificationStatus{ data in
                                self.isStatus = data?.verificationStatus ?? 0
                            }
                        }
                        self.navigationController?.present(vc, animated: false)
                    }else{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGigAddVC") as! NewGigAddVC
                            vc.isComing = true
                            self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
        }
    }
    @IBAction func actionMenu(_ sender: UIButton) {
//        let deviceHasNotch = UIApplication.shared.hasNotch
//            if deviceHasNotch{
//              heightBottomVw.constant = 104
//              topShadowView.constant = 0
//            }else{
//              heightBottomVw.constant = 80
//              topShadowView.constant = 0
//            }
       
        print("\(selectedButtonTag)")
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            menuSetup()
            selectedButtonTag = sender.tag
            NotificationCenter.default.post(name: Notification.Name("CallMenuApi"), object: nil)
        }
    }
    func menuSetup(){
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*5, y: 0), animated: false)
        btnAddService.isHidden = false
        lblMenu.textColor = .app
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblExplore.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnExplore.setImage(UIImage(named: "explore"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuselect"), for: .normal)
        btnMenu.isSelected = true
        btnHome.isSelected = false
        btnExplore.isSelected = false
        btnChat.isSelected = false
        btnProfile.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    @IBAction func actionBusiness(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected{
            btnHome.isSelected = false
//            btnGig.isSelected = false
            //btnStore.isSelected = false

            isGigType = true
//            isBusinessType = false
//            isStoreType = true
            viewBusiness.backgroundColor = .app
            imgVwBusiness.image = UIImage(named: "selBB")
            lblBusiness.textColor = .white
            viewGig.backgroundColor = .white
            imgVwGig.image = UIImage(named: "noSelG")
            lblGig.textColor = .black
            
            viewStore.backgroundColor = .white
            imgVwStore.image = UIImage(named: "noSelP")
            lblStore.textColor = .black
            
            
            // Notify observers (optional)
            NotificationCenter.default.post(name: Notification.Name("businessSel"), object: nil)
            HideStackViewBtns()
//        }else{
//            HideStackViewBtns()
//        }
    }
    @IBAction func actionGig(_ sender: UIButton) {
            Store.isSelectTab = false
            btnHome.isSelected = false
            isGigType = false
//            isBusinessType = true
//            isStoreType = true
            viewGig.backgroundColor = .app
            imgVwGig.image = UIImage(named: "selG")
            lblGig.textColor = .white
            btnBusiness.isSelected = false
            btnStore.isSelected = false
            viewBusiness.backgroundColor = .white
            imgVwBusiness.image = UIImage(named: "noSelBB")
            lblBusiness.textColor = .black
            viewStore.backgroundColor = .white
            imgVwStore.image = UIImage(named: "noSelP")
            lblStore.textColor = .black
            NotificationCenter.default.post(name: Notification.Name("gigSel"), object: nil)
            HideStackViewBtns()
    }
    @IBAction func actionPopup(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected{
            
            isGigType = true
//            isBusinessType = true
//            isStoreType = false
            viewStore.backgroundColor = .app
            imgVwStore.image = UIImage(named: "selP")
            lblStore.textColor = .white
        
            btnHome.isSelected = false
//            btnBusiness.isSelected = false
//            btnGig.isSelected = false
            
            viewBusiness.backgroundColor = .white
            imgVwBusiness.image = UIImage(named: "noSelBB")
            lblBusiness.textColor = .black
            
            viewGig.backgroundColor = .white
            imgVwGig.image = UIImage(named: "noSelG")
            lblGig.textColor = .black
            
            
            NotificationCenter.default.post(name: Notification.Name("storeSel"), object: nil)
            HideStackViewBtns()
//        }else{
//            HideStackViewBtns()
//        }
        
    }

    @IBAction func actionHome(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let deviceHasNotch = UIApplication.shared.hasNotch
      
        if sender.isSelected {
            // Home button is selected
            Store.isSelectTab = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("TabBar"), object: nil)
                self.homeSetup()
                NotificationCenter.default.post(name: Notification.Name("selectHomeBtn"), object: nil)
            }

            let deviceHasNotch = UIApplication.shared.hasNotch
                if deviceHasNotch{
                    if UIDevice.current.hasDynamicIsland {
                        heightBottomVw.constant = 114
                        topShadowView.constant = -68
                        }else{
                        heightBottomVw.constant = 104
                        topShadowView.constant = -58
                    }
                
                }else{
                  heightBottomVw.constant = 80
                  topShadowView.constant = -80
                }
        } else {
            // Home button is deselected
            if deviceHasNotch {
                if UIDevice.current.hasDynamicIsland {
                    heightBottomVw.constant = 114
                    topShadowView.constant = -68
                    }else{
                    heightBottomVw.constant = 104
                    topShadowView.constant = -52
                }
            } else {
                heightBottomVw.constant = 80
                topShadowView.constant = -80
            }
            Store.isSelectTab = false
            NotificationCenter.default.post(name: Notification.Name("deSelectHomeBtn"), object: nil)
        }
        
        // Common setup for both states
        selectedButtonTag = sender.tag
        zoomHomeIcon(isZoomedIn: sender.isSelected)
        homeButtonsSetup(sender: sender.isSelected)
    }
    
    func homeButtonsSetup(sender: Bool) {
        if Store.role == "user"{
            if sender {
                // Show stack view with animation
                stackVwBtns.transform = CGAffineTransform(translationX: 0, y: 200)
                stackVwBtns.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.stackVwBtns.transform = .identity
                    self.stackVwBtns.alpha = 1
                })
            } else {
                // Hide stack view with animation
                UIView.animate(withDuration: 0.3, animations: {
                    self.stackVwBtns.transform = CGAffineTransform(translationX: 0, y: 200)
                    self.stackVwBtns.alpha = 0
                }, completion: { _ in
                    self.stackVwBtns.isHidden = true
                })
            }
        }
    }
    func zoomHomeIcon(isZoomedIn: Bool) {
        if Store.role == "user"{
            if isZoomedIn {
                // Zoom in with upward animation
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomImmgVwImgAppIcon.constant = -35 // Move upward
                    self.imgVwAppIcon.transform = CGAffineTransform(scaleX: 2.4, y: 2.4)
                    self.view.layoutIfNeeded() // Apply the constraint changes
                })
            } else {
                // Unzoom and reset position
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomImmgVwImgAppIcon.constant = -20 // Reset position
                    self.imgVwAppIcon.transform = .identity
                    self.view.layoutIfNeeded() // Apply the constraint changes
                })
            }
        }
    }

    func homeSetup(){
        scrollVw.setContentOffset(.zero, animated: false)
        btnAddService.isHidden = true
        lblHome.textColor = .app
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblExplore.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        btnAddService.isHidden = true
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnExplore.setImage(UIImage(named: "explore"), for: .normal)
        btnHome.isSelected = true
        btnMenu.isSelected = false
        btnExplore.isSelected = false
        btnChat.isSelected = false
        btnProfile.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    @IBAction func actionExplore(_ sender: UIButton) {
        //isHomeBtnSelect = true
        homeButtonsSetup(sender: false)
        self.zoomHomeIcon(isZoomedIn: false)
        let deviceHasNotch = UIApplication.shared.hasNotch
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                heightBottomVw.constant = 114
                topShadowView.constant = 0
                }else{
                heightBottomVw.constant = 104
                topShadowView.constant = 0
            }
        
        }else{
          heightBottomVw.constant = 80
          topShadowView.constant = 0
        }
        NotificationCenter.default.post(name: Notification.Name("StopTimer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ExploreApi"), object: nil)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            NotificationCenter.default.post(name: Notification.Name("SelectOther"), object: nil)
            exploreSetup()
            selectedButtonTag = sender.tag
        }
    }
    func exploreSetup(){
        btnAddService.isHidden = false
        lblExplore.textColor = .app
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*1, y: 0), animated: false)
        btnAddService.isHidden = true
        btnExplore.setImage(UIImage(named: "selectExplor 1"), for: .normal)
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnExplore.isSelected = true
        btnHome.isSelected = false
        btnChat.isSelected = false
        btnProfile.isSelected = false
        btnMenu.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    func bookmarkSetup(){
        btnAddService.isHidden = true
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblExplore.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*2, y: 0), animated: false)
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnExplore.setImage(UIImage(named: "explore"), for: .normal)
        btnHome.isSelected = false
        btnExplore.isSelected = false
        btnChat.isSelected = false
        btnProfile.isSelected = false
        btnMenu.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    @IBAction func actionChat(_ sender: UIButton) {
        homeButtonsSetup(sender: false)
        self.zoomHomeIcon(isZoomedIn: false)
     let deviceHasNotch = UIApplication.shared.hasNotch
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                heightBottomVw.constant = 114
                topShadowView.constant = 0
                }else{
                heightBottomVw.constant = 104
                topShadowView.constant = 0
            }
        
        }else{
          heightBottomVw.constant = 80
          topShadowView.constant = 0
        }
    NotificationCenter.default.post(name: Notification.Name("StopTimer"), object: nil)
     NotificationCenter.default.post(name: Notification.Name("GetMessage"), object: nil)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            NotificationCenter.default.post(name: Notification.Name("SelectOther"), object: nil)
            chatSetup()
            selectedButtonTag = sender.tag
        }
    }
    func chatSetup(){
        btnAddService.isHidden = true
        lblChat.textColor = .app
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblExplore.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*3, y: 0), animated: false)
        btnChat.setImage(UIImage(named: "selectChat"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnExplore.setImage(UIImage(named: "explore"), for: .normal)
        btnChat.isSelected = true
        btnHome.isSelected = false
        btnExplore.isSelected = false
        btnProfile.isSelected = false
        btnMenu.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    @IBAction func actionProfile(_ sender: UIButton) {
        homeButtonsSetup(sender: false)
        self.zoomHomeIcon(isZoomedIn: false)

        let deviceHasNotch = UIApplication.shared.hasNotch
            if deviceHasNotch{
                if UIDevice.current.hasDynamicIsland {
                    heightBottomVw.constant = 114
                    topShadowView.constant = 0
                    }else{
                    heightBottomVw.constant = 104
                    topShadowView.constant = 0
                }
            
            }else{
              heightBottomVw.constant = 80
              topShadowView.constant = 0
            }
        print("Token:- \(Store.authKey ?? "")")
        NotificationCenter.default.post(name: Notification.Name("ForBank"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("StopTimer"), object: nil)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            NotificationCenter.default.post(name: Notification.Name("SelectOther"), object: nil)
            profileSetup()
            selectedButtonTag = sender.tag
        }
    }
    func profileSetup(){
        
        btnAddService.isHidden = true
        lblProfile.textColor = .app
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblExplore.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*4, y: 0), animated: false)
        btnProfile.setImage(UIImage(named: "selectProfile"), for: .normal)
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnExplore.setImage(UIImage(named: "explore"), for: .normal)
        btnProfile.isSelected = true
        btnMenu.isSelected = false
        btnHome.isSelected = false
        btnExplore.isSelected = false
        btnChat.isSelected = false
        lblItinerary.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255,alpha: 1.0)
        btnItinerary.isSelected = false
        btnItinerary.setImage(UIImage(named: "grayItinerary"), for: .normal)
    }
    
    @IBAction func actionItinerary(_ sender: UIButton) {
        homeButtonsSetup(sender: false)
        self.zoomHomeIcon(isZoomedIn: false)
        let deviceHasNotch = UIApplication.shared.hasNotch
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                heightBottomVw.constant = 114
                topShadowView.constant = 0
                }else{
                heightBottomVw.constant = 104
                topShadowView.constant = 0
            }
        
        }else{
          heightBottomVw.constant = 80
          topShadowView.constant = 0
        }
        NotificationCenter.default.post(name: Notification.Name("StopTimer"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ExploreApi"), object: nil)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            NotificationCenter.default.post(name: Notification.Name("SelectOther"), object: nil)
            itinerarySetup()
            selectedButtonTag = sender.tag
        }
    }
    func itinerarySetup(){
        btnAddService.isHidden = false
        lblItinerary.textColor = .app
        lblMenu.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblHome.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblChat.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        lblProfile.textColor = UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1.0)
        scrollVw.setContentOffset(.zero, animated: false)
        scrollVw.setContentOffset(CGPoint(x: scrollVw.frame.size.width*6, y: 0), animated: false)
        btnAddService.isHidden = true
        btnItinerary.setImage(UIImage(named: "itinerary"), for: .normal)
        btnChat.setImage(UIImage(named: "chatt"), for: .normal)
        btnProfile.setImage(UIImage(named: "profiletab"), for: .normal)
        btnMenu.setImage(UIImage(named: "menuunselect"), for: .normal)
        btnItinerary.isSelected = true
        btnHome.isSelected = false
        btnChat.isSelected = false
        btnProfile.isSelected = false
        btnMenu.isSelected = false
    }
    @objc func touchMap(notification:Notification){
        homeButtonsSetup(sender: false)
        self.zoomHomeIcon(isZoomedIn: false)
    }
}
