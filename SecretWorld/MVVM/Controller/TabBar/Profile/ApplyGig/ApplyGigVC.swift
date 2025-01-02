//
//  ApplyGigVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 03/01/24.
//

import UIKit
import FXExpandableLabel
import SideMenu
import MapboxMaps
import Solar
import AlignedCollectionViewFlowLayout

class ApplyGigVC: UIViewController, UIGestureRecognizerDelegate, SideMenuNavigationControllerDelegate {
    //MARK: - OUTLEST
    @IBOutlet weak var lblTotalParticipant: UILabel!
    @IBOutlet weak var widthGigType: NSLayoutConstraint!
    @IBOutlet weak var lblGigType: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSafetyTips: UILabel!
    @IBOutlet weak var lblInstruction: UILabel!
    @IBOutlet weak var lblTaskDescription: UILabel!
    @IBOutlet weak var lblGigExperience: UILabel!
    @IBOutlet weak var lblGigCategory: UILabel!
    @IBOutlet weak var lblGigDuration: UILabel!
    @IBOutlet weak var lblGigDate: UILabel!
    @IBOutlet weak var lblGigTime: UILabel!
    @IBOutlet weak var mapVw: MapView!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet var viewCompletegigMsg: UIView!
    @IBOutlet var viewSeprator: UIView!
    @IBOutlet var viewServiceProvider: UIView!
    @IBOutlet var lblPrticipansCount: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblProviderName: UILabel!
    @IBOutlet var imgVwProvider: UIImageView!
    @IBOutlet var lblServiceProvider: UILabel!
    @IBOutlet var lblPlace: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgVwTitle: UIImageView!
    @IBOutlet var lblreview: UILabel!
    @IBOutlet var heightViewReviewTile: NSLayoutConstraint!
    @IBOutlet var heightTllvwHeight: NSLayoutConstraint!
    @IBOutlet var heightviewCompleteMsg: NSLayoutConstraint!
    @IBOutlet var btnApply: UIButton!
    @IBOutlet var btnParticipants: UIButton!
    @IBOutlet var btnMore: UIButton!
    @IBOutlet var tblVwReiew: UITableView!
    @IBOutlet weak var collVwTools: UICollectionView!
    @IBOutlet weak var collVwSkills: UICollectionView!
    @IBOutlet weak var heightCollVwTools: NSLayoutConstraint!
    @IBOutlet weak var heightCollVwSkill: NSLayoutConstraint!
    
    //MARK: - VARIABLES
    var arrCompleteParticipants = [GetRequestData]()
    var isComing = 0
    var isLabelExpanded = false
    var gigId = ""
    var viewModel = AddGigVM()
    var BusinessUserDetail:UserDetailes?
    var userDetail:UserDetailses?
    var userGigDetail:GetUserGigData?
    var businessGigDetail:GetGigDetailData?
    var userGigStatus:Int?
    var businessGigStatus:Int?
    var userId = ""
    var arrUserReview = [Reviews]()
    var arrBusinessReview = [ReviewGigBuser]()
    var gigUserType = ""
    var heightDescription = 0
    var reviewHeight = 0
    var callBack:(()->())?
    var promoCodeDetail:PromoCodes?
    var providerUserId = ""
    var paymentStatus = 0
    var price = 0
    var matchId = false
    var participantsId = ""
    var walletAmount = 0
    var textAbout = ""
    var arrDetail = [GroupChatModel]()
    var participantCount = 0
    var gigUserId = ""
    var sideMenu: SideMenuNavigationController?
    var groupId = ""
    var isReviewNil:Bool?
    private var solar: Solar?
    var arrSkill = [Skills]()
    var arrCategory = [Skills]()
    var arrTools = [String]()
    var customAnnotations: [ClusterPoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiData()
    }
    
    func uiData(){
        sideMenu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
         sideMenu?.sideMenuDelegate = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)

        imgVwTitle.layer.cornerRadius = 15
        imgVwTitle.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        let nibNearBy = UINib(nibName: "ReviewTVC", bundle: nil)
        tblVwReiew.register(nibNearBy, forCellReuseIdentifier: "ReviewTVC")
        tblVwReiew.estimatedRowHeight = 80
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwTools.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        collVwSkills.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        let alignedFlowLayoutCollVwDietry = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwTools.collectionViewLayout = alignedFlowLayoutCollVwDietry
        
