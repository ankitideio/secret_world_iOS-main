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

class UserApplyGigVC: UIViewController, SideMenuNavigationControllerDelegate {
    //MARK: - OUTLEST
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
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet var imgVwTitle: UIImageView!
    @IBOutlet var btnAddreview: UIButton!
    @IBOutlet var heightBtnApply: NSLayoutConstraint!
    @IBOutlet var lblreview: UILabel!
    @IBOutlet var heightViewReviewTile: NSLayoutConstraint!
    @IBOutlet var heightTllvwHeight: NSLayoutConstraint!
    @IBOutlet var heightviewCompleteMsg: NSLayoutConstraint!
    @IBOutlet var btnApply: UIButton!
    @IBOutlet var btnParticipants: UIButton!
    @IBOutlet var btnGigType: UIButton!
    @IBOutlet var btnMore: UIButton!
    @IBOutlet var tblVwReiew: UITableView!
    
    //MARK: - VARIABLES
    var gigId = ""
    var viewModel = AddGigVM()
    var businessGigDetail:GetGigDetailData?
    var BusinessUserDetail:UserDetailes?
    var businessGigStatus:Int?
    var arrUserReview = [ReviewGigBuser]()
    var heightDescription = 0
    var reviewHeight = 0
    var paymentStatus = 0
    var price = 0
    var providerUserId = ""
    var userGigDetail:GetGigDetailData?
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
        
    }
    @objc func handleSwipe() {
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
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
        btnAddreview.isHidden = true
        lblreview.isHidden = true
        heightTllvwHeight.constant = 0
        heightviewCompleteMsg.constant = 0
        viewServiceProvider.isHidden = true
        viewSeprator.isHidden = true
        lblAbout.numberOfLines = 5
        addTapGestureToLabel()
        getBusinessGigDetailApi()
        getCompleteParticipants(loader: false)
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
            self.arrUserReview = data?.reviews ?? []
            self.userGigDetail = data
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
            self.businessGigDetail = data
            self.BusinessUserDetail = data?.user
            self.businessGigStatus = data?.status
            self.btnApply.isHidden = true
            self.participantCount = data?.appliedParticipants ?? 0
            if data?.status == 0{
                self.btnApply.isHidden = true
                self.btnMore.isHidden = false
               
            }else if data?.status == 1{
                
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                self.btnApply.setTitle("Complete", for: .normal)
                self.btnApply.backgroundColor =  UIColor.app
                self.btnApply.setTitleColor(UIColor.white, for: .normal)
                self.btnChat.isHidden = false
            }else if data?.status == 2{
                
                self.btnApply.isHidden = false
                self.btnMore.isHidden = true
                for i in data?.reviews ?? []{
                    if Store.userId == i.userID?.id{
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
            }else{
                self.btnMore.isHidden = true
                    self.btnApply.isHidden = false
                    self.btnApply.setTitle("Apply", for: .normal)
                    self.btnApply.backgroundColor =  UIColor.app
                    self.btnApply.setTitleColor(UIColor.white, for: .normal)
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
            self.lblAbout.numberOfLines = 2
            self.lblAbout.appendReadmore(after: self.textAbout, trailingContent: .readmore)
            self.lblAbout.sizeToFit()
            
            self.lblPlace.text = data?.place ?? ""
            
            if data?.participants == "0"{
                self.lblPrticipansCount.text = "No participant"
            }else if data?.participants == "1"{
                self.lblPrticipansCount.text = "\(data?.participants ?? "") Participant left"
            }else{
                self.lblPrticipansCount.text = "\(data?.participants ?? "") Participants left"
            }
            
            if data?.appliedParticipants ?? 0 == 0{
                self.btnParticipants.setTitle("No request", for: .normal)
            }else if data?.appliedParticipants ?? 0 == 1{
                self.btnParticipants.setTitle("\(data?.appliedParticipants ?? 0) New request", for: .normal)
            }else{
                self.btnParticipants.setTitle("\(data?.appliedParticipants ?? 0) New requests", for: .normal)
            }
            
            self.lblTitle.text = data?.title ?? ""
            let attributedString = NSMutableAttributedString(string: "Price  ")
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 6))
            let priceString = "$\(data?.price ?? 0)"
            let priceAttributeString = NSAttributedString(string: priceString, attributes: [.foregroundColor: UIColor.app])
            attributedString.append(priceAttributeString)
            self.lblPrice.attributedText = attributedString
            if data?.type == "worldwide"{
                self.btnGigType.setTitle("Worldwide", for: .normal)
            }else{
                self.btnGigType.setTitle("My location", for: .normal)
            }
            self.tblVwReiew.reloadData()
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
    
    func addTapGestureToLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        lblAbout.isUserInteractionEnabled = true
        lblAbout.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = lblAbout.text else { return }

              let readmore = (text as NSString).range(of: TrailingContent.readmore.text)
              let readless = (text as NSString).range(of: TrailingContent.readless.text)
              if gesture.didTap(label: lblAbout, inRange: readmore) {
                  lblAbout.appendReadLess(after: textAbout, trailingContent: .readless)
              } else if  gesture.didTap(label: lblAbout, inRange: readless) {
                  lblAbout.appendReadmore(after: textAbout, trailingContent: .readmore)
              } else { return }
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
                vc.isComing = 5
                vc.gigId = gigId
                vc.userId = providerUserId
                vc.userToUserGigDetail = userGigDetail
                for (index, review) in arrUserReview.enumerated() {
                    if Store.userId == review.userID?.id ?? ""{
                        vc.isUpdateReview = true
                        vc.userToUserGigReview = review
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
                        self.getBusinessGigDetailApi()
                        
                        
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
                            self.navigationController?.present(vc, animated: true)
                        }else{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                            vc.modalPresentationStyle = .overFullScreen
                            vc.isSelect = 20
                            vc.callBack = {[weak self] in
                                guard let self = self else { return }
                                SceneDelegate().GigListVCRoot()
                            }
                            self.navigationController?.present(vc, animated: true)
                        }
                        
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
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddGigVC") as! AddGigVC
                vc.isComing = false
                vc.gigDetail = self.businessGigDetail
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
            vc.userOwnerGigDetail = userGigDetail
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
    //{
        
//        guard let menu = sideMenu else { return }
//
//           var settings = SideMenuSettings()
//           settings.presentationStyle = .menuSlideIn
//        settings.presentDuration = 1.4
//        settings.dismissDuration = 1.4
//           settings.menuWidth = view.frame.width * 1.0
//           settings.statusBarEndAlpha = 0
//           settings.presentationStyle.backgroundColor = .white
//           settings.presentationStyle.presentingEndAlpha = 0.3
//           SideMenuManager.default.rightMenuNavigationController = menu
//           menu.settings = settings
//        DispatchQueue.global(qos: .userInitiated).async {
//            // Do heavy tasks like data fetching here
//            Store.gigDetail = ["gigId": self.gigId, "participantCount": self.participantCount, "userGigId": self.gigUserId]
//
//            DispatchQueue.main.async {
//                // Present menu on main thread after background work is done
//                self.present(menu, animated: true, completion: nil)
//            }
//        }
    //}
    
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
