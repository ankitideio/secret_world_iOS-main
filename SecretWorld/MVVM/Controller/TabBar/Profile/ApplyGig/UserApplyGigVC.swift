//
//  UserApplyGigVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 26/03/24.
//

import UIKit
import FXExpandableLabel
import SideMenu
import MapboxMaps
import Solar
import AlignedCollectionViewFlowLayout

class UserApplyGigVC: UIViewController, SideMenuNavigationControllerDelegate {
    //MARK: - OUTLEST
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet var lblParticipants: UILabel!
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
    var arrSkills: [CategoryGig]?
    var arrTools: [String]?
    var gigId = ""
    var viewModel = AddGigVM()
    var businessGigDetail:BusinessGigDetailData?
    //    var BusinessUserDetail:UserDetailes?

    var arrUserReview = [ReviewGigBuser]()
    var heightDescription = 0
    var reviewHeight = 0
    var paymentStatus = 0
    var price = 0
    var providerUserId = ""
    var userGigDetail:GetUserGigDetailData?
    var arrCompleteParticipants = [GetRequestData]()
    var participantsId = ""
    var arrDetail = [GroupChatModel]()
    var textAbout = ""
    var participantCount = 0
    var yourGig = false
    var gigUserId = ""
    var sideMenu: SideMenuNavigationController?
    var groupId = ""
    var isReviewNil = false
    private var solar: Solar?
    var callBack:(()->())?
    var isComing = false
    var userGigStatus:String = ""
    var bsuinessGigStatus:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenuNavigationController") as? SideMenuNavigationController
        sideMenu?.sideMenuDelegate = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
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
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AuthKey-----",Store.authKey ?? "")
        uiSet()
        getGigChat()
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
        
        lblreview.isHidden = true
        heightTllvwHeight.constant = 0
        heightviewCompleteMsg.constant = 0
     