        let alignedFlowLayoutCollVwSpecializ = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collVwSkills.collectionViewLayout = alignedFlowLayoutCollVwSpecializ
        
        
        if let flowLayout = collVwTools.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
        }
        
        if let flowLayout1 = collVwSkills.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout1.estimatedItemSize = CGSize(width: 0, height: 37)
            flowLayout1.itemSize = UICollectionViewFlowLayout.automaticSize
            //collVwSkills.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightInterest = self.collVwTools.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwTools.constant = heightInterest
        let heightDietry = self.collVwSkills.collectionViewLayout.collectionViewContentSize.height
        self.heightCollVwSkill.constant = heightDietry
        self.view.layoutIfNeeded()
      }
    @objc func handleSwipe() {
        self.navigationController?.popViewController(animated: true)
        callBack?()
           }

    override func viewWillAppear(_ animated: Bool) {
        uiSet()
        getGigChat()
        print("AuthKey------",Store.authKey ?? "")
    }
    
    override func viewWillLayoutSubviews() {
        self.heightTllvwHeight.constant = self.tblVwReiew.contentSize.height+10
        
        print("ReviewHeight------",self.heightTllvwHeight.constant)
        NotificationCenter.default.post(name: Notification.Name("AddReview"), object: nil)
    }
    func uiSet(){
        if let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: myCurrentLat, longitude: myCurrentLong)) {
            self.solar = solar
            let isDaytime = solar.isDaytime
            print(isDaytime ? "It's day time!" : "It's night time!")
            if isDaytime{
                if let styleURL = URL(string: "mapbox://styles/kevinzhang23a/cm2bod8mi00qg01pgepsohjq0") {
                    mapVw.mapboxMap.loadStyleURI(StyleURI(url: styleURL) ?? .light)
                }

            }else{
        if let styleURL = URL(string: "mapbox://styles/kevinzhang23a/cm2bod8mi00qg01pgepsohjq0") {
                           mapVw.mapboxMap.loadStyleURI(StyleURI(url: styleURL) ?? .light)
                       }
            }
            }
        mapVw.ornaments.scaleBarView.isHidden = true
        mapVw.ornaments.logoView.isHidden = true
        mapVw.ornaments.attributionButton.isHidden = true
        
        tblVwReiew.estimatedRowHeight = 100
        tblVwReiew.rowHeight = UITableView.automaticDimension
        if isComing == 1{
            //Business
          
            heightTllvwHeight.constant = 0
            heightviewCompleteMsg.constant = 0
            viewServiceProvider.isHidden = true
            viewSeprator.isHidden = true
            viewCompletegigMsg.isHidden = true
            tblVwReiew.isHidden = false
            getBusinessGigDetailApi()
            getCompleteParticipants(loader: false)
        }else{
            //User
          
            heightTllvwHeight.constant = 0
            heightviewCompleteMsg.constant = 0
            viewServiceProvider.isHidden = false
            viewSeprator.isHidden = false
            getUserGigDetailApi()
        }
    }
    func getCompleteParticipants(loader: Bool) {
        viewModel.GetCompleteGigParticipantsListApi(loader: loader, gigId: gigId) { data in
            self.arrCompleteParticipants = data ?? []
            for i in data ?? [] {
                self.participantsId = i.applyuserID ?? ""
            }
            if let participants = data, participants.count > 0 {
                if participants.count > 1 {
                    self.isReviewNil = false
                } else {
                    if participants[0].review == nil {
                        self.isReviewNil = false
                    } else {
                        self.isReviewNil = true
                    }
                }
            } else {
                self.isReviewNil = false
            }
        }
    }
    func getUserGigDetailApi(){
        
        viewModel.GetUserGigDetailApi(gigId: gigId) { data in
            let clusterManager = ClusterManager(mapView: self.mapVw)
            clusterManager.removeClusters()
            self.customAnnotations.removeAll()
            self.arrSkill.removeAll()
            self.arrTools.removeAll()
            self.arrCategory.removeAll()
            self.arrCategory.append(Skills(id: data?.gig?.category?.id ?? "", name: data?.gig?.category?.name ?? ""))
            for i in data?.gig?.skills ?? []{
                self.arrSkill.append(Skills(id: i.id ?? "", name: i.name ?? ""))
            }
            self.arrTools = data?.gig?.tools ?? []
            self.collVwTools.reloadData()
            self.collVwSkills.reloadData()
            self.lblTitle.text = data?.gig?.title ?? ""
            self.lblPlace.text = data?.gig?.place ?? ""
          
            self.lblGigDuration.text = data?.gig?.serviceDuration ?? ""
            self.lblGigCategory.text = data?.gig?.category?.name ?? ""
            self.lblGigExperience.text = data?.gig?.experience ?? ""
            self.lblTaskDescription.text = data?.gig?.about ?? ""
            self.lblSafetyTips.text = data?.gig?.safetyTips ?? ""
            self.lblPrice.text = "$\(data?.gig?.price ?? 0)"
            self.lblInstruction.text = data?.gig?.description ?? ""
            if data?.gig?.distance ?? 0 > 0{
                let formattedNumber = String(format: "%.0f", data?.gig?.distance ?? 0.0)
                self.lblDistance.text = "\(formattedNumber)Km away from you"
            }else{
                let formattedNumber = String(format: "%.1f", data?.gig?.distance ?? 0.0)
                self.lblDistance.text = "\(formattedNumber)Km away from you"
            }
            for i in data?.reviews ?? []{
                if Store.userId == i.user?.id{
                    self.matchId = true
                }
            }
            self.gigId = data?.id ?? ""
            
            self.providerUserId = data?.gig?.user?.id ?? ""
            self.gigUserId = data?.gig?.user?.id ?? ""
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: data?.gig?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd/MM/yy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.lblGigDate.text = formattedDate
            }
            if let time = isoDateFormatter.date(from: data?.gig?.startTime ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "hh:mm a"
                let formattedDate = displayDateFormatter.string(from: time)
                self.lblGigTime.text = formattedDate
            }
            
            self.mapVw.mapboxMap.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: data?.gig?.lat ?? 0, longitude: data?.gig?.long ?? 0),zoom: 11,bearing: 0,pitch: 0))
            self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: data?.gig?.lat ?? 0, longitude: data?.gig?.long ?? 0 ), price: data?.gig?.price ?? 0, seen: 2))
            clusterManager.addClusters(with: self.customAnnotations)

            self.userGigDetail = data
            self.promoCodeDetail = data?.promoCodes
            self.arrUserReview.removeAll()
            self.arrUserReview.append(contentsOf: data?.reviews ?? [])
            self.participantCount = data?.appliedParticipants ?? 0
            if data?.reviews?.count ?? 0 > 0{
                self.lblreview.isHidden = false
            }else{
              self.lblreview.isHidden = true
             
            }
            if data?.gig?.type == "worldwide"{
                self.lblGigType.text = "(WorldWide)"
                self.widthGigType.constant = 96
            }else{
                self.lblGigType.text = "(Local)"
                self.widthGigType.constant = 56
            }
            self.btnMore.isHidden = true
            self.userId = data?.gig?.user?.id ?? ""
            self.gigUserType = data?.gig?.usertype ?? ""
            self.userDetail = data?.gig?.user
            
            self.userGigStatus = data?.status
            self.imgVwProvider.imageLoad(imageUrl: data?.gig?.user?.profilePhoto ?? "")
            self.lblProviderName.text = data?.gig?.user?.name ?? ""
            
            if data?.gig?.image == "" || data?.gig?.image == nil{
                self.imgVwTitle.image = UIImage(named: "dummy")
                self.mapVw.isHidden = false
            }else{
                self.imgVwTitle.imageLoad(imageUrl: data?.gig?.image ?? "")
                self.mapVw.isHidden = true
            }

            
