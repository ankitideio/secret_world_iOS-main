//
//  PopupTypeVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 12/12/24.
//

import UIKit

class PopupTypeVC: UIViewController {

    @IBOutlet var lblHidden: UILabel!
    @IBOutlet var lblOngo: UILabel!
    @IBOutlet var lblStill: UILabel!
    @IBOutlet var imgVwHidden: UIImageView!
    @IBOutlet var imgVwOngo: UIImageView!
    @IBOutlet var imgVwStill: UIImageView!
    @IBOutlet weak var btnHidden: UIButton!
    @IBOutlet weak var btnOngo: UIButton!
    @IBOutlet weak var btnStill: UIButton!
    @IBOutlet var viewBack: UIView!
    
    var callBack:((_ type:Int?)->())?
    var popUptype = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
    }
    func uiSet(){
        viewBack.layer.cornerRadius = 35
        viewBack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if popUptype == 0{
           imgVwHidden.image = UIImage(named: "selectedGender")
           imgVwOngo.image = UIImage(named: "unSelect")
           imgVwStill.image = UIImage(named: "unSelect")
       }else if popUptype == 1{
            imgVwHidden.image = UIImage(named: "unSelect")
            imgVwOngo.image = UIImage(named: "selectedGender")
            imgVwStill.image = UIImage(named: "unSelect")
        }else if popUptype == 2{
            imgVwHidden.image = UIImage(named: "unSelect")
            imgVwOngo.image = UIImage(named: "unSelect")
            imgVwStill.image = UIImage(named: "selectedGender")
        }else{
            imgVwHidden.image = UIImage(named: "unSelect")
            imgVwOngo.image = UIImage(named: "unSelect")
            imgVwStill.image = UIImage(named: "unSelect")
        }
        setupOverlayView()
    }
    func setupOverlayView() {
        viewBack = UIView(frame: self.view.bounds)
        viewBack.backgroundColor = UIColor.black.withAlphaComponent(0.5)
              let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        viewBack.addGestureRecognizer(tapGesture)
              self.view.insertSubview(viewBack, at: 0)
          }
        @objc func overlayTapped() {
              self.dismiss(animated: true)
          }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func actionHidden(_ sender: UIButton) {
        self.dismiss(animated: true)
        callBack?(0)
    }
    @IBAction func actionOngo(_ sender: UIButton) {
        self.dismiss(animated: true)
        callBack?(1)
    }
    @IBAction func actionStills(_ sender: UIButton) {
        self.dismiss(animated: true)
        callBack?(2)
    }
}
