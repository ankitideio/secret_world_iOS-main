//
//  HomeFilterTVC.swift
//  SecretWorld
//
//  Created by Ideio Soft on 16/12/24.
//

import UIKit
import RangeSeekSlider

class HomeFilterTVC: UITableViewCell {

    @IBOutlet weak var sliderDistance: UISlider!
    @IBOutlet weak var vwDistance: UIView!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var bottomLine: NSLayoutConstraint!
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var SliderVw: UIView!
    @IBOutlet weak var DropDownVw: UIView!
    @IBOutlet weak var imgVwDropdown: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
