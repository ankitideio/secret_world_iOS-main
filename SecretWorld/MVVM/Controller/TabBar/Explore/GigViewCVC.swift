//
//  GigViewCVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 29/11/24.
//

import UIKit

class GigViewCVC: UICollectionViewCell {
    //MARK: - IBOutlet
    @IBOutlet var viewShare: UIView!
   // @IBOutlet var viewMore: UIView!
    @IBOutlet var widthCollVwParticipanst: NSLayoutConstraint!
    @IBOutlet var collVwParticipants: UICollectionView!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblPayout: UILabel!
    @IBOutlet var lblParticipantsCount: UILabel!
    @IBOutlet var lblNameProvider: UILabel!
    @IBOutlet var lblGigName: UILabel!
    @IBOutlet var imgVwServiceProvider: UIImageView!
    @IBOutlet var btnDismiss: UIButton!
    @IBOutlet var btnApply: UIButton!
    @IBOutlet var btnViewMore: UIButton!
    //MARK: - Variables
    var arrUser = ["near","dp","cutting"]
    override func awakeFromNib() {
        super.awakeFromNib()
       
        let nib = UINib(nibName: "GigParticipanstsCVC", bundle: nil)
        collVwParticipants.register(nib, forCellWithReuseIdentifier: "GigParticipanstsCVC")
        collVwParticipants.delegate = self
        collVwParticipants.dataSource = self
        widthCollVwParticipanst.constant = CGFloat(arrUser.count * 20)
        
    }
    func uiSet(){
        collVwParticipants.reloadData()
    }
}
//MARK: - UICollectionViewDelegate

extension GigViewCVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrUser.count > 0{
            return arrUser.count
        }else{
            return 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GigParticipanstsCVC", for: indexPath) as! GigParticipanstsCVC
        if arrUser.count > 0{
            cell.imgVwUser.image = UIImage(named: arrUser[indexPath.row])
            cell.imgVwUser.layer.cornerRadius = 10
        }
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -10
    }

}
