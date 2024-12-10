//
//  SenderTVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 05/01/24.
//

import UIKit

class SenderTVC: UITableViewCell {
    @IBOutlet weak var heightProfileImg: NSLayoutConstraint!
    @IBOutlet weak var topProfileImg: NSLayoutConstraint!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var imgVwProfile: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imgVwProfile.image = nil  // Clear the image to avoid showing the wrong one momentarily
    }

}