//            self.lblAbout.text = data?.gig?.about ?? ""
            self.textAbout = data?.gig?.about ?? ""
            self.lblPlace.text = data?.gig?.place ?? ""
            
              
            
            let participant = (Int(data?.gig?.totalParticipants ?? "") ?? 0) - (Int(data?.gig?.participants ?? "") ?? 0)
            
   
            self.lblTotalParticipant.text = "\(participant)/\(data?.gig?.totalParticipants ?? "") Participants"
            self.lblPrticipansCount.text = "\(participant)"
            
            self.lblTitle.text = data?.gig?.title ?? ""

            if data?.gig?.paymentTerms == 0{
                self.lblPrice.text = "$\(data?.gig?.price ?? 0) Fixed"
            }else{
                self.lblPrice.text = "$\(data?.gig?.price ?? 0) Hourly"
            }
          
           
            
            if data?.gig?.usertype == "user"{
                if data?.status == 0{
                    self.btnApply.setTitle("Requested", for: .normal)
                    self.btnApply.backgroundColor =  UIColor(red: 255/255, green: 230/255, blue: 182/255, alpha: 1.0)
                    self.btnApply.setTitleColor(UIColor(red: 255/255, green: 178/255, blue: 30/255, alpha: 1.0), for: .normal)
                    self.btnApply.isUserInteractionEnabled = false
                    self.btnMore.isHidden = true
                }else  if data?.status == 1{
                    self.btnApply.isHidden = true
                    self.btnApply.setTitle("", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.clear
                    self.btnApply.setTitleColor(UIColor.clear, for: .normal)
                    self.btnMore.isHidden = true
                    self.btnApply.isUserInteractionEnabled = false
                    self.btnChat.isHidden = false
                }else if data?.status == 2{
                    
                    //complete
                    self.btnChat.isHidden = true
                    self.btnMore.isHidden = true
                    if data?.promoCodes?.isViewed == false{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodePopUpVC") as! PromoCodePopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.promoCodeDetail = self.promoCodeDetail
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            self.getUserGigDetailApi()
                        }
                        self.navigationController?.present(vc, animated: false)
                        
                    }else{
                        if data?.isReview == true{
                            
                            self.btnApply.isHidden = false
                         
                            self.heightviewCompleteMsg.constant = 0
                       
                            self.btnApply.setTitle("Update review", for: .normal)
                        }else{
                            
                            self.btnApply.isHidden = false
                       
                            self.btnApply.backgroundColor =  UIColor.app
                            self.btnApply.setTitleColor(UIColor.white, for: .normal)
                            self.btnMore.isHidden = true
                            self.heightviewCompleteMsg.constant = 100
                          
                            self.btnApply.setTitle("Add review", for: .normal)


                        }
                    }
                }else{
                    if Store.userId == data?.gig?.user?.id ?? ""{
                        self.btnApply.isHidden = true
                        self.btnApply.setTitle("", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.clear
                        self.btnApply.setTitleColor(UIColor.clear, for: .normal)
                    }else{
                        self.btnApply.isHidden = false
                        self.btnApply.setTitle("Apply", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.app
                        self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    }
                   
                  
                    self.btnMore.isHidden = true
                }
            }else{
                
                if data?.status == 0{
                    self.btnApply.setTitle("Requested", for: .normal)
                    self.btnApply.backgroundColor =  UIColor(red: 255/255, green: 230/255, blue: 182/255, alpha: 1.0)
                    self.btnApply.setTitleColor(UIColor(red: 255/255, green: 178/255, blue: 30/255, alpha: 1.0), for: .normal)
                    self.btnApply.isUserInteractionEnabled = false
                    self.btnMore.isHidden = true
                }else  if data?.status == 1{
                    self.btnApply.isHidden = true
                    self.btnApply.setTitle("", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.clear
                    self.btnApply.setTitleColor(UIColor.clear, for: .normal)
                    self.btnMore.isHidden = true
                    self.btnApply.isUserInteractionEnabled = false
                    self.btnChat.isHidden = false
                }else if data?.status == 2{
                    
                    //complete
                    self.btnChat.isHidden = true
                    self.btnMore.isHidden = true
                    if data?.promoCodes?.isViewed == false{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodePopUpVC") as! PromoCodePopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.promoCodeDetail = self.promoCodeDetail
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            self.getUserGigDetailApi()
                        }
                        self.navigationController?.present(vc, animated: false)
                        
                    }else{
                        if data?.isReview == true{
                        
                            self.btnApply.isHidden = true
                            self.btnMore.isHidden = true
                            self.heightviewCompleteMsg.constant = 0
                        
                            self.btnApply.setTitle("Update review", for: .normal)
                          
                        }else{
                            
                            self.btnApply.isHidden = false
                        
                            self.btnApply.backgroundColor =  UIColor.app
                            self.btnApply.setTitleColor(UIColor.white, for: .normal)
                            self.btnMore.isHidden = true
                            self.heightviewCompleteMsg.constant = 100
                          
                            self.btnApply.setTitle("Add review", for: .normal)

                        }
                    }
                    
                }else{
                    if Store.userId == data?.gig?.user?.id ?? ""{
                        self.btnApply.isHidden = true
                        self.btnApply.setTitle("", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.clear
                        self.btnApply.setTitleColor(UIColor.clear, for: .normal)
                    }else{
                        self.btnApply.isHidden = false
                        self.btnApply.setTitle("Apply", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.app
                        self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    }
                    self.btnMore.isHidden = true
                }
            }
            self.tblVwReiew.reloadData()
            self.tblVwReiew.invalidateIntrinsicContentSize()
        }
    }
    func getBusinessGigDetailApi(){
        
        viewModel.GetBuisnessGigDetailApi(gigId: gigId) { data in
            let clusterManager = ClusterManager(mapView: self.mapVw)
            clusterManager.removeClusters()
            self.customAnnotations.removeAll()
            self.arrSkill.removeAll()
            self.arrTools.removeAll()
            self.arrCategory.removeAll()
            self.arrCategory.append(Skills(id: data?.category?.id ?? "", name: data?.category?.name ?? ""))
            for i in data?.skills ?? []{
                self.arrSkill.append(Skills(id: i.id ?? "", name: i.name ?? ""))
            }
            self.arrTools = data?.tools ?? []
            self.collVwTools.reloadData()
            self.collVwSkills.reloadData()
            self.businessGigDetail = data
            self.BusinessUserDetail = data?.user
            self.gigUserId = data?.user?.id ?? ""
            self.businessGigStatus = data?.status
            self.participantCount = data?.appliedParticipants ?? 0
            self.arrBusinessReview = data?.reviews ?? []
            self.providerUserId = data?.user?.id ?? ""
            self.price = data?.price ?? 0
            
            self.lblTitle.text = data?.title ?? ""
            self.lblPlace.text = data?.place ?? ""
         
            self.lblGigDuration.text = data?.serviceDuration ?? ""
            self.lblGigCategory.text = data?.category?.name ?? ""
            self.lblGigExperience.text = data?.experience ?? ""
            self.lblTaskDescription.text = data?.about ?? ""
            self.lblSafetyTips.text = data?.safetyTips ?? ""
            self.lblPrice.text = "$\(data?.price ?? 0)"
            self.lblInstruction.text = data?.description ?? ""
          
            self.lblTitle.text = data?.title ?? ""
            self.lblPlace.text = data?.place ?? ""
            
            if data?.distance ?? 0 > 0{
                let formattedNumber = String(format: "%.0f", data?.distance ?? 0.0)
                self.lblDistance.text = "\(formattedNumber)Km away from you"
            }else{
                let formattedNumber = String(format: "%.1f", data?.distance ?? 0.0)
                self.lblDistance.text = "\(formattedNumber)Km away from you"
            }
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: data?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd/MM/yy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.lblGigDate.text = formattedDate
            }
            if let time = isoDateFormatter.date(from: data?.startTime ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "hh:mm a"
                let formattedDate = displayDateFormatter.string(from: time)
                self.lblGigTime.text = formattedDate
            }
            self.mapVw.mapboxMap.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0),zoom: 11,bearing: 0,pitch: 0))
            self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0 ), price: data?.price ?? 0, seen: 2))
            clusterManager.addClusters(with: self.customAnnotations)
            
            if data?.reviews?.count ?? 0 > 0{
                self.lblreview.isHidden = false
              
            }else{
              self.lblreview.isHidden = true
              
            }
            if data?.type == "worldwide"{
                self.lblGigType.text = "(WorldWide)"
                self.widthGigType.constant = 96
            }else{
                self.lblGigType.text = "(Local)"
                self.widthGigType.constant = 56
            }
            if data?.status == 0{
                self.btnMore.isHidden = false
              
                if data?.paymentStatus == 0{
                    self.btnApply.isHidden = false
                  
                    self.btnApply.setTitle("Pay Now", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.app
                    self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    self.paymentStatus = 0
                }else{
                    self.btnApply.isHidden = true
                    
                    self.paymentStatus = 1
                }
                
            }else if data?.status == 1{
           
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                self.btnApply.setTitle("Complete", for: .normal)
                self.btnApply.backgroundColor =  UIColor.app
                self.btnApply.setTitleColor(UIColor.white, for: .normal)
                self.btnChat.isHidden = false
            }else if data?.status == 2{
                
            
                self.btnMore.isHidden = true
                self.btnApply.isHidden = false
                self.btnApply.backgroundColor = .app
                self.btnApply.setTitleColor(.white, for: .normal)
                
                    if self.isReviewNil == true{
                     
                        self.btnApply.setTitle("Update review", for: .normal)
                   
                    }else{
                     
                        self.btnApply.setTitle("Add review", for: .normal)
                       
                    }
                
            }else{
             
                self.btnApply.isHidden = true
                self.btnMore.isHidden = true
                
                
            }
            
            self.imgVwProvider.imageLoad(imageUrl: data?.user?.profilePhoto ?? "")
            self.lblProviderName.text = data?.user?.name ?? ""
            if data?.image == "" || data?.image == nil{
                self.imgVwTitle.image = UIImage(named: "dummy")
                self.mapVw.isHidden = false
            }else{
                self.imgVwTitle.imageLoad(imageUrl: data?.image ?? "")
                self.mapVw.isHidden = true
            }
            
//            self.lblAbout.text = data?.about ?? ""
            self.textAbout = data?.about ?? ""
            self.lblPlace.text = data?.place ?? ""
            
            let participant = (Int(data?.totalParticipants ?? "") ?? 0) - (Int(data?.participants ?? "") ?? 0)
            
            self.lblTotalParticipant.text = "\(participant)/\(data?.totalParticipants ?? "") Participants"
            self.lblPrticipansCount.text = "\(participant)"
//            self.lblTotalParticipant.text = "\(data?.appliedParticipants ?? 0)/\(data?.totalParticipants ?? "") Participants"
//            self.lblPrticipansCount.text = "\(data?.appliedParticipants ?? 0)"
            
            self.lblTitle.text = data?.title ?? ""

            if data?.paymentTerms == 0{
                self.lblPrice.text = "$\(data?.price ?? 0) Fixed"
            }else{
                self.lblPrice.text = "$\(data?.price ?? 0) Hourly"
            }
            self.tblVwReiew.reloadData()
            self.tblVwReiew.invalidateIntrinsicContentSize()
            
            
        }
    }
    
    func getGigChat(){
        let param:parameters = ["gigId":self.gigId,"senderId":Store.userId ?? "","isOpen":true,"deviceId":Store.deviceToken ?? "","groupId":groupId]
        print("Param-----",param)
        SocketIOManager.sharedInstance.getGroupChat(dict: param)
        SocketIOManager.sharedInstance.groupData = { data in
            if data?[0].groupChatDetails?.count ?? 0 > 0{
                self.groupId = data?[0].groupChatDetails?[0].group?.id ?? ""
                print("dataaa-----",data ?? [])
                let id = data?[0].groupChatDetails?[0].gig?._id ?? ""
                
                if self.gigId == id {
                    Store.GigChatDetail = data ?? []
                }
            }
        }
    }
    
 
 
    
    //MARK: - BUTTON ACTIONS
    
    @IBAction func actionSelectUser(_ sender: UIButton) {
        
        if gigUserType == "user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewVC") as! ProfileViewVC
            vc.id = userId
            vc.isComingChat = true
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            vc.businessId = providerUserId
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func actionCompletePaticipants(_ sender: UIButton) {
        
//        if businessGigStatus == 2{
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
//            vc.isComing = 2
//            vc.gigId = gigId
//            vc.businessGigDetail = businessGigDetail
//
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    @IBAction func actionAddReview(_ sender: UIButton) {
        
        if Store.role == "b_user"{
            if arrCompleteParticipants.count > 1{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
                vc.isComing = 2
                vc.businessGigDetail = businessGigDetail
                vc.gigId = gigId
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isComing = 1
                vc.gigId = gigId
                vc.userId = participantsId
                if arrCompleteParticipants[sender.tag].review == nil{
                    vc.isUpdateReview = false
                }else{
                    vc.isUpdateReview = true
                    vc.reviewsToParticipants = arrCompleteParticipants[0].review
                }
                vc.businessGigDetail = businessGigDetail
                vc.callBack = { [weak self] in
                    guard let self = self else { return }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.btnApply.isHidden = true
                        self.viewCompletegigMsg.isHidden = true
                        self.heightviewCompleteMsg.constant = 0
                        self.getBusinessGigDetailApi()
                        self.getCompleteParticipants(loader: false)
                    }
                    self.navigationController?.present(vc, animated: false)
                    
                }
                self.navigationController?.present(vc, animated: true)
            }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
            vc.modalPresentationStyle = .overFullScreen
            vc.isComing = 2
            vc.gigId = gigId
            vc.userId = providerUserId
            vc.userGigDetail = userGigDetail
            for (index, review) in arrUserReview.enumerated() {
                if Store.userId == review.user?.id ?? ""{
                    vc.isUpdateReview = true
                    vc.gigReview = review
                    break
                }
            }
            vc.callBack = { [weak self] in
                guard let self = self else { return }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    
                    self.btnApply.isHidden = true
                    self.viewCompletegigMsg.isHidden = true
                    self.heightviewCompleteMsg.constant = 0
                    self.getUserGigDetailApi()
                    
                    
                }
                self.navigationController?.present(vc, animated: false)
                
            }
            self.navigationController?.present(vc, animated: true)
            
        }
    }
    @IBAction func actionMore(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreOptionPopUpVC") as! MoreOptionPopUpVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { [weak self] isComing in
            guard let self = self else { return }
            if isComing == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 0
                vc.gigId = self.businessGigDetail?.id ?? ""
                vc.callBack = { [weak self] message in
                    guard let self = self else { return }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isSelect = 10
                    vc.message = message
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.navigationController?.present(vc, animated: false)
                    
                }
                self.navigationController?.present(vc, animated: false)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGigAddVC") as! NewGigAddVC
                vc.isComing = false
                if isComing == true{
                    vc.isDetailData = true
                }else{
                    vc.isDetailData = false
                }
                vc.arrTools = self.arrTools
                vc.arrSkills = self.arrSkill
                vc.isDetailData = true
                vc.gigId = gigId
                vc.userGigDetail = self.userGigDetail
                vc.bsuinessGigDetail = self.businessGigDetail
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        callBack?()
    }
    @IBAction func actionParticipants(_ sender: UIButton) {
        
        if Store.role == "b_user"{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
            vc.isComing = 0
            vc.gigId = gigId
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
            vc.isComing = 1
            vc.gigId = gigId
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func actionApply(_ sender: UIButton) {
        
        if Store.role == "b_user"{
            if businessGigStatus == 2{
                if arrCompleteParticipants.count > 1{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
                    vc.isComing = 2
                    vc.businessGigDetail = businessGigDetail
                    vc.gigId = gigId
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                    
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComing = 1
                    if arrCompleteParticipants[sender.tag].review == nil{
                        vc.isUpdateReview = false
                    }else{
                        vc.isUpdateReview = true
                        vc.reviewsToParticipants = arrCompleteParticipants[sender.tag].review
                    }
                    vc.gigId = gigId
                    vc.userId = participantsId
                    vc.businessGigDetail = businessGigDetail
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            self.btnApply.isHidden = true
                            self.viewCompletegigMsg.isHidden = true
                            self.heightviewCompleteMsg.constant = 0
                            self.getBusinessGigDetailApi()
                            self.getCompleteParticipants(loader: false)
                            
                        }
                        self.navigationController?.present(vc, animated: false)
                        
                    }
                    self.navigationController?.present(vc, animated: true)
                }
                
            }else if businessGigStatus == 1{
                viewModel.CompleteGigApi(gigid: gigId) { message in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                    vc.isSelect = 10
                    vc.message = message
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.getBusinessGigDetailApi()
                        self.getGigChat()
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.present(vc, animated: true)
                    
                }
            }else{
                print(businessGigStatus ?? 0)
                if paymentStatus == 0{
                    viewModel.createGig(gigId: gigId,price:price) { data in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.paymentLink = data?.url ?? ""
                        vc.callback = { [weak self] payment in
                            guard let self = self else { return }
                            if payment == true{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCreatedVC") as! GigCreatedVC
                                vc.modalPresentationStyle = .overFullScreen
                                vc.callBack = {[weak self] in
                                    guard let self = self else { return }
                                    SceneDelegate().GigListVCRoot()
                                }
                                self.navigationController?.present(vc, animated: false)
                            }else{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                                vc.isSelect = 20
                                vc.callBack = {[weak self] in
                                    guard let self = self else { return }
                                    SceneDelegate().GigListVCRoot()
                                }
                                vc.modalPresentationStyle = .overFullScreen
                                self.navigationController?.present(vc, animated: true)
                            }
                            
                            
                        }
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: false)
                    }
                }
            }
            
            
        }else{
            if userGigStatus == 0{
                print(userGigStatus ?? 0)
            }else if userGigStatus == 1{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
                vc.receiverId = providerUserId
                self.navigationController?.pushViewController(vc, animated: true)
            }else if userGigStatus == 2{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isComing = 2
                vc.gigId = gigId
                vc.userId = providerUserId
                vc.userGigDetail = userGigDetail
                for (index, review) in arrUserReview.enumerated() {
                    if Store.userId == review.user?.id ?? ""{
                        vc.isUpdateReview = true
                        vc.gigReview = review
                        break
                    }
                }
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.btnApply.isHidden = true
                        self.viewCompletegigMsg.isHidden = true
                        self.heightviewCompleteMsg.constant = 0
                        self.getUserGigDetailApi()
                        
                        
                    }
                    self.navigationController?.present(vc, animated: false)
                    
                }
                self.navigationController?.present(vc, animated: true)
                
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as! UserDetailVC
                vc.modalPresentationStyle = .overFullScreen
                vc.gigId = gigId
                vc.userDetail = userDetail
                vc.callBack = { [weak self] message in
                    guard let self = self else { return }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                    vc.isSelect = 10
                    vc.message = message
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.getUserGigDetailApi()
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.present(vc, animated: true)
                    
                }
                self.navigationController?.present(vc, animated: true)
            }
        }
        
        
        
    }
    
    @IBAction func actionGigChat(_ sender: UIButton) {
        
        if Store.GigChatDetail?[0].isReady == 1{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigChatVC") as! GigChatVC
            vc.gigId = self.gigId
            vc.gigUserId = self.gigUserId
            vc.modalPresentationStyle = .overFullScreen
            vc.callBack = { [weak self] isBack in
                guard let self = self else { return }
                if !isBack{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCompleteVC") as! GigCompleteVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.callBack = {[weak self] in
                        guard let self = self else { return }
                        self.getGigChat()
                        self.uiSet()
                    }
                    self.navigationController?.present(vc, animated: true)
                }
                
            }
            self.navigationController?.present(vc, animated: true)
        }else{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigReadyVC") as! GigReadyVC
            vc.modalPresentationStyle = .overFullScreen
            vc.isComing = 1
            vc.gigDetail2 = userGigDetail
            vc.groupId = groupId
            vc.callBack = {[weak self] in
                guard let self = self else { return }
                
                let param:parameters = ["userId":Store.userId ?? "","deviceId":Store.deviceToken ?? "","gigId":self.gigId,"groupId":self.groupId]
                print("param--",param)
                
                SocketIOManager.sharedInstance.readyUser(dict: param)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                    if Store.role == "user"{
                        let param2 = ["senderId":Store.userId ?? "","groupId":self.groupId,
                                      "message":"\(Store.UserDetail?["userName"] as? String ?? "") is ready",
                                      "deviceId":Store.deviceToken ?? "",
                                      "gigId":self.gigId]
                        SocketIOManager.sharedInstance.sendMessage(dict: param2)
                    }else{
                        let param2 = ["senderId":Store.userId ?? "",
                                      "groupId":self.groupId,
                                      "message":"\(Store.BusinessUserDetail?["userName"] as? String ?? "") is ready",
                                      "deviceId":Store.deviceToken ?? "",
                                      "gigId":self.gigId]
                        SocketIOManager.sharedInstance.sendMessage(dict: param2)
                    }
                    
                }

                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigChatVC") as! GigChatVC
                vc.gigId = self.gigId
                vc.gigUserId = self.gigUserId
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack = { [weak self] isBack in
                    guard let self = self else { return }
                    if !isBack{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCompleteVC") as! GigCompleteVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            self.getGigChat()
                            self.uiSet()
                        }
                        self.navigationController?.present(vc, animated: true)
                    }
                }
                self.navigationController?.present(vc, animated: true)
                
            }
            self.navigationController?.present(vc, animated: true)
        }
    }

    
}
//MARK: -UITableViewDelegate
extension ApplyGigVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isComing == 0{
            return arrUserReview.count
        }else{
            return arrBusinessReview.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
        
        if isComing == 0{
            cell.imgVwUser.imageLoad(imageUrl: arrUserReview[indexPath.row].user?.profilePhoto ?? "")
            cell.lblName.text = arrUserReview[indexPath.row].user?.name ?? ""
            cell.lblDescription.text = arrUserReview[indexPath.row].comment ?? ""
            cell.lblDescription.sizeToFit()
            let rating = arrUserReview[indexPath.row].starCount ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            cell.lblRating.text = formattedRating
            cell.ratingView.rating = rating
            heightDescription += Int(cell.lblDescription.frame.size.height)
            
            if arrUserReview[indexPath.row].media == "" || arrUserReview[indexPath.row].media == nil{
                cell.heightImgVw.constant = 0
                reviewHeight += Int(70 + CGFloat(self.heightDescription))
            }else{
                cell.heightImgVw.constant = 150
                reviewHeight += Int(220 + CGFloat(self.heightDescription))
                cell.imgVwReview.imageLoad(imageUrl: arrUserReview[indexPath.row].media ?? "")
            }
            
            let createdAt = arrUserReview[indexPath.row].createdAt ?? ""
            let timeAgoString = createdAt.timeAgoSinceDate()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let createdDate = dateFormatter.date(from: createdAt) {
                let timeDifference = Date().timeIntervalSince(createdDate)
                if timeDifference < 60 {
                    cell.lblTime.text = "Just now"
                } else {
                    cell.lblTime.text = "\(timeAgoString) Ago"
                }
            } else {
                cell.lblTime.text = "\(timeAgoString) Ago"
            }
            
        }else{
            cell.imgVwUser.imageLoad(imageUrl: arrBusinessReview[indexPath.row].userID?.profilePhoto ?? "")
            cell.lblName.text = arrBusinessReview[indexPath.row].userID?.name ?? ""
            cell.lblDescription.text = arrBusinessReview[indexPath.row].comment ?? ""
            cell.lblDescription.sizeToFit()
            let rating = arrBusinessReview[indexPath.row].starCount ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            cell.lblRating.text = formattedRating
            cell.ratingView.rating = rating
            heightDescription += Int(cell.lblDescription.frame.size.height)
            
            let createdAt = arrBusinessReview[indexPath.row].createdAt ?? ""
            let timeAgoString = createdAt.timeAgoSinceDate()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let createdDate = dateFormatter.date(from: createdAt) {
                let timeDifference = Date().timeIntervalSince(createdDate)
                if timeDifference < 60 {
                    cell.lblTime.text = "Just now"
                } else {
                    cell.lblTime.text = "\(timeAgoString) Ago"
                }
            } else {
                cell.lblTime.text = "\(timeAgoString) Ago"
            }
            
            if arrBusinessReview[indexPath.row].media == "" || arrBusinessReview[indexPath.row].media == nil{
                cell.heightImgVw.constant = 0
                reviewHeight += Int(70 + CGFloat(self.heightDescription))
            }else{
                cell.heightImgVw.constant = 150
                reviewHeight += Int(220 + CGFloat(self.heightDescription))
                cell.imgVwReview.imageLoad(imageUrl: arrBusinessReview[indexPath.row].media ?? "")
            }
        }
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegate
extension ApplyGigVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwTools{
            return arrTools.count
        }else{
            return arrSkill.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwTools{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrTools[indexPath.row]
            cell.vwBg.layer.cornerRadius = 4
            cell.vwBg.backgroundColor = UIColor(hex: "#C7E2C4")
            cell.lblName.textColor = .black
            cell.widthBtnCross.constant = 0
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.lblName.text = arrSkill[indexPath.row].name
            cell.vwBg.layer.cornerRadius = 4
            cell.vwBg.backgroundColor = UIColor(hex: "#C7E2C4")
            cell.lblName.textColor = .black
            cell.widthBtnCross.constant = 0
            
            return cell
        }
    }
   
}
