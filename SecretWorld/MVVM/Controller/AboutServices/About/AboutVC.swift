//
//  AboutVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 23/12/23.
//

import UIKit
import FXExpandableLabel

class AboutVC: UIViewController, UIGestureRecognizerDelegate {
    //MARK: - OUTLETS
    @IBOutlet var viewServiceProvider: UIView!
    @IBOutlet var lblProviderAbout: UILabel!
    @IBOutlet var lblProviderName: UILabel!
    @IBOutlet var imgVwProvider: UIImageView!
    @IBOutlet var tblVwBusinessHour: UITableView!
    @IBOutlet weak var lblAbout: UILabel!
    
    //MARK: - VARIABLES
    var arrdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday","sunday"]
    var obj = [BusinessTimingModel]()
    var receiverId = ""
    var phoneNumber: Int?
    var textAbout = ""
    var isSeeMore = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib2 = UINib(nibName: "BusinessHourTVC", bundle: nil)
        tblVwBusinessHour.register(nib2, forCellReuseIdentifier: "BusinessHourTVC")
        
        uiSet()
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("GetStoreServiceData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationUser(notification:)), name: Notification.Name("GetUserAbout"), object: nil)
       
    }
    
    
    func uiSet(){
        
        addTapGestureToLabel()
        obj = arrdays.map { day in
            BusinessTimingModel(day: day, starttime: "", endtime: "", status: "0")
        }
        
        if Store.role == "b_user"{
            viewServiceProvider.isHidden = true
        }else{
            viewServiceProvider.isHidden = false
            }
        
        
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
       
        lblAbout.numberOfLines = 5
        lblProviderName.text = Store.ServiceDetailData?.user?.name ?? ""
        
        imgVwProvider.imageLoad(imageUrl: Store.ServiceDetailData?.user?.profile_photo ?? "")
        self.receiverId = Store.ServiceDetailData?.user?.id ?? ""
//        lblAbout.text = Store.UserServiceDetailData?.getBusinessDetails?.about ?? ""
        for i in Store.ServiceDetailData?.service ?? []{
            self.textAbout = i.description ?? ""
            
            self.lblAbout.appendReadmore(after: self.textAbout, trailingContent: .readmore)
        }
        lblAbout.sizeToFit()
        print("Dataaaaaa-----",lblAbout.frame.size.height)
        
        Store.aboutHeight = lblAbout.frame.size.height
        openingHoursSetupBusiness()
        
    }
    func openingHoursSetupBusiness() {
        guard let openingHours = Store.ServiceDetailData?.user?.openingHours else { return }

        for openingHour in openingHours {
            let lowercaseDay = (openingHour.day ?? "").lowercased() 
            if let index = arrdays.firstIndex(of: lowercaseDay) {
                obj[index] = BusinessTimingModel(day: lowercaseDay, starttime: openingHour.starttime ?? "", endtime: openingHour.endtime ?? "", status: "1")
            }
        }

        tblVwBusinessHour.reloadData()
    }
    
    @objc func methodOfReceivedNotificationUser(notification: Notification) {
        guard let businessDetail = Store.getBusinessDetail else { return }
        
        lblAbout.numberOfLines = 5
        self.receiverId = businessDetail.userID ?? ""
        phoneNumber = businessDetail.mobile ?? 0
        lblProviderName.text = businessDetail.name ?? ""
        imgVwProvider.imageLoad(imageUrl: businessDetail.profilePhoto ?? "")
        self.textAbout = businessDetail.about ?? ""
        if isSeeMore == true{
          
            self.lblAbout.appendReadLess(after: self.textAbout, trailingContent: .readless)
        }else{
            self.lblAbout.appendReadmore(after: self.textAbout, trailingContent: .readmore)
        }
       
        self.lblAbout.sizeToFit()

        guard let openingHours = Store.getBusinessDetail?.openingHours else { return }
        
        for openingHour in openingHours {
            if let index = arrdays.firstIndex(of: openingHour.day ?? "") {
                obj[index] = BusinessTimingModel(day: openingHour.day ?? "", starttime: openingHour.starttime ?? "", endtime: openingHour.endtime ?? "", status: "1")
            }
        }
        tblVwBusinessHour.reloadData()

        
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
        NotificationCenter.default.post(name: Notification.Name("UpdateAboutText"), object: nil)
    }
    
    @IBAction func actionServiceProviderProfile(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
        vc.businessId = Store.getBusinessDetail?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionMessage(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
        vc.receiverId = Store.recevrID ?? ""
        vc.isAbout = true
        vc.callBack = {[weak self] in
            guard let self = self else { return }
            NotificationCenter.default.post(name: Notification.Name("UpdateAboutText"), object: nil)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionCall(_ sender: UIButton) {
          isCall = true
          guard let number = phoneNumber else { return }
          let numberUrl = URL(string: "tel://\(number)")!
          if UIApplication.shared.canOpenURL(numberUrl) {
              UIApplication.shared.open(numberUrl)
          }
    }
}
//MARK: -UITableViewDelegate
extension AboutVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            return  arrdays.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessHourTVC", for: indexPath) as! BusinessHourTVC
        
            let day = obj[indexPath.row].day
            cell.lblday.text = day.capitalized
            
            if obj[indexPath.row].status == "1"{
                let startTime24 = obj[indexPath.row].starttime
                let endTime24 = obj[indexPath.row].endtime
                
                let startTime12 = convertTo12HourFormat(startTime24)
                let endTime12 = convertTo12HourFormat(endTime24)
                
                cell.lblTime.text = "\(startTime12) - \(endTime12)"
                cell.lblTime.textColor = UIColor( red: 91 / 255.0,green: 91 / 255.0,blue: 91 / 255.0,alpha: 1.0)
            } else {
                cell.lblTime.text = "Closed"
                cell.lblTime.textColor = UIColor( red: CGFloat(0xFF) / 255.0,green: CGFloat(0x3B) / 255.0,blue: CGFloat(0x3B) / 255.0,alpha: 1.0)
        }
        return cell
    }

   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
          return  35
        
    }
    
}
extension AboutVC {
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
