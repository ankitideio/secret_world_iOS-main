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

struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
struct ClusterPoint: Hashable {
    let coordinate: CLLocationCoordinate2D
    let price: Int
    let seen: Int
    // Conform to Hashable for deduplication
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(price)
        hasher.combine(seen)
    }
    static func == (lhs: ClusterPoint, rhs: ClusterPoint) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.price == rhs.price &&
        lhs.seen == rhs.seen
    }
}

class ExploreTabVC: UIViewController, JJFloatingActionButtonDelegate, GestureManagerDelegate {
    //MARK: - OUTLETS
    @IBOutlet var btnInMyLocation: UIButton!
    @IBOutlet var imgVwInMyLocation: UIImageView!
    @IBOutlet var viewInMyLocation: UIView!
    @IBOutlet var btnWorldwide: UIButton!
    @IBOutlet var imgVwWorldwide: UIImageView!
    @IBOutlet var viewWorldwide: UIView!
    @IBOutlet weak var topMapVw: NSLayoutConstraint!
    @IBOutlet weak var vwCustomMap: UIView!
    @IBOutlet weak var vwPopUpCenter: UIView!
    @IBOutlet weak var vwBusinessCenter: UIView!
    @IBOutlet weak var vwCenter: UIView!
    @IBOutlet weak var btnBusiness: UIButton!
    @IBOutlet weak var btnPopUp: UIButton!
    @IBOutlet weak var btnGig: UIButton!
    @IBOutlet weak var vwFloating: UIView!
    @IBOutlet var imgVwGigType: UIImageView!
    @IBOutlet var viewGigType: UIView!
    @IBOutlet var btnThreeDot: UIButton!
    @IBOutlet var viewThreeDot: UIView!
    @IBOutlet var lblGigCount: UILabel!
    @IBOutlet var imgVwEarnShadow: UIImageView!
    @IBOutlet var imgGigBtn: UIImageView!
    @IBOutlet var imgBusinessBtn: UIImageView!
    @IBOutlet var imgStoreBtn: UIImageView!
    @IBOutlet var viewGigList: UIView!
    @IBOutlet var collVwStore: UICollectionView!
    @IBOutlet var viewStoreList: UIView!
    @IBOutlet var collVwBusiness: UICollectionView!
    @IBOutlet var viewBusinessList: UIView!
    @IBOutlet var viewBtnStore: UIView!
    @IBOutlet var btnStore: UIButton!
    @IBOutlet var viewBtnBusiness: UIView!
    @IBOutlet weak var bottomCollVw: NSLayoutConstraint!
    @IBOutlet var viewBtnGig: UIView!
    @IBOutlet var viewRefresh: UIView!
    @IBOutlet var btnRefresh: UIButton!
    @IBOutlet var viewRecenter: UIView!
    @IBOutlet weak var btnRecenter: UIButton!
    @IBOutlet weak var lblEarning: UILabel!
    @IBOutlet weak var vwEarning: UIView!
    @IBOutlet var viewNoMatch: UIView!
    @IBOutlet var heightViewShadow: NSLayoutConstraint!
    @IBOutlet var tblVwList: UITableView!
    @IBOutlet var btnUpArrow: UIButton!
    
    //MARK: - VARIABLES
    var stickers: [MSSticker] = []
    var isAnnotationViewVisible = false
    var isAppendHeatMap = false
    var isGigType = true
    var isPopupType = true
    var isBusinessType = true
    var currentDay:String?
    let locationManager = CLLocationManager()
    var arrData = [FilteredItem]()
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
    var restrictedRegion: MKCoordinateRegion?
    var gigAppliedStatus = 0
    var isReadyChat = 0
    var gigDetail:FilteredItem?
    var gigUserId = ""
    var gigIdForGroup = ""
    var groupId = ""
    var type = 1
    var pointAnnotationManager: PointAnnotationManager!
    var arrGigPointAnnotations: [PointAnnotation] = []
    var arrPopUpPointAnnotations: [PointAnnotation] = []
    var arrBusinessPointAnnotations: [PointAnnotation] = []
    var arrSingleBuisnessAnnotation: [PointAnnotation] = []
    var arrSinglePopUpAnnotation: [PointAnnotation] = []
    var arrPoint = [Point]()
    var arrOverlapAnnotation = [CLLocationCoordinate2D]()
    private var cancelables = Set<AnyCancelable>()
    var isPopUpVCShown = false
    var isUploadData = false
    var isSelectType = 1
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
    var isInMyLocation = true
    var isWorldWide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        willAppear()
    }
    func willAppear(){
        if type == 1{
            viewWorldwide.isHidden = false
            viewInMyLocation.isHidden = false
        }else{
            viewWorldwide.isHidden = true
            viewInMyLocation.isHidden = true
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
    func getWillApearAllData(){
        
        homeListenerCall = false
        if Store.role == "b_user"{
            arrData.removeAll()
            vwEarning.isHidden = true
            vwCenter.isHidden = true
            vwPopUpCenter.isHidden = true
            vwBusinessCenter.isHidden = true
            socketData()
        }else{
            if type == 1{
                vwEarning.isHidden = false
            }else{
                vwEarning.isHidden = true
            }
            socketData()
        }
    }
    
    func addCurrentLocationMarker() {
        let someCoordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
        
        let originalImage = UIImage(named: "blueDot")!
        let resizedImage = resizeImage(originalImage, to: CGSize(width: 35, height: 35))
        var pointAnnotation = PointAnnotation(coordinate: someCoordinate)
        pointAnnotation.image = .init(image: resizedImage ?? UIImage(), name: "blueDot")
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager.annotations = [pointAnnotation]
    }
    
    func floatingActionButtonDidOpen(_ button: JJFloatingActionButton) {
        actionButton.buttonImage = UIImage(named: "more25")
        
    }
    func floatingActionButtonDidClose(_ button: JJFloatingActionButton) {
        actionButton.buttonImage = UIImage(named: "more25")
    }
    
    func getDidLoadData(){
        let nib = UINib(nibName: "StoreCVC", bundle: nil)
        collVwStore.register(nib, forCellWithReuseIdentifier: "StoreCVC")
        let nibBusiness = UINib(nibName: "PopularServicesCVC", bundle: nil)
        collVwBusiness.register(nibBusiness, forCellWithReuseIdentifier: "PopularServicesCVC")
        collVwBusiness.decelerationRate = .fast
        collVwStore.decelerationRate = .fast
        uiSet()
        NotificationCenter.default.addObserver(self, selector: #selector(self.HandleHomeTabClick(notification:)), name: Notification.Name("TabBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationAllow(notification:)), name: Notification.Name("locationAllow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationDenied(notification:)), name: Notification.Name("locationDenied"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedGetTabBar(notification:)), name: Notification.Name("TabBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedSelectHome(notification:)), name: Notification.Name("selectHomeBtn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceiveddeSelectHome(notification:)), name: Notification.Name("deSelectHomeBtn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectOtherTab(notification:)), name: Notification.Name("SelectOther"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.SelectBusiness(notification:)), name: Notification.Name("businessSel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectGig(notification:)), name: Notification.Name("gigSel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectStore(notification:)), name: Notification.Name("storeSel"), object: nil)
        
    }
    @objc func HandleHomeTabClick(notification: Notification) {
        
        self.viewWorldwide.isHidden = true
        self.viewInMyLocation.isHidden = true
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            
            self.dismiss(animated: false)
            self.btnUpArrow.setImage(UIImage(named:"uparrow"), for: .normal)
            self.tblVwList.isScrollEnabled = false
        default:
            
            print("Location permission not determined")
        }
    }
    @objc func getLocationDenied(notification:Notification){
        removeDataWhileLocationDenied()
    }
    func removeDataWhileLocationDenied(){
        self.btnUpArrow.isHidden = true
        self.heightViewShadow.constant = 0
        self.removeAllArray()
        viewStoreList.isHidden = true
        viewGigList.isHidden = true
        viewBusinessList.isHidden = true
        viewThreeDot.isHidden = true
        viewRefresh.isHidden = true
        viewRecenter.isHidden = true
        
        tblVwList.reloadData()
        collVwStore.reloadData()
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
        removePointClusters()
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
        removePointClusters()
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
    
    @objc func SelectBusiness(notification:Notification){
        self.viewBusinessList.isHidden = false
        if homeListenerCall{
            
            getBusinessData(visibleIndex: 0)
        }
    }
    
    @objc func methodOfReceivedSelectHome(notification:Notification){
        if isSelectType == 3{
            viewStoreList.isHidden = true
        }else if isSelectType == 2{
            viewBusinessList.isHidden = true
        }else{
            
            self.viewWorldwide.isHidden = true
            self.viewInMyLocation.isHidden = true
        }
        
    }
    @objc func methodOfReceiveddeSelectHome(notification:Notification){
        if isSelectType == 3{
            viewStoreList.isHidden = false
        }else if isSelectType == 2{
            viewBusinessList.isHidden = false
        }else{
            
            self.viewWorldwide.isHidden = false
            self.viewInMyLocation.isHidden = false
        }
    }
    @objc func selectGig(notification:Notification){
        if homeListenerCall{
            getGigData()
        }
    }
    @objc func selectStore(notification:Notification){
        self.viewStoreList.isHidden = false
        if homeListenerCall{
            getStoreData(visibleIndex: 0)
        }
    }
    
    func centerCell() {
        centerVisibleItem(in: collVwBusiness)
        centerVisibleItem(in: collVwStore)
    }
    
    private func centerVisibleItem(in collectionView: UICollectionView) {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.midX,
                                  y: collectionView.frame.midY)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            if let visibleIndexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)) {
                print("Currently visible index: \(visibleIndexPath.row)")
                let item = arrData[visibleIndexPath.row]
                let uniqueID = "businessSingle_\(item.id ?? "")"
                self.visibleIndex = visibleIndexPath.row
                
                self.arrSinglePopUpAnnotation.removeAll()
                
                self.downloadSingleBusinessImage(at: visibleIndexPath.row, isMove: true)
                
                self.downloadBusinessImage(at: visibleIndexPath.row)
                self.downloadPopUpImage(at: visibleIndexPath.row, isScroll: true)
                let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
                mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: mapView.mapboxMap.cameraState.zoom))
                
