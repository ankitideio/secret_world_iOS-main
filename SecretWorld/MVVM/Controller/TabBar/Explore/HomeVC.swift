//
//  HomeVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 13/02/25.
//

import UIKit
import Messages
import Pulsator
import JJFloatingActionButton
import VerticalSlider
import MapKit
import SwiftUI
import SDWebImage
import SocketIO
import MapboxMaps
import MapboxCommon
import MapboxCoreMaps
import Turf
import Solar



class HomeVC: UIViewController, JJFloatingActionButtonDelegate, GestureManagerDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var vwSearch: UIView!
    
    @IBOutlet weak var heightPopUpColl: NSLayoutConstraint!
    @IBOutlet weak var heightBusinessColl: NSLayoutConstraint!
    @IBOutlet weak var heightTaslTblVw: NSLayoutConstraint!
    @IBOutlet weak var bottomCenterVw: NSLayoutConstraint!
    @IBOutlet weak var topSearchVw: NSLayoutConstraint!
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet weak var vwSearchResult: UIView!
    @IBOutlet weak var vwResultFound: UIView!
    @IBOutlet weak var heightHeaderVw: NSLayoutConstraint!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var btnAllPopup: UIButton!
    @IBOutlet weak var btnAllBusiness: UIButton!
    @IBOutlet weak var btnAllTask: UIButton!
    @IBOutlet weak var vwRefresh: UIView!
    @IBOutlet weak var vwRecenter: UIView!
    @IBOutlet weak var lblWorldwideTask: UILabel!
    @IBOutlet weak var imgVwWorldwideTask: UIImageView!
    @IBOutlet weak var lblLocalTask: UILabel!
    @IBOutlet weak var imgVwLocalTask: UIImageView!
    @IBOutlet weak var vwWorldwideTask: UIView!
    @IBOutlet weak var vwLocalTask: UIView!
    @IBOutlet weak var vwPopup: UIView!
    @IBOutlet weak var vwBusiness: UIView!
    @IBOutlet weak var vwTask: UIView!
    @IBOutlet weak var collVwPopUp: UICollectionView!
    @IBOutlet weak var collVwBusiness: UICollectionView!
    @IBOutlet weak var collVwSelectType: UICollectionView!
    @IBOutlet weak var tblVwTask: UITableView!
    @IBOutlet weak var btnGigFilter: UIButton!
    @IBOutlet weak var btnStoreFilter: UIButton!
    @IBOutlet weak var btnBusinessFilter: UIButton!
    @IBOutlet weak var heightStackVw: NSLayoutConstraint!
    @IBOutlet weak var bottomStackVw: NSLayoutConstraint!
    @IBOutlet weak var topMapVw: NSLayoutConstraint!
    @IBOutlet weak var vwCustomMap: UIView!
    @IBOutlet weak var vwSelectType: UIView!
    @IBOutlet var imgVwEarnShadow: UIImageView!
    @IBOutlet weak var lblEarning: UILabel!
    @IBOutlet weak var vwEarning: UIView!
  
    
    
    //MARK: - VARIABLES
    private var currentLocationAnnotationManager: PointAnnotationManager?
    var mapAdded:Bool = false
    var stickers: [MSSticker] = []
    var isAnnotationViewVisible = false
    var isAppendHeatMap = false
    var isGigType = true
    var isPopupType = true
    var isBusinessType = true
    var currentDay:String?
    let locationManager = CLLocationManager()
    var arrData = [FilteredItem]()
    var arrTask = [FilteredItem]()
    var arrPopUp = [FilteredItem]()
    var arrBusiness = [FilteredItem]()
    var isSelectAnother = false
    var currentLat = 0.0
    var currentLong = 0.0
    var totalPage = 0
    var totalPrice = 0
    var viewModel = AddGigVM()
    var annotation:MKPointAnnotation!
    var circle: MKCircle!
    var movementTimer: Timer?
    let movementSpeed: Double = 0.01
    var activeTimers: [Coordinate: Timer] = [:]
    var homeListenerCall = false
    var selectItemSeen = 0
    var selectGigId = ""
    var isCustomAnnotationViewVisible = false
    var customButton = UIButton(type: .system)
    var mapRadius:Double = 10
    var minDitance = 0.0
    var maxDistance = 8046.72
    var restrictedRegion: MKCoordinateRegion?
    var gigAppliedStatus = 0
    var isReadyChat = 0
    var gigDetail:FilteredItem?
    var gigUserId = ""
    var gigIdForGroup = ""
    var groupId = ""
    var type = 4
    var pointAnnotationManager: PointAnnotationManager!
    var arrGigPointAnnotations: [PointAnnotation] = []
    var arrPopUpPointAnnotations: [PointAnnotation] = []
    var arrBusinessPointAnnotations: [PointAnnotation] = []
    var arrPoint = [Point]()
    var arrOverlapAnnotation = [CLLocationCoordinate2D]()
    private var cancelables = Set<AnyCancelable>()
    var isPopUpVCShown = false
    var isUploadData = false
    var isSelectType = 4
    private var solar: Solar?
    var selectLocationType:String = "myLocation"
    private var isChanged = false
    var moveTimer: Timer!
    private let clusterLayerID = "fireHydrantClusters"
    var customAnnotations: [ClusterPoint] = []
    var gigPopUpShow = false
    fileprivate let actionButton = JJFloatingActionButton()
    var mapView:MapView!
    var visibleIndex = 0
    let deviceHasNotch = UIApplication.shared.hasNotch
    var isSelectGigList = false
    var isSelectTask = false
    var lastZoomUpdateTime: TimeInterval = 0
    private var arrType = ["All","Task","Popup","Business"]
    private var typeIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationdata()
        bottomPopUpHeight(selectHome: true)
    }
    
    func locationdata(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            getDidLoadData()
        default:
            print("Location permission not determined")
        }
    }
    override func viewWillAppear(_ animated: Bool){
      
       
        Store.isSelectTab = false
        willAppear()
    }
    func willAppear(){
        if deviceHasNotch{
              if UIDevice.current.hasDynamicIsland {
                  if isSelectAnother{
                      
                       self.bottomStackVw.constant = 66
                   }else{
                     
                       self.bottomStackVw.constant = 110
                   }
              }else{
                bottomStackVw.constant = 104
              }
            }else{
              bottomStackVw.constant = 90
            }
        animateZoomInOut()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        currentDay = dateFormatter.string(from: Date())
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
            locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.getWillApearAllData()
        default:
            print("Location permission not determined")
        }
    }
   
    func bottomPopUpHeight(selectHome:Bool){
        if self.deviceHasNotch{
         
            if UIDevice.current.hasDynamicIsland {
               if isSelectAnother{
                    self.topMapVw.constant = -66
                    
                    self.bottomStackVw.constant = 66
                }else{
                    self.topMapVw.constant = -110
               
                    self.bottomStackVw.constant = 110
                }
               
                self.topSearchVw.constant = 10
               
                }else{
                self.topMapVw.constant = -104
                self.bottomStackVw.constant = 104
                self.topSearchVw.constant = 10
            }
        }else{
            if selectHome{
                self.topMapVw.constant = -88
                self.bottomStackVw.constant = 88
            }else{
                self.topMapVw.constant = -70
                self.bottomStackVw.constant = 70
            }
            self.topSearchVw.constant = 10
            
        }
    }
    func getWillApearAllData(){
        print("Token------",Store.authKey ?? "")
        homeListenerCall = false
        if Store.role == "b_user"{
            arrData.removeAll()
         
            vwEarning.isHidden = true
            vwSearch.isHidden = true
            vwSelectType.isHidden = true
            heightStackVw.constant = 0
            bottomCenterVw.constant = 20
//            viewGigList.isHidden = true
            socketData()
        }else{
            if type == 1{
                vwEarning.isHidden = false
            }else{
                vwEarning.isHidden = true
            }
            bottomCenterVw.constant = 10
            heightStackVw.constant = 100
            vwSearch.isHidden = false
            vwSelectType.isHidden = false
            socketData()
        }
    }
    
    
    
    func floatingActionButtonDidOpen(_ button: JJFloatingActionButton) {
        actionButton.buttonImage = UIImage(named: "more25")
        
    }
    func floatingActionButtonDidClose(_ button: JJFloatingActionButton) {
        actionButton.buttonImage = UIImage(named: "more25")
    }
    
    func getDidLoadData(){
        let nib = UINib(nibName: "StoreCVC", bundle: nil)
        collVwPopUp.register(nib, forCellWithReuseIdentifier: "StoreCVC")
        let nibBusiness = UINib(nibName: "PopularServicesCVC", bundle: nil)
        collVwBusiness.register(nibBusiness, forCellWithReuseIdentifier: "PopularServicesCVC")
        collVwBusiness.decelerationRate = .fast
        collVwPopUp.decelerationRate = .fast
        uiSet()
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationAllow(notification:)), name: Notification.Name("locationAllow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationDenied(notification:)), name: Notification.Name("locationDenied"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedGetTabBar(notification:)), name: Notification.Name("TabBar"), object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectOtherTab(notification:)), name: Notification.Name("SelectOther"), object: nil)
     

    }

    
    @objc func methodOfReceivedGetTabBar(notification: Notification) {
//        bottomPopUpHeight(selectHome: true)
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                if  isSelectAnother{
                    bottomStackVw.constant = 58
                    self.topMapVw.constant = -58
                }else{
                    bottomStackVw.constant = 58
                    self.topMapVw.constant = -58
                }
              
                self.topSearchVw.constant = 10
            }else{
                bottomStackVw.constant = 58
                self.topMapVw.constant = 0
                self.topSearchVw.constant = 10
            }
        }else{
            if  isSelectAnother{
                bottomStackVw.constant = 60
                self.topMapVw.constant = -60
            }else{
                bottomStackVw.constant = 70
                self.topMapVw.constant = -70
            }
        
            self.topSearchVw.constant = 10
        }
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
           // locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: true)
          
