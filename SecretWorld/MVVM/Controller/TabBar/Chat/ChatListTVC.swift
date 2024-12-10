//
//  ChatListTVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 27/12/23.
//

import UIKit

class ChatListTVC: UITableViewCell {

    @IBOutlet var lblMsgCount: UILabel!
    @IBOutlet var viewMsgCount: UIView!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblMsg: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgVwUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
