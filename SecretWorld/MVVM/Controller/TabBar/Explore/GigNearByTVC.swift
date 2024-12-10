//
//  GigNearByTVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 03/01/24.
//

import UIKit

class GigNearByTVC: UITableViewCell {
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgVwGig: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblRatingReview: UILabel!
    
    @IBOutlet var viewShadow: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
