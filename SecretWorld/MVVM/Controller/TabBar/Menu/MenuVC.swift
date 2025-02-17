//
//  MenuVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 24/01/24.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation

class MenuVC: UIViewController {
    
    @IBOutlet var viewDot: UIView!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var viewBack: UIView!
    @IBOutlet var btnLoaccation: UIButton!
    @IBOutlet var tblVwServices: UITableView!
    
    var viewModel = AddServiceVM()
    var arrService = [ServiceDetail]()
    var userDetail:GetBusinessServiceData?
    var locationManager = CLLocationManager()
    var offSet = 1
    var limit = 10
    var totalpages = 0
    var placesClient: GMSPlacesClient!
    var apiCalling = false
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDidLoadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationMenu(notification:)), name: Notification.Name("CallMenuApi"), object: nil)
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationAllow(notification:)), name: Notification.Name("locationAllow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getLocationDenied(notification:)), name: Notification.Name("locationDenied"), object: nil)
          getWillAppearData()
        
    }
    @objc func getLocationAllow(notification: Notification) {
        btnLoaccation.isHidden = false
    }
    @objc func getLocationDenied(notification: Notification) {
        
        btnLoaccation.isHidden = true
        locationDeniedAlert()
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
    @objc func methodOfReceivedNotificationMenu(notification: Notification) {
        
        offSet = 1
        arrService.removeAll()
        getServiceApi(loader: false)
    }
    func getWillAppearData(){
        if Store.userNotificationCount ?? 0 > 0{
            self.viewDot.isHidden = false
        }else{
            self.viewDot.isHidden = true
        }
        offSet = 1
        arrService.removeAll()
        getServiceApi(loader: false)

    }
    func getDidLoadData(){
        btnLoaccation.titleLabel?.numberOfLines = 2
        uiSet()
    }
    func uiSet() {
          let nibNearBy = UINib(nibName: "ServiceTVC", bundle: nil)
          tblVwServices.register(nibNearBy, forCellReuseIdentifier: "ServiceTVC")
          viewBack.layer.cornerRadius = 15
          viewBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
          tblVwServices.showsVerticalScrollIndicator = false
          tblVwServices.refreshControl = refreshControl // Set the refresh control
          refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged) // Add target for refresh
          getLocation()
      }
    
    @objc private func refreshData() {
          offSet = 1
          arrService.removeAll()
          getServiceApi(loader: false)
      }
      
    
    func getLocation(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
    }
    func getServiceApi(loader:Bool){
        arrService.removeAll()
        viewModel.getAllService(loader: loader, offSet: offSet, limit: limit) { data in
            self.arrService.append(contentsOf: data?.service ?? [])
            Store.BusinessServicesList = data
            self.totalpages = data?.totalPages ?? 0
            self.userDetail = data
            if self.arrService.count > 0{
                self.lblNoData.text = ""
            }else{
                self.lblNoData.text = "Data Not Found!"
            }
            DispatchQueue.main.async {
                self.tblVwServices.reloadData()
                self.apiCalling = true
                self.refreshControl.endRefreshing()
            }
           
        }
    }
    
    @IBAction func actionLocation(_ sender: UIButton) {
    }
    @IBAction func actionNotifications(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        vc.callBack = {
            self.viewDot.isHidden = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - UITableViewDelegate
extension MenuVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  arrService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTVC", for: indexPath) as! ServiceTVC
        if arrService.count > 0{
            
            if arrService[indexPath.row].serviceImages?.count ?? 0 > 0{
                cell.imgVwService.imageLoad(imageUrl: arrService[indexPath.row].serviceImages?[0] ?? "")
            }
            let price = Double(arrService[indexPath.row].actualPrice ?? 0)
          
            cell.lblPrice.text = String(format: "$%.2f", price)
            cell.lblOff.text = "\(arrService[indexPath.row].discount ?? 0)% Off"
            cell.lblPrevPrice.text = "$\(arrService[indexPath.row].price ?? 0)"
            cell.lblServiceName.text = arrService[indexPath.row].serviceName ?? ""
            cell.lblUserName.text = arrService[indexPath.row].serviceName ?? ""
            
            let rating = arrService[indexPath.row].rating ?? 0.0
            let formattedRating = String(format: "%.1f", rating)
            cell.lblRating.text = formattedRating
            cell.contentView.layer.masksToBounds = false
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowOpacity = 0.1
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.contentView.layer.shouldRasterize = true
            cell.contentView.layer.rasterizationScale = UIScreen.main.scale
            
            DispatchQueue.main.async {
                cell.indexpath = indexPath.row
                cell.uiSet()
            }
           
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if totalpages > offSet{
            offSet += 1
            getServiceApi(loader: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if apiCalling == true{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailVC
            
            if arrService.count > 0{
                vc.serviceId = arrService[indexPath.row]._id ?? ""
                apiCalling = false
            }
                self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  120
        
    }
    
}
extension MenuVC:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geocoder = GMSGeocoder()
            let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            geocoder.reverseGeocodeCoordinate(currentLocation.coordinate) { response, error in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                    return
                }
                
                guard let address = response?.firstResult(), let lines = address.lines else {
                    print("No address found")
                    return
                }
                
                let fullAddress = lines.joined(separator: ", ")
//                print("Current Address: \(fullAddress)")
                DispatchQueue.main.async {
                    self.btnLoaccation.setTitle(fullAddress, for: .normal)
                }
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