//            btnUpArrow.isSelected = false
            removeAllArray()
            homeListenerCall = false
            mapData(radius: mapRadius, type: type, gigType: Store.GigType ?? 0,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)
        default:
            print("Location permission not determined")
        }
    }
    @objc func selectOtherTab(notification: Notification) {
        isSelectAnother = true
        if deviceHasNotch{
            if UIDevice.current.hasDynamicIsland {
                bottomStackVw.constant = 84
                self.topMapVw.constant = 0
                self.topSearchVw.constant = 10
            }else{
                bottomStackVw.constant = 58
                self.topMapVw.constant = 0
                self.topSearchVw.constant = 100
            }
        }else{
            bottomStackVw.constant = 70
            self.topMapVw.constant = -70
            self.topSearchVw.constant = 10
        }
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
           // locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: true)
          

        default:
            print("Location permission not determined")
        }
    }
    
    @objc func getLocationDenied(notification:Notification){
        removeDataWhileLocationDenied()
    }
    func removeDataWhileLocationDenied(){
//        self.btnUpArrow.isHidden = true
        self.removeAllArray()
//        viewStoreList.isHidden = true
//        viewGigList.isHidden = true
//        viewBusinessList.isHidden = true
//
        vwRefresh.isHidden = true
        vwRecenter.isHidden = true
        
        tblVwTask.reloadData()
        collVwPopUp.reloadData()
        collVwBusiness.reloadData()
    }
    @objc func getLocationAllow(notification:Notification){
        self.dismiss(animated: false)
        getWillApearAllData()
        getDidLoadData()
    }
    
    func getWorlwideGigs(){
        mapView.viewAnnotations.removeAll()
        homeListenerCall = false
        mapView.viewAnnotations.removeAll()
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        removeAllArray()
        self.mapData(radius: self.mapRadius,
                     type: 1,
                     gigType:0,
                     lat: self.mapView.mapboxMap.cameraState.center.latitude,
                     long: self.mapView.mapboxMap.cameraState.center.longitude)
        self.getEarning(radius: self.mapRadius,
                        lat: self.mapView.mapboxMap.cameraState.center.latitude,
                        long: self.mapView.mapboxMap.cameraState.center.longitude)
        self.animateZoomInOut()
        
    }
    func getInmylocationGigs(){
        mapView.viewAnnotations.removeAll()
        homeListenerCall = false
        mapView.viewAnnotations.removeAll()
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        removeAllArray()
        self.mapData(radius: self.mapRadius,
                     type: 1,
                     gigType:1,
                     lat: self.mapView.mapboxMap.cameraState.center.latitude,
                     long: self.mapView.mapboxMap.cameraState.center.longitude)
        self.getEarning(radius: self.mapRadius,
                        lat: self.mapView.mapboxMap.cameraState.center.latitude,
                        long: self.mapView.mapboxMap.cameraState.center.longitude)
        self.animateZoomInOut()
        
    }
    
  
    
   
    func animateZoomInOut() {
        UIView.animate(withDuration: 3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.imgVwEarnShadow.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.imgVwEarnShadow.center = CGPoint(x: self.vwEarning.bounds.midX, y: self.vwEarning.bounds.midY)
        }) { (finished) in
            UIView.animate(withDuration: 3, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.imgVwEarnShadow.transform = CGAffineTransform.identity
                self.imgVwEarnShadow.center = CGPoint(x: self.vwEarning.bounds.midX, y: self.vwEarning.bounds.midY)
            }, completion: { _ in
                self.animateZoomInOut()
            })
        }
    }
    @objc func overlayTapped() {
        tappedAnyWhere()
        
    }
    func tappedAnyWhere(){
        if homeListenerCall{
            if type == 1{
                UIView.animate(withDuration: 0.5) {
//                    self.viewGigType.isHidden = true
                    if self.isSelectTask{
                        self.vwRecenter.isHidden = false
                        self.vwRefresh.isHidden = false
                    }

                }
            }else{
                UIView.animate(withDuration: 0.5) {
//                    self.viewGigType.isHidden = true
                    if self.isSelectTask{
                        self.vwRecenter.isHidden = false
                        self.vwRefresh.isHidden = false
                    }

                }

            }
        }
        
    }
    
    func addMapView(currentLat:Double,currentLong:Double){
        let mapInitOptions = MapInitOptions(
            cameraOptions: CameraOptions(
                center: CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong),
                zoom: 10
            )
        )
        
        DispatchQueue.main.async {
            self.mapView = MapView(frame: self.view.bounds, mapInitOptions: mapInitOptions)
            self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.vwCustomMap.addSubview(self.mapView)
            
            if let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong)) {
                self.solar = solar
                let isDaytime = solar.isDaytime
                print(isDaytime ? "It's day time!" : "It's night time!")
                if isDaytime{
                    if let styleURL = URL(string: "mapbox://styles/kevinzhang23a/cm2bod8mi00qg01pgepsohjq0") {
//                        self.mapView.mapboxMap.styleURI = .dark
                        self.mapView.mapboxMap.loadStyle(StyleURI(url: styleURL) ?? .light)
                    }
                    
                }else{
                    self.mapView.mapboxMap.styleURI = .dark
                }
            }
            self.mapView.ornaments.scaleBarView.isHidden = true
            self.mapView.ornaments.logoView.isHidden = true
            self.mapView.ornaments.attributionButton.isHidden = true
            
            self.mapView.gestures.delegate = self
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.overlayTapped))
            self.mapView.addGestureRecognizer(tapGesture)
        
            
            
        }
    }
    func addCurrentLocationMarker(location:CLLocationCoordinate2D) {
        // Create or reuse the annotation manager
        if currentLocationAnnotationManager == nil {
          currentLocationAnnotationManager = mapView.annotations.makePointAnnotationManager()
        }
        // Clear any existing annotations
        currentLocationAnnotationManager?.annotations = []
        // Create and add the new annotation
        let originalImage = UIImage(named: "blueDot")!
        let resizedImage = resizeImage(originalImage, to: CGSize(width: 35, height: 35))
        var pointAnnotation = PointAnnotation(coordinate: location)
        pointAnnotation.image = .init(image: resizedImage ?? UIImage(), name: "blueDot")
        currentLocationAnnotationManager?.annotations = [pointAnnotation]
      }
    func bounceCoinAnimation(view:UIView) {
        // Initial position
        let originalY = view.center.y
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            // Add keyframes for the bounce effect
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                view.center.y = originalY - 10 // Move up
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
                view.center.y = originalY // Move down
            }
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                view.transform = CGAffineTransform(scaleX: 1.1, y: 0.9) // Slight squish
            }
            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 0.1) {
                view.transform = .identity // Restore original scale
            }
        })
    }
    func startPulsingAnimation(on button: UIButton) {
        // Create a scaling animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.8
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        
        // Add the animation to the button's layer
        button.layer.add(scaleAnimation, forKey: "pulsing")
    }
    //MARK: - FUNCTIONS
    func uiSet(){
        print("Device Token---",Store.deviceToken ?? "")
//        if Store.role == "b_user"{
//            viewGigList.isHidden = true
//            viewNoMatch.isHidden = true
//        }else{
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            vwSelectType.addGestureRecognizer(panGesture)
//            let panGesturePopUp = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesturePopUp(_:)))
//            viewStoreList.addGestureRecognizer(panGesturePopUp)
//            let panGestureBusiness = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureBusiness(_:)))
//            viewBusinessList.addGestureRecognizer(panGestureBusiness)
//        }
        let nibNearBy = UINib(nibName: "GigNearByTVC", bundle: nil)
        tblVwTask.register(nibNearBy, forCellReuseIdentifier: "GigNearByTVC")
//        tblVwList.showsVerticalScrollIndicator = false
//        viewNoMatch.layer.cornerRadius = 20
//        viewNoMatch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        viewGigList.layer.cornerRadius = 35
//        viewGigList.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        viewGigList.layer.masksToBounds = false
//        viewGigList.layer.shadowColor = UIColor.black.cgColor
//        viewGigList.layer.shadowOffset = CGSize(width: 0, height: 0)
//        viewGigList.layer.shadowOpacity = 0.17
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func getMapRadiusInKilometers() -> CLLocationDistance {
        mapView.ornaments.scaleBarView.isHidden = true
        mapView.ornaments.logoView.isHidden = true
        let centerCoordinate = mapView.cameraState.center
        let topCenterPoint = CGPoint(x: mapView.bounds.midX, y: 0)
        let topCenterCoordinate = mapView.mapboxMap.coordinate(for: topCenterPoint)
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radiusInMeters = centerLocation.distance(from: topCenterLocation)
        let radiusInKilometers = radiusInMeters
        return radiusInKilometers
    }
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        switch gesture.state {
        case .changed:
            let velocity = gesture.velocity(in: self.view).y
            if velocity < 0 {
                self.vwLocalTask.isHidden = true
                self.vwWorldwideTask.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.vwRefresh.isHidden = true
                    self.vwRecenter.isHidden = true
                    self.mapView.viewAnnotations.removeAll()
                    self.actionButton.isHidden = true
                   
//                    self.btnGigFilter.isHidden = false
                   
                    if self.deviceHasNotch{
                        if UIDevice.current.hasDynamicIsland {
                            self.heightStackVw.constant = CGFloat(self.view.frame.height - 150)
                        }else{
                            self.heightStackVw.constant = CGFloat(self.view.frame.height - 140)
                        }
                    }else{
                      self.heightStackVw.constant = CGFloat(self.view.frame.height - 90)
                    }

                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    if self.isSelectType == 1{
                        self.vwLocalTask.isHidden = false
                        self.vwWorldwideTask.isHidden = false
                    }
                    if self.isSelectTask{
                        self.vwRecenter.isHidden = false
                        self.vwRefresh.isHidden = false
                    }
                 
//                    self.btnGigFilter.isHidden = false
                  
                    self.isSelectGigList = false
                    self.view.layoutIfNeeded()
                    self.heightStackVw.constant = 100
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.actionButton.isHidden = false
                    }
                }
            }
        default:
            break
    }
    }
  
    func getEarning(radius:Double,lat:Double,long:Double){
        if Store.GigType == 0 || Store.GigType == 1{
            let param: [String: Any] = [
                "deviceId":Store.deviceToken ?? "",
                "userId": Store.userId ?? "",
                "lat": "\(lat)",
                "long": "\(long)",
                "radius": radius,
                "gigType":Store.GigType ?? 0
            ]
            print("getEarningParam----", param)
            SocketIOManager.sharedInstance.getEarnings(dict: param)

        }else{
            let param: [String: Any] = [
                "deviceId":Store.deviceToken ?? "",
                "userId": Store.userId ?? "",
                "lat": "\(lat)",
                "long": "\(long)",
                "radius": radius,
            ]
            print("getEarningParam----", param)
            SocketIOManager.sharedInstance.getEarnings(dict: param)

        }
        SocketIOManager.sharedInstance.earningData = { data in
            if Store.role == "user" {
                self.lblEarning.text = "$\(data?[0].totalEarnings ?? 0)"
                
            }
        }
    }
    func convertKilometersToMiles(kilometers: Double) -> Double {
        return kilometers * 0.621371
    }
    func convertMilesToKilometers(miles: Double) -> Double {
        return miles / 1.60934
    }
    func mapData(radius: Double, type: Int, gigType: Int, lat: Double, long: Double) {
       
         guard let userId = Store.userId else { return }
//         var param: [String: Any] = ["userId": userId, "lat": lat, "long": long, "radius": radius, "type": type]
        var param: [String: Any] = ["userId": userId, "lat": lat, "long": long, "type": type]
         if Store.role == "user" {
             switch type {
             case 1: // Gig
                 if Store.isSelectGigFilter == true {
                    
                     param.merge(Store.filterData ?? [:]) { _, new in new }
                    
                     param = param.mapValues { value in
                         if let nsArray = value as? NSArray {
                             return nsArray.compactMap { $0 as? Int }
                         }
                         return value
                     }
                     let allDistances = Set([1,2,3])
                     let selectedDistances = Set(Store.taskMiles)
                     
                     if allDistances.isSubset(of: selectedDistances) {
                         print("All")
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = maxDistance
                     } else if selectedDistances == [1] {
                         print("Only 1")
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = maxDistance
                     }else if selectedDistances == [2] {
                         print("Only 2")
                       
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = maxDistance
                     } else if selectedDistances == [3] {
                         print("Only 3")
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = 1000000
//                         param.removeValue(forKey: "maxDistanceInMeters")
                     } else if selectedDistances == [1,2] {
                         print("Only 1,2")
                        
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = 24140.2
                     } else if selectedDistances == [2,3] {
                         print("Only 2,3")
                         param["maxDistanceInMeters"] = 1000000
                         param["minDistanceInMeters"] = minDitance
                        
                     } else if selectedDistances == [1,3] {
                         print("Only 1,3")
                       
                         param["minDistanceInMeters"] = minDitance
                         param["maxDistanceInMeters"] = maxDistance
                     }
                     param["gigType"] = gigType
                 }else{
                     param["minDistanceInMeters"] = minDitance
                     param["maxDistanceInMeters"] = maxDistance
                    param["gigType"] = gigType
                     
                 }
                 
             case 2: // Store
                 if Store.isSelectPopUpFilter == true {
                     param.merge(Store.filterDataPopUp ?? [:]) { _, new in new }
                     param = param.mapValues { value in
                         if let nsArray = value as? NSArray {
                             return nsArray.compactMap { $0 as? Int }
                         }
                         return value
                     }
                     param["minDistanceInMeters"] = minDitance
                     param["maxDistanceInMeters"] = maxDistance
                 }else{
                     param["minDistanceInMeters"] = minDitance
                     param["maxDistanceInMeters"] = maxDistance
                 }
             case 4: // Store
                 param["minDistanceInMeters"] = 0
                 param["maxDistanceInMeters"] = 100000
             default: // Business
                 if Store.isSelectBusinessFilter == true {
                     param.merge(Store.filterDataBusiness ?? [:]) { _, new in new }
                     param = param.mapValues { value in
                         if let nsArray = value as? NSArray {
                             return nsArray.compactMap { $0 as? Int }
                         }
                         return value
                     }
                     param["minDistanceInMeters"] = minDitance
                     param["maxDistanceInMeters"] = maxDistance
                 }else{
                     param["minDistanceInMeters"] = minDitance
                     param["maxDistanceInMeters"] = maxDistance
                 }
                 let param2: [String: Any] = ["userId": userId, "lat": lat, "long": long, "radius": radius]
             }
             print("Param-----",param)
             SocketIOManager.sharedInstance.home(dict: param)

             SocketIOManager.sharedInstance.homeData = { data in
                
                 guard let data = data, data.count > 0 else { return }
             
                 if !self.homeListenerCall {
                     self.updateData(from: data[0].data)
                 }
             }
         }else{
             var param: [String: Any] = ["userId": userId, "lat": lat, "long": long, "type": 4]
             param["minDistanceInMeters"] = 0
             param["maxDistanceInMeters"] = 100000
//             let param2: [String: Any] = ["userId": userId, "lat": lat, "long": long, "radius": radius]
             print("Param-----",param)
              SocketIOManager.sharedInstance.home(dict: param)

              SocketIOManager.sharedInstance.homeData = { data in
                  guard let data = data, data.count > 0 else { return }
                  print("Data------",data)
                  if !self.homeListenerCall {
                      self.updateData(from: data[0].data)
                  }
              }
         }

        
      
     }

     // Helper Methods
     private func updateData(from data: HomeData?) {
         guard let data = data else { return }
    
         // Update notifications count
         Store.userNotificationCount = data.notificationsCount ?? 0

         // Filter and append data
         let filteredItems = data.filteredItems ?? []
         let filteredItemIDs = Set(filteredItems.map { $0.id })
          
         self.arrData.removeAll { !filteredItemIDs.contains($0.id) }
         for item in filteredItems where !self.arrData.contains(where: { $0.id == item.id }) {
             
             self.arrData.append(item)
         }

         if Store.role == "user" {
             handleTypeUpdateUI(data: arrData)
         } else {
          
//             viewRefresh.isHidden = false
//             viewRecenter.isHidden = false
         }

         handlePaymentPopUp(data: data)
         updateAnnotations(from: filteredItems)
     }

     private func handlePaymentPopUp(data: HomeData) {
         guard !paymentPopUp, let paymentStatus = data.paymentStatus, paymentStatus == 0 else { return }
         let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentAlertVC") as! PaymentAlertVC
         vc.callBack = { [weak self] in
             guard let self = self else { return }
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
             vc.isComing = 2
             self.navigationController?.pushViewController(vc, animated: true)
         }
         vc.modalPresentationStyle = .overFullScreen
         navigationController?.present(vc, animated: true)
     }

    private func updateAnnotations(from items: [FilteredItem]) {
        print("Items----",items)
        
        for item in items {
            let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
            if Store.role == "user"{
                switch isSelectType {
                case 1: // Gig
                    let userId = item.userID
                    if Store.userId == userId{
                        
                        self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: 2))
                    }else{
                        
                        self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: item.seen ?? 0))
                    }
                    processGigImageAndAnnotation(for: item)
                case 2: // Business
                    downloadBusinessImage(for: item)
                case 4:
                    handlePopupAnnotation(for: item)
                    let userId = item.userID
                    if Store.userId == userId{
                        
                        self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: 2))
                    }else{
                        
                        self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: item.seen ?? 0))
                    }
                    processGigImageAndAnnotation(for: item)
                    downloadBusinessImage(for: item)
                 
                default: // Popup
                    handlePopupAnnotation(for: item)
                }
                
                
            }else{
                let userId = item.userID
                if Store.userId == userId{
                    
                    self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: 2))
                }else{
                    
                    self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0 ), price: Int(item.price ?? 0), seen: item.seen ?? 0))
                }
                processGigImageAndAnnotation(for: item)
                downloadBusinessImage(for: item)
                handlePopupAnnotation(for: item)
            }
            if pointAnnotationManager == nil {
                pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
                pointAnnotationManager?.delegate = self
            }
            
            homeListenerCall = true
        }
    }
     private func handlePopupAnnotation(for item: FilteredItem) {
         downloadPopUpImage(for: item)
     }

     private func processGigImageAndAnnotation(for item: FilteredItem) {
         let uniqueID = "gig_\(item.id ?? "")"
         let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
         
         if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
             arrPoint.append(Point(centerCoordinate))
             isAppendHeatMap = true
         }
         
         let width = calculateGigImageWidth(for: Double(item.price ?? 0))
         guard let originalImage = UIImage(named: item.seen == 1 ? "seeGig" : "seeGig") else { return }
         let resizedImage = resizeGigImage(originalImage, to: Int(item.price ?? 0), withTitle: "", width: Int(width), height: Int(width))

         let pointAnnotation = createPointAnnotation(for: centerCoordinate, withImage: resizedImage, uniqueID: uniqueID)
         updateGigAnnotations(with: pointAnnotation, uniqueID: uniqueID)
     }

     private func calculateGigImageWidth(for price: Double) -> CGFloat {
         switch price {
         case ..<10: return 30
         case ..<100: return 45
         case ..<1000: return 55
         case ..<10000: return 65
         default: return 75
         }
     }

     private func createPointAnnotation(for coordinate: CLLocationCoordinate2D, withImage image: UIImage, uniqueID: String) -> PointAnnotation {
         var pointAnnotation = PointAnnotation(coordinate: coordinate)
         pointAnnotation.image = .init(image: image, name: uniqueID)
         return pointAnnotation
     }

     private func updateGigAnnotations(with pointAnnotation: PointAnnotation, uniqueID: String) {
         if let existingIndex = arrGigPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
             arrGigPointAnnotations[existingIndex] = pointAnnotation
         } else {
             let clusterManager = ClusterManager(mapView: self.mapView)
             clusterManager.removeClusters()
             DispatchQueue.main.async {
                 clusterManager.addClusters(with: self.customAnnotations)
             }
             arrGigPointAnnotations.append(pointAnnotation)
         }

         DispatchQueue.main.async {
             self.pointAnnotationManager?.annotations = self.arrGigPointAnnotations
         }
     }
  
    func downloadPopUpImage(for item: FilteredItem) {
        let uniqueID = "popup_\(item.id ?? "")"
        let logoURL = URL(string: (item.businessLogo ?? item.image) ?? "")
        
        guard let logoURL = logoURL else {
            print("Invalid URL")
            return
        }
        
        SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] downloadedImage, _, _, error in
            guard let self = self else { return }
            guard let downloadedImage = downloadedImage else {
                print("Failed to download image")
                return
            }
      
            // Remove background and process image on a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    
                    let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
                    
                    if !self.arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                        self.arrPoint.append(Point(centerCoordinate))
                        self.isAppendHeatMap = true
                    }
                    
                    // Combine images on the background thread as well
                    let combinedImage = self.combineImagesPopUp(overlayImage: UIImage(named: "newPopUp") ?? UIImage(), overlaySize: CGSize(width: 60, height: 70))

                    guard let combinedImage = combinedImage else {
                        print("Failed to create combined image")
                        return
                    }
                    
                    // Switch back to the main thread for UI updates
                    DispatchQueue.main.async {
                        let pointAnnotation = self.createPointAnnotation(for: centerCoordinate, withImage: combinedImage, uniqueID: uniqueID)
                        self.updatePopUpAnnotations(with: pointAnnotation, uniqueID: uniqueID)
                    }
                } catch {
                    print("Error processing background removal: \(error)")
                }
            }
        }
    }

         private func updatePopUpAnnotations(with pointAnnotation: PointAnnotation, uniqueID: String) {
             if let existingIndex = arrPopUpPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
                 arrPopUpPointAnnotations[existingIndex] = pointAnnotation
             } else {
                 arrPopUpPointAnnotations.append(pointAnnotation)
             }

             DispatchQueue.main.async {
                 if self.mapView.mapboxMap.cameraState.zoom > 7 {
                     self.pointAnnotationManager?.annotations = self.arrPopUpPointAnnotations
                 } else {
                     self.pointAnnotationManager?.annotations = []
                 }
             }
         }

     func downloadBusinessImage(for item: FilteredItem) {
         
         let uniqueID = "business_\(item.id ?? "")"
         guard let logoURL = URL(string: item.profilePhoto ?? "") else {
             print("Invalid business image URL")
             return
         }

         let centerCoordinate = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
         if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
             arrPoint.append(Point(centerCoordinate))
             self.isAppendHeatMap = true
         }

         SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
             guard let self = self else { return }
             guard let overlayImage = overlayImage else { return }
             
             let resizedOverlayImage = self.resizeImage(overlayImage, to: CGSize(width: 25, height: 25))
             let combinedImage = self.combineImages(baseImage: UIImage(named: "business")!, overlayImage: resizedOverlayImage ?? UIImage(), baseSize: CGSize(width: 34, height: 45), overlaySize: CGSize(width: 25, height: 25), type: "business")
             
             let pointAnnotation = self.createPointAnnotation(for: centerCoordinate, withImage: combinedImage ?? UIImage(), uniqueID: uniqueID)
             self.updateBusinessAnnotations(with: pointAnnotation, uniqueID: uniqueID)
         }
     }
   
     private func updateBusinessAnnotations(with pointAnnotation: PointAnnotation, uniqueID: String) {
         if let existingIndex = arrBusinessPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
             arrBusinessPointAnnotations[existingIndex] = pointAnnotation
         } else {
             arrBusinessPointAnnotations.append(pointAnnotation)
         }

         DispatchQueue.main.async {
             if self.mapView.mapboxMap.cameraState.zoom > 7 {
                 self.pointAnnotationManager?.annotations = self.arrBusinessPointAnnotations
             } else {
                 self.pointAnnotationManager?.annotations = []
             }
         }
     }
    
    func heatMapLayer() {
        let currentTime = Date().timeIntervalSince1970
        guard currentTime - lastZoomUpdateTime > 0.5 else { return } // Debounce for 0.5 seconds
        
        lastZoomUpdateTime = currentTime
        if type != 1 {
            let zoomLevel = self.mapView.mapboxMap.cameraState.zoom
            print("Current zoom level: \(zoomLevel)")
            
            let clusterManager = ClusterManager(mapView: self.mapView)
            
            if zoomLevel < 7 {
                // Remove all existing annotations
                self.pointAnnotationManager?.annotations = []
                self.arrPopUpPointAnnotations.removeAll()
                self.arrBusinessPointAnnotations.removeAll()
                self.arrGigPointAnnotations.removeAll()
                print("All annotations removed.")
                
                guard !self.arrPoint.isEmpty else {
                    print("No points to create earthquake source.")
                    return
                }
                
                // Create the heatmap layer
                clusterManager.removeExistingLayersAndSources()
                clusterManager.createEarthquakeSource(arrFeature: self.arrPoint)
                clusterManager.createHeatmapLayer()
                
                self.isAppendHeatMap = false
                print("Heatmap layer created.")
            } else {
                // Remove the heatmap layer and restore annotations for zoom level >= 5
                clusterManager.removeExistingLayersAndSources()
                print("Heatmap layers and sources removed for zoom level >= 5.")
                
                // Optionally restore annotations if needed
                if type == 2 {
                    self.pointAnnotationManager?.annotations = self.arrPopUpPointAnnotations
                } else {
                    self.pointAnnotationManager?.annotations = self.arrBusinessPointAnnotations
                }
                
                print("Annotations restored.")
            }
        }
    }
     
     func handleTypeUpdateUI(data:[FilteredItem]){
         if type == 1{
             let filteredPrices = data.compactMap { $0.price }
             let totalPrice = filteredPrices.reduce(0, +)
             if self.arrData.count > 0{
                 self.lblEarning.text = "$\(totalPrice)"
             }else{
                 let clusterManager = ClusterManager(mapView: self.mapView)
                 clusterManager.removeClusters()
                 self.lblEarning.text = "$\(0)"
             }
           
             if self.arrData.count > 0 {
               
                 if !(Store.isSelectTab ?? false){
//                     self.viewGigList.isHidden = false
                     if self.isSelectGigList{
                      
                         self.vwRefresh.isHidden = true
                         self.vwRecenter.isHidden = true
                         self.mapView.viewAnnotations.removeAll()
                        
                         self.actionButton.isHidden = true
//                         self.btnGigFilter.isHidden = true
                      
//                         self.btnUpArrow.setImage(UIImage(named:"bottomarrow"), for: .normal)
                         self.tblVwTask.isScrollEnabled = true
//                         self.btnUpArrow.isSelected = true
//                         if self.viewGigType.isHidden == false{
//                             self.viewGigType.isHidden = true
                             self.vwRefresh.isHidden = true
                             self.vwRecenter.isHidden = true
//
//                         }
                     }else{
                         if (self.isSelectTask){
                             self.vwRecenter.isHidden = false
                             self.vwRefresh.isHidden = false
                         }
//
//                         self.btnGigFilter.isHidden = true
//                         self.btnUpArrow.setImage(UIImage(named:"uparrow"), for: .normal)
                         self.tblVwTask.isScrollEnabled = false
//                         self.btnUpArrow.isSelected = false
                    
                         self.view.layoutIfNeeded()
                      
                         DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                             self.actionButton.isHidden = false
                         }
                     }
                    
//                     self.viewNoMatch.isHidden = true
//                     self.bottomStackVwRefreshAndRecenter.constant = 10
                     
                 }
             } else {
                 self.arrGigPointAnnotations.removeAll()
//                 self.bottomStackVwRefreshAndRecenter.constant = 20
                 let clusterManager = ClusterManager(mapView: self.mapView)
                 clusterManager.removeClusters()
//                 if !(Store.isSelectTab ?? false){
//
//                     self.viewGigList.isHidden = true
//                     self.viewNoMatch.isHidden = true
//                 }
             }
           
             self.tblVwTask.reloadData()
         }else if type == 2{
             
             
             //             self.viewNoMatch.isHidden = true
             //             self.viewGigList.isHidden = true
             
             if self.arrData.count > 0{
                 //                 if self.viewStoreList.isHidden{
                 //                     self.bottomStackVwRefreshAndRecenter.constant = 20
                 //                 }else{
                 //                     self.bottomStackVwRefreshAndRecenter.constant = 10
                 //                 }
                 
             }else{
                 self.arrPopUpPointAnnotations.removeAll()
                 //                 self.bottomStackVwRefreshAndRecenter.constant = 20
                 
             }
             self.collVwPopUp.reloadData()
         }else if type == 4{
             for i in arrData{
                 if i.type == "gig"{
                     self.arrTask.append(i)
                 }else if i.type == "popUp"{
                     self.arrPopUp.append(i)
                 }else{
                     self.arrBusiness.append(i)
                 }
             }
             if arrTask.count == 0{
                 self.heightTaslTblVw.constant = CGFloat(0)
                 self.btnAllTask.isHidden = true
                 self.vwTask.isHidden = true
             }else if arrTask.count < 2{
                 self.heightTaslTblVw.constant = CGFloat(arrTask.count*130)
                 self.btnAllTask.isHidden = true
                 self.vwTask.isHidden = false
             }else{
                 self.heightTaslTblVw.constant = 260
                 self.btnAllTask.isHidden = false
                 self.vwTask.isHidden = false
             }
             if arrPopUp.count == 0{
                 self.heightPopUpColl.constant = CGFloat(0)
                 self.btnAllPopup.isHidden = true
                 self.vwPopup.isHidden = true
             }else if arrPopUp.count < 2{
                 self.heightPopUpColl.constant = CGFloat(arrPopUp.count*100)
                 self.btnAllPopup.isHidden = true
                 self.vwPopup.isHidden = false
             }else{
                 self.heightPopUpColl.constant = 200
                 self.btnAllPopup.isHidden = false
                 self.vwPopup.isHidden = false
             }
             if arrBusiness.count == 0{
                 self.heightBusinessColl.constant = CGFloat(0)
                 self.btnAllBusiness.isHidden = true
                 self.vwBusiness.isHidden = true
             }else if arrBusiness.count < 2{
                 self.heightBusinessColl.constant = CGFloat(arrBusiness.count*100)
                 self.btnAllBusiness.isHidden = true
                 self.vwBusiness.isHidden = false
             }else{
                 self.heightBusinessColl.constant = 200
                 self.btnAllBusiness.isHidden = false
                 self.vwBusiness.isHidden = false
             }
             self.tblVwTask.reloadData()
             self.collVwBusiness.reloadData()
             self.collVwPopUp.reloadData()
         }else{
            
             if self.arrData.count > 0{
//                 if self.viewBusinessList.isHidden{
//                     self.bottomStackVwRefreshAndRecenter.constant = 20
//                 }else{
//                     self.bottomStackVwRefreshAndRecenter.constant = 10
//                 }
//
               
             }else{
//                 self.bottomStackVwRefreshAndRecenter.constant = 20
              
                 self.arrBusinessPointAnnotations.removeAll()
            
             }
           
//             self.viewNoMatch.isHidden = true
//             self.viewGigList.isHidden = true
             self.collVwBusiness.reloadData()
          
           

         }
     }
  
   
  
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
      defer { UIGraphicsEndImageContext() }
      image.draw(in: CGRect(origin: .zero, size: size))
      return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizeImagePopUp(_ image: UIImage, to size: CGSize, withText text: String, at point: CGPoint) -> UIImage? {
        // Set up text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 6), // Adjust font size
            .foregroundColor: UIColor.white // Adjust text color
        ]
        
        // Calculate text size
        let textSize = text.size(withAttributes: attributes)
        print("Text size: \(textSize)") // Debugging
        
        // Adjust the image width based on the text size
        let adjustedWidth = max(size.width, textSize.width+20)
        let adjustedHeight = size.height

        // Start graphics context with adjusted size
        UIGraphicsBeginImageContextWithOptions(CGSize(width: adjustedWidth, height: adjustedHeight), false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw the resized image to fit the adjusted size
        image.draw(in: CGRect(origin: .zero, size: CGSize(width: adjustedWidth, height: adjustedHeight)))
        
        // Calculate the text position (centered horizontally, 20 points from bottom)
        let textRect = CGRect(
            x: (adjustedWidth - textSize.width) / 2,
            y: max(0, adjustedHeight - textSize.height - 22),
            width: textSize.width,
            height: textSize.height
        )
        
        print("Text Rect: \(textRect)") // Debugging
        text.draw(in: textRect, withAttributes: attributes)
        
        // Retrieve the new image with text
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizeGigImage(_ image: UIImage, to price: Int, withTitle title: String, width: Int, height: Int) -> UIImage {
        let size = CGSize(width: width, height: height)
        
        // Begin image context for drawing
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // Create a circular path and clip the context to make the resulting image round
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        context?.addPath(circlePath.cgPath)
        context?.clip()
        
        // Draw the resized image into the clipped context
        image.draw(in: CGRect(origin: .zero, size: size))
        
        // Determine text color based on daytime/nighttime logic
        var textColor: UIColor = .white
        if let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)) {
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
        
        // Draw the text into the circular image
        let titleText = NSString(string: title)
        titleText.draw(in: textRect, withAttributes: textAttributes)
        
        // Retrieve the resulting rounded image
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage ?? image
    }
    


    func combineImagesPopUp(
        overlayImage: UIImage,
        overlaySize: CGSize
    ) -> UIImage? {
        // Set up text attributes
       
        let adjustedBaseSize = CGSize(width: overlaySize.width, height:overlaySize.height )

        // Start graphics context with adjusted base size
        UIGraphicsBeginImageContextWithOptions(adjustedBaseSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to create graphics context.")
            return nil
        }
        
        // Draw the base image with the adjusted size
        overlayImage.draw(in: CGRect(origin: .zero, size: adjustedBaseSize))
        
        // Draw the overlay image
        let overlayOrigin = CGPoint(x: (adjustedBaseSize.width - overlaySize.width) / 2, y: 8)
        let overlayRect = CGRect(origin: overlayOrigin, size: overlaySize)
        let path = UIBezierPath(ovalIn: overlayRect)
        context.saveGState()
        path.addClip()
        overlayImage.draw(in: overlayRect)
        context.restoreGState()
        
       
        
        // Get the combined image from the context
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    func popUpTime(endTime: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Parse the end time into a Date object
        if let endTime = dateFormatter.date(from: endTime) {
            // Get the current date and time
            let currentTime = Date()

            // Calculate the difference in hours and minutes
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: currentTime, to: endTime)
            
            if let hours = components.hour, let minutes = components.minute {
                // Return the difference as a string
                return "\(hours)h \(minutes)m"
            } else {
                return "Could not calculate the difference."
            }
        } else {
            return "0h 0m"
        }
    }
    func combineImages(baseImage: UIImage, overlayImage: UIImage, baseSize: CGSize, overlaySize: CGSize, overlayPosition: CGPoint? = nil,type:String) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(baseSize, false, 0.0)
      baseImage.draw(in: CGRect(origin: .zero, size: baseSize))
      let overlayOrigin = overlayPosition ?? CGPoint(
        x: (baseSize.width - overlaySize.width) / 2,
        y: type == "business" ? 3 : 8
      )
      let overlayFrame = CGRect(origin: overlayOrigin, size: overlaySize)
      let path = UIBezierPath(ovalIn: overlayFrame)
      path.addClip()
      overlayImage.draw(in: overlayFrame)
      let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return combinedImage
    }
     

   
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        
        print("DidBegan")
       

        self.vwLocalTask.isHidden = true
        self.vwWorldwideTask.isHidden = true
        self.isSelectGigList = false

        NotificationCenter.default.post(name: Notification.Name("touchMap"), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()){
            if self.gigPopUpShow == true{
                if self.mapView.viewAnnotations.allAnnotations.count > 0{
                    self.mapView.viewAnnotations.removeAll()
                    self.gigPopUpShow = false
                }
            }
        }
      
    }
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        heatMapLayer()
        print("didendanimate")
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
            //locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
        let radius = getMapRadiusInKilometers()
            
        mapRadius = radius
            if (Store.isSelectGigFilter ?? false){
                let allDistances = Set([1,2,3])
                let selectedDistances = Set(Store.taskMiles)
                
                if allDistances.isSubset(of: selectedDistances) {
                    minDitance = 0
                    maxDistance = radius
                } else if selectedDistances == [1] {
                    minDitance = 0
                    maxDistance = radius
                }else if selectedDistances == [2] {
                    minDitance = 0
                    maxDistance = radius
                } else if selectedDistances == [3] {
                    minDitance = radius
                    maxDistance = 1000000
                } else if selectedDistances == [1,2] {
                    minDitance = 0
                    maxDistance = radius
                } else if selectedDistances == [2,3] {
                    minDitance = radius
                    
                    maxDistance = 1000000
                } else if selectedDistances == [1,3] {
                    print("Only 1,3")
                    minDitance = 0
                    maxDistance = radius
                }
            }else{
                minDitance = 0
                maxDistance = radius
            }
        print("Radius of visible map area: \(radius) km\(mapView.mapboxMap.cameraState.center.latitude)")
            
            homeListenerCall = false
            mapData(radius: mapRadius, type: type, gigType: Store.GigType ?? 0,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)
          
        if Store.role == "user"{
            if type == 1{
                getEarning(radius: mapRadius,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)
            }
        }
        default:
            print("Location permission not determined")
        }
 
    }
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        heatMapLayer()
        print("didendanimate")
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
            //locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
        let radius = getMapRadiusInKilometers()
        mapRadius = radius
        print("Radius of visible map area: \(radius) km\(mapView.mapboxMap.cameraState.center.latitude)")
            homeListenerCall = false
            mapData(radius: mapRadius, type: type, gigType: Store.GigType ?? 0,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)

        if Store.role == "user"{
            if type == 1{
                getEarning(radius: mapRadius,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)
            }
        }
        default:
            print("Location permission not determined")
        }
       
    }
   
  

    func socketData(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            if SocketIOManager.sharedInstance.socket?.status == .connected{
                self.mapData(radius: self.mapRadius, type: self.type, gigType: Store.GigType ?? 0,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
                if self.type == 1{
                    
                    self.getEarning(radius: self.mapRadius,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
                    
                    if Store.GigType == 0{
                        self.worldwideSetup()
                    }else{
                        self.myLocationSetup()
                    }
                }
                
            }else{
                SocketIOManager.sharedInstance.reConnectSocket(userId: Store.userId ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now()+4.0){
                    self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
                    if self.type == 1{
                        self.getEarning(radius: self.mapRadius,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
                    }
                }
            }
        }
    }
    func combineImages(backgroundImage: UIImage, foregroundImage: UIImage, backgroundSize: CGSize, foregroundSize: CGSize, type: String) -> UIImage? {
        let size = backgroundSize
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // Draw background image
        backgroundImage.draw(in: CGRect(origin: .zero, size: size))
        // Calculate position for foreground image (centered)
        let x = (size.width - foregroundSize.width) / 2.0
        let y: CGFloat
        switch type {
        case "popUp":
            y = (size.height - foregroundSize.height) / 2.0
//        case "currentLocation":
//            y = 6  // Adjust as needed
        default:
            y = 2  // Adjust as needed
        }
        // Draw foreground image
        drawRoundedImage(image: foregroundImage, frame: CGRect(x: x, y: y, width: foregroundSize.width, height: foregroundSize.height))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }
    func drawRoundedImage(image: UIImage, frame: CGRect) {
        guard UIGraphicsGetCurrentContext() != nil else { return }
        let path = UIBezierPath(roundedRect: frame, cornerRadius: frame.size.width / 2)  // Adjust corner radius if needed
        path.addClip()
        image.draw(in: frame)
    }
    func loadForegroundImage(from url: URL, placeholder: UIImage? = nil, completion: @escaping (UIImage?) -> Void) {
        // Show placeholder image immediately if provided
        completion(placeholder)
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .highPriority,
            progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                if let image = image {
                    completion(image)
                } else {
                    // Optionally handle errors or provide a default image
                    completion(nil)
                }
            }
    }
    func indexOfItem(withId id: String, in array: [FilteredItem]) -> Int? {
        return array.firstIndex { $0.id == id }
    }
    func setupMapWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        currentLat = coordinate.latitude
        currentLong = coordinate.longitude
        if Store.role == "user"{
            if addPopUp == false{
                myPopUpLat = coordinate.latitude
                myPopUpLong = coordinate.longitude
            }
        }else{
            if addPopUp == false{
                myPopUpLat = Store.businessLatLong?["lat"] as? Double ?? 0.0
                myPopUpLong = Store.businessLatLong?["long"] as? Double ?? 0.0
            }
        }
        let centerCoordinate = CLLocationCoordinate2D(latitude: myPopUpLat, longitude:myPopUpLong )
        let regionRadius: CLLocationDistance = 1100 // 1000 meters (1km) radius
        let coordinateRegion = MKCoordinateRegion(
            center: centerCoordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        Store.connectSocket = true
        if !(Store.tabBarNotificationPosted ?? false){
            Store.tabBarNotificationPosted = true
        }
        if Store.role != "b_user"{
//                if self.arrData.count > 0 {
//                    self.viewNoMatch.isHidden = true
//                } else {
//                    self.viewNoMatch.isHidden = true
//                }
        }
    }

    func updateMapRegion(withRadius radius: Double) {
        let centerCoordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
        let radiusInMeters = radius * 1000 // Convert to meters
        print("Radius in meters: \(radiusInMeters)")
        
        let region = MKCoordinateRegion(center: centerCoordinate,
                                        latitudinalMeters: radiusInMeters * 2,
                                        longitudinalMeters: radiusInMeters * 2)
        if CLLocationCoordinate2DIsValid(centerCoordinate) {
            restrictMapVisibleArea(to: region, radiusInMeters: radiusInMeters)
            restrictedRegion = region // Store the restricted region
        } else {
            print("Invalid coordinate or region.")
        }
    }

    func restrictMapVisibleArea(to region: MKCoordinateRegion, radiusInMeters: Double) {
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + (region.span.latitudeDelta / 2),
            longitude: region.center.longitude - (region.span.longitudeDelta / 2)
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - (region.span.latitudeDelta / 2),
            longitude: region.center.longitude + (region.span.longitudeDelta / 2)
        )
        let mapBoundary = MKMapRect(
            origin: MKMapPoint(topLeft),
            size: MKMapSize(width: fabs(MKMapPoint(bottomRight).x - MKMapPoint(topLeft).x),
                            height: fabs(MKMapPoint(bottomRight).y - MKMapPoint(topLeft).y))
        )
        let boundary = MKCoordinateRegion(mapBoundary)
        // Print radius to debug
        print("Restricting map with radius (meters): \(radiusInMeters)")
    }


    
    //MARK: - BUTTON ACTION
    
    
    @IBAction func actionBackSearch(_ sender: UIButton) {
        UIView.animate(withDuration: 0.0) {
            self.vwLocalTask.isHidden = false
            self.vwWorldwideTask.isHidden = false
            if self.isSelectTask{
                self.vwRecenter.isHidden = false
                self.vwRefresh.isHidden = false
            }
         
//            self.btnGigFilter.isHidden = false
          
            self.view.layoutIfNeeded()
            self.heightStackVw.constant = 100
//            self.btnGigFilter.isHidden = true
            self.vwSelectType.isHidden = false
            self.vwResultFound.isHidden = true
            self.vwHeader.isHidden = true
            self.vwSearchResult.isHidden = true
            self.heightHeaderVw.constant = 0
        }
    }
    @IBAction func actionSearch(_ sender: UIButton) {
        self.vwLocalTask.isHidden = true
        self.vwWorldwideTask.isHidden = true
        UIView.animate(withDuration: 0.0) {
            self.vwRefresh.isHidden = true
            self.vwRecenter.isHidden = true
            self.mapView.viewAnnotations.removeAll()
            self.actionButton.isHidden = true
           
            self.btnGigFilter.isHidden = false
            self.vwSelectType.isHidden = true
            self.vwResultFound.isHidden = false
            self.vwHeader.isHidden = false
            self.vwSearchResult.isHidden = false
            if self.deviceHasNotch{
                if UIDevice.current.hasDynamicIsland {
                    self.heightStackVw.constant = CGFloat(self.view.frame.height-80)
                    self.heightHeaderVw.constant = 76
                }else{
                    self.heightStackVw.constant = CGFloat(self.view.frame.height-90)
                    self.heightHeaderVw.constant = 46
                }
            }else{
                self.heightStackVw.constant = CGFloat(self.view.frame.height-64)
                self.heightHeaderVw.constant = 40
            }
        

            self.view.layoutIfNeeded()
        }
    }
    @IBAction func actionInMyLocation(_ sender: UIButton) {
        self.dismiss(animated: true)
//            viewInMyLocation.animateRefreshAndRecenter()
            Store.GigType = 1
//            viewGigList.isHidden = false
        vwLocalTask.isHidden = true
        vwWorldwideTask.isHidden = true
            getInmylocationGigs()
            myLocationSetup()
        
    }
    func myLocationSetup(){
        isSelectTask = true
        vwRefresh.isHidden = false
        vwRecenter.isHidden = false
        vwWorldwideTask.borderWid = 1
        vwWorldwideTask.borderCol = .app
        lblLocalTask.textColor = .white
        lblWorldwideTask.textColor = .app
        vwLocalTask.backgroundColor = .app
        imgVwLocalTask.image = UIImage(named: "inMySel")
        vwWorldwideTask.backgroundColor = .white
        imgVwWorldwideTask.image = UIImage(named: "world")
        
    }
    @IBAction func actionWorldWide(_ sender: UIButton) {
        self.dismiss(animated: true)
//            viewWorldwide.animateRefreshAndRecenter()
            Store.GigType = 0
//            viewGigList.isHidden = false
        vwLocalTask.isHidden = true
        vwWorldwideTask.isHidden = true
            getWorlwideGigs()
            worldwideSetup()
        
    }
    func worldwideSetup(){
        isSelectTask = true
        vwRefresh.isHidden = false
        vwRecenter.isHidden = false
        vwLocalTask.borderWid = 1
        vwLocalTask.borderCol = .app
        lblWorldwideTask.textColor = .white
        lblLocalTask.textColor = .app
        vwLocalTask.backgroundColor = .white
        imgVwLocalTask.image = UIImage(named: "inmy")
        vwWorldwideTask.backgroundColor = .app
        imgVwWorldwideTask.image = UIImage(named: "worldSel")
        
    }
   
    @IBAction func actionFilter(_ sender: UIButton) {
        let  vc = self.storyboard?.instantiateViewController(withIdentifier: "AllFilterVC") as! AllFilterVC
        vc.modalPresentationStyle = .overFullScreen
        vc.type = self.type
        
        vc.callBack = { (distance) in
            self.homeListenerCall = false
            if self.type == 1{
                self.getGigData()
                if (Store.isSelectGigFilter ?? false){
                    self.minDitance = Store.filterData?["minDistanceInMeters"] as? Double ?? 0
                    self.maxDistance = Store.filterData?["maxDistanceInMeters"] as? Double ?? 8046.72
                    let mapWidth = self.mapView.bounds.width
                    print(Store.filterData?["minDistanceInMeters"] as? Double ?? 0)
                    print(Store.filterData?["maxDistanceInMeters"] as? Double ?? 8046.72)
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: (distance ?? 8046.72)/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }else{
                    self.minDitance = 0
                    self.maxDistance = 8046.72
                    let mapWidth = self.mapView.bounds.width
                    
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: self.maxDistance/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }
            }else if self.type == 2{
                self.getStoreData()
                if (Store.isSelectGigFilter ?? false){
                    self.minDitance = Store.filterDataPopUp?["minDistanceInMeters"] as? Double ?? 0
                    self.maxDistance = Store.filterDataPopUp?["maxDistanceInMeters"] as? Double ?? 8046.72
                    let mapWidth = self.mapView.bounds.width
                 
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: (distance ?? 8046.72)/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }else{
                    self.minDitance = 0
                    self.maxDistance = 8046.72
                    let mapWidth = self.mapView.bounds.width
                    
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: self.maxDistance/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }

            }else if self.type == 3{
                if (Store.isSelectBusinessFilter ?? false){
                    self.minDitance = Store.filterDataBusiness?["minDistanceInMeters"] as? Double ?? 0
                    self.maxDistance = Store.filterDataBusiness?["maxDistanceInMeters"] as? Double ?? 8046.72
                    let mapWidth = self.mapView.bounds.width
                 
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: (distance ?? 8046.72)/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }else{
                    self.minDitance = 0
                    self.maxDistance = 8046.72
                    let mapWidth = self.mapView.bounds.width
                    
                    self.mapRadius = Double(radius)
                    // Calculate the zoom level
                  
                    let zoom = self.zoomLevel(from: self.maxDistance/1000, mapViewWidth: mapWidth)
                    print("Zoom Level: \(zoom), Radius: \(radius) km")
                    let cameraOptions = CameraOptions(
                        center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
                        zoom: zoom,
                        pitch: 0.0
                    )
                    
                    self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
                }
            }
          
        }
        self.navigationController?.present(vc, animated:true)
//        let  vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeFilterVC") as! HomeFilterVC
//        vc.modalPresentationStyle = .overFullScreen
//        vc.gigType = self.type
//        vc.type = self.type
//        vc.lat = self.currentLat
//        vc.long = self.currentLong
//        vc.gigCount = self.arrData.count
//        vc.callBack = { (radius) in
//
//            self.homeListenerCall = false
//            if self.type == 1{
//                self.getGigData()
//            }else if self.type == 2{
//                self.getStoreData()
//
//            }else{
//                self.getBusinessData()
//            }
//
//            let mapWidth = self.mapView.bounds.width
//            self.mapRadius = Double(radius)
//                  // Calculate the zoom level
//
//            let zoom = self.zoomLevel(from: Double(radius), mapViewWidth: mapWidth)
//                  print("Zoom Level: \(zoom), Radius: \(radius) km")
//            let cameraOptions = CameraOptions(
//                center: CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong),
//                zoom: zoom,
//                  pitch: 0.0
//              )
//
//            self.mapView.camera.ease(to: cameraOptions, duration: 0.3, curve: .easeInOut)
//
//        }
//        self.navigationController?.present(vc, animated:false)
    }
    
    @IBAction func actionSeeAll(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SeeAllTypeVC") as! SeeAllTypeVC
        vc.isSelect = sender.tag
        if sender.tag == 1{
            vc.arrData = arrTask
        }else if sender.tag == 3{
            vc.arrData = arrPopUp
        }else{
            vc.arrData = arrBusiness
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func zoomLevel(from radius: Double, mapViewWidth: CGFloat) -> Double {
        let earthCircumference: Double = 40075016.686 // Earth's circumference in meters
        let radiusInMeters = radius * 1000 // Convert kilometers to meters
        let mapWidth = Double(mapViewWidth) // Map's pixel width
        
        // Calculate zoom level
        let zoom = log2((mapWidth * earthCircumference) / (radiusInMeters * 2)) - 8
        return zoom
    }
    
    @IBAction func actionStickers(_ sender: UIButton) {
        // Make sure the device supports stickers
            

            // Create an array of MSSticker objects (you need actual stickers here)
           

            // Example: Add a sticker (make sure the file URL points to a valid sticker)
            if let stickerURL = Bundle.main.url(forResource: "stickerName", withExtension: "png") {
                if let sticker = try? MSSticker(contentsOfFileURL: stickerURL, localizedDescription: "Sample Sticker") {
                    stickers.append(sticker)
                }
            }

            // Initialize MSStickerBrowserViewController
            let stickerBrowserViewController = MSStickerBrowserViewController(stickerSize: .regular)
        stickerBrowserViewController.stickerBrowserView.dataSource = self

            // Present the sticker browser view controller
            self.present(stickerBrowserViewController, animated: true, completion: nil)

    }
 
    @IBAction func actionGigType(_ sender: UIButton) {
      
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
            //locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: false)

            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigTypeVC") as! GigTypeVC
            vc.modalPresentationStyle = .overFullScreen
            vc.isComing = false
            vc.gigType = Store.GigType ?? 0
            vc.callBack = { [weak self] type in
                
                guard let self = self else { return }
                
                Store.GigType = type
                self.removeAllArray()
                self.isSelectType = 1
                self.homeListenerCall = false
                
            }
            self.present(vc, animated: true)
        default:
            print("Location permission not determined")
        }
    }
    @IBAction func actionGigs(_ sender: UIButton) {
   
//        viewBusinessList.isHidden = true
//        viewStoreList.isHidden = true
//        viewNoMatch.isHidden = true
        
//        if selectLocationType == "myLocation"{
//            btnGig.setImage(UIImage(named: "selworld"), for: .normal)
//            selectLocationType = "world"
//            Store.GigType = 1
//
//        }else{
//            btnGig.setImage(UIImage(named: "selmy"), for: .normal)
//            selectLocationType = "myLocation"
//            Store.GigType = 0
//
//        }
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        clusterManager.removeExistingLayersAndSources()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
//            if homeListenerCall{
//                if isGigType{
                    isGigType = false
                    isPopupType = true
                    isBusinessType = true
                    removeAllArray()
                    tappedAnyWhere()
                  
                    type = 1
                    isSelectType = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
                    isSelectGig()
//                }
//            }
        default:
            print("Location permission not determined")
        }

    }
    func getGigData(){
     
//        viewWorldwide.isHidden = false
//        viewInMyLocation.isHidden = false
//
//        viewBusinessList.isHidden = true
//        viewStoreList.isHidden = true
//        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        clusterManager.removeExistingLayersAndSources()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
                    isGigType = false
                    isPopupType = true
                    isBusinessType = true
                    removeAllArray()
                    tappedAnyWhere()
                  
                    type = 1
                    isSelectType = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
                    isSelectGig()
        default:
            print("Location permission not determined")
        }

    }
    func isSelectGig(){
        if self.isSelectTask{
            self.vwRefresh.isHidden = false
            self.vwRecenter.isHidden = false
        }
    
        vwEarning.isHidden = false
    }
    func removeAllArray(){
        SDWebImageDownloader.shared.cancelAllDownloads()
        pointAnnotationManager?.annotations = []
        arrBusinessPointAnnotations.removeAll()
        arrGigPointAnnotations.removeAll()
        arrPopUpPointAnnotations.removeAll()
        arrPoint.removeAll()
        arrData.removeAll()
     
        customAnnotations.removeAll()
    }
    @IBAction func actionStores(_ sender: UIButton) {
        self.visibleIndex = 0
      
//        viewGigList.isHidden = true
//        viewBusinessList.isHidden = true
//        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        clusterManager.removeExistingLayersAndSources()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if homeListenerCall{
                if isPopupType{
                    isPopupType = false
                    isGigType = true
                    isBusinessType = true
               
//                    viewBusinessList.isHidden = true
//                    viewGigList.isHidden = true
                    removeAllArray()
                   
                    type = 2
                    isSelectType = 3
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
                    isSelectStoreAndBusinessBtn()
                }
            }
        default:
            print("Location permission not determined")
        }


    }
    func getStoreData(){
      
//        viewWorldwide.isHidden = true
//        viewInMyLocation.isHidden = true
//
//        viewGigList.isHidden = true
//        viewBusinessList.isHidden = true
//        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        clusterManager.removeExistingLayersAndSources()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if !homeListenerCall{
//                if isPopupType{
                    isPopupType = false
                    isGigType = true
                    isBusinessType = true
//
//                    viewBusinessList.isHidden = true
//                    viewGigList.isHidden = true
                    removeAllArray()
                   
                    type = 2
                    isSelectType = 3
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
                    isSelectStoreAndBusinessBtn()
//                }
            }
        default:
            print("Location permission not determined")
        }


    }
    @IBAction func actionBusiness(_ sender: UIButton) {
        self.visibleIndex = 0
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        clusterManager.removeExistingLayersAndSources()
//        viewGigList.isHidden = true
//        viewStoreList.isHidden = true
//        viewNoMatch.isHidden = true
     
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if !homeListenerCall{
                if isBusinessType{
                    isBusinessType = false
                    isGigType = true
                    isPopupType = true
                  
//                    viewStoreList.isHidden = true
//                    viewGigList.isHidden = true
                 
                    removeAllArray()
                  
                    type = 3
                    isSelectType = 2
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
                    isSelectStoreAndBusinessBtn()
                }
            }
    default:
        print("Location permission not determined")
    }

    }
    func getBusinessData(){
     
//        viewWorldwide.isHidden = true
//        viewInMyLocation.isHidden = true
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
//        viewBusinessList.isHidden = false
//        viewGigList.isHidden = true
//        viewStoreList.isHidden = true
//        viewNoMatch.isHidden = true
      
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if homeListenerCall{
//                if isBusinessType{
                    isBusinessType = false
                    isGigType = true
                    isPopupType = true
             
//                    viewStoreList.isHidden = true
//                    viewGigList.isHidden = true
//
                    removeAllArray()
                 

                    type = 3
                    isSelectType = 2
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                        self.getWillApearAllData()
                    }
//                    if self.arrData.count > 0{
//                        self.viewBusinessList.isHidden = false
//                    }else{
//                        self.viewBusinessList.isHidden = false
//                    }

                    isSelectStoreAndBusinessBtn()
//                }
            }
    default:
        print("Location permission not determined")
    }

    }
    func isSelectStoreAndBusinessBtn(){
        if self.isSelectTask{
            self.vwRefresh.isHidden = false
            self.vwRecenter.isHidden = false
        }
//
//        viewGigType.isHidden = true
        vwEarning.isHidden = true
    }
  

    @IBAction func actionRefresh(_ sender: UIButton) {
        
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            print("denied")
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: false)
            customAnnotations.removeAll()
            let clusterManager = ClusterManager(mapView: self.mapView)
            clusterManager.removeClusters()