//                self.downloadSinglePopUpImage(at: visibleIndexPath.row, isScroll: true)
                
            }
        } else {
            print("No item found at the center of \(collectionView)")
        }
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
                    self.viewGigType.isHidden = true
                    self.viewRecenter.isHidden = false
                    self.viewRefresh.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.viewThreeDot.isHidden = true
                    }
                }
            }else{
                UIView.animate(withDuration: 0.5) {
                    self.viewGigType.isHidden = true
                    self.viewRecenter.isHidden = false
                    self.viewRefresh.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.viewThreeDot.isHidden = true
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
                        self.mapView.mapboxMap.loadStyle(StyleURI(url: styleURL) ?? .light)
                    }
                    
                }else{
                    self.mapView.mapboxMap.styleURI = .dark
                }
            }
            self.mapView.ornaments.scaleBarView.isHidden = true
            self.mapView.ornaments.logoView.isHidden = true
            
            self.mapView.gestures.delegate = self
            self.addCurrentLocationMarker()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.overlayTapped))
            self.mapView.addGestureRecognizer(tapGesture)
            let deviceHasNotch = UIApplication.shared.hasNotch
            if Store.role == "user"{
                if deviceHasNotch{
                    self.topMapVw.constant = -59
                    self.bottomCollVw.constant = 65
                    
                }else{
                    self.topMapVw.constant = 0
                    self.bottomCollVw.constant = 80
                    
                }
                
            }else{
                if deviceHasNotch{
                    self.topMapVw.constant = -59
                    self.bottomCollVw.constant = 75
                }else{
                    self.topMapVw.constant = 0
                    self.bottomCollVw.constant = 100
                }
                
            }
            
            
        }
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
        if Store.role == "b_user"{
            viewGigList.isHidden = true
            viewNoMatch.isHidden = true
        }else{
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            viewGigList.addGestureRecognizer(panGesture)
        }
        let nibNearBy = UINib(nibName: "GigNearByTVC", bundle: nil)
        tblVwList.register(nibNearBy, forCellReuseIdentifier: "GigNearByTVC")
        tblVwList.showsVerticalScrollIndicator = false
        viewNoMatch.layer.cornerRadius = 20
        viewNoMatch.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewGigList.layer.cornerRadius = 35
        viewGigList.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewGigList.layer.masksToBounds = false
        viewGigList.layer.shadowColor = UIColor.black.cgColor
        viewGigList.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewGigList.layer.shadowOpacity = 0.17
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
        let radiusInKilometers = radiusInMeters / 1000.0
        return radiusInKilometers
    }
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: self.view)
            switch gesture.state {
            case .changed:
                let velocity = gesture.velocity(in: self.view).y
                if velocity < 0 {
                    UIView.animate(withDuration: 0.5) {
                        self.mapView.viewAnnotations.removeAll()
                        self.viewThreeDot.isHidden = true
                        self.actionButton.isHidden = true
                        self.heightViewShadow.constant = CGFloat(self.arrData.count * 130)
                        self.btnUpArrow.setImage(UIImage(named:"bottomarrow"), for: .normal)
                        self.tblVwList.isScrollEnabled = true
                        self.btnUpArrow.isSelected = true
                        if self.viewGigType.isHidden == false{
                        self.viewGigType.isHidden = true
                        self.viewRefresh.isHidden = true
                        self.viewRecenter.isHidden = true
                        }
                        self.view.layoutIfNeeded()
                    }
                } else {
                    UIView.animate(withDuration: 0.5) {
                        self.viewThreeDot.isHidden = true
                       
                        self.btnUpArrow.setImage(UIImage(named:"uparrow"), for: .normal)
                        self.tblVwList.isScrollEnabled = false
                        self.btnUpArrow.isSelected = false
                        self.view.layoutIfNeeded()
                        self.heightViewShadow.constant = 60
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
    func mapData(radius:Double,type:Int,gigType:Int,lat:Double,long:Double) {
        arrSinglePopUpAnnotation.removeAll()
            if Store.role == "user"{
                if type == 1{
                    //gig
                    if Store.GigType == 0 || Store.GigType == 1{
                        let param = ["userId": Store.userId ?? "",
                                     "lat": lat,
                                     "long": long,
                                     "radius": mapRadius,
                                     "type":type,
                                     "gigType":gigType] as [String: Any]
                        print("Param----", param)
                        SocketIOManager.sharedInstance.home(dict: param)
                    }else{
                        let param = ["userId": Store.userId ?? "",
                                     "lat": lat,
                                     "long": long,
                                     "radius": mapRadius,
                                     "type":type] as [String: Any]
                        print("Param----", param)
                        SocketIOManager.sharedInstance.home(dict: param)
                    }
                }else{
                    //store
                    let param = ["userId": Store.userId ?? "",
                                 "lat": lat,
                                 "long": long,
                                 "radius": mapRadius,
                                 "type":type] as [String: Any]
                    print("Param----", param)
                    SocketIOManager.sharedInstance.home(dict: param)
                }
            }else{
                let param = ["userId": Store.userId ?? "",
                             "lat": lat,
                             "long": long,
                             "radius": mapRadius] as [String: Any]
                print("Param----", param)
                SocketIOManager.sharedInstance.home(dict: param)
            }
            SocketIOManager.sharedInstance.homeData = { data in
                print("Received data from socket: \(String(describing: data))")
                if self.homeListenerCall == false {
                    guard let data = data, data.count > 0 else { return }
                    if let notificationCount = data[0].data?.notificationsCount {
                        Store.userNotificationCount = notificationCount
                    }
                    let filteredItems = data[0].data?.filteredItems ?? []
                    // Create a set for faster lookups if necessary
                    let filteredItemIDs = Set(filteredItems.map { $0.id })
                    // Add new items to arrDuplicateData or remove existing ones
                    self.arrData.removeAll { existingItem in
                        // If existingItem is not in filteredItems, remove it
                        !filteredItemIDs.contains(existingItem.id)
                    }
                    // Add items from filteredItems to arrDuplicateData if not already present
                    for item in filteredItems {
                        if !self.arrData.contains(where: { $0.id == item.id }) {
                            self.arrData.append(item)
                            
                        }
                    }
                    if Store.role == "user"{
                        if type == 1{
                            let filteredPrices = filteredItems.compactMap { $0.price }
                            let totalPrice = filteredPrices.reduce(0, +)
                            if self.arrData.count > 0{
                                self.lblEarning.text = "$\(totalPrice)"
                            }else{
                                self.lblEarning.text = "$\(0)"
                            }
                            if self.arrData.count > 0 {
                                self.heightViewShadow.constant = 60
                                self.viewNoMatch.isHidden = true
                                self.viewGigList.isHidden = false
                                
                            } else {
                                self.heightViewShadow.constant = 0
                                self.viewNoMatch.isHidden = false
                                self.viewGigList.isHidden = true
                            }
                            if self.arrData.count == 1{
                                self.lblGigCount.text = "\(self.arrData.count) Result"
                            }else{
                                self.lblGigCount.text = "\(self.arrData.count) Results"
                            }
                            self.tblVwList.reloadData()
                        }else if type == 2{
//                            if self.arrData.count > 0 {
//                                self.viewStoreList.isHidden = false
//                            }else{
//                                self.viewStoreList.isHidden = true
//                            }
                            self.heightViewShadow.constant = 0
                            self.viewNoMatch.isHidden = true
                            self.viewGigList.isHidden = true
                            self.collVwStore.reloadData()
                        }else{
//                            if self.arrData.count > 0 {
//                                self.viewBusinessList.isHidden = false
//                            }else{
//                                self.viewBusinessList.isHidden = true
//                            }
                            self.heightViewShadow.constant = 0
                            self.viewNoMatch.isHidden = true
                            self.viewGigList.isHidden = true
                            self.collVwBusiness.reloadData()
                        }
                    }else{
                        self.viewThreeDot.isHidden = true
                        self.viewRefresh.isHidden = false
                        self.viewRecenter.isHidden = false
                    }
                    print("arrData.coun:---\(self.arrData.count)")
                    if !paymentPopUp, let paymentStatus = data[0].data?.paymentStatus, paymentStatus == 0 {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentAlertVC") as! PaymentAlertVC
                        vc.callBack = { [weak self] in
                            
                            guard let self = self else { return }
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GigListVC") as! GigListVC
                            vc.isComing = 2
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        vc.modalPresentationStyle = .overFullScreen
                        self.navigationController?.present(vc, animated: true)
                    }
                    for (index, i) in self.arrData.enumerated() {
                        let centerCoordinate: CLLocationCoordinate2D
                        if Store.role == "user"{
                            
                            switch self.isSelectType {
                            case 1: // Gig
                                let uniqueID = "gig_\(i.id ?? "")"
                                let userId = i.userID
                                if Store.userId == userId{
                                    
                                    self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: i.lat ?? 0, longitude: i.long ?? 0 ), price: i.price ?? 0, seen: 2))
                                }else{
                                    
                                    self.customAnnotations.append(ClusterPoint(coordinate: CLLocationCoordinate2D(latitude: i.lat ?? 0, longitude: i.long ?? 0 ), price: i.price ?? 0, seen: i.seen ?? 0))
                                }
                                
                                let centerCoordinate = CLLocationCoordinate2D(latitude: i.lat ?? 0, longitude: i.long ?? 0)
                                self.processGigImageAndAnnotation(for: i, at: index)
                                
                        
                            case 2: // Business
                            
                                    if index == self.visibleIndex{
                                        self.downloadSingleBusinessImage(at: index, isMove: false)
                                    }
                                
                                self.downloadBusinessImage(at: index)
                            default: // Popup
                                centerCoordinate = CLLocationCoordinate2D(latitude: i.lat ?? 0, longitude: i.long ?? 0)
                                if !self.arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                                    self.arrPoint.append(Point(centerCoordinate))
                                    self.isAppendHeatMap = true
                                }
                                //popupMarker
                          
                               
                               
//                                self.downloadSinglePopUpImage(at: self.visibleIndex,isScroll: false)
                                let difference = self.popUpTime(endTime: i.endDate ?? "")
                                    let imageName = (self.mapView.mapboxMap.styleURI == .dark) ? "newPopUp" : "newPopUp"
                                    if i.image == nil || i.image == ""{
                                        let imageName = (self.mapView.mapboxMap.styleURI == .dark) ? "newPopUp" : "newPopUp"
                                        if let baseImage = UIImage(named: imageName),
                                           let resizedImage = self.resizeImagePopUp(baseImage, to: CGSize(width: 61, height: 93), withText: difference, at: CGPoint(x: 0, y: 10)) {
                                            var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                                            pointAnnotation.image = .init(image: resizedImage, name: "popup_\(index)")
                                            if index < self.arrPopUpPointAnnotations.count {
                                                self.arrPopUpPointAnnotations[index] = pointAnnotation
                                            } else {
                                                self.arrPopUpPointAnnotations.append(pointAnnotation)
                                            }
                                        }
                                    }else{
                                        self.downloadPopUpImage(at: index, isScroll: false)
                           
                                    }
                                }

                            
                        }else{
                            switch i.type ?? "" {
                            case "gig": // Gig
                               
                                self.processGigImageAndAnnotation(for: i, at: index)
                            case "business": // Gig
                                if index == self.visibleIndex{
                                    self.downloadSingleBusinessImage(at: 0, isMove: false)
                                }
                                self.downloadBusinessImage(at: index)
                            default: // Popup
                                
                                centerCoordinate = CLLocationCoordinate2D(latitude: i.lat ?? 0, longitude: i.long ?? 0)
                                                if !self.arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                                                  self.arrPoint.append(Point(centerCoordinate))
                                                  self.isAppendHeatMap = true
                                                }
                                
                                
                                
                                let imageName = (self.mapView.mapboxMap.styleURI == .dark) ? "newPopUp" : "newPopUp"
                                if let baseImage = UIImage(named: imageName),
                                                 let resizedImage = self.resizeImage(baseImage, to: CGSize(width: 61, height: 93)) {
                                                  var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                                                  pointAnnotation.image = .init(image: resizedImage, name: "popup_\(index)")
                                                  if index < self.arrGigPointAnnotations.count {
                                                    self.arrGigPointAnnotations[index] = pointAnnotation
                                                  } else {
                                                    self.arrGigPointAnnotations.append(pointAnnotation)
                                                  }
                                                }
                                                DispatchQueue.main.async {
                                                 if self.mapView.mapboxMap.cameraState.zoom > 7{
                                                    self.pointAnnotationManager?.annotations = self.arrGigPointAnnotations
                                                  }else{
                                                    self.pointAnnotationManager.annotations = []
                                                  }
                                                }
                                              }
                                            }
                                          }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Remove heatmap layers and sources based on zoom level and data presence
                        if self.isAppendHeatMap {
                            let zoomLevel = self.mapView.mapboxMap.cameraState.zoom
                            print("Current zoom level: \(zoomLevel)") // Debugging output
                            if zoomLevel < 5 {
                                self.removeExistingLayersAndSources()
                                // Ensure `arrPoint` contains data before proceeding
                                guard !self.arrPoint.isEmpty else {
                                    print("No points to create earthquake source.")
                                    return
                                }
                                // Create the heatmap source and layer
                                if type != 1{
                                    self.createEarthquakeSource(arrFeature: self.arrPoint)
                                    self.createHeatmapLayer()
                                
                                self.isAppendHeatMap = false
                                }
                            } else {
                               
                                    self.removeExistingLayersAndSources()
                                
                            }
                        }
                    }
                    
                    if self.pointAnnotationManager == nil {
                        self.pointAnnotationManager = self.mapView.annotations.makePointAnnotationManager()
                        self.pointAnnotationManager?.delegate = self
                    }
                   
                   
                    self.homeListenerCall = true
                }
            }
        }
   
    func processGigImageAndAnnotation(for item: FilteredItem, at index: Int) {
        let uniqueID = "gig_\(item.id ?? "")"
        let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
//
        // Add to heatmap points if it doesn't already exist
      
        if !self.arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
            self.arrPoint.append(Point(centerCoordinate))
            self.isAppendHeatMap = true
        }

        // Determine image and size based on item properties
        let imageName = item.seen == 1 ? "seeGig" : "seeGig"
        
        let price = item.price ?? 0
        let width = price < 10 ? 30 :
                    price < 100 ? 45 :
                    price < 1000 ? 55 :
                    price < 10000 ? 65 : 75

        guard let originalImage = UIImage(named: imageName) else { return }
        let resizedImage = self.resizeGigImage(
            originalImage,
            to: price,
            withTitle: "", // Format price as a string
            width: width, height: width
        )

        // Create the annotation
        var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
        pointAnnotation.image = .init(image: resizedImage, name: uniqueID)

        // Check if an annotation with the same unique ID exists
        if let existingIndex = self.arrGigPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
            // Update the existing annotation
            self.arrGigPointAnnotations[existingIndex] = pointAnnotation
        } else {
            // Add a new annotation
            self.removePointClusters()
            DispatchQueue.main.async(qos:.background){
                self.addPointClusters()
            }
            self.arrGigPointAnnotations.append(pointAnnotation)
        }

        
        DispatchQueue.main.async {
//            if self.mapView.mapboxMap.cameraState.zoom > 7 {
                self.pointAnnotationManager?.annotations = self.arrGigPointAnnotations
//            } else {
//                self.pointAnnotationManager?.annotations = []
//            }
          

        }
      
       

    }
  
    func addPointClusters() {
        var features: [MapboxMaps.Feature] = []
        let uniqueAnnotations = Array(Set(customAnnotations))
        
        for item in uniqueAnnotations {
            let point = Point(item.coordinate)
            var properties: JSONObject = [:]
            properties["price"] = JSONValue(item.price)
            properties["seen"] = JSONValue(item.seen)
         
            var feature = Feature(geometry: point)
            feature.properties = properties
            features.append(feature)
        }
        
     let featureCollection = FeatureCollection(features: features)
        var source = GeoJSONSource(id: "custom-clustered-source")
        source.data = .featureCollection(featureCollection)
        
        source.cluster = true
        source.clusterRadius = 60
        source.clusterMaxZoom = 16
        source.clusterProperties = [
            "sum_price": Exp(.sum) { Exp(.get) { "price" } },
            "seen": Exp(.sum) { Exp(.get) { "seen" } },
        ]
 
        do {
            try mapView.mapboxMap.addSource(source)
        } catch {
            print("Error adding GeoJSON source: \(error)")
        }
        
        addImageToStyle()
        
        var clusteredLayer = createClusteredLayer(source: source.id)
        let clusterCountLayer = createNumberLayer(source: source.id)
        var unclusteredLayer = createUnclusteredLayer(source: source.id)
        let unclusteredTextLayer = createUnclusteredTextLayer(source: source.id)
        let symbolLayer = createSymbolLayer(source: source.id)
        do {
            try mapView.mapboxMap.addLayer(clusteredLayer)
            try mapView.mapboxMap.addLayer(clusterCountLayer)
            try mapView.mapboxMap.addLayer(unclusteredLayer)
            try mapView.mapboxMap.addLayer(unclusteredTextLayer)
            try mapView.mapboxMap.addLayer(symbolLayer) // Add after the other layers
        } catch {
            print("Error adding layers: \(error)")
        }
    }
  
    func removePointClusters() {

        do {
            try mapView.mapboxMap.style.removeLayer(withId: "clustered-layer")
        } catch {
            print("Error removing source \("clustered-layer"): \(error)")
        }
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "unclustered-layer")
        } catch {
            print("Error removing source \("clustered-layer"): \(error)")
        }
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "unclustered-symbol-layer")
        } catch {
            print("Error removing source \("unclustered-layer"): \(error)")
        }
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "unclustered-text-layer")
        } catch {
            print("Error removing source \("unclustered-text-layer"): \(error)")
        }
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "cluster-count-layer")
        } catch {
            print("Error removing source \("cluster-count-layer"): \(error)")
        }
        // Remove the source
        let sourceID = "custom-clustered-source" // Replace with the actual source ID
        do {
            try mapView.mapboxMap.style.removeLayer(withId: sourceID)
        } catch {
            print("Error removing source \(sourceID): \(error)")
        }
       
        do {
            try mapView.mapboxMap.style.removeSource(withId: sourceID)
        } catch {
            print("Error removing source \(sourceID): \(error)")
        }
    }
    
   
    func createClusteredLayer(source: String) -> CircleLayer {
        var clusteredLayer = CircleLayer(id: "clustered-layer", source: source)
        clusteredLayer.filter = Exp(.has) { "point_count" }
      
        clusteredLayer.circleColor = .expression(Exp(.match) {
            Exp(.get) { "seen" } // Property to evaluate
            0 // If "seen" equals 0
            UIColor(hex: "#efd267") // Use this color
            UIColor(hex: "#e8b602") // Default color
        })
        
        clusteredLayer.circleRadius = .expression(Exp(.step) {
            Exp(.get) { "sum_price" }
            10 // Default radius
            10 // For `sum_price` >= 10
            25
            500
            25
            1000
            25
        })
     
        return clusteredLayer
    }


    func createNumberLayer(source: String) -> SymbolLayer {
        var numberLayer = SymbolLayer(id: "cluster-count-layer", source: source)
        numberLayer.filter = Exp(.has) { "point_count" }
        
        // Display the aggregated "sum_price" on clusters.
        numberLayer.textField = .expression(Exp(.toString) {
            Exp(.get) { "sum_price" }
        })
//        numberLayer.iconImage = .constant(.name("CoinSeen"))
        
        numberLayer.iconImage = .expression(Exp(.match) {
            Exp(.get) { "seen" }
            1.0
            "Coin"
            2.0
            "grayCoin"
            "CoinSeen"
        })
        
        numberLayer.iconSize = .constant(0.1) // Adjust the size as needed
        numberLayer.textSize = .constant(12)
        numberLayer.textColor = .constant(StyleColor(UIColor.black))
        numberLayer.textHaloColor = .constant(StyleColor(UIColor.clear))
        numberLayer.textHaloWidth = .constant(2)

        return numberLayer
    }
    
    func createSymbolLayer(source: String) -> SymbolLayer {
        var symbolLayer = SymbolLayer(id: "unclustered-symbol-layer", source: source)
        symbolLayer.filter = Exp(.not) { Exp(.has) { "point_count" } }
        symbolLayer.iconImage = .expression(Exp(.match) {
            Exp(.get) { "seen" }
            1.0
            "Coin"
            2.0
            "grayCoin"
            "CoinSeen"
        })
       
      
        do {
            try mapView.mapboxMap.addLayer(symbolLayer)
        } catch {
            print("Error adding symbol layer with image: \(error)")
        }
        return symbolLayer
    }
    
    func createUnclusteredTextLayer(source: String) -> SymbolLayer {
     
    
        var unclusteredTextLayer = SymbolLayer(id: "unclustered-text-layer", source: source)
        
        // Filter for unclustered points.
        unclusteredTextLayer.filter = Exp(.not) { Exp(.has) { "point_count" } }
       
        unclusteredTextLayer.textField = .expression(Exp(.toString) {
            Exp(.get) { "price" }
        })
//        unclusteredTextLayer.iconImage = .constant(.name("CoinSeen"))
        unclusteredTextLayer.iconImage = .expression(Exp(.match) {
            Exp(.get) { "seen" }
            1.0
            "Coin"
            2.0
            "grayCoin"
            "CoinSeen"
        })
       
       
        unclusteredTextLayer.iconSize = .constant(0.1)
        unclusteredTextLayer.textSize = .constant(10)
        unclusteredTextLayer.textColor = .constant(StyleColor(UIColor.black))
       
        unclusteredTextLayer.textHaloColor = .constant(StyleColor(UIColor.clear))
        unclusteredTextLayer.textHaloWidth = .constant(1)
        
        return unclusteredTextLayer
    }
    func createUnclusteredLayer(source: String) -> CircleLayer {
        var unclusteredLayer = CircleLayer(id: "unclustered-layer", source: source)
        unclusteredLayer.filter = Exp(.not) { Exp(.has) { "point_count" } }
        
        unclusteredLayer.circleColor = .expression(Exp(.match) {
            Exp(.get) { "seen" } // Property to evaluate
            0 // If "seen" equals 0
            UIColor(hex: "#e8b602") // Default color
            UIColor(hex: "#efd267") // Use this color
        })
       
        unclusteredLayer.circleRadius = .constant(25)
        unclusteredLayer.circleStrokeWidth = .constant(0)
        unclusteredLayer.circleStrokeColor = .constant(StyleColor(.black))
       
        // Add SymbolLayer for image icon
        var symbolLayer = SymbolLayer(id: "unclustered-symbol-layer", source: source)
        symbolLayer.filter = Exp(.not) { Exp(.has) { "point_count" } }
        
        do {
            try mapView.mapboxMap.addLayer(symbolLayer)
        } catch {
            print("Error adding symbol layer with image: \(error)")
        }

        return unclusteredLayer
    }
    func addImageToStyle() {
        do {
            if let unseenImage = UIImage(named: "Coin") {
                try mapView.mapboxMap.style.addImage(unseenImage, id: "Coin")
            }
            if let unseenImage = UIImage(named: "grayCoin") {
                try mapView.mapboxMap.style.addImage(unseenImage, id: "grayCoin")
            }
            if let seenImage = UIImage(named: "CoinSeen") {
                try mapView.mapboxMap.style.addImage(seenImage, id: "CoinSeen")
            }
        } catch {
            print("Error adding images to style: \(error)")
        }
    }

    func downloadSinglePopUpImage(at index: Int,isScroll:Bool) {
        guard index < arrData.count, Store.role == "user", isSelectType == 3 else { return }

        let item = arrData[index]
        let uniqueID = "popupSingle_\(item.id ?? "")"
        let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
        if isScroll{
            mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: mapView.mapboxMap.cameraState.zoom))
        }
        // Remove annotations if the index is not equal to visibleIndex
        if isScroll == true{
            if index != self.visibleIndex {
                self.arrSinglePopUpAnnotation.removeAll()
                return
            }
        }
        // Process the visibleIndex
        let centerCoordinate1 = CLLocationCoordinate2D(latitude: arrData[index].lat ?? 0, longitude: arrData[index].long ?? 0)
        let imageName = "newPopUp"
        if let baseImage = UIImage(named: imageName),
           let resizedImage = self.resizeImage(baseImage, to: CGSize(width: 61, height: 93)) {
            var pointAnnotation = PointAnnotation(coordinate: centerCoordinate1)
            pointAnnotation.image = .init(image: resizedImage, name: uniqueID)

            // Update or add the annotation
            if let existingIndex = self.arrSinglePopUpAnnotation.firstIndex(where: { $0.image?.name == uniqueID }) {
                self.arrSinglePopUpAnnotation[existingIndex] = pointAnnotation
                
            } else {
                self.arrSinglePopUpAnnotation.append(pointAnnotation)
            }
        }

        DispatchQueue.main.async {
            if self.mapView.mapboxMap.cameraState.zoom > 7 {
//                let combinedAnnotations = self.arrSinglePopUpAnnotation + self.arrPopUpPointAnnotations
//                self.pointAnnotationManager?.annotations = combinedAnnotations
                if self.viewStoreList.isHidden{
                    let combinedAnnotations = self.arrPopUpPointAnnotations
                    self.pointAnnotationManager?.annotations = combinedAnnotations
                }else{
                    let combinedAnnotations = self.arrSinglePopUpAnnotation + self.arrPopUpPointAnnotations
                    self.pointAnnotationManager?.annotations = combinedAnnotations
                }
            } else {
                self.pointAnnotationManager?.annotations = []
            }
        }
    }
    func downloadPopUpImage(at index: Int,isScroll:Bool) {
        if Store.role == "user"{
            
          guard index < arrData.count, Store.role == "user", isSelectType == 3 else { return }
          let item = arrData[index]
          let uniqueID = "popup_\(item.id ?? "")"
          guard let baseImage = UIImage(named: "newPopUp"),
             let logoURL = URL(string: item.image ?? "") else {
              downloadPopUpImage(at: index + 1, isScroll: isScroll)
            return
          }
          let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.long ?? 0)
            if isScroll{
                mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: mapView.mapboxMap.cameraState.zoom))
             
            }
          if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
            arrPoint.append(Point(centerCoordinate))
            self.isAppendHeatMap = true
          }
          // Begin download with completion block
            let difference = popUpTime(endTime: item.endDate ?? "")
            SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
              guard let self = self else { return }
              if let overlayImage = overlayImage {
                  let combinedImage = self.combineImagesPopUp(baseImage: baseImage,
                                                              overlayImage: overlayImage,
                                                              baseSize: CGSize(width: 61, height: 93),
                                                              overlaySize: CGSize(width: 28, height: 28), type: "popup", text: difference
                        )
                        if combinedImage == nil {
                          print("Failed to create combined image")
                        }
                        var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                        pointAnnotation.image = .init(image: combinedImage ?? UIImage(), name: uniqueID)
                        // Check if annotation already exists for this unique ID
                          if let existingIndex = self.arrPopUpPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
                            self.arrPopUpPointAnnotations[existingIndex] = pointAnnotation
                          } else {
                            self.arrPopUpPointAnnotations.append(pointAnnotation)
                          }
                          DispatchQueue.main.async {
                           if self.mapView.mapboxMap.cameraState.zoom > 7{
                           
          //                      self.pointAnnotationManager?.annotations = self.arrPopUpPointAnnotations
                               if self.viewStoreList.isHidden{
                                   let combinedAnnotations = self.arrPopUpPointAnnotations
                                   self.pointAnnotationManager?.annotations = combinedAnnotations
                               }else{
//                                   let combinedAnnotations = self.arrSinglePopUpAnnotation + self.arrPopUpPointAnnotations
                                   let combinedAnnotations = self.arrPopUpPointAnnotations
                                   self.pointAnnotationManager?.annotations = combinedAnnotations
                               }
                            }else{
                              self.pointAnnotationManager.annotations = []
                            }
                          }
                    }
                
            }

        }else{
          guard index < arrData.count, Store.role != "user" else { return }
          let item = arrData[index]
          let uniqueID = "popup_\(item.id ?? "")"
          guard let baseImage = UIImage(named: "newPopUp"),
             let logoURL = URL(string: item.image ?? "") else {
              downloadPopUpImage(at: index+1, isScroll: isScroll)
            return
          }
          let centerCoordinate = CLLocationCoordinate2D(latitude: item.lat ?? 0, longitude: item.lat ?? 0)
          if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
            arrPoint.append(Point(centerCoordinate))
            self.isAppendHeatMap = true
          }
          // Begin download with completion block
          SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
            guard let self = self else { return }
            if let overlayImage = overlayImage {
              let combinedImage = self.combineImagesPopUp(
                baseImage: baseImage,
                overlayImage: overlayImage,
                baseSize: CGSize(width: 40, height: 50),
                overlaySize: CGSize(width: 30, height: 30), type: "popup", text: "05.10"
              )
              var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
              pointAnnotation.image = .init(image: combinedImage ?? UIImage(), name: uniqueID)
              // Check if annotation already exists for this unique ID
                if let existingIndex = self.arrPopUpPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
                  self.arrPopUpPointAnnotations[existingIndex] = pointAnnotation
                } else {
                  self.arrPopUpPointAnnotations.append(pointAnnotation)
                }
                DispatchQueue.main.async {
                 if self.mapView.mapboxMap.cameraState.zoom > 7{
                     let combinedAnnotations = self.arrSinglePopUpAnnotation + self.arrPopUpPointAnnotations
                          self.pointAnnotationManager?.annotations = combinedAnnotations
//                    self.pointAnnotationManager?.annotations = self.arrPopUpPointAnnotations
                  }else{
                    self.pointAnnotationManager.annotations = []
                  }
                }
            }
          }
        }
      }
  
   
        func downloadBusinessImage(at index: Int) {
            if Store.role == "user"{
                guard index < arrData.count, Store.role == "user", isSelectType == 2 else { return }
                let item = arrData[index]
                let uniqueID = "business_\(item.id ?? "")"
                guard let baseImage = UIImage(named: "business"),
                      let logoURL = URL(string: item.profilePhoto ?? "") else {
                    downloadBusinessImage(at: index + 1)
                    return
                }
                let centerCoordinate = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
                if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                    arrPoint.append(Point(centerCoordinate))
                    self.isAppendHeatMap = true
                }
                // Begin download with completion block
                SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
                    guard let self = self else { return }
                    if let overlayImage = overlayImage {
                        let combinedImage = self.combineImages(
                            baseImage: baseImage,
                            overlayImage: overlayImage,
                            baseSize: CGSize(width: 34, height: 45),
                            overlaySize: CGSize(width: 25, height: 25), type: "business"
                        )
                        var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                        pointAnnotation.image = .init(image: combinedImage ?? UIImage(), name: uniqueID)
                        // Check if annotation already exists for this unique ID

                            if let existingIndex = self.arrBusinessPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
                                self.arrBusinessPointAnnotations[existingIndex] = pointAnnotation
                              
                            } else {
                                self.arrBusinessPointAnnotations.append(pointAnnotation)
                            }
                            DispatchQueue.main.async {
                               if self.mapView.mapboxMap.cameraState.zoom > 7{
                                   if self.viewBusinessList.isHidden{
                                       let combinedAnnotations =  self.arrBusinessPointAnnotations
                                       self.pointAnnotationManager?.annotations = combinedAnnotations
                                   }else{
                                       let combinedAnnotations = self.arrSingleBuisnessAnnotation + self.arrBusinessPointAnnotations
                                       self.pointAnnotationManager?.annotations = combinedAnnotations
                                   }
                                }else{
                                    self.pointAnnotationManager.annotations = []
                                }

                            }
                        }

                }
            }else{
                
                guard index < arrData.count, Store.role != "user" else { return }
                let item = arrData[index]
                
                let uniqueID = "business_\(item.id ?? "")"
                guard let baseImage = UIImage(named: "business"),
                      let logoURL = URL(string: item.profilePhoto ?? "") else {
                    downloadBusinessImage(at: index+1)
                    return
                }
                let centerCoordinate = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
                if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                    arrPoint.append(Point(centerCoordinate))
                    self.isAppendHeatMap = true
                }
                // Begin download with completion block
                SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
                    guard let self = self else { return }
                    if let overlayImage = overlayImage {
                        let combinedImage = self.combineImages(
                            baseImage: baseImage,
                            overlayImage: overlayImage,
                            baseSize: CGSize(width: 34, height: 45),
                            overlaySize: CGSize(width: 25, height: 25), type: "business"
                        )
                        var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                        pointAnnotation.image = .init(image: combinedImage ?? UIImage(), name: uniqueID)
                        // Check if annotation already exists for this unique ID
                        
                            if let existingIndex = self.arrGigPointAnnotations.firstIndex(where: { $0.image?.name == uniqueID }) {
                                self.arrGigPointAnnotations[existingIndex] = pointAnnotation
                            
                            } else {
                                self.arrGigPointAnnotations.append(pointAnnotation)
                            }
                            DispatchQueue.main.async {
                               if self.mapView.mapboxMap.cameraState.zoom > 7{
                                    self.pointAnnotationManager?.annotations = self.arrGigPointAnnotations
                                }else{
                                    self.pointAnnotationManager.annotations = []
                                }
                                
                            }
                        
                    }
                }
            }
        }
   
    func downloadSingleBusinessImage(at index: Int,isMove:Bool) {
       
        if Store.role == "user"{
            guard index < arrData.count, Store.role == "user", isSelectType == 2 else { return }
            let item = arrData[index]
            let uniqueID = "businessSingle_\(item.id ?? "")"
            guard let baseImage = UIImage(named: "marker2"),
                  let logoURL = URL(string: item.profilePhoto ?? "") else {
                downloadSingleBusinessImage(at: index, isMove: isMove)
                return
            }
            let centerCoordinate = CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0)
            if isMove{
                mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: mapView.mapboxMap.cameraState.zoom))
            }
            if !arrPoint.contains(where: { $0.coordinates == centerCoordinate }) {
                arrPoint.append(Point(centerCoordinate))
                self.isAppendHeatMap = true
            }
            // Begin download with completion block
            SDWebImageDownloader.shared.downloadImage(with: logoURL) { [weak self] overlayImage, _, _, error in
                guard let self = self else { return }
                if let overlayImage = overlayImage {
                    let combinedImage = self.combineImages(
                        baseImage: baseImage,
                        overlayImage: overlayImage,
                        baseSize: CGSize(width: 42, height: 55),
                        overlaySize: CGSize(width: 33, height: 33), type: "business"
                    )
                    var pointAnnotation = PointAnnotation(coordinate: centerCoordinate)
                    pointAnnotation.image = .init(image: combinedImage ?? UIImage(), name: uniqueID)
                    // Check if annotation already exists for this unique ID
                    
                    if let existingIndex = self.arrSingleBuisnessAnnotation.firstIndex(where: { $0.image?.name == uniqueID }) {
                        self.arrSingleBuisnessAnnotation.removeAll()
                        self.arrSingleBuisnessAnnotation.append(pointAnnotation)
                        
                    } else {
                        self.arrSingleBuisnessAnnotation.removeAll()
                        self.arrSingleBuisnessAnnotation.append(pointAnnotation)
                        
                    }
                    DispatchQueue.main.async {
                        if self.mapView.mapboxMap.cameraState.zoom > 7{
                            self.pointAnnotationManager?.annotations = self.arrSingleBuisnessAnnotation
                        }else{
                            self.pointAnnotationManager.annotations = []
                        }
                        
                    }
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
    
    func resizeImagePopUp(_ image: UIImage, to size: CGSize, withText text: String, at point: CGPoint) -> UIImage? {
        // Set up text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8), // Adjust font size
            .foregroundColor: UIColor.white // Adjust text color
        ]
        
        // Calculate text size
        let textSize = text.size(withAttributes: attributes)
        print("Text size: \(textSize)") // Debugging
        
        // Adjust the image width based on the text size
        let adjustedWidth = max(size.width, textSize.width+50)
        let adjustedHeight = size.height

        // Start graphics context with adjusted size
        UIGraphicsBeginImageContextWithOptions(CGSize(width: adjustedWidth, height: adjustedHeight), false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw the resized image to fit the adjusted size
        image.draw(in: CGRect(origin: .zero, size: CGSize(width: adjustedWidth, height: adjustedHeight)))
        
        // Calculate the text position (centered horizontally, 20 points from bottom)
        let textRect = CGRect(
            x: (adjustedWidth - textSize.width) / 2,
            y: max(0, adjustedHeight - textSize.height - 23),
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
        baseImage: UIImage,
        overlayImage: UIImage,
        baseSize: CGSize,
        overlaySize: CGSize,
        type: String,
        text: String
    ) -> UIImage? {
        // Set up text attributes
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.clear
        ]
        
        // Calculate text size
        let textSize = text.size(withAttributes: textAttributes)
        print("Text size: \(textSize)") // Debugging
        
        // Adjust base width based on text width
        let adjustedBaseWidth = max(baseSize.width, textSize.width + 50) // Adding some padding around the text
        let adjustedBaseSize = CGSize(width: adjustedBaseWidth, height: baseSize.height)

        // Start graphics context with adjusted base size
        UIGraphicsBeginImageContextWithOptions(adjustedBaseSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to create graphics context.")
            return nil
        }
        
        // Draw the base image with the adjusted size
        baseImage.draw(in: CGRect(origin: .zero, size: adjustedBaseSize))
        
        // Draw the overlay image
        let overlayOrigin = CGPoint(x: (adjustedBaseSize.width - overlaySize.width) / 2, y: 8)
        let overlayRect = CGRect(origin: overlayOrigin, size: overlaySize)
        let path = UIBezierPath(ovalIn: overlayRect)
        context.saveGState()
        path.addClip()
        overlayImage.draw(in: overlayRect)
        context.restoreGState()
        
        // Draw the text
        let textRect = CGRect(
            x: max(0, (adjustedBaseSize.width - textSize.width) / 2),
            y: max(0, adjustedBaseSize.height - textSize.height - 23),
            width: textSize.width,
            height: textSize.height
        )
        
        print("Text Rect: \(textRect)") // Debugging
        text.draw(in: textRect, withAttributes: textAttributes)
        
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
      func removeExistingLayersAndSources() {
        // Remove heatmap layer
        do {
          try mapView.mapboxMap.removeLayer(withId: heatmapLayerId)
          print("Heatmap layer removed successfully")
        } catch {
          print("Error removing heatmap layer: \(error)")
        }
        // Remove the GeoJSON source if it exists
        do {
          try mapView.mapboxMap.removeSource(withId: earthquakeSourceId)
          print("Earthquake source removed successfully")
        } catch {
          print("Error removing earthquake source: \(error)")
        }
      }
     
      func createEarthquakeSource(arrFeature: [Point]) {
        let features: [MapboxMaps.Feature] = arrFeature.map { point in
          MapboxMaps.Feature(geometry: .point(point))
        }
        let featureCollection = FeatureCollection(features: features)
        var geoJSONSource = GeoJSONSource(id: earthquakeSourceId)
        geoJSONSource.data = .featureCollection(featureCollection)
        do {
          try mapView.mapboxMap.addSource(geoJSONSource)
          print("Source added successfully")
        } catch {
          print("Error adding source: \(error)")
        }
      }
    func createHeatmapLayer() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
            //locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            
            var heatmapLayer = HeatmapLayer(id: heatmapLayerId, source: earthquakeSourceId)
            heatmapLayer.heatmapColor = .expression(
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.heatmapDensity)
                    0
                    UIColor.clear
                    0.3 // Adjusted density for #2F8E82
                    UIColor(hex: "#2F8E82") // Increase the density threshold for this color
                    0.5
                    UIColor(hex: "#86AD40")
                    0.6
                    UIColor(hex: "#BF9013")
                    0.8
                    UIColor(hex: "#D05D10")
                    1.0
                    UIColor(hex: "#DA0509")
                }
            )
            // Set heatmap intensity and radius
            heatmapLayer.heatmapIntensity = .constant(0.7)
            heatmapLayer.heatmapRadius = .expression(Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                40 // Larger radius at low zoom levels
                9
                50 // Increase radius as zoom level increases
                15
                70 // Maximum radius at highest zoom level
            })
            // Set heatmap opacity based on zoom level
            heatmapLayer.heatmapOpacity = .expression(Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                1 // Full opacity at zoom level 0
                9
                0.5 // Reduced opacity at zoom level 9
                12
                0 // Hide heatmap at zoom level 12 and above
            })
            // Add the heatmap layer above other layers
            do {
                try mapView.mapboxMap.addLayer(heatmapLayer)
                print("Heatmap layer added successfully")
            } catch {
                print("Error adding heatmap layer: \(error)")
            }
        default:
            print("wdwedwd")
        }
      }

   
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        
        print("DidBegan")
       
        if isSelectType == 2{
            self.viewBusinessList.isHidden = true
           
        }else if isSelectType == 3{
            self.viewStoreList.isHidden = true
        }else{
            self.viewInMyLocation.isHidden = false
            self.viewWorldwide.isHidden = false
        }
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
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
    
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
   
  
    @objc func methodOfReceivedGetTabBar(notification: Notification) {
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
           // locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: true)
            if Store.role == "user"{
//                viewBtnGig.isHidden = false
//                viewBtnBusiness.isHidden = false
//                viewBtnStore.isHidden = false
                if type == 1{
                    if viewGigType.isHidden == true{
//                        viewThreeDot.isHidden = false
                        viewThreeDot.isHidden = true
                    }
                }else{
                    if viewGigType.isHidden == false{
                        viewThreeDot.isHidden = true
                        
                    }
                }
            }else{
                viewThreeDot.isHidden = true
            }
            btnUpArrow.isSelected = false
            removeAllArray()
            homeListenerCall = false
            mapData(radius: mapRadius, type: type, gigType: Store.GigType ?? 0,lat: mapView.mapboxMap.cameraState.center.latitude,long: mapView.mapboxMap.cameraState.center.longitude)
        default:
            print("Location permission not determined")
        }
    }
    @objc func selectOtherTab(notification: Notification) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
           // locationDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: true)
            if type == 1{
                if viewGigType.isHidden == true{
//                    viewThreeDot.isHidden = false
                    viewThreeDot.isHidden = false
                }
                
            }else{
                if viewGigType.isHidden == false{
                    viewThreeDot.isHidden = true
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
                if self.arrData.count > 0 {
                    self.viewNoMatch.isHidden = true
                } else {
                    self.viewNoMatch.isHidden = false
                }
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
//        mapVw.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: boundary), animated: true)
        // Print radius to debug
        print("Restricting map with radius (meters): \(radiusInMeters)")
        

        // Update zoom range dynamically
//        mapVw.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 10000, maxCenterCoordinateDistance: radiusInMeters * 2), animated: true)
    }


    
    //MARK: - BUTTON ACTION
    @IBAction func actionInMyLocation(_ sender: UIButton) {
        self.dismiss(animated: true)
        if isInMyLocation{
            viewInMyLocation.animateRefreshAndRecenter()
            Store.GigType = 1
            isInMyLocation = false
            isWorldWide = true
            getInmylocationGigs()
            myLocationSetup()
        }
    }
    func myLocationSetup(){
        viewInMyLocation.backgroundColor = .app
        imgVwInMyLocation.image = UIImage(named: "inMySel")
        viewWorldwide.backgroundColor = .white
        imgVwWorldwide.image = UIImage(named: "world")
        
    }
    @IBAction func actionWorldWide(_ sender: UIButton) {
        self.dismiss(animated: true)
        if isWorldWide{
            viewWorldwide.animateRefreshAndRecenter()
            Store.GigType = 0
            isInMyLocation = true
            isWorldWide = false
            getWorlwideGigs()
            worldwideSetup()
        }
    }
    func worldwideSetup(){
        viewInMyLocation.backgroundColor = .white
        imgVwInMyLocation.image = UIImage(named: "inmy")
        viewWorldwide.backgroundColor = .app
        imgVwWorldwide.image = UIImage(named: "worldSel")
        
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
//
//        let editor = ZLEditImageViewController(image: imgVwAddStcikers.image ?? UIImage())
//                  // editor.editFinishBlock = { [weak self] editedImage in
//                       // self?.handleEditedImage(editedImage)
//                   // }
//                    self.present(editor, animated: true, completion: nil)
    }
    @IBAction func actionThreeDot(_ sender: UIButton) {
        mapView.viewAnnotations.removeAll()
//        self.sideMenuController?.showLeftView(animated: true)
          self.viewThreeDot.isHidden = true

          // Set the initial hidden state for the views
          self.viewGigType.transform = CGAffineTransform(rotationAngle: .pi / 2)
          self.viewRecenter.transform = CGAffineTransform(rotationAngle: .pi / 2)
          self.viewRefresh.transform = CGAffineTransform(rotationAngle: .pi / 2)

          // Make views hidden initially
          self.viewGigType.isHidden = true
          self.viewRecenter.isHidden = true
          self.viewRefresh.isHidden = true

          UIView.animate(withDuration: 0.5, animations: {
              if self.type == 1 {
                  // Show and animate the viewGigType
                  self.viewGigType.isHidden = false
                  self.viewGigType.transform = .identity // Rotate back to normal

                  // Show and animate the viewRecenter
                  self.viewRecenter.isHidden = false
                  self.viewRecenter.transform = .identity

                  // Show and animate the viewRefresh
                  self.viewRefresh.isHidden = false
                  self.viewRefresh.transform = .identity
              } else {
                  // Hide viewGigType
                  self.viewGigType.isHidden = true

                  // Show and animate the viewRecenter
                  self.viewRecenter.isHidden = false
                  self.viewRecenter.transform = .identity

                  // Show and animate the viewRefresh
                  self.viewRefresh.isHidden = false
                  self.viewRefresh.transform = .identity
              }
          })

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
        self.heightViewShadow.constant = 0
        viewBusinessList.isHidden = true
        viewStoreList.isHidden = true
        viewNoMatch.isHidden = true
        
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
        removePointClusters()
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
        viewWorldwide.isHidden = false
        viewInMyLocation.isHidden = false
        heightViewShadow.constant = 0
        viewBusinessList.isHidden = true
        viewStoreList.isHidden = true
        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        removePointClusters()
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
        viewRecenter.isHidden = false
        viewRefresh.isHidden = false
        viewThreeDot.isHidden = true
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
    }
    @IBAction func actionStores(_ sender: UIButton) {
        self.visibleIndex = 0
        self.heightViewShadow.constant = 0
        viewGigList.isHidden = true
        viewBusinessList.isHidden = true
        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        removePointClusters()
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
                    heightViewShadow.constant = 0
                    viewBusinessList.isHidden = true
                    viewGigList.isHidden = true
                    removeAllArray()
                    viewThreeDot.isHidden = true
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
    func getStoreData(visibleIndex:Int){
        viewWorldwide.isHidden = true
        viewInMyLocation.isHidden = true
        self.visibleIndex = visibleIndex
        self.heightViewShadow.constant = 0
        viewGigList.isHidden = true
        viewBusinessList.isHidden = true
        viewNoMatch.isHidden = true
        customAnnotations.removeAll()
        removePointClusters()
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
                    heightViewShadow.constant = 0
                    viewBusinessList.isHidden = true
                    viewGigList.isHidden = true
                    removeAllArray()
                    viewThreeDot.isHidden = true
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
    @IBAction func actionBusiness(_ sender: UIButton) {
        self.visibleIndex = 0
        customAnnotations.removeAll()
        removePointClusters()
        viewGigList.isHidden = true
        viewStoreList.isHidden = true
        viewNoMatch.isHidden = true
        self.heightViewShadow.constant = 0
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if homeListenerCall{
                if isBusinessType{
                    isBusinessType = false
                    isGigType = true
                    isPopupType = true
                    heightViewShadow.constant = 0
                    viewStoreList.isHidden = true
                    viewGigList.isHidden = true
                    viewThreeDot.isHidden = true
                    removeAllArray()
                    viewThreeDot.isHidden = true

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
    func getBusinessData(visibleIndex:Int){
        viewWorldwide.isHidden = true
        viewInMyLocation.isHidden = true
        self.visibleIndex = visibleIndex
        customAnnotations.removeAll()
        removePointClusters()
        viewBusinessList.isHidden = false
        viewGigList.isHidden = true
        viewStoreList.isHidden = true
        viewNoMatch.isHidden = true
        self.heightViewShadow.constant = 0
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            removeDataWhileLocationDenied()
        case .authorizedWhenInUse, .authorizedAlways:
            if homeListenerCall{
                if isBusinessType{
                    isBusinessType = false
                    isGigType = true
                    isPopupType = true
                    heightViewShadow.constant = 0
                    viewStoreList.isHidden = true
                    viewGigList.isHidden = true
                    viewThreeDot.isHidden = true
                    removeAllArray()
                    viewThreeDot.isHidden = true

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
    func isSelectStoreAndBusinessBtn(){
        viewRecenter.isHidden = false
         viewRefresh.isHidden = false
        viewThreeDot.isHidden = true
        viewGigType.isHidden = true
        vwEarning.isHidden = true
    }
  
    @IBAction func actionUpArrow(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            self.btnUpArrow.setImage(UIImage(named:"bottomarrow"), for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.heightViewShadow.constant = CGFloat(self.arrData.count*130+40)
                self.tblVwList.isScrollEnabled = true
                self.view.layoutIfNeeded()
            }
        } else {
            self.btnUpArrow.setImage(UIImage(named:"uparrow"), for: .normal)
            UIView.animate(withDuration: 0.5) {
               self.heightViewShadow.constant = 130+5
                self.tblVwList.isScrollEnabled = false
                self.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func actionRefresh(_ sender: UIButton) {
        
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied:
            print("denied")
        case .authorizedWhenInUse, .authorizedAlways:
            self.dismiss(animated: false)
            customAnnotations.removeAll()
            removePointClusters()
            viewRefresh.animateRefreshAndRecenter()
            removeAllArray()
            tblVwList.reloadData()
            collVwStore.reloadData()
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
            mapRadius = 10
                recenter()
        default:
            print("Location permission not determined")
        }
    }
    func recenter() {
        viewRecenter.animateRefreshAndRecenter()
        customAnnotations.removeAll()
        removePointClusters()
        removeAllArray()
        tblVwList.reloadData()
        collVwStore.reloadData()
        collVwBusiness.reloadData()
        getWillApearAllData()

        let centerCoordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong)
        mapView.mapboxMap.setCamera(to: CameraOptions(center: centerCoordinate, zoom: 10))

    }
}
//MARK: - CLLocationManagerDelegate
extension ExploreTabVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.last else { return }
        setupMapWithCoordinate(userLocation.coordinate)
        currentLat = userLocation.coordinate.latitude
        currentLong = userLocation.coordinate.longitude
        myCurrentLat = userLocation.coordinate.latitude
        myCurrentLong = userLocation.coordinate.longitude
        uiSet()
        addMapView(currentLat: userLocation.coordinate.latitude, currentLong: userLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
       
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
extension ExploreTabVC:AnnotationInteractionDelegate{
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
                vc.callBack = { [weak self] isSelect in
                    guard let self = self else { return }
                    if isSelect == 0{
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
                        vc.gigId = selectedItem.id ?? ""
                        vc.callBack = { [weak self] in
                            guard let self = self else { return }
                            self.customAnnotations.removeAll()
                            self.removePointClusters()
                            let status = CLLocationManager.authorizationStatus()
                            switch status {
                            case .restricted, .denied:
                                print("denied")
                            case .authorizedWhenInUse, .authorizedAlways:
                                self.dismiss(animated: false)
                                self.removeAllArray()
                                self.tblVwList.reloadData()
                                self.collVwStore.reloadData()
                                self.collVwBusiness.reloadData()
                                self.getWillApearAllData()
                            default:
                                print("Location permission not determined")
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)

                    }
                }
                self.present(vc, animated: true)
            }else{
      
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
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
                
            }
        }else if selectedItem.type == "popUp"{
          guard !isPopUpVCShown else { return }
          isPopUpVCShown = true
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
          vc.popupId = selectedItem.id ?? ""
            vc.callBack = { [weak self] index in
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
            vc.gigId = selectGigId
            vc.callBack = {[weak self] in
                
                guard let self = self else { return }
             self.mapView.viewAnnotations.removeAll()
             self.pointAnnotationManager.annotations = []
             self.arrGigPointAnnotations.removeAll()
             self.mapData(radius: self.mapRadius, type: self.type, gigType: Store.GigType ?? 0 ,lat: self.mapView.mapboxMap.cameraState.center.latitude,long: self.mapView.mapboxMap.cameraState.center.longitude)
            }
            self.navigationController?.pushViewController(vc, animated: true)
           } else if selectItemSeen == 0 {
            let param: parameters = ["userId": Store.userId ?? "", "lat": "\(currentLat)", "long": "\(currentLong)", "radius": mapRadius, "gigId": selectGigId,"type":2,"gigType":Store.GigType ?? 0 ]
            SocketIOManager.sharedInstance.home(dict: param)
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
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
           }
          }
         }else{
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
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
         }
        }
    }
//MARK: - UICollectionViewDelegate
extension ExploreTabVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrData.count > 0{
            return arrData.count
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collVwBusiness{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularServicesCVC", for: indexPath) as! PopularServicesCVC
            cell.vwShadow.layer.masksToBounds = false
            cell.vwShadow.layer.shadowColor = UIColor(hex: "#5F5F5F").cgColor
            cell.vwShadow.layer.shadowOpacity = 0.44
            cell.vwShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.vwShadow.layer.shouldRasterize = true
            cell.vwShadow.layer.rasterizationScale = UIScreen.main.scale
            cell.isComing = true
            if arrData.count > 0{
                cell.indexpath = indexPath.row
                if arrData[indexPath.row].categoryName?.count ?? 0 > 0{
                    cell.arrCategories = arrData[indexPath.row].categoryName ?? []
                }
                cell.uiSet()
                let business = arrData[indexPath.row]
                let rating = business.UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
                cell.lblUserRatingCount.text = "(\(business.userRatingCount ?? 0))"
                cell.lblServiceName.text = business.businessname ?? ""
                cell.imgVwUser.imageLoad(imageUrl: business.profilePhoto ?? "")
                cell.imgVwService.imageLoad(imageUrl: business.coverPhoto ?? "")
                if business.status == 2{
                    cell.imgVwBlueTick.isHidden = false
                }else{
                    cell.imgVwBlueTick.isHidden = true
                }
                var openingHoursFound = false
                for openingHour in business.openingHours ?? [] {
                    if openingHour.day == currentDay {
                        openingHoursFound = true
                        let startTime12 = convertTo12HourFormat(openingHour.starttime ?? "")
                        let endTime12 = convertTo12HourFormat(openingHour.endtime ?? "")
                        cell.lblTime.text = "\(startTime12) - \(endTime12)"
                        break
                    }
                }
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
            if arrData.count > 0{
                cell.lblStoreName.text = arrData[indexPath.row].name ?? ""
                cell.imgVwStore.imageLoad(imageUrl: arrData[indexPath.row].businessLogo ?? "")
                cell.lblUserName.text = arrData[indexPath.row].user?.name ?? ""
                let rating = arrData[indexPath.row].UserRating ?? 0
                let formattedRating = String(format: "%.1f", rating)
                cell.lblRating.text = formattedRating
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        if arrData.count > 0{
            
            if homeListenerCall{
                
                self.dismiss(animated: true)
                if collectionView == collVwBusiness{
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutServicesVC") as! AboutServicesVC
                    vc.businessId = arrData[indexPath.row].id ?? ""
                    vc.businessIndex = indexPath.row
                    
                    Store.BusinessUserIdForReview = arrData[indexPath.row].id ?? ""
                    vc.callBack = { [weak self] index in
                        
                        guard let self = self else { return }
                        self.animateZoomInOut()
                        self.getBusinessData(visibleIndex: index)
                        
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpDeatilVC") as! PopUpDeatilVC
                    vc.popupId = arrData[indexPath.row].id ?? ""
                    vc.popupIndex = indexPath.row
                    vc.callBack = { [weak self] index in
                        guard let self = self else { return }
                        self.animateZoomInOut()
                        self.getStoreData(visibleIndex: index)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collVwBusiness{
            return CGSize(width: view.frame.size.width / 1-20, height: 200)
        }else{
            return CGSize(width: view.frame.size.width / 1-20, height: 100)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
          
          let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//          if let visibleIndexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)) {
//              print("Currently visible index: \(visibleIndexPath.row)")
//              let item = arrData[visibleIndexPath.row]
//              let uniqueID = "businessSingle_\(item.id ?? "")"
//              self.visibleIndex = visibleIndexPath.row
//              self.arrSinglePopUpAnnotation.removeAll()
//              self.downloadSingleBusinessImage(at: visibleIndexPath.row)
//
//              self.downloadBusinessImage(at: visibleIndexPath.row)
//              self.downloadSinglePopUpImage(at: visibleIndexPath.row, isScroll: true)
//
//          }
       centerCell()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        centerCell()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            centerCell()
       
        }
    }
 
}

extension ExploreTabVC {
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
extension ExploreTabVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//MARK: - TABLEVIEW DELEGATE AND DATASOURCE
extension ExploreTabVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataCount = arrData.count
        tableView.isScrollEnabled = dataCount > 1
        return dataCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigNearByTVC", for: indexPath) as! GigNearByTVC
        if arrData.count > 0 {
            cell.lblName.text = arrData[indexPath.row].name
            cell.lblTitle.text = arrData[indexPath.row].title
            cell.lblPrice.text = "$\(arrData[indexPath.row].price ?? 0)"
            let rating = arrData[indexPath.row].UserRating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            let reviewCount = arrData[indexPath.row].userRatingCount ?? 0
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
            if arrData[indexPath.row].image == "" || arrData[indexPath.row].image == nil{
                cell.imgVwGig.image = UIImage(named: "dummy")
            }else{
                cell.imgVwGig.imageLoad(imageUrl: arrData[indexPath.row].image ?? "")
            }

            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if homeListenerCall{
            self.dismiss(animated: true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplyGigVC") as! ApplyGigVC
            if arrData.count > 0{
                vc.gigId = arrData[indexPath.row].id ?? ""
            }
            vc.callBack = {[weak self] in
                
                guard let self = self else { return }
                self.animateZoomInOut()
                self.getGigData()
                if self.type == 1{
                    self.viewThreeDot.isHidden = false
                }
            }

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension ExploreTabVC {
    var earthquakeSourceId: String { "earthquakes" }
    var earthquakeLayerId: String { "earthquake-viz" }
    var heatmapLayerId: String { "earthquakes-heat" }
    var heatmapLayerSource: String { "earthquakes" }
    var circleLayerId: String { "earthquakes-circle" }
    var earthquakeURL: URL { URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson")! }
}
//MARK: - CLLocationCoordinate2D
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
//MARK: - MSStickerBrowserViewDataSource
extension ExploreTabVC: MSStickerBrowserViewDataSource{
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

