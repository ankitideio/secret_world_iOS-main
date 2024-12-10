//
//  GigPopupViewVC.swift
//  SecretWorld
//
//  Created by IDEIO SOFT on 29/11/24.
//

import UIKit
import Hero

class GigPopupViewVC: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet var collVwGigList: UICollectionView!
    //MARK: - Variables
    var isSelectBtn = 0
    var callBack:((_ isSelect:Int?)->())?
    var arrData = [FilteredItem]()
    var currentIndex = 0
    var selectedId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Find the index of the selected ID
            if let index = arrData.firstIndex(where: { $0.id == selectedId }) {
                currentIndex = index
                
            }
            
            // Register the collection view cell
            let nibCollvw = UINib(nibName: "GigViewCVC", bundle: nil)
            collVwGigList.register(nibCollvw, forCellWithReuseIdentifier: "GigViewCVC")
            
            // Reload and scroll to the current index
            collVwGigList.reloadData()
        
        DispatchQueue.main.async {
               self.scrollToCurrentIndex()
           }
          
    }
    
    private func scrollToCurrentIndex() {
        collVwGigList.layoutIfNeeded() // Ensure the layout is updated
        if arrData.indices.contains(currentIndex) {
            let indexPath = IndexPath(item: currentIndex, section: 0)
            collVwGigList.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    @IBAction func actionLeftClick(_ sender: UIButton) {
        if currentIndex > 0 {
                    currentIndex -= 1
                    scrollToCurrentIndex()
                }
    }
    @IBAction func actionRightClick(_ sender: UIButton) {
        if currentIndex < arrData.count - 1 {
                    currentIndex += 1
                    scrollToCurrentIndex()
                }
    }
}

//MARK: - UICollectionViewDataSource,UICollectionViewDelegate
extension GigPopupViewVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrData.count > 0{
            return arrData.count
        }else{
            return 0
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GigViewCVC", for: indexPath) as! GigViewCVC
        if arrData.count > 0{
            let gigDetail = arrData[indexPath.row]
            let priceText = "Payout: $\(gigDetail.price ?? 0)"
            let attributedString = NSMutableAttributedString(string: priceText)
            if let priceRange = priceText.range(of: "$\(gigDetail.price ?? 0)") {
                let nsRange = NSRange(priceRange, in: priceText)
                attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 14)], range: nsRange)
            }
            cell.lblPayout.attributedText = attributedString
            cell.lblLocation.text = "Location: \(gigDetail.place ?? "")"
            cell.lblGigName.text = gigDetail.title ?? ""
            cell.lblNameProvider.text = "Mr.\(gigDetail.name ?? "")"
            cell.imgVwServiceProvider.imageLoad(imageUrl: gigDetail.image ?? "")
            cell.collVwParticipants.reloadData()
            cell.btnDismiss.tag = indexPath.row
            cell.btnDismiss.addTarget(self, action: #selector(actionDismiss), for: .touchUpInside)
            cell.btnViewMore.tag = indexPath.row
            cell.btnViewMore.addTarget(self, action: #selector(actionViewMore), for: .touchUpInside)
        }
        return cell
    }
    @objc func actionDismiss(sender:UIButton){
        self.dismiss(animated: true)
    }
    @objc func actionViewMore(sender:UIButton){
        self.dismiss(animated: true)
        callBack?(1)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collVwGigList.frame.size.width, height: 375)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