//            viewRefresh.animateRefreshAndRecenter()
            removeAllArray()
//            if viewNoMatch.isHidden{
//                bottomStackVwRefreshAndRecenter.constant = 10
//            }else{
//                bottomStackVwRefreshAndRecenter.constant = 10
//            }
            tblVwTask.reloadData()
            collVwPopUp.reloadData()
            collVwBusiness.reloadData()
            getWillApearAllData()
        default:
            print("Location permission not determined")
        }
    }
    @IBAction func actionRecenter(_ sender: UIButton){
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            print("denied")
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: false)
            mapRadius = 0.7
                recenter()
        default:
            print("Location permission not determined")
        }
    }
    func recenter() {
//        viewRecenter.animateRefreshAndRecenter()
        customAnnotations.removeAll()
        let clusterManager = ClusterManager(mapView: self.mapView)
        clusterManager.removeClusters()
        removeAllArray()
//        if viewNoMatch.isHidden{
//            bottomStackVwRefreshAndRecenter.constant = 10
//        }else{
//            bottomStackVwRefreshAndRecenter.constant = 10
//        }
        tblVwTask.reloadData()
        collVwPopUp.reloadData()
        collVwBusiness.reloadData()
        getWillApearAllData()

        let centerCoordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
        mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: 15))

    }
}
//MARK: - CLLocationManagerDelegate
extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        setupMapWithCoordinate(userLocation.coordinate)
        currentLat = userLocation.coordinate.latitude
        currentLong = userLocation.coordinate.longitude
        myCurrentLat = userLocation.coordinate.latitude
        myCurrentLong = userLocation.coordinate.longitude
        uiSet()
        if !self.mapAdded{
            self.addMapView(currentLat: myCurrentLat, currentLong: myCurrentLong)
            self.mapAdded = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
           
            self.addCurrentLocationMarker(location: userLocation.coordinate)
        }
    //    locationManager.stopUpdatingLocation()
      }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                print("User has not yet made a choice regarding location permissions")
            case .restricted, .denied:
                print("Location access denied")
                removeDataWhileLocationDenied()
                locationDeniedAlert()
            case .authorizedWhenInUse, .authorizedAlways:
                self.dismiss(animated: false)
                getDidLoadData()
                getWillApearAllData()
                print("Location access granted")
            @unknown default:
                print("Unknown location permission status")
            }
        }
    func locationDeniedAlert(){
        let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
//MARK: - AnnotationInteractionDelegate
extension HomeVC:AnnotationInteractionDelegate{
    func annotationManager(_ manager: any MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [any MapboxMaps.Annotation]) {
        
        if Store.role == "user" {
            if type == 1 {
                guard let annotation = annotations.first as? PointAnnotation else { return }
                let coordinate = annotation.point.coordinates
                print("Annotation tapped at coordinate: \(coordinate)")
                self.showAnnotationView(at: coordinate)
                    // Ensure the annotation view is only shown once
                    if !self.isAnnotationViewVisible {
                        
                        self.isAnnotationViewVisible = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.showAnnotationView(at: coordinate)
                            // Reset the flag after showing the view, if needed
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isAnnotationViewVisible = false
                                
                            }
                        }
                    }
            } else {
                guard let annotation = annotations.first as? PointAnnotation else { return }
                let coordinate = annotation.point.coordinates
                print("Annotation tapped at coordinate: \(coordinate)")
                
                // Ensure the annotation view is only shown once
                if !self.isAnnotationViewVisible {
                    self.isAnnotationViewVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.showAnnotationView(at: coordinate)
                        // Reset the flag after showing the view, if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isAnnotationViewVisible = false
                        }
                    }
                }
            }
        } else {
            guard let annotation = annotations.first as? PointAnnotation else { return }
            let coordinate = annotation.point.coordinates
            print("Annotation tapped at coordinate: \(coordinate)")
            
            // Ensure the annotation view is only shown once
            if !self.isAnnotationViewVisible {
                self.isAnnotationViewVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.showAnnotationView(at: coordinate)
                    // Reset the flag after showing the view, if needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isAnnotationViewVisible = false
                    }
                }
            }
        }
    }
      func showAnnotationView(at coordinate: CLLocationCoordinate2D) {
          
        guard let selectedItem = arrData.first(where: {
          ($0.lat == coordinate.latitude || $0.latitude == coordinate.latitude) &&
          ($0.long == coordinate.longitude || $0.longitude == coordinate.longitude)
        }) else {
          print("No matching item found for the provided coordinate")
          return // Exit if no match is found
        }
          // Get the index of the selected item
              guard let selectedIndex = arrData.firstIndex(where: {
                  ($0.lat == coordinate.latitude || $0.latitude == coordinate.latitude) &&
                  ($0.long == coordinate.longitude || $0.longitude == coordinate.longitude)
              }) else {
                  print("Unable to find index for the selected item")
                  return
              }
              
              print("Selected item index: \(selectedIndex)")
          
        if selectedItem.type == "gig"{
            
            if Store.role == "user"{
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigPopupViewVC") as! GigPopupViewVC
                vc.currentIndex = selectedIndex
                vc.selectedId = selectedItem.id ?? ""
                vc.modalPresentationStyle = .overFullScreen
                vc.arrData = arrData

                vc.callBack = { [weak self] isSelect,isChat,data,isUserGig in
                    if isUserGig{
                        
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "AddTaskVC") as! AddTaskVC
                        vc.isComing = false
                        vc.IsUserGig = true
//                        vc.userGigDetail = data
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    }else{
                        
                        if selectedItem.seen == 0 {
                            let param: parameters = ["userId": Store.userId ?? "",
                                                     "lat": "\(self?.currentLat ?? 0.0)",
                                                     "long": "\(self?.currentLong ?? 0.0)",
                                                     "radius": self?.mapRadius ?? 0.0,
                                                     "gigId": selectedItem.id ?? "",
                                                     "type":2,
                                                     "gigType":Store.GigType ?? 0 ]
                            SocketIOManager.sharedInstance.home(dict: param)
                            
                        }
                        let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
                        vc.gigId = selectedItem.id ?? ""
                        vc.callBack = { [weak self] in
                            guard let self = self else { return }
                            self.customAnnotations.removeAll()
                            let clusterManager = ClusterManager(mapView: self.mapView)
                            
                            clusterManager.removeClusters()
                            
                            
                            let status = CLLocationManager.authorizationStatus()
                            switch status {
                            case .restricted, .denied:
                                print("denied")
                            case .authorizedWhenInUse, .authorizedAlways:
                                self.dismiss(animated: false)
                                self.removeAllArray()
                                self.tblVwTask.reloadData()
                                self.collVwPopUp.reloadData()
                                self.collVwBusiness.reloadData()
                                self.getWillApearAllData()
                            default:
                                print("Location permission not determined")
                            }
                        }
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
//                            let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//                            vc.gigId = selectedItem.id ?? ""
//                            vc.callBack = { [weak self] in
//                                guard let self = self else { return }
//                                self.customAnnotations.removeAll()
//                                let clusterManager = ClusterManager(mapView: self.mapView)
//                                clusterManager.removeClusters()
//                                let status = CLLocationManager.authorizationStatus()
//                                switch status {
//                                case .restricted, .denied:
//                                    print("denied")
//                                case .authorizedWhenInUse, .authorizedAlways:
//                                    self.dismiss(animated: false)
//                                    self.removeAllArray()
//                                    self.tblVwList.reloadData()
//                                    self.collVwStore.reloadData()
//                                    self.collVwBusiness.reloadData()
//                                    self.getWillApearAllData()
//                                default:
//                                    print("Location permission not determined")
//                                }
//                            }
//                            self?.navigationController?.pushViewController(vc, animated: true)
                        
                    }
             
                }
                self.present(vc, animated: true)
            }else{
      
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
                vc.gigId = selectedItem.id ?? ""
                vc.isComing = 1
                vc.callBack = { [weak self] in
                    guard let self = self else { return }
//                        self.mapView.viewAnnotations.removeAll()
               
                    self.pointAnnotationManager.annotations = []
                    self.arrGigPointAnnotations.removeAll()
                    self.animateZoomInOut()
                    self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
                }
                self.navigationController?.pushViewController(vc, animated: true)
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//                    vc.gigId = selectedItem.id ?? ""
//                    vc.isComing = 1
//                    vc.callBack = { [weak self] in
//                        guard let self = self else { return }
////                        self.mapView.viewAnnotations.removeAll()
//                        self.pointAnnotationManager.annotations = []
//                        self.arrGigPointAnnotations.removeAll()
//                        self.animateZoomInOut()
//                        self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
//                    }
//                    self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }else if selectedItem.type == "popUp"{
//          guard !isPopUpVCShown else { return }
//          isPopUpVCShown = true
//          let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
//          vc.popupId = selectedItem.id ?? ""
//            vc.callBack = { [weak self] index in
//                guard let self = self else { return }
//            self.isPopUpVCShown = false
//            self.animateZoomInOut()
//          }
//          self.navigationController?.pushViewController(vc, animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupUserVC") as! PopupUserVC
                    vc.popupId = selectedItem.id ?? ""
            vc.callBack = { [weak self]  in
                guard let self = self else { return }
               
                self.isPopUpVCShown = false
                self.animateZoomInOut()
            }
           self.navigationController?.pushViewController(vc, animated: true)
        }else {
          guard !isPopUpVCShown else { return }
          isPopUpVCShown = true
          if Store.role == "b_user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            vc.businessId = selectedItem.id ?? ""
            vc.isComing = true
            self.navigationController?.pushViewController(vc, animated: true)
          }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutServicesVC") as!
            AboutServicesVC
            vc.businessId = selectedItem.id ?? ""
            Store.BusinessUserIdForReview = selectedItem.id ?? ""
              vc.businessIndex = visibleIndex
              vc.callBack = { [weak self] index in
                  guard let self = self else { return }
                 
                self.visibleIndex = index
              self.animateZoomInOut()
              self.isPopUpVCShown = false
            }
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
      }
    @objc func viewMore(sender:UIButton){
         if Store.role == "user"{
          print(gigAppliedStatus)
          if gigAppliedStatus == 1{
           if isReadyChat == 1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigChatVC") as! GigChatVC
            vc.modalPresentationStyle = .overFullScreen
            vc.gigId = gigIdForGroup
            vc.gigUserId = self.gigUserId
            vc.callBack = { [weak self] isBack in
                guard let self = self else { return }
             self.getWillApearAllData()
             if !isBack{
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCompleteVC") as! GigCompleteVC
              vc.modalPresentationStyle = .overFullScreen
              vc.callBack = {[weak self] in
                  
                  guard let self = self else { return }
               self.socketData()
               self.mapView.viewAnnotations.removeAll()
              }
              self.navigationController?.present(vc, animated: true)
             }
            }
            self.present(vc, animated: true)
           }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigReadyVC") as! GigReadyVC
            vc.modalPresentationStyle = .overFullScreen
            vc.gigDetail = gigDetail
            vc.groupId = groupId
               vc.callBack = { [weak self] in
               guard let self = self else { return }
             let param:parameters = ["userId":Store.userId ?? "",
                   "deviceId":Store.deviceToken ?? "",
                   "gigId":self.gigIdForGroup,
                   "groupId":self.groupId]
             print("param--",param)
             SocketIOManager.sharedInstance.readyUser(dict: param)
             DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
              if Store.role == "user"{
               let param2 = ["senderId":Store.userId ?? "","groupId":self.groupId,
                   "message":"\(Store.UserDetail?["userName"] as? String ?? "") is ready",
                   "deviceId":Store.deviceToken ?? "",
                   "gigId":self.gigIdForGroup]
               print("param2--",param2)
               SocketIOManager.sharedInstance.sendMessage(dict: param2)
              }else{
               let param2 = ["senderId":Store.userId ?? "",
                   "groupId":self.groupId,
                   "message":"\(Store.BusinessUserDetail?["userName"] as? String ?? "") is ready",
                   "deviceId":Store.deviceToken ?? "",
                   "gigId":self.gigIdForGroup]
               SocketIOManager.sharedInstance.sendMessage(dict: param2)
              }
             }
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigChatVC") as! GigChatVC
             vc.modalPresentationStyle = .overFullScreen
             vc.gigId = self.gigIdForGroup
             vc.gigUserId = self.gigUserId
             vc.callBack = { [weak self] isBack in
                 
                 guard let self = self else { return }
                 
              self.getWillApearAllData()
              if !isBack{
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigCompleteVC") as! GigCompleteVC
               vc.modalPresentationStyle = .overFullScreen
               vc.callBack = { [weak self] in
                   guard let self = self else { return }
                self.socketData()
               }
               self.navigationController?.present(vc, animated: true)
              }
             }
             self.present(vc, animated: true)
            }
            self.present(vc, animated: true)
           }
          }else{
           print("View More button pressed")
           print("selectItemSeen: \(selectItemSeen)")
           if selectItemSeen == 1 {
               
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
               vc.gigId = selectGigId
               vc.callBack = {[weak self] in
                   
                   guard let self = self else { return }
                
                self.mapView.viewAnnotations.removeAll()
                self.pointAnnotationManager.annotations = []
                self.arrGigPointAnnotations.removeAll()
                self.mapData(radius: self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
               }
               self.navigationController?.pushViewController(vc, animated: true)
               
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//            vc.gigId = selectGigId
//            vc.callBack = {[weak self] in
//
//                guard let self = self else { return }
//             self.mapView.viewAnnotations.removeAll()
//             self.pointAnnotationManager.annotations = []
//             self.arrGigPointAnnotations.removeAll()
//             self.mapData(radius: self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
           } else if selectItemSeen == 0 {
            let param: parameters = ["userId": Store.userId ?? "", "lat": "\(currentLat)", "long": "\(currentLong)", "radius": mapRadius, "gigId": selectGigId,"type":2,"gigType":Store.GigType ?? 0 ]
            SocketIOManager.sharedInstance.home(dict: param)
               let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
               vc.callBack = { [weak self] in
                   guard let self = self else { return }
                  
              self.mapView.viewAnnotations.removeAll()
              self.pointAnnotationManager.annotations = []
              self.arrGigPointAnnotations.removeAll()
                self.removeAllArray()
                self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
               }
               vc.gigId = self.selectGigId
               print("Pushing ApplyGigVC with gigId: \(vc.gigId)")
               self.navigationController?.pushViewController(vc, animated: true)
//             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//             vc.callBack = { [weak self] in
//                 guard let self = self else { return }
//            self.mapView.viewAnnotations.removeAll()
//            self.pointAnnotationManager.annotations = []
//            self.arrGigPointAnnotations.removeAll()
//              self.removeAllArray()
//              self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
//             }
//             vc.gigId = self.selectGigId
//             print("Pushing ApplyGigVC with gigId: \(vc.gigId)")
//             self.navigationController?.pushViewController(vc, animated: true)
           }
          }
         }else{
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
             vc.gigId = self.selectGigId
             vc.isComing = 1
             vc.callBack = {[weak self] in
                 
                 guard let self = self else { return }
                
              self.mapView.viewAnnotations.removeAll()
              self.pointAnnotationManager.annotations = []
              self.arrGigPointAnnotations.removeAll()
              self.animateZoomInOut()
              self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
             }
             self.navigationController?.pushViewController(vc, animated: true)
//          let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//          vc.gigId = self.selectGigId
//          vc.isComing = 1
//          vc.callBack = {[weak self] in
//
//              guard let self = self else { return }
//           self.mapView.viewAnnotations.removeAll()
//           self.pointAnnotationManager.annotations = []
//           self.arrGigPointAnnotations.removeAll()
//           self.animateZoomInOut()
//           self.mapData(radius:self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
//          }
//          self.navigationController?.pushViewController(vc, animated: true)
         }
        }
    }
