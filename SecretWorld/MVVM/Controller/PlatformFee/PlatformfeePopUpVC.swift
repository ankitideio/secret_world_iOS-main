//
//  PlatformfeePopUpVC.swift
//  SecretWorld
//
//  Created by meet sharma on 31/05/24.
//

import UIKit

class PlatformfeePopUpVC: UIViewController {

    @IBOutlet var btnPay: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    var callBack:((_ isPAy:Bool)->())?
    
    var titleText = ""
    var isAmountLess = false
    override func viewDidLoad() {
        super.viewDidLoad()

       uiSet()
    }
    func uiSet(){
        lblTitle.attributedText = createBoldText(for: titleText)
        if isAmountLess{
            btnPay.setTitle("Refund", for: .normal)
        }else{
            btnPay.setTitle("Pay", for: .normal)
        }
    }
    func createBoldText(for text: String) -> NSAttributedString {
           let regularFont = UIFont(name: "Nunito-SemiBold", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
           let boldFont = UIFont(name: "Nunito-Bold", size: 16.0) ?? UIFont.boldSystemFont(ofSize: 16.0)
           let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: regularFont])
        let pattern = "[0-9]+(?:\\.[0-9]+)?|\\$|%"
           if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
               let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
               
               for match in matches {
                   attributedString.addAttribute(.font, value: boldFont, range: match.range)
               }
           }
           return attributedString
       }
    @IBAction func actionPay(_ sender: UIButton) {
     
        dismiss(animated: true)
        callBack?(true)
    }
    
    @IBAction func actionDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        
    }
    
  

}
