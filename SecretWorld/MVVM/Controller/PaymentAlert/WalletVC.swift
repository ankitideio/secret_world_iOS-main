//
//  WalletVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 30/08/24.
//
import UIKit
class WalletVC: UIViewController {
//MARK: - outlets
    @IBOutlet var viewBack: UIView!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet var lblBalance: UILabel!
    //MARK: - variables
    var viewModel = PaymentVM()
    var isComing = false
    var callBack:(()->())?
    var isBank = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                   swipeRight.direction = .right
                   view.addGestureRecognizer(swipeRight)
        viewBack.applyShadow()
    }
    @objc func handleSwipe() {
        if isComing == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            if isBank == true{
                SceneDelegate().tabBarProfileRoot()
            }else{
                SceneDelegate().addGigRoot()
                callBack?()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        getWallet()
    }
    func getWallet() {
        viewModel.getWalletAmount(loader: true) { data in
            let amount = data?.checkWallet?.amount ?? 0
            Store.WalletAmount = amount
            let formattedAmount = String(format: "%.2f", amount)
            if amount > 0 {
                self.lblBalance.text = "$\(formattedAmount)"
                self.btnWallet.isHidden = false
            } else {
                self.lblBalance.text = "$0"
                self.btnWallet.isHidden = true
            }
        }
    }
    //MARK: - @IBAction
    @IBAction func actionBack(_ sender: UIButton) {
        if isComing == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            if isBank == true{
                SceneDelegate().tabBarProfileRoot()
            }else{
                SceneDelegate().addGigRoot()
                callBack?()
            }
        }
    }
    @IBAction func actionAddPayment(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawAmountVC") as! WithdrawAmountVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = false
        vc.callBack = { [weak self] amount,message,isBalance in
            
                guard let self = self else { return }
            self.viewModel.AddWalletApi(amount: amount, type: sender.tag) { url in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WalletWebViewVC") as! WalletWebViewVC
                vc.modalPresentationStyle = .overFullScreen
                vc.paymentLink = url ?? ""
                vc.callback = { [weak self] (payment) in
                    guard let self = self else { return }
                    
                    if payment == true{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 21
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            if self.isComing == true{
                                self.getWallet()
                            }else{
                                SceneDelegate().addGigRoot()
                            }
                        }
                        self.present(vc, animated: true)
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                        vc.modalPresentationStyle = .overFullScreen
                        vc.isSelect = 20
                        vc.callBack = {[weak self] in
                            guard let self = self else { return }
                            if self.isComing == true{
                                self.getWallet()
                            }else{
                                SceneDelegate().addGigRoot()
                            }
                        }
                        self.present(vc, animated: true)
                    }
                }
                self.present(vc, animated: false)
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    @IBAction func actionWithdraw(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WithdrawAmountVC") as! WithdrawAmountVC
        vc.modalPresentationStyle = .overFullScreen
        vc.isComing = true
        vc.callBack = { [weak self] amount,message,isBalance in
            guard let self = self else { return }
            if isBalance == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 10
                vc.message = message
                vc.callBack = {[weak self] in
                    guard let self = self else { return }
                    self.getWallet()
                }
                self.present(vc, animated: true)
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonPopUpVC") as! CommonPopUpVC
                vc.modalPresentationStyle = .overFullScreen
                vc.isSelect = 10
                vc.message = "Your wallet balance is lower than the withdrawal amount"
                self.present(vc, animated: true)
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
}
extension UIView {
    func applyShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 14 / 2.0
        self.layer.masksToBounds = false
    }
}
