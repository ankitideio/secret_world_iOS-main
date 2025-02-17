//
//  CreatAcSuccessVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//

import UIKit

class CreatAcSuccessVC: UIViewController {

    @IBOutlet var lblMsg: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMsg.font = UIFont(name: "Nunito-Regular", size: 18)
        print("successloginStore.autoLogin:-\(Store.autoLogin)")
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        SceneDelegate().userRoot()
//        let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
//        vc.selectedButtonTag = 1
//        navigationController?.pushViewController(vc, animated: true)
        
    }
   

}
