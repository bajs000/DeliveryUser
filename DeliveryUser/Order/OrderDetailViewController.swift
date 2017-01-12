//
//  OrderDetailViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/10.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class OrderDetailViewController: UIViewController, BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    @IBOutlet weak var mapView: BMKMapView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var startPlace: UILabel!
    @IBOutlet weak var endPlace: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var contactUserBtn: UIButton!
    @IBOutlet weak var arriveShopBtn: UIButton!
    @IBOutlet weak var sureOrderBtn: UIButton!
    @IBOutlet weak var chargeMoneyLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var sureComplete: UIButton!
    
    var locService:BMKLocationService?
    var orderInfo:NSDictionary?
    var userPhoneNum:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "订单详情"
        self.mapView.delegate = self
        self.locService = BMKLocationService.init()
        self.locService?.delegate = self
        self.avatar.layer.cornerRadius = 26.5
        self.contactUserBtn.layer.borderWidth = 1
        self.contactUserBtn.layer.borderColor = UIColor.colorWithHexString(hex: "d7d7d7").cgColor
        self.contactUserBtn.layer.cornerRadius = 12.5
        self.arriveShopBtn.layer.borderWidth = 1
        self.arriveShopBtn.layer.borderColor = UIColor.colorWithHexString(hex: "d7d7d7").cgColor
        self.arriveShopBtn.layer.cornerRadius = 12.5
        self.sureOrderBtn.layer.cornerRadius = 12.5
        self.sureComplete.layer.cornerRadius = 12.5
        sureOrderBtn.backgroundColor = UIColor.colorWithHexString(hex: "fbb528")
        if self.orderInfo != nil {
            self.requestOrderInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - BMKMapViewDelegate
    func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        self.locService?.startUserLocationService()
        self.mapView.showsUserLocation = false
        self.mapView.userTrackingMode = BMKUserTrackingModeNone
        self.mapView.showsUserLocation = true
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        self.mapView.updateLocationData(userLocation)
        self.mapView.setCenter(userLocation.location.coordinate, animated: true)
        self.mapView.setRegion(BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.05, 0.05)), animated: true)
        self.locService?.stopUserLocationService()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func contactUserBtnDidClick(_ sender: Any) {
        if userPhoneNum != nil {
            UIApplication.shared.openURL(URL(string: "tel://" + userPhoneNum!)!)
        }else{
            SVProgressHUD.showError(withStatus: "信息错误")
        }
    }
    
    @IBAction func upStoreBtnDidClick(_ sender: Any) {
        
    }
    
    @IBAction func acceptGoodsBtnDidClick(_ sender: Any) {
        
    }
    
    @IBAction func sureCompleteBtnDidClick(_ sender: Any) {
        
    }
    
    func requestOrderInfo() -> Void {
        SVProgressHUD.show()
        NetworkModel.request(["order_number":(self.orderInfo?["order_number"] as! String)], url: "/user_order_details") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                SVProgressHUD.dismiss()
                self.orderInfo = (dic as! NSDictionary)
                if self.orderInfo?["u_info"] != nil && (self.orderInfo?["u_info"] as! NSObject).isKind(of: NSDictionary.self){
                    let dict = self.orderInfo?["u_info"] as! NSDictionary
                    self.avatar.sd_setImage(with: URL(string: Helpers.baseImgUrl() + (dict["head_graphic"] as! String)), placeholderImage: UIImage(named: "order-default-sender"))
                    if dict["user_name"] != nil && !(dict["user_name"] as! NSObject).isKind(of: NSNull.self) {
                        self.phoneNum.text = dict["user_name"] as? String
                    }else{
                        self.phoneNum.text = ""
                    }
                }
                
                if self.orderInfo?["info"] != nil && (self.orderInfo?["info"] as! NSObject).isKind(of: NSDictionary.self){
                    let dict = self.orderInfo?["info"] as! NSDictionary
                    if dict["remarks"] != nil && !(dict["remarks"] as! NSObject).isKind(of: NSNull.self) {
                        self.userName.text = "留言：" + (dict ["remarks"] as! String)
                    }else{
                        self.userName.text = "留言："
                    }
                    if dict["buy_address"] != nil && !(dict["buy_address"] as! NSObject).isKind(of: NSNull.self) {
                        self.startPlace.text = "始发地：" + (dict ["buy_address"] as! String)
                    }else{
                        self.startPlace.text = "始发地："
                    }
                    if dict["dilometers"] != nil && !(dict["dilometers"] as! NSObject).isKind(of: NSNull.self) {
                        self.distance.text = "距离：" + (dict ["dilometers"] as! String) + "km"
                    }else{
                        self.distance.text = "距离："
                    }
                    if dict["charge_money"] != nil && !(dict["charge_money"] as! NSObject).isKind(of: NSNull.self) {
                        self.chargeMoneyLabel.text = "应代收货款：" + (dict ["charge_money"] as! String) + "元"
                        let tempStr = NSMutableAttributedString(string: (self.chargeMoneyLabel.text)!)
                        tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(6, (self.chargeMoneyLabel.text?.characters.count)! - 6))
                        self.chargeMoneyLabel.attributedText = tempStr
                    }else{
                        self.chargeMoneyLabel.text = "应代收货款："
                    }
                    if dict["money"] != nil && !(dict["money"] as! NSObject).isKind(of: NSNull.self) {
                        self.moneyLabel.text = "收益：" + (dict ["money"] as! String) + "元"
                        let tempStr = NSMutableAttributedString(string: (self.moneyLabel.text)!)
                        tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(3, (self.moneyLabel.text?.characters.count)! - 3))
                        self.moneyLabel.attributedText = tempStr
                    }else{
                        self.moneyLabel.text = "收益："
                    }
                }
                
                if self.orderInfo?["b_u_info"] != nil && (self.orderInfo?["b_u_info"] as! NSObject).isKind(of: NSDictionary.self){
                    let dict = self.orderInfo?["b_u_info"] as! NSDictionary
                    if dict["for_address"] != nil && !(dict["for_address"] as! NSObject).isKind(of: NSNull.self) {
                        self.endPlace.text = "目的地：" + (dict ["for_address"] as! String)
                    }else{
                        self.endPlace.text = "目的地："
                    }
                }
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }

}
