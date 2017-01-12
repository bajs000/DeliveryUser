//
//  CustomAlert.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/11.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit

class CustomAlert: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var alertViewHeight: NSLayoutConstraint!
    
    var photoList = [UIImage]()
    var showImgPicker:(() -> Void)?
    var completeOrder:(([UIImage],IndexPath) -> Void)?
    var currentIndexPath:IndexPath?
    var currentSelectImg:UIImage?{
        didSet {
            photoList.append(currentSelectImg!)
            self.collectionView.reloadData()
            let row:Int = photoList.count / 3
            let height = 238 + 10 + CGFloat(row) * 55.5
            if row > 0 && self.alertViewHeight.constant < height && row < 4{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.alertViewHeight.constant = 238 + CGFloat(row) * 65.5
                        self.layoutIfNeeded()
                    })
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alertView.layer.cornerRadius = 6
        self.sureBtn.layer.cornerRadius = 19
        let nib = UINib(nibName: "PhotoCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: ({
            self.alertView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }), completion: {(_ finish:Bool) -> Void in
            UIView.animate(withDuration: 0.23, delay: 0, options: .curveEaseInOut, animations: ({
                self.alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }), completion: {(_ finish:Bool) -> Void in
                UIView.animate(withDuration: 0.09, delay: 0.02, options: .curveEaseInOut, animations: ({
                    self.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }), completion: {(_ finish:Bool) -> Void in
                    UIView.animate(withDuration: 0.05, delay: 0.02, options: .curveEaseInOut, animations: ({
                        self.alertView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }), completion: {(_ finish:Bool) -> Void in
                        
                    })
                })
            })
        })
    }
    
    func showAlert(_ indexPath:IndexPath) -> Void {
        self.currentIndexPath = indexPath
        let window:UIWindow = ((UIApplication.shared.delegate?.window)!)! as UIWindow
        self.frame = window.frame
        window.addSubview(self)
        window.bringSubview(toFront: self)
        self.layoutIfNeeded()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoList.count == 0 {
            return 1
        }
        return self.photoList.count
//        return 1 + self.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if indexPath.row == self.photoList.count {
            (cell.viewWithTag(1) as! UIImageView).image = UIImage(named: "main-camera")
        }else{
            (cell.viewWithTag(1) as! UIImageView).image = self.photoList[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.photoList.count {
            self.showImgPicker!()
        }else{
            
        }
    }
    
    @IBAction func sureBtnDidClick(_ sender: Any) {
        if self.completeOrder != nil {
            if self.photoList.count > 0 {
                self.completeOrder!(self.photoList,self.currentIndexPath!)
            }
        }
        self.removeFromSuperview()
    }

}
