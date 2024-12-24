//
//  ParticipantsVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 03/01/24.
//

import UIKit


class ParticipantsVC: UIViewController {
    //MARK: - OUTLEST
    @IBOutlet var btnRejected: UIButton!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var heightStackVwBtns: NSLayoutConstraint!
    @IBOutlet var btnAccepted: UIButton!
    @IBOutlet var btnNew: UIButton!
    @IBOutlet var tblVwList: UITableView!
    
    //MARK: - VARIABLES
    var isComing = 0
    var viewModel = AddGigVM()
    var arrUserParticipants = [GetParticipantsData]()
    var arrGroupParticipant = [Participant]()
    var arrNewParticipants = [UserDetaills]()
    var arrCompleteParticipants = [GetRequestData]()
    var gigId = ""
    var participantsStatus:Int?
    var idForHire = ""
    var gigType = 0
    var isGroup = false
    var isCustomerAsProvider = false
    var businessGigDetail:BusinessGigDetailData?
    var callBack: (()->())?
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                   swipeRight.direction = .right
                   view.addGestureRecognizer(swipeRight)

    }
    @objc func handleSwipe() {
                navigationController?.popViewController(animated: true)
                callBack?()
            }

    override func viewWillAppear(_ animated: Bool) {
        uiSet()
    }
    func uiSet(){
        let nibNearBy = UINib(nibName: "ParticipantTVC", bundle: nil)
        tblVwList.register(nibNearBy, forCellReuseIdentifier: "ParticipantTVC")
        tblVwList.estimatedRowHeight = 60
        tblVwList.rowHeight = UITableView.automaticDimension
        if isGroup == true{
            heightStackVwBtns.constant = 0
            getGroupParticipant()
            
        }else{
            if isComing == 1{
                getUserParticipants()
                heightStackVwBtns.constant = 0
            }else if isComing == 0{
                heightStackVwBtns.constant = 45
                btnRejected.isHidden = true
                getBusinessParticipants(gigtype: gigType)
            }else{
                heightStackVwBtns.constant = 0
                getCompleteParticipants(loader: true)
            }
        }
        
    }
    func getGroupParticipant(){
        viewModel.GetUserGroupParticipantsListApi(gigId: gigId) { data in
            if data?.participants?.count ?? 0 > 0{
                self.arrGroupParticipant = data?.participants ?? []
                if self.arrGroupParticipant.count > 0{
                    self.lblNoData.text = ""
                }else{
                    self.lblNoData.text = "Data Not Found!"
                }
                self.tblVwList.reloadData()
            }
        }
    }
    func getUserParticipants(){
        viewModel.GetUserParticipantsListApi(gigId: gigId) { data in
            self.arrUserParticipants = data ?? []
            
            if self.arrUserParticipants.count > 0{
                self.lblNoData.text = ""
            }else{
                self.lblNoData.text = "Data Not Found!"
            }
            self.tblVwList.reloadData()
        }
    }
    func getCompleteParticipants(loader:Bool){
        viewModel.GetCompleteGigParticipantsListApi(loader: true, gigId: gigId){ data in
            self.arrCompleteParticipants = data ?? []
            
            if self.arrCompleteParticipants.count > 0{
                self.lblNoData.text = ""
            }else{
                self.lblNoData.text = "Data Not Found!"
            }
            self.tblVwList.reloadData()
        }
    }
    func getBusinessParticipants(gigtype:Int) {
        viewModel.GetBusinessParticipantsListApi(gigId: gigId, type: gigtype) { data in
            self.arrNewParticipants.removeAll()
            for i in data?.user ?? [] {
                self.participantsStatus = i.status
                
                self.arrNewParticipants.append(i)
                
            }
            if self.arrNewParticipants.count > 0{
                self.lblNoData.text = ""
            }else{
                self.lblNoData.text = "Data Not Found!"
            }
            
            self.tblVwList.reloadData()
        }
    }
    //MARK: - Button actions
    @IBAction func actionRejected(_ sender: UIButton) {
       
    }
    @IBAction func actionAccepted(_ sender: UIButton) {
        selectedBtnAccepted()
        gigType = 1
        getBusinessParticipants(gigtype: gigType)
        
    }
    func selectedBtnAccepted(){
        btnAccepted.backgroundColor = UIColor(red: 231/255, green: 243/255, blue: 230/255, alpha: 1.0)
        btnAccepted.setTitleColor(UIColor.app, for: .normal)
        btnNew.backgroundColor = .white
        btnNew.setTitleColor(UIColor.darkGray, for: .normal)
        btnRejected.backgroundColor = .white
        btnRejected.setTitleColor(UIColor.darkGray, for: .normal)
        
    }
    @IBAction func actionNew(_ sender: UIButton) {
        selectedBtnNew()
        gigType = 0
        getBusinessParticipants(gigtype: gigType)
    }
    func selectedBtnNew(){
        btnNew.backgroundColor = UIColor(red: 231/255, green: 243/255, blue: 230/255, alpha: 1.0)
        btnNew.setTitleColor(UIColor.app, for: .normal)
        btnAccepted.backgroundColor = .white
        btnAccepted.setTitleColor(UIColor.darkGray, for: .normal)
        btnRejected.backgroundColor = .white
        btnRejected.setTitleColor(UIColor.darkGray, for: .normal)
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        callBack?()
    }
    
    
    
}
//MARK: -UITableViewDelegate
extension ParticipantsVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isGroup == true{
            return arrGroupParticipant.count
        }else{
            if isComing == 1{
                return arrUserParticipants.count
            }else if isComing == 0{
                
                return arrNewParticipants.count
                
            }else{
                return arrCompleteParticipants.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantTVC", for: indexPath) as! ParticipantTVC
        if isGroup == true {
            cell.lblName.text = arrGroupParticipant[indexPath.row].name ?? ""
            cell.lblGender.text = arrGroupParticipant[indexPath.row].gender ?? ""
            cell.widthBtnMessage.constant = 0
            cell.heightStackvw.constant = 0
            cell.imgVwUser.imageLoad(imageUrl: arrGroupParticipant[indexPath.row].profilePhoto ?? "")
            cell.viewBack.layer.cornerRadius = 15
        }else{
            if isComing == 1{
                //user
                cell.widthBtnMessage.constant = 0
                cell.heightStackvw.constant = 0
                cell.lblName.text = arrUserParticipants[indexPath.row].applyuserID?.name ?? ""
                cell.lblGender.text = arrUserParticipants[indexPath.row].applyuserID?.gender ?? ""
                cell.imgVwUser.imageLoad(imageUrl: arrUserParticipants[indexPath.row].applyuserID?.profilePhoto ?? "")
                cell.viewBack.layer.cornerRadius = 15
            }else if isComing == 0{
                //business
                if arrNewParticipants[indexPath.row].status ==  0{
                    cell.widthBtnMessage.constant = 0
                    cell.heightStackvw.constant = 36
                    cell.btnChat.setTitle("Chat", for: .normal)
                    cell.btnHere.setTitle("Hire", for: .normal)
                }else{
                    cell.widthBtnMessage.constant = 100
                    cell.heightStackvw.constant = 0
                }
                cell.viewBack.layer.cornerRadius = 6
                cell.btnHere.backgroundColor =  UIColor.app
                cell.btnHere.setTitleColor(UIColor.white, for: .normal)
                cell.lblName.text = arrNewParticipants[indexPath.row].name ?? ""
                cell.lblGender.text = arrNewParticipants[indexPath.row].message ?? ""
                cell.imgVwUser.imageLoad(imageUrl: arrNewParticipants[indexPath.row].image   ?? "")
                cell.btnChat.tag = indexPath.row
                cell.btnChat.addTarget(self, action: #selector(actionChat), for: .touchUpInside)
                cell.btnHere.tag = indexPath.row
                cell.btnHere.addTarget(self, action: #selector(actionHire), for: .touchUpInside)
                cell.btnMessage.tag = indexPath.row
                cell.btnMessage.addTarget(self, action: #selector(actionMessage), for: .touchUpInside)
                
            }else{
                
                if  arrCompleteParticipants[indexPath.row].review == nil{
                    cell.btnMessage.setTitle("Add review", for: .normal)
                    cell.widthBtnMessage.constant = 100
                }else{
                    cell.btnMessage.setTitle("Update review", for: .normal)
                    cell.widthBtnMessage.constant = 115
                }
               
                cell.heightStackvw.constant = 0
                cell.lblName.text = arrCompleteParticipants[indexPath.row].name ?? ""
                cell.lblGender.text = arrCompleteParticipants[indexPath.row].gender ?? ""
                cell.imgVwUser.imageLoad(imageUrl: arrCompleteParticipants[indexPath.row].profilePhoto ?? "")
                cell.viewBack.layer.cornerRadius = 15
                cell.btnMessage.tag = indexPath.row
                cell.btnMessage.addTarget(self, action: #selector(actionMessage), for: .touchUpInside)
            }
        }
        return cell
    }
    @objc func actionMessage(sender:UIButton){
        if isComing == 1 || isComing == 0{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
            vc.receiverId = arrNewParticipants[sender.tag].applyuserId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)

        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
            vc.modalPresentationStyle = .overFullScreen
            if arrCompleteParticipants[sender.tag].review == nil{
                vc.isUpdateReview = false
                
            }else{
                vc.isUpdateReview = true
                vc.reviewsToParticipants = arrCompleteParticipants[sender.tag].review
                
            }
            vc.isComing = 1
            vc.userId = arrCompleteParticipants[sender.tag].applyuserID ?? ""
            vc.gigId = arrCompleteParticipants[sender.tag].gigID ?? ""
            vc.businessGigDetail = businessGigDetail
            vc.callBack = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AfterFeedbackPopUpVC") as! AfterFeedbackPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.callBack = {
                    self.navigationController?.popViewController(animated: true)
                    
                }
                self.navigationController?.present(vc, animated: false)
                
            }
            self.navigationController?.present(vc, animated: true)

        }
    }
    @objc func actionChat(sender:UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatInboxVC") as! ChatInboxVC
        if Store.role == "b_user"{
            vc.receiverId = arrNewParticipants[sender.tag].applyuserId ?? ""
        }else{
            vc.receiverId = arrNewParticipants[sender.tag].applyuserId ?? ""
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func actionHire(sender: UIButton) {
        guard sender.tag >= 0 && sender.tag < arrNewParticipants.count else {
            return
        }
        
        sender.isEnabled = false
        print("UserId-------",Store.userId ?? "")
        viewModel.HireForGigApi(gigid: gigId, userid: arrNewParticipants[sender.tag].applyuserId ?? "") {
            [weak self] in
            guard let self = self else { return }
            guard sender.tag >= 0 && sender.tag < self.arrNewParticipants.count else {
                return
            }
            let param:parameters = ["userId":arrNewParticipants[sender.tag].applyuserId ?? "","gigId":gigId,"senderId":Store.userId ?? "","gigName":arrNewParticipants[sender.tag].title ?? ""]
            print("Param--------",param)
//            let param:parameters = ["userId":arrNewParticipants[sender.tag].applyuserId ?? "","gigId":gigId]
            SocketIOManager.sharedInstance.joinGroup(dict: param)
            self.arrNewParticipants.remove(at: sender.tag)
            self.getBusinessParticipants(gigtype: self.gigType)
            sender.isEnabled = true
        }
    }

    
    
    
}
