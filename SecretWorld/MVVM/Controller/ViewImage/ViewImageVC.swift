//
//  ViewImageVC.swift
//  SecretWorld
//
//  Created by meet sharma on 20/05/24.
//

import UIKit
import AVFoundation
import AVKit

class ViewImageVC: UIViewController {
    
    @IBOutlet var btnRghtArrow: UIButton!
    @IBOutlet var btnLeftArrow: UIButton!
    @IBOutlet weak var clsnVwImages: UICollectionView!
    
    var arrImage = [String]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                  swipeRight.direction = .right
                  view.addGestureRecognizer(swipeRight)
        uiSet()
    }
    @objc func handleSwipe() {
               navigationController?.popViewController(animated: true)
           }
    func uiSet(){
        if arrImage.count == 1{
            btnLeftArrow.isHidden = true
            btnRghtArrow.isHidden = true
        }else{
            btnLeftArrow.isHidden = false
            btnRghtArrow.isHidden = false
        }
        clsnVwImages.delegate = self
        clsnVwImages.dataSource = self
        clsnVwImages.collectionViewLayout = createLayout()
        
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
            self.clsnVwImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .horizontal
           layout.minimumLineSpacing = 0
           layout.minimumInteritemSpacing = 0
           return layout
       }
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           
           if let layout = clsnVwImages.collectionViewLayout as? UICollectionViewFlowLayout {
               layout.itemSize = CGSize(width: clsnVwImages.frame.size.width, height: clsnVwImages.frame.size.height)
               layout.invalidateLayout()
           }
       }
    func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let asset = AVURLAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                let thumbnail = UIImage(cgImage: thumbnailCGImage)
                
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionRight(_ sender: UIButton) {
        if index < arrImage.count - 1 {
            index += 1
            let indexPath = IndexPath(item: index, section: 0)
            clsnVwImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func actionLeft(_ sender: UIButton) {
        if index > 0 {
            index -= 1
            let indexPath = IndexPath(item: index, section: 0)
            clsnVwImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
    
}

extension ViewImageVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewImageCVC", for: indexPath) as! ViewImageCVC
        
        if arrImage[indexPath.row].contains(".png") || arrImage[indexPath.row].contains(".jpg") || arrImage[indexPath.row].contains(".jpeg"){
            cell.imgVwPlay.isHidden = true
            cell.btnPlay.isUserInteractionEnabled = false
            cell.imgVwView.imageLoad(imageUrl: arrImage[indexPath.item])
        }else{
            cell.imgVwPlay.isHidden = false
            cell.btnPlay.isUserInteractionEnabled = true
            cell.btnPlay.tag = indexPath.row
            cell.btnPlay.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
            cell.imgVwView.kf.indicatorType = .activity
            cell.imgVwView.kf.indicator?.view.tintColor = UIColor.black
            cell.imgVwView.kf.indicator?.startAnimatingView()
            if let url = URL(string: arrImage[indexPath.row]) {
                print("Url",url)
                generateThumbnail(url: url) { thumbnail in
                    if let thumbnail = thumbnail {
                        cell.imgVwView.kf.indicator?.stopAnimatingView()
                        cell.imgVwView.image = thumbnail
                        print("Thumbnail loaded")
                    } else {
                        print("Failed to load thumbnail")
                    }
                }
            }
        }

        return cell
        
    }
    @objc func playVideo(sender:UIButton){
        let videoUrlString = arrImage[sender.tag]
          if let videoUrl = URL(string: videoUrlString) {
              let player = AVPlayer(url: videoUrl)
              let playerViewController = AVPlayerViewController()
              playerViewController.player = player

              present(playerViewController, animated: true) {
                  player.play()
              }
          }
    }
}
