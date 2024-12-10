//
//  ChatOptionVC.swift
//  SecretWorld
//
//  Created by meet sharma on 18/04/24.
//

import UIKit

class ChatOptionVC: UIViewController {

    @IBOutlet weak var tblVwOption: UITableView!
    
    var arrOption = [String]()
    var blockStatusMe = false
    var blockStatusOther = false
    var receiverId = ""
    var callBack:((_ isReport:Bool)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      uiSet()
     
    }
    func uiSet(){
        arrOption.removeAll()
        if blockStatusMe == true{
            arrOption.append("Unblock")
            arrOption.append("Report")
      
        }else{
            if blockStatusOther == true{
                arrOption.append("Block")
                arrOption.append("Report")
            }else{
                arrOption.append("Block")
                arrOption.append("Report")
            }
        }
        tblVwOption.reloadData()
    }



}

extension ChatOptionVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOption.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatOptionTVC", for: indexPath) as! ChatOptionTVC
        cell.lblOption.text = arrOption[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let param = ["senderId":Store.userId ?? "","receiverId":self.receiverId]
            SocketIOManager.sharedInstance.blockUnblock(dict: param)
            dismiss(animated: true)
            callBack?(false)
        }else{
            dismiss(animated: true)
            callBack?(true)
        }
  
    }
    
}