//MARK: - UICollectionViewDelegate
extension HomeVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collVwSelectType{
            return arrType.count
        }else if collectionView == collVwPopUp{
            if arrPopUp.count > 0{
                return arrPopUp.count
            }else{
                return 0
            }
        }else{
            if arrBusiness.count > 0{
                return arrBusiness.count
            }else{
                return 0
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwSelectType{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTypeCVC", for: indexPath) as! SelectTypeCVC
            cell.lblType.text = arrType[indexPath.row]
            if typeIndex == indexPath.row{
                cell.vwMain.backgroundColor = .app
                cell.lblType.textColor = .white
            }else{
                cell.vwMain.backgroundColor = .white
                cell.lblType.textColor = .black
            }
            
            return cell

        } else if collectionView == collVwBusiness{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularServicesCVC", for: indexPath) as! PopularServicesCVC
            cell.vwShadow.layer.masksToBounds = false
            cell.vwShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
            cell.vwShadow.layer.shadowOpacity = 0.44
            cell.vwShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.vwShadow.layer.shouldRasterize = true
            cell.vwShadow.layer.rasterizationScale = UIScreen.main.scale
            cell.isComing = true
            if arrBusiness.count > 0{
                cell.indexpath = indexPath.row
//                if arrData[indexPath.row].categoryName?.count ?? 0 > 0{
//                    cell.arrCategories = arrData[indexPath.row].userservices ?? []
//                }
                cell.uiSet()
                let business = arrBusiness[indexPath.row]
                let rating = business.UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
              
                cell.lblServiceName.text = business.businessname ?? ""
                cell.imgVwUser.imageLoad(imageUrl: business.profilePhoto ?? "")
                cell.lblAddress.text = business.place ?? ""
                if business.status == 2{
                    cell.imgVwBlueTick.isHidden = false
                }else{
                    cell.imgVwBlueTick.isHidden = true
                }
                var openingHoursFound = false
//                for openingHour in business.openingHours ?? [] {
//                    if openingHour.day == currentDay {
//                        openingHoursFound = true
//                        let startTime12 = convertTo12HourFormat(openingHour.starttime ?? "")
//                        let endTime12 = convertTo12HourFormat(openingHour.endtime ?? "")
//                        cell.lblTime.text = "\(startTime12) - \(endTime12)"
//                        break
//                    }
//                }
                if !openingHoursFound {
                    cell.lblTime.text = "Closed"
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCVC", for: indexPath) as! StoreCVC
            cell.viewShadow.layer.masksToBounds = false
            cell.viewShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
            cell.viewShadow.layer.shadowOpacity = 0.44
            cell.viewShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.viewShadow.layer.shouldRasterize = true
            cell.viewShadow.layer.rasterizationScale = UIScreen.main.scale
            if arrPopUp.count > 0{
                cell.lblStoreName.text = arrPopUp[indexPath.row].name ?? ""
                cell.imgVwStore.imageLoad(imageUrl: arrPopUp[indexPath.row].businessLogo ?? "")
                cell.lblUserName.text = arrPopUp[indexPath.row].user?.name ?? ""
                let rating = arrPopUp[indexPath.row].UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collVwSelectType{
            typeIndex = indexPath.row
            switch indexPath.row{
            case 0:
                btnAllTask.isHidden = false
                btnAllPopup.isHidden = false
                btnAllBusiness.isHidden = false
                btnGigFilter.isHidden = true
                btnStoreFilter.isHidden = true
                btnBusinessFilter.isHidden = true
                
                vwWorldwideTask.isHidden = true
                vwLocalTask.isHidden = true
                vwTask.isHidden = false
                vwBusiness.isHidden = false
                vwPopup.isHidden = false
                tblVwTask.isHidden = false
                collVwBusiness.isHidden = false
                collVwPopUp.isHidden = false
                if deviceHasNotch{
                    if UIDevice.current.hasDynamicIsland {
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 110
                        }
                    }else{
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 104
                        }
                    }
                }else{
                    if  isSelectAnother{
                        bottomStackVw.constant = 70
                    }else{
                        bottomStackVw.constant = 90
                    }
                  
                }
            case 1:
                
                btnAllTask.isHidden = true
                btnAllPopup.isHidden = true
                btnAllBusiness.isHidden = true
                btnGigFilter.isHidden = false
                btnStoreFilter.isHidden = false
                btnBusinessFilter.isHidden = false
                
                vwWorldwideTask.isHidden = false
                vwLocalTask.isHidden = false
                vwTask.isHidden = false
                vwBusiness.isHidden = true
                vwPopup.isHidden = true
                tblVwTask.isHidden = false
                collVwBusiness.isHidden = true
                collVwPopUp.isHidden = true
                homeListenerCall = false
                type = 1
                isSelectType = 1
                vwWorldwideTask.isHidden = false
                vwLocalTask.isHidden = false
 
                if deviceHasNotch{
                    if UIDevice.current.hasDynamicIsland {
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 110
                        }
                    }else{
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 104
                        }
                    }
                }else{
                    if  isSelectAnother{
                        bottomStackVw.constant = 70
                    }else{
                        bottomStackVw.constant = 90
                    }
                }
                getGigData()
            case 2:
                btnAllTask.isHidden = true
                btnAllPopup.isHidden = true
                btnAllBusiness.isHidden = true
                btnGigFilter.isHidden = false
                btnStoreFilter.isHidden = false
                btnBusinessFilter.isHidden = false
                
                vwWorldwideTask.isHidden = true
                vwLocalTask.isHidden = true
                vwTask.isHidden = true
                vwBusiness.isHidden = true
                vwPopup.isHidden = false
                tblVwTask.isHidden = true
                collVwBusiness.isHidden = true
                collVwPopUp.isHidden = false
                homeListenerCall = false
                type = 2
                isSelectType = 3
                self.getStoreData()

                if deviceHasNotch{
                    if UIDevice.current.hasDynamicIsland {
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 110
                        }
                    }else{
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 104
                        }
                    }
                }else{
                    if  isSelectAnother{
                        bottomStackVw.constant = 70
                    }else{
                        bottomStackVw.constant = 90
                    }
                }
            case 3:
                btnAllTask.isHidden = true
                btnAllPopup.isHidden = true
                btnAllBusiness.isHidden = true
                btnGigFilter.isHidden = false
                btnStoreFilter.isHidden = false
                btnBusinessFilter.isHidden = false
                
                vwWorldwideTask.isHidden = true
                vwLocalTask.isHidden = true
                vwTask.isHidden = true
                vwBusiness.isHidden = false
                vwPopup.isHidden = true
                tblVwTask.isHidden = true
                collVwBusiness.isHidden = false
                collVwPopUp.isHidden = true
                type = 3
                isSelectType = 2
                    getBusinessData()
                if deviceHasNotch{
                    if UIDevice.current.hasDynamicIsland {
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 110
                        }
                    }else{
                        if  isSelectAnother{
                            bottomStackVw.constant = 60
                        }else{
                            bottomStackVw.constant = 104
                        }
                    }
                }else{
                    if  isSelectAnother{
                        bottomStackVw.constant = 70
                    }else{
                        bottomStackVw.constant = 90
                    }
                }
            default:
                break
            }
            collVwSelectType.reloadData()
        }else{
           
                
                if homeListenerCall{
                    
                    self.dismiss(animated: true)
                    if collectionView == collVwBusiness{
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutServicesVC") as! AboutServicesVC
                        vc.businessId = arrBusiness[indexPath.row].id ?? ""
                        vc.businessIndex = indexPath.row
                        
                        Store.BusinessUserIdForReview = arrBusiness[indexPath.row].id ?? ""
                        vc.callBack = { [weak self] index in
                            
                            guard let self = self else { return }
                            self.animateZoomInOut()
                            self.getBusinessData()
                            
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupUserVC") as! PopupUserVC
                        vc.popupId = arrPopUp[indexPath.row].id ?? ""
                        vc.callBack = { [weak self]  in
                            guard let self = self else { return }
                            self.isPopUpVCShown = false
                            self.animateZoomInOut()
                            self.getStoreData()
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                        //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
                        //                    vc.popupId = arrData[indexPath.row].id ?? ""
                        //                    vc.popupIndex = indexPath.row
                        //                    vc.callBack = { [weak self] index in
                        //                        guard let self = self else { return }
                        //                        self.animateZoomInOut()
                        //                        self.getStoreData()
                        //                    }
                        //                    self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collVwSelectType{
            return CGSize(width: view.frame.size.width / 4-9, height: 35)
        }else if collectionView == collVwBusiness{
            return CGSize(width: view.frame.size.width / 1-20, height: 100)
        }else{
            return CGSize(width: view.frame.size.width / 1-20, height: 100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collVwSelectType{
            return 5
        }else{
            return 0
        }
       
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collVwSelectType{
            return 5
        }else{
            return 0
        }
    }

 
}

extension HomeVC {
    func convertTo12HourFormat(_ time24: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date24 = dateFormatter.date(from: time24) {
            dateFormatter.dateFormat = "h:mm a"
            let time12 = dateFormatter.string(from: date24)
            return time12
        }
        return ""
    }
}
//MARK: - UIPopoverPresentationControllerDelegate
extension HomeVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//MARK: - TABLEVIEW DELEGATE AND DATASOURCE
extension HomeVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataCount = arrTask.count
//        tableView.isScrollEnabled = dataCount > 1
        return dataCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigNearByTVC", for: indexPath) as! GigNearByTVC
        if arrTask.count > 0 {
       
            cell.lblName.text = arrTask[indexPath.row].name
            cell.lblTitle.text = arrTask[indexPath.row].title
            cell.lblPrice.text = "$\(arrTask[indexPath.row].price ?? 0)"
            cell.lblAddress.text = arrTask[indexPath.row].place ?? ""
            
            if let formattedDate = convertToDateFormat(arrTask[indexPath.row].startDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", convertFormat:"dd MMM yyyy") {
                cell.lblDate.text = formattedDate
            } else {
                print("Invalid date format")
            }
            if let formattedDate = convertToDateFormat(arrTask[indexPath.row].startDate ?? "", dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", convertFormat:"h a") {
                cell.lblTime.text = formattedDate
            } else {
                print("Invalid date format")
            }
            print(arrTask[indexPath.row].startDate ?? "")
            cell.viewShadow.applyShadow()
            let rating = arrTask[indexPath.row].UserRating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            let reviewCount = arrTask[indexPath.row].userRatingCount ?? 0
            if reviewCount > 1{
                cell.lblRatingReview.text = "\(formattedRating) \("(\(reviewCount) Reviews)")"
                let attributedText = NSMutableAttributedString(string: cell.lblRatingReview.text ?? "")
                if let range = cell.lblRatingReview.text?.range(of: "(\(reviewCount) Reviews)") {
                    let nsRange = NSRange(range, in: cell.lblRatingReview.text ?? "")
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.app, range: nsRange)
                }
                cell.lblRatingReview.attributedText = attributedText
            }else{
                cell.lblRatingReview.text = "\(formattedRating) \("(\(reviewCount) Review)")"
                let attributedText = NSMutableAttributedString(string: cell.lblRatingReview.text ?? "")
                if let range = cell.lblRatingReview.text?.range(of: "(\(reviewCount) Review)") {
                    let nsRange = NSRange(range, in: cell.lblRatingReview.text ?? "")
                    attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.app, range: nsRange)
                }
                cell.lblRatingReview.attributedText = attributedText
            }
            if arrTask[indexPath.row].image == "" || arrTask[indexPath.row].image == nil{
                cell.imgVwGig.image = UIImage(named: "dummy")
            }else{
                cell.imgVwGig.imageLoad(imageUrl: arrTask[indexPath.row].image ?? "")
            }

            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if homeListenerCall{
            self.dismiss(animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewTaskVC") as! ViewTaskVC
            if arrTask.count > 0{
                vc.gigId = arrTask[indexPath.row].id ?? ""
            }
            vc.callBack = {
                self.isSelectAnother = false
                self.animateZoomInOut()
                self.getGigData()
             
            }

            self.navigationController?.pushViewController(vc, animated: true)
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
//            if arrData.count > 0{
//                vc.gigId = arrData[indexPath.row].id ?? ""
//            }
//            vc.callBack = {[weak self] in
//
//                guard let self = self else { return }
//                self.animateZoomInOut()
//                self.getGigData()
//                if self.type == 1{
//                    self.viewThreeDot.isHidden = false
//                }
//            }
//
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func convertToDateFormat(_ dateString: String,dateFormat:String,convertFormat:String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = dateFormat
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = convertFormat
            outputFormatter.timeZone = TimeZone.current // Adjust as needed

            return outputFormatter.string(from: date)
        }
        return nil // Return nil if parsing fails
    }
}



//MARK: - MSStickerBrowserViewDataSource
extension HomeVC: MSStickerBrowserViewDataSource{
    func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        print("stickerBrowserView")
        return 1
    }
    
    func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        print("stickerBrowserView")
        return stickers[index]
    }
    
    func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, didSelectSticker sticker: MSSticker) {
        print("Sticker selected: \(sticker.localizedDescription)")
    }
}

