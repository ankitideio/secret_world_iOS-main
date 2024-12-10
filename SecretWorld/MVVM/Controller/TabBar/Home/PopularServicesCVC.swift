//
//  PopularServicesCVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 22/12/23.
//

import UIKit
import AlignedCollectionViewFlowLayout

class PopularServicesCVC: UICollectionViewCell {
    @IBOutlet var lblUserRatingCount: UILabel!
    @IBOutlet var imgVwBlueTick: UIImageView!
    @IBOutlet var collVwSubCategory: UICollectionView!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblServiceName: UILabel!
    @IBOutlet var imgVwUser: UIImageView!
    @IBOutlet var imgVwService: UIImageView!
    @IBOutlet var vwShadow: UIView!
    
    var arrCategories = [String]()
    var indexpath = 0
    var isComing = false
    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "BusinessCategoryCVC", bundle: nil)
        collVwSubCategory.register(nib, forCellWithReuseIdentifier: "BusinessCategoryCVC")
        if let flowLayout = collVwSubCategory.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = CGSize(width: 0, height: 36)
                flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
            
            }
        collVwSubCategory.delegate = self
        collVwSubCategory.dataSource = self
        imgVwService.layer.cornerRadius = 10
        imgVwService.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    }
    func uiSet(){
        if isComing == true{
            if arrCategories.count > 0{
                collVwSubCategory.reloadData()
            }

        }else{
            let data = Store.ExploreData?.business ?? []
            if data.count > 0{
                arrCategories = data[indexpath].categoryName ?? []
                
                collVwSubCategory.reloadData()
            }
        }
        
    }

}
//MARK: - UICollectionViewDelegate
extension PopularServicesCVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrCategories.count > 0{
            return arrCategories.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCategoryCVC", for: indexPath) as! BusinessCategoryCVC
        
            cell.vwBg.layer.cornerRadius = 2
            cell.lblName.font = UIFont.systemFont(ofSize: 9)
            cell.vwBg.backgroundColor = UIColor(red: 0xEF/255.0, green: 0xEF/255.0, blue: 0xEF/255.0, alpha: 1.0)
            cell.widthBtnCross.constant = 0
        cell.lblName.text = arrCategories[indexPath.row]
        
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwSubCategory.frame.size.width / 3, height: 16)
    }
    

}
