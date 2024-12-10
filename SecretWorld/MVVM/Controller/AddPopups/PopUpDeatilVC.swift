//
//  PopUpDeatilVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 25/01/24.
//
import UIKit
class PopUpDeatilVC: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet var lblProductCount: UILabel!
    @IBOutlet var btnRequests: UIButton!
    @IBOutlet var lblRequests: UILabel!
    @IBOutlet var heightRequestView: NSLayoutConstraint!
    @IBOutlet var btnThreeDot: UIButton!
    @IBOutlet var btnProvider: UIButton!
    @IBOutlet var lblServiceProvider: UILabel!
    @IBOutlet var heightVwProvider: NSLayoutConstraint!
    @IBOutlet var lblEndTime: UILabel!
    @IBOutlet var lblStartTime: UILabel!
    @IBOutlet var widthBtnMessage: NSLayoutConstraint!
    @IBOutlet var btnMessage: UIButton!
    @IBOutlet var lblPlace: UILabel!
    @IBOutlet var lblPopupName: UILabel!
    @IBOutlet var heightTblview: NSLayoutConstraint!
    @IBOutlet var tblVwList: UITableView!
    @IBOutlet var lblEndDate: UILabel!
    @IBOutlet var lblStartDate: UILabel!
    @IBOutlet var lblAbout: UILabel!
    @IBOutlet var lblProviderDescription: UILabel!
    @IBOutlet var lblProviderName: UILabel!
    @IBOutlet var imgVwServiceProvider: UIImageView!
    @IBOutlet var imgVwBack: UIImageView!
    
    var popupIndex = 0
    var popupId = ""
    var viewMOdel = PopUpVM()
    var arrProductList = [AddProducts]()
    var status:Int?
    var arrSearchResultes = [SearchList]()
    var providerId = ""
    var usertype:String?
    var callBack:((_ indexx:Int)->())?
    var isComing = false
    var popupDetails:PopupDetailData?
    var textAbout = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        uiSet()
    }
    @objc func handleSwipe() {
              navigationController?.popViewController(animated: true)
        callBack?(popupIndex)
          }
    override func viewWillAppear(_ animated: Bool) {
        addTapGestureToLabel()
        getPopupsApi()
    }
    func uiSet(){
        let nibNearBy = UINib(nibName: "ProductListTVC", bundle: nil)
        tblVwList.register(nibNearBy, forCellReuseIdentifier: "ProductListTVC")
        imgVwBack.layer.cornerRadius = 15
        imgVwBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        if isComing{
            heightRequestView.constant = 30
            lblRequests.text = "Requests"
            btnRequests.isHidden = false
        }else{
            heightRequestView.constant = 0
            lblRequests.text = ""
            btnRequests.isHidden = true
        }
    }
    func getPopupsApi(){
        viewMOdel.getPopupDetailApi(loader: true, popupId: popupId) { data in
            if self.isComing{
                if data?.timeStatus ?? 0 == 0{
                    self.btnThreeDot.isHidden = false
                }else{
                    self.btnThreeDot.isHidden = true
                }
            }else{
                self.btnThreeDot.isHidden = true
            }
            self.popupDetails = data
            self.usertype = data?.usertype ?? ""
            self.providerId = data?.user?.id ?? ""
            self.imgVwServiceProvider.imageLoad(imageUrl: data?.user?.profilePhoto ?? "")
            self.imgVwBack.imageLoad(imageUrl: data?.businessLogo ?? "")
            self.lblPopupName.text = data?.name ?? ""
            self.lblProductCount.text = "\(data?.addProducts?.count ?? 0)"
            if data?.Requests == 0{
                self.btnRequests.setTitle("No Request", for: .normal)
            }else if data?.Requests == 1{
                self.btnRequests.setTitle("\(data?.Requests ?? 0) New Request", for: .normal)
            }else{
                self.btnRequests.setTitle("\(data?.Requests ?? 0) New Requests", for: .normal)
            }
            if Store.role == "user"{
                if Store.userId == data?.user?.id ?? ""{
                    self.btnMessage.isHidden = true
                    self.heightVwProvider.constant = 0
                    self.lblProviderName.text = ""
                    self.lblServiceProvider.text = ""
                    self.lblProviderDescription.text = ""
                    self.btnProvider.isHidden = false
                }else{
                    self.lblProviderName.text = data?.user?.name ?? ""
                    self.lblServiceProvider.text = "Service Provider"
                    self.lblProviderDescription.text = "Service Provider"
                    self.btnProvider.isHidden = false
                    self.btnMessage.isHidden = false
                    self.heightVwProvider.constant = 44
                }
            }else{
                self.btnMessage.isHidden = true
                self.lblProviderDescription.text = ""
                self.heightVwProvider.constant = 0
                self.lblServiceProvider.text = ""
                self.btnProvider.isHidden = true
                self.lblProviderName.text = ""
            }
            let convertedStartTime = self.convertDToAMPM(data?.startDate ?? "")
            self.lblStartTime.text = convertedStartTime
            let convertedEndTime = self.convertDToAMPM(data?.endDate ?? "")
            self.lblEndTime.text = convertedEndTime
            let convertedStartDate = self.convertDateString(data?.startDate ?? "")
            self.lblStartDate.text = convertedStartDate
            let convertedEndDate = self.convertDateString(data?.endDate ?? "")
            self.lblEndDate.text = convertedEndDate
//            self.lblAbout.text = data?.description ?? ""
            self.textAbout = data?.description ?? ""
            self.lblAbout.numberOfLines = 2
            self.lblAbout.appendReadmore(after: self.textAbout, trailingContent: .readmore)
            self.lblAbout.sizeToFit()
            self.lblPlace.text = data?.place ?? ""
            self.arrProductList = data?.addProducts ?? []
            self.status = data?.status?.status
            if data?.status?.status == 0{
                self.btnMessage.setImage(UIImage(named: ""), for: .normal)
                self.btnMessage.setTitle("Requested", for: .normal)
                self.btnMessage.isUserInteractionEnabled = false
                self.btnMessage.setTitleColor(UIColor.app, for: .normal)
                self.widthBtnMessage.constant = 100
            }else if data?.status?.status == 1{
                self.btnMessage.setTitle("", for: .normal)
                self.btnMessage.setImage(UIImage(named: "message"), for: .normal)
                self.btnMessage.isUserInteractionEnabled = true
                self.widthBtnMessage.constant = 40
            }else if data?.status?.status == 2{
                self.btnMessage.setImage(UIImage(named: ""), for: .normal)
                self.btnMessage.setTitle("Rejected", for: .normal)
                self.btnMessage.isUserInteractionEnabled = false
                self.btnMessage.setTitleColor(UIColor.red, for: .normal)
                self.widthBtnMessage.constant = 100
            }else{
                self.btnMessage.setTitle("", for: .normal)
                self.btnMessage.setImage(UIImage(named: "message"), for: .normal)
                self.btnMessage.isUserInteractionEnabled = true
                self.widthBtnMessage.constant = 40
            }
            self.heightTblview.constant = CGFloat(self.arrProductList.count*50)
            self.tblVwList.reloadData()
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
    //MARK: - BUTTON ACTIONS
    @IBAction func actionRequests(_ sender: UIButton) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserParticipantsListVC") as! UserParticipantsListVC
            vc.isComing = 1
            vc.popupId = popupDetails?.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionThreedot(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesMoreOptionsVC") as! ServicesMoreOptionsVC
        vc.modalPresentationStyle = .overFullScreen
        vc.callBack = { [weak self] isSelect in
            guard let self = self else { return }
            if isSelect == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPopUpVC") as! AddPopUpVC
                vc.isComing = true
                vc.popupDetails = self.popupDetails
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelGigVC") as! CancelGigVC
                vc.isSelect = 2
                vc.popupId = self.popupDetails?.id ?? ""
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack  = { message in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 10
                        vc.message = message
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            self.navigationController?.popViewController(animated: true)
                            self.callBack?(self.popupIndex)
                        }
                        self.navigationController?.present(vc, animated: false)
                }
                self.navigationController?.present(vc, animated: false)
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionServiceProvider(_ sender: UIButton) {
        if usertype == "user"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewVC") as! ProfileViewVC
            vc.id = providerId
            vc.isComingChat = true
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileVC") as! BusinessProfileVC
            vc.businessId = providerId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func actionMessage(_ sender: UIButton) {
        if status == 1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
            vc.receiverId = providerId
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessagePopupVC") as! MessagePopupVC
            vc.modalPresentationStyle = .overFullScreen
            vc.popupId = popupId
            vc.callBack = { [weak self] message in
                guard let self = self else { return }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 10
                vc.message = message
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    self.getPopupsApi()
                }
                self.navigationController?.present(vc, animated: false)
            }
            self.navigationController?.present(vc, animated: true)
        }
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        callBack?(popupIndex)
    }
    func convertDToAMPM(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        if dateString.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func convertDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        if dateString.contains(".") {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
//MARK: - UITableViewDelegate
extension PopUpDeatilVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrProductList.count > 0{
            return arrProductList.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListTVC", for: indexPath) as! ProductListTVC
        if arrProductList.count > 0{
            cell.widthEditBtn.constant = 0
            cell.lblProductName.text = "\(indexPath.row + 1). \(arrProductList[indexPath.row].productName ?? "")"
            cell.lblPrice.text = "$\(arrProductList[indexPath.row].price ?? 0)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  50
    }
}