        if Store.role != "user"{
            //Business
            
            heightTllvwHeight.constant = 0
            heightviewCompleteMsg.constant = 0
            viewServiceProvider.isHidden = true
            viewSeprator.isHidden = true
            viewCompletegigMsg.isHidden = true
            tblVwReiew.isHidden = false
            
            getCompleteParticipants(loader: false)
            getBusinessGigDetailApi()
        
        }else{
            //User
            
            heightTllvwHeight.constant = 0
            heightviewCompleteMsg.constant = 0
            viewServiceProvider.isHidden = false
            viewSeprator.isHidden = false
            getUserGigDetailApi()
        
        }
    }
    func getCompleteParticipants(loader:Bool){
        
        viewModel.GetCompleteGigParticipantsListApi(loader: loader, gigId: gigId){ data in
            self.arrCompleteParticipants = data ?? []
            if let data = data, !data.isEmpty {
                self.arrCompleteParticipants = data
                self.providerUserId = data[0].applyuserID ?? ""
            } else {
                self.arrCompleteParticipants = []
                self.providerUserId = ""
            }
        }
    }
    
    func getBusinessGigDetailApi(){
        viewModel.GetBuisnessGigDetailApi(gigId: gigId) { data in
            self.businessGigDetail = data
            
            self.mapVw.mapboxMap.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0),zoom: 11,bearing: 0,pitch: 0))
            let someCoordinate = CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0)
            var pointAnnotation = PointAnnotation(coordinate: someCoordinate)
            let imageName = "unseen"
            
            let price = data?.price ?? 0
            let width = price < 10 ? 30 :
            price < 100 ? 45 :
            price < 1000 ? 55 :
            price < 10000 ? 65 : 75
            
            guard let originalImage = UIImage(named: imageName) else { return }
            let resizedImage = self.resizeGigImage(
                originalImage,
                to: price,
                withTitle: "$\(price)", // Format price as a string
                width: width
            )
            
            // Create the annotation
            
            pointAnnotation.image = .init(image: resizedImage, name: imageName)
            let pointAnnotationManager = self.mapVw.annotations.makePointAnnotationManager()
            pointAnnotationManager.annotations = [pointAnnotation]
            
            self.price = data?.price ?? 0
            if self.arrUserReview.count > 0{
                self.lblreview.isHidden = false
                self.heightViewReviewTile.constant = 40
            }else{
                self.lblreview.isHidden = true
                self.heightViewReviewTile.constant = 0
            }
            
            self.gigUserId = data?.user?.id ?? ""
            
            self.arrSkills = data?.skills ?? []
            self.arrTools = data?.tools ?? []
            self.lblDistance.text = "\(Int(data?.distance ?? 0.0))Km away from you"
            
            self.lblTitle.text = data?.title ?? ""
            self.lblPlace.text = data?.place ?? ""
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: data?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd/MM/yy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.lblGigDate.text = formattedDate
            }
            
            self.lblGigTime.text = data?.startTime ?? ""
            self.lblGigDuration.text = data?.serviceDuration ?? ""
            self.lblGigCategory.text = data?.category?.name ?? ""
            self.lblGigExperience.text = data?.experience ?? ""
            self.lblTaskDescription.text = data?.about ?? ""
            self.lblInstruction.text = data?.description ?? ""
            self.lblSafetyTips.text = data?.safetyTips ?? ""
            self.lblPrice.text = "$\(data?.price ?? 0)"
            self.lblInstruction.text = data?.safetyTips ?? ""
            self.lblParticipants.text = "\(data?.appliedParticipants ?? 0)/\(data?.appliedParticipants ?? 0) participants"
            
            self.btnApply.isHidden = false
            if data?.status == 0{
                self.bsuinessGigStatus = "0"
                if Store.userId == data?.user?.id ?? ""{
                    self.btnApply.isHidden = true
                    if self.isComing == true{
                        self.btnMore.isHidden = false
                    }else{
                        self.btnMore.isHidden = true
                    }
                   
                }else{
                    self.btnApply.isHidden = false
                    self.btnMore.isHidden = true
                }
            }else if data?.status == 1{
                self.bsuinessGigStatus = "1"
                self.btnChat.isHidden = false
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                self.btnApply.setTitle("Complete", for: .normal)
                self.btnApply.backgroundColor =  UIColor.app
                self.btnApply.setTitleColor(UIColor.white, for: .normal)
                self.btnChat.isHidden = false
            }else if data?.status == 2{
                self.bsuinessGigStatus = "2"
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                for i in data?.reviews ?? []{
                    if Store.userId == i.user?.id{
                        self.isReviewNil = true
                        break
                    }else{
                        self.isReviewNil = false
                    }
                }
                if self.isReviewNil == true{
                    self.btnApply.setTitle("Update review", for: .normal)
                }else{
                    self.btnApply.setTitle("Add review", for: .normal)
                }
                
                self.btnApply.backgroundColor = .app
                self.btnApply.setTitleColor(.white, for: .normal)
                self.btnChat.isHidden = false
            }else{
                self.bsuinessGigStatus = ""
                if Store.userId == data?.user?.id ?? ""{
                  
                    if self.isComing == true{
                        self.btnMore.isHidden = false
                    }else{
                        self.btnMore.isHidden = true
                    }
                    self.btnApply.isHidden = true
                }else{
                    self.btnMore.isHidden = true
                    self.btnApply.isHidden = false
                    self.btnApply.setTitle("Apply", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.app
                    self.btnApply.setTitleColor(UIColor.white, for: .normal)
                }
                self.paymentStatus = 0
                
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
            
            
            self.textAbout = data?.about ?? ""
       
            self.lblPlace.text = data?.place ?? ""
            
            if data?.participants == "0"{
                self.lblPrticipansCount.text = "0"
            }else if data?.participants == "1"{
                self.lblPrticipansCount.text = "\(data?.participants ?? "")"
            }else{
                self.lblPrticipansCount.text = "\(data?.participants ?? "")"
            }
            
            self.lblTitle.text = data?.title ?? ""
            let attributedString = NSMutableAttributedString(string: "Price  ")
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 6))
            let priceString = "$\(data?.price ?? 0)"
            let priceAttributeString = NSAttributedString(string: priceString, attributes: [.foregroundColor: UIColor.app])
            attributedString.append(priceAttributeString)
            self.lblPrice.attributedText = attributedString
            
            self.tblVwReiew.reloadData()
            self.collVwTools.reloadData()
            self.collVwSkills.reloadData()
            self.tblVwReiew.invalidateIntrinsicContentSize()
        }
        
    }
    
    func getUserGigDetailApi(){
        
        viewModel.GetUserGigDetailApi(gigId: gigId) { data in
            self.userGigDetail = data
            self.providerUserId = data?.gig?.user?.id ?? ""
            self.mapVw.mapboxMap.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: data?.gig?.lat ?? 0, longitude: data?.gig?.long ?? 0),zoom: 11,bearing: 0,pitch: 0))
            let someCoordinate = CLLocationCoordinate2D(latitude: data?.gig?.lat ?? 0, longitude: data?.gig?.long ?? 0)
            var pointAnnotation = PointAnnotation(coordinate: someCoordinate)
            let imageName = "unseen"
            
            let price = data?.gig?.price ?? 0
            let width = price < 10 ? 30 :
            price < 100 ? 45 :
            price < 1000 ? 55 :
            price < 10000 ? 65 : 75
            
            guard let originalImage = UIImage(named: imageName) else { return }
            let resizedImage = self.resizeGigImage(
                originalImage,
                to: price,
                withTitle: "$\(price)", // Format price as a string
                width: width
            )
            
            // Create the annotation
            
            self.lblDistance.text = "\(Int(data?.gig?.distance ?? 0.0))Km away from you"
            pointAnnotation.image = .init(image: resizedImage, name: imageName)
            let pointAnnotationManager = self.mapVw.annotations.makePointAnnotationManager()
            pointAnnotationManager.annotations = [pointAnnotation]
            
            self.price = data?.gig?.price ?? 0
            if self.arrUserReview.count > 0{
                self.lblreview.isHidden = false
                self.heightViewReviewTile.constant = 40
            }else{
                self.lblreview.isHidden = true
                self.heightViewReviewTile.constant = 0
            }
            
            self.gigUserId = data?.gig?.user?.id ?? ""
            
            self.arrSkills = data?.gig?.skills ?? []
            self.arrTools = data?.gig?.tools ?? []
            
            self.lblTitle.text = data?.gig?.title ?? ""
            self.lblPlace.text = data?.gig?.place ?? ""
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDateFormatter.date(from: data?.gig?.startDate ?? "") {
                let displayDateFormatter = DateFormatter()
                displayDateFormatter.dateFormat = "dd/MM/yy"
                let formattedDate = displayDateFormatter.string(from: date)
                self.lblGigDate.text = formattedDate
            }
            
            self.lblGigTime.text = data?.gig?.startTime ?? ""
            self.lblGigDuration.text = data?.gig?.serviceDuration ?? ""
            self.lblGigCategory.text = data?.gig?.category?.name ?? ""
            self.lblGigExperience.text = data?.gig?.experience ?? ""
            self.lblTaskDescription.text = data?.gig?.about ?? ""
            self.lblInstruction.text = data?.gig?.description ?? ""
            self.lblSafetyTips.text = data?.gig?.safetyTips ?? ""
            self.lblPrice.text = "$\(data?.gig?.price ?? 0)"
            self.lblInstruction.text = data?.gig?.safetyTips ?? ""
            self.lblParticipants.text = "\(data?.appliedParticipants ?? 0)/\(data?.gig?.totalParticipants ?? "") participants"
           
            if data?.status == 0{
                if Store.userId == data?.gig?.user?.id ?? ""{
                    self.btnApply.isHidden = true
                    if self.isComing == true{
                        self.btnMore.isHidden = false
                    }else{
                        self.btnMore.isHidden = true
                    }
                }else{
                    self.btnApply.isHidden = false
                    self.btnMore.isHidden = true
                    self.btnApply.setTitle("Requested", for: .normal)
                    self.btnApply.backgroundColor = UIColor(red: 255/255, green: 230/255, blue: 182/255, alpha: 1.0)
                    self.btnApply.setTitleColor(UIColor(red: 255/255, green: 178/255, blue: 30/255, alpha: 1.0), for: .normal)
                    self.btnApply.isUserInteractionEnabled = false
                }
                self.userGigStatus = "0"
            }else if data?.status == 1{
                if Store.userId == data?.gig?.user?.id{
                    self.btnChat.isHidden = false
                    self.btnApply.isHidden = false
                    self.btnMore.isHidden = true
                    self.btnApply.setTitle("Complete", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.app
                    self.btnApply.setTitleColor(UIColor.white, for: .normal)
                }else{
                    self.btnChat.isHidden = false
                    self.btnApply.isHidden = true
                    self.btnMore.isHidden = true
                    
                }
               
                self.userGigStatus = "1"
            }else if data?.status == 2{
                
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                for i in data?.reviews ?? []{
                    if Store.userId == i.user?.id{
                        self.isReviewNil = true
                        break
                    }else{
                        self.isReviewNil = false
                    }
                }
                if self.isReviewNil == true{
                    self.btnApply.setTitle("Update review", for: .normal)
                }else{
                    self.btnApply.setTitle("Add review", for: .normal)
                }
                
                self.btnApply.backgroundColor = .app
                self.btnApply.setTitleColor(.white, for: .normal)
                self.btnChat.isHidden = true
                self.userGigStatus = "2"
                
            }else{
                if data?.participantsList?.count ?? 0 > 0{
                    if Store.userId == data?.gig?.user?.id ?? ""{
                        self.btnChat.isHidden = false
                        self.btnApply.isHidden = false
                        self.btnMore.isHidden = true
                        self.btnApply.setTitle("Complete", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.app
                        self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    }else{
                        self.btnMore.isHidden = true
                        self.btnApply.isHidden = false
                        self.btnApply.setTitle("Compelete", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.app
                        self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    }
                    self.paymentStatus = 0
                    self.userGigStatus = ""
                }else{
                    if Store.userId == data?.gig?.user?.id ?? ""{
                        
                        if self.isComing == true{
                            self.btnMore.isHidden = false
                        }else{
                            self.btnMore.isHidden = true
                        }
                        self.btnApply.isHidden = true
                    }else{
                        self.btnMore.isHidden = true
                        self.btnApply.isHidden = false
                        self.btnApply.setTitle("Apply", for: .normal)
                        self.btnApply.backgroundColor =  UIColor.app
                        self.btnApply.setTitleColor(UIColor.white, for: .normal)
                    }
                    self.paymentStatus = 0
                    self.userGigStatus = ""
                }
            }
            self.imgVwProvider.imageLoad(imageUrl: data?.gig?.user?.profilePhoto ?? "")
            self.lblProviderName.text = data?.gig?.user?.name ?? ""
            if data?.gig?.image == "" || data?.gig?.image == nil{
                self.imgVwTitle.image = UIImage(named: "dummy")
                self.mapVw.isHidden = false
            }else{
                self.imgVwTitle.imageLoad(imageUrl: data?.gig?.image ?? "")
                self.mapVw.isHidden = true
            }
            
            
            self.textAbout = data?.gig?.about ?? ""
          
            self.lblPlace.text = data?.gig?.place ?? ""
            
            if data?.gig?.participants == "0"{
                self.lblPrticipansCount.text = "0"
            }else if data?.gig?.participants == "1"{
                self.lblPrticipansCount.text = "\(data?.gig?.participants ?? "")"
            }else{
                self.lblPrticipansCount.text = "\(data?.gig?.participants ?? "")"
            }
            
            self.lblTitle.text = data?.gig?.title ?? ""
            let attributedString = NSMutableAttributedString(string: "Price  ")
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 6))
            let priceString = "$\(data?.gig?.price ?? 0)"
            let priceAttributeString = NSAttributedString(string: priceString, attributes: [.foregroundColor: UIColor.app])
            attributedString.append(priceAttributeString)
            self.lblPrice.attributedText = attributedString
            
            self.tblVwReiew.reloadData()
            self.collVwTools.reloadData()
            self.collVwSkills.reloadData()
            self.tblVwReiew.invalidateIntrinsicContentSize()
            
        }
    }
    func getGigChat(){
        let param:parameters = ["gigId":self.gigId,"senderId":Store.userId ?? "","isOpen":true,"deviceId":Store.deviceToken ?? ""]
        SocketIOManager.sharedInstance.getGroupChat(dict: param)
        SocketIOManager.sharedInstance.groupData = { data in
            if data?[0].groupChatDetails?.count ?? 0 > 0{
                self.groupId = data?[0].groupChatDetails?[0].group?.id ?? ""
                let id = data?[0].groupChatDetails?[0].gig?._id ?? ""
                
                if self.gigId == id {
                    Store.GigChatDetail = data ?? []
                }
            }
        }
    }
    
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resizeGigImage(_ image: UIImage, to price: Int, withTitle title: String,width:Int) -> UIImage {
        // Set static width and height to 30
        let size = CGSize(width: width, height: 30)
        
        // Resize the original image to the fixed size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        
        // Set text color based on daytime/nighttime logic
        var textColor: UIColor = .white
        if let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: myCurrentLat, longitude: myCurrentLong)) {
            self.solar = solar
            let isDaytime = solar.isDaytime
            textColor = isDaytime ? .white : .black
        }
        
        // Define text attributes (font, color, alignment)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Nunito-SemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: textColor,
            .backgroundColor: UIColor.clear
        ]
        
        // Calculate position for the centered text within the image
        let textSize = title.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // Draw the text into the image
        let titleText = NSString(string: title)
        titleText.draw(in: textRect, withAttributes: textAttributes)
        
        // Get the resulting image with text overlay
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage ?? image
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func actionApply(_ sender: UIButton) {
        
        if Store.role == "b_user"{
            if bsuinessGigStatus == "2"{
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
          }else if bsuinessGigStatus == "1"{
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
            
          if userGigStatus == "0"{
            print(userGigStatus ?? 0)
          }else if userGigStatus == "1"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
            vc.receiverId = providerUserId
            self.navigationController?.pushViewController(vc, animated: true)
          }else if userGigStatus == "2"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
            vc.modalPresentationStyle = .overFullScreen
            vc.isComing = 2
            vc.gigId = gigId
            vc.userId = providerUserId
            vc.userGigDetail = userGigDetail
            for (index, review) in arrUserReview.enumerated() {
              if Store.userId == review.user?.id ?? ""{
                vc.isUpdateReview = true
//                vc.gigReview = review
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
              if userGigDetail?.participantsList?.count ?? 0 > 0{
                  viewModel.CompleteGigApi(gigid: gigId) { message in
                       let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                       vc.isSelect = 10
                       vc.message = message
                       vc.callBack = {[weak self] in
                         guard let self = self else { return }
                         self.getUserGigDetailApi()
                         self.getGigChat()
                       }
                       vc.modalPresentationStyle = .overFullScreen
                       self.navigationController?.present(vc, animated: true)
                     }
              }else{
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as! UserDetailVC
                  vc.modalPresentationStyle = .overFullScreen
                  vc.gigId = gigId
                  vc.userDetail = userGigDetail
                  vc.businessDetail = businessGigDetail
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
      }
    @IBAction func actionParticipants(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ParticipantsVC") as! ParticipantsVC
        vc.gigId = gigId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionThreeDot(_ sender: UIButton) {
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
                
                vc.gigId = gigId
                if Store.role == "user"{
                    vc.userGigDetail = self.userGigDetail
                }else{
                    vc.bsuinessGigDetail = self.businessGigDetail
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func actionGigChat(_ sender: UIButton){
        
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
            vc.isComing = 2
            //            vc.userOwnerGigDetail = userGigDetail
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
                                      // "groupId":self.groupId,
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
extension UserApplyGigVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as! ReviewTVC
        
        cell.imgVwUser.imageLoad(imageUrl: arrUserReview[indexPath.row].userID?.profilePhoto ?? "")
        cell.lblName.text = arrUserReview[indexPath.row].userID?.name ?? ""
        cell.lblDescription.text = arrUserReview[indexPath.row].comment ?? ""
        cell.lblDescription.sizeToFit()
        let rating = arrUserReview[indexPath.row].starCount ?? 0.0
        let formattedRating = String(format: "%.1f", rating)
        cell.lblRating.text = formattedRating
        cell.ratingView.rating = rating
        heightDescription += Int(cell.lblDescription.frame.size.height)
        
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
        if arrUserReview[indexPath.row].media == "" || arrUserReview[indexPath.row].media == nil{
            cell.heightImgVw.constant = 0
            reviewHeight += Int(70 + CGFloat(self.heightDescription))
        }else{
            cell.heightImgVw.constant = 150
            reviewHeight += Int(220 + CGFloat(self.heightDescription))
            cell.imgVwReview.imageLoad(imageUrl: arrUserReview[indexPath.row].media ?? "")
        }
        
        
        return cell
    }
    
    
}
//MARK: - UICollectionViewDelegate
extension UserApplyGigVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwTools{
            return arrTools?.count ?? 0
        }else{
            return arrSkills?.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwTools{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.vwBg.backgroundColor = UIColor(hex: "#C7E2C4")
            cell.lblName.text = arrTools?[indexPath.row]
            cell.vwBg.layer.cornerRadius = 18
            cell.widthBtnCross.constant = 0
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
            cell.vwBg.backgroundColor = UIColor(hex: "#C7E2C4")
            cell.lblName.text = arrSkills?[indexPath.row].name ?? ""
            cell.vwBg.layer.cornerRadius = 18
            cell.widthBtnCross.constant = 0
            
            return cell
        }
    }
    
}
