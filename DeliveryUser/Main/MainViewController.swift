//
//  MainViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/9.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import Masonry
import MJRefresh
import SDWebImage
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var titleView: UIView!
    @IBOutlet weak var workStatusImg: UIImageView!
    @IBOutlet weak var workStatus: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bubbleView: UIView!
    @IBOutlet weak var selectBtnLineLeading: NSLayoutConstraint!
    @IBOutlet var userCenter: UserCenterView!
    @IBOutlet weak var topView: UIView!
    
    var alertView:CustomAlert?
    var location:CLLocation?
    var orderList:[NSDictionary]?
    var manager:CLLocationManager?
    var count = 0
    var currentBtn:UIButton?
    var acceptGoodsDic:NSDictionary?
    var arriveShopDic:NSDictionary?
    var completeOrderDic:NSDictionary?
    var completePhotos:[UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleView
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        userCenter.tableViewLeading.constant = -(Helpers.screanSize().width - 35)
        
        self.currentBtn = self.topView.viewWithTag(1) as? UIButton
        
        self.tableView.mj_header = MJRefreshHeader.init(refreshingBlock: { 
            [unowned self] in
            self.requestOrderList()
        })
        
        self.tableView.mj_footer = MJRefreshFooter.init(refreshingBlock: {
            [unowned self] in
            self.requestOrderList()
        })
        
        if CLLocationManager.locationServicesEnabled() {
            manager = CLLocationManager.init()
            manager?.delegate = self
            manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager?.distanceFilter = 200
            manager?.requestWhenInUseAuthorization()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestUserInfo), name: NSNotification.Name(rawValue: "UPDATEINFO"), object: nil)
        
        self.requestUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if  status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }else{
            SVProgressHUD.showError(withStatus: "请到设置里面打开定位，我们才能给你提供更好的服务")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        count = count + 1
        if count <= 1 {
            location = locations.last
            if acceptGoodsDic != nil {
                self.requestAcceptGoods(acceptGoodsDic!)
            }else if self.completePhotos != nil && self.completeOrderDic != nil {
                self.requestUploadImg()
            }else if arriveShopDic != nil {
                self.requestArriveShop()
            }else{
                self.tableView.mj_header.beginRefreshing()
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.orderList == nil {
            return 0
        }
        return (self.orderList?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic = self.orderList?[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var img:UIImage?
        var typeName = ""
        var typeColor:UIColor?
        if Int(dic?["type"] as! String) == 0 {
            img = UIImage(named: "main-btn-0")
            typeName = "代购"
            typeColor = UIColor.colorWithHexString(hex: "54ccff")
        }else if Int(dic?["type"] as! String) == 1 {
            img = UIImage(named: "main-btn-1")
            typeName = "配送"
            typeColor = UIColor.colorWithHexString(hex: "ff9b2b")
        }else{
            img = UIImage(named: "main-btn-2")
            typeName = "定制"
            typeColor = UIColor.colorWithHexString(hex: "f76969")
        }
        (cell.viewWithTag(1) as! UIImageView).image = img
        (cell.viewWithTag(2) as! UILabel).text = typeName
        (cell.viewWithTag(2) as! UILabel).textColor = typeColor
        if dic?["remarks"] != nil && !(dic?["remarks"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(3) as! UILabel).text = (dic?["remarks"] as! String)
        }else{
            (cell.viewWithTag(3) as! UILabel).text = ""
        }
        if dic?["buy_address"] != nil && !(dic?["buy_address"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(4) as! UILabel).text = "始发地：" + (dic?["buy_address"] as! String)
        }else{
            (cell.viewWithTag(4) as! UILabel).text = "始发地："
        }
        if dic?["de_address"] != nil && !(dic?["de_address"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(5) as! UILabel).text = "目的地：" + (dic?["de_address"] as! String)
        }else{
            (cell.viewWithTag(5) as! UILabel).text = "目的地："
        }
        if dic?["dilometers"] != nil && !(dic?["dilometers"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(6) as! UILabel).text = "距离：" + (dic?["dilometers"] as! String) + "km"
            let tempStr = NSMutableAttributedString(string: ((cell.viewWithTag(6) as! UILabel).text)!)
            tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "54ccff"), range: NSMakeRange(3, ((cell.viewWithTag(6) as! UILabel).text?.characters.count)! - 3))
            (cell.viewWithTag(6) as! UILabel).attributedText = tempStr
        }else{
            (cell.viewWithTag(6) as! UILabel).text = "距离："
        }
        if dic?["charge_money"] != nil && !(dic?["charge_money"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(7) as! UILabel).text = "应代收货款：" + (dic?["charge_money"] as! String) + "元"
            let tempStr = NSMutableAttributedString(string: ((cell.viewWithTag(7) as! UILabel).text)!)
            tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(6, ((cell.viewWithTag(7) as! UILabel).text?.characters.count)! - 6))
            (cell.viewWithTag(7) as! UILabel).attributedText = tempStr
        }else{
            (cell.viewWithTag(7) as! UILabel).text = "应代收货款："
        }
        (cell.viewWithTag(9) as! UIButton).layer.cornerRadius = 12.5
        (cell.viewWithTag(9) as! UIButton).layer.borderWidth = 1
        (cell.viewWithTag(9) as! UIButton).layer.borderColor = UIColor.colorWithHexString(hex: "d7d7d7").cgColor
        (cell.viewWithTag(9) as! UIButton).setTitleColor(UIColor.colorWithHexString(hex: "666666"), for: .normal)
        (cell.viewWithTag(10) as! UIButton).layer.cornerRadius = 12.5
        (cell.viewWithTag(10) as! UIButton).layer.borderWidth = 1
        (cell.viewWithTag(10) as! UIButton).layer.borderColor = UIColor.colorWithHexString(hex: "d7d7d7").cgColor
        (cell.viewWithTag(10) as! UIButton).setTitleColor(UIColor.colorWithHexString(hex: "666666"), for: .normal)
        (cell.viewWithTag(11) as! UIButton).layer.cornerRadius = 12.5
        (cell.viewWithTag(11) as! UIButton).backgroundColor = UIColor.colorWithHexString(hex: "fbb528")
        (cell.viewWithTag(11) as! UIButton).setTitleColor(UIColor.white, for: .normal)
        if self.currentBtn?.tag == 1{
            (cell.viewWithTag(8) as! UILabel).isHidden = false
            cell.viewWithTag(9)?.isHidden = true
            cell.viewWithTag(10)?.isHidden = true
            cell.viewWithTag(11)?.isHidden = false
            let str = dic?["money"] as? String
            let tempStr = NSMutableAttributedString(string: "收益：" + str!)
            tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(3, (str?.characters.count)!))
            (cell.viewWithTag(8) as! UILabel).attributedText = tempStr
            (cell.viewWithTag(11) as! UIButton).setTitle("接单", for: .normal)
            
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(acceptGoods(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(sureCompleteBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).addTarget(self, action: #selector(acceptOrderBtnDidClick(_:)), for: .touchUpInside)
        }else if self.currentBtn?.tag == 2{
            (cell.viewWithTag(8) as! UILabel).isHidden = true
            cell.viewWithTag(9)?.isHidden = false
            cell.viewWithTag(10)?.isHidden = false
            cell.viewWithTag(11)?.isHidden = false
            (cell.viewWithTag(9) as! UIButton).setTitle("联系用户", for: .normal)
            (cell.viewWithTag(10) as! UIButton).setTitle("上报到店", for: .normal)
            (cell.viewWithTag(11) as! UIButton).setTitle("确认取件", for: .normal)
            (cell.viewWithTag(9) as! UIButton).addTarget(self, action: #selector(makePhoneCall(_:)), for: .touchUpInside)
            
            (cell.viewWithTag(10) as! UIButton).removeTarget(self, action: #selector(acceptOrderBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(10) as! UIButton).addTarget(self, action: #selector(arriveShop(_:)), for: .touchUpInside)
            
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(acceptOrderBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(sureCompleteBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).addTarget(self, action: #selector(acceptGoods(_:)), for: .touchUpInside)
        }else{
            (cell.viewWithTag(8) as! UILabel).isHidden = true
            cell.viewWithTag(9)?.isHidden = true
            cell.viewWithTag(10)?.isHidden = false
            cell.viewWithTag(11)?.isHidden = false
            (cell.viewWithTag(10) as! UIButton).setTitle("联系用户", for: .normal)
            (cell.viewWithTag(11) as! UIButton).setTitle("确认完成", for: .normal)
            
            (cell.viewWithTag(10) as! UIButton).removeTarget(self, action: #selector(acceptOrderBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(10) as! UIButton).addTarget(self, action: #selector(makePhoneCall(_:)), for: .touchUpInside)
            
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(acceptOrderBtnDidClick(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).removeTarget(self, action: #selector(acceptGoods(_:)), for: .touchUpInside)
            (cell.viewWithTag(11) as! UIButton).addTarget(self, action: #selector(sureCompleteBtnDidClick(_:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissBubbleView()
        self.performSegue(withIdentifier: "detailPush", sender: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissBubbleView()
    }
    
    // MARK: - UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        alertView?.currentSelectImg = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPush" {
            let vc = segue.destination as! OrderDetailViewController
            let dic = self.orderList?[(sender as! IndexPath).section]
            vc.orderInfo = dic
            if dic?["consignee"] != nil && !(dic?["consignee"] as! NSObject).isKind(of: NSNull.self){
                vc.userPhoneNum = (dic?["consignee"] as! String)
            }
        }
    }
    
    
    func dismissBubbleView() -> Void {
        if self.bubbleView.superview != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.bubbleView.mas_updateConstraints({ (make) in
                    _ = make?.right.equalTo()(self.navigationController?.view.mas_right)
                    _ = make?.top.equalTo()(self.navigationController?.mas_topLayoutGuide)?.with().offset()(40)
                    _ = make?.width.equalTo()(83)
                    _ = make?.height.equalTo()(0)
                })
                self.navigationController?.view.layoutIfNeeded()
            }) { (finish) in
                self.bubbleView.removeFromSuperview()
            }
        }
    }
    
    func acceptOrderBtnDidClick(_ sender:UIButton){
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        let dic = self.orderList?[(indexPath?.section)!]
        self.requestAcceptOrder(dic!)
    }
    
    func makePhoneCall(_ sender: UIButton){
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        let dic = self.orderList?[(indexPath?.section)!]
        
        if dic?["consignee"] != nil && !(dic?["consignee"] as! NSObject).isKind(of: NSNull.self){
            UIApplication.shared.openURL(URL(string: "tel://" + (dic?["consignee"] as! String))!)
        }else{
            SVProgressHUD.showError(withStatus: "信息错误")
        }
    }
    
    func acceptGoods(_ sender: UIButton) -> Void {
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        let dic = self.orderList?[(indexPath?.section)!]
        acceptGoodsDic = dic
        count = 0
        manager?.startUpdatingLocation()
    }
    
    func arriveShop(_ sender: UIButton) {
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        let dic = self.orderList?[(indexPath?.section)!]
        self.arriveShopDic = dic
        count = 0
        manager?.startUpdatingLocation()
    }
    
    func sureCompleteBtnDidClick(_ sender: UIButton) -> Void {
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        let dic = self.orderList?[(indexPath?.section)!]
        alertView = Bundle.main.loadNibNamed("CustomAlert", owner: nil, options: nil)?[0] as? CustomAlert
        alertView?.showImgPicker = {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "相机", style: .default, handler: { (alertAction) in
                let imgPicker = UIImagePickerController.init()
                imgPicker.sourceType = .camera
                imgPicker.delegate = self
                self.present(imgPicker, animated: true, completion: nil)
            })
            let photoAction = UIAlertAction(title: "相册", style: .default, handler: { (alertAction) in
                let imgPicker = UIImagePickerController.init()
                imgPicker.sourceType = .savedPhotosAlbum
                imgPicker.delegate = self
                self.present(imgPicker, animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (alertAction) in
                
            })
            sheet.addAction(cameraAction)
            sheet.addAction(photoAction)
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true, completion: nil)
        }
        alertView?.completeOrder = {(photoList,indexPath) -> Void in
            self.completeOrderDic = dic
            self.completePhotos = photoList
            self.count = 0
            self.manager?.startUpdatingLocation()
        }
        alertView?.showAlert(indexPath!)
        
    }
    
    @IBAction func titleStatusDidClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var start = "1"
        if sender.isSelected {//忙碌
            self.workStatus.text = "忙碌"
            self.workStatusImg.image = UIImage(named: "main-work-state-1")
            start = "2"
        }else{//开工
            self.workStatus.text = "开工"
            self.workStatusImg.image = UIImage(named: "main-work-state-0")
            start = "1"
        }
        SVProgressHUD.show()
        NetworkModel.request(["b_user_id":UserModel.shareInstance.userId,"start":start], url: "/store_user_start") { (dic) in
            if ((dic as! NSDictionary)["code"] as! NSNumber).intValue == 200 {
                SVProgressHUD.dismiss()
                UserDefaults.standard.set(start, forKey: "WORKSTATUS")
                UserDefaults.standard.synchronize()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }

    @IBAction func settingBarItemDidClick(_ sender: Any) {
        self.navigationController?.view.addSubview(self.userCenter)
        self.userCenter.mas_makeConstraints { (make) in
            _ = make?.top.equalTo()(self.navigationController?.view.mas_top)
            _ = make?.left.equalTo()(self.navigationController?.view.mas_left)
            _ = make?.bottom.equalTo()(self.navigationController?.view.mas_bottom)
            _ = make?.right.equalTo()(self.navigationController?.view.mas_right)
        }
        self.userCenter.userCenterTableDidSelected = {(tableView,indexPath) -> Void in
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "orderListPush", sender: indexPath)
            }else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "statisticsPush", sender: indexPath)
            }else if indexPath.row == 5 {
                self.performSegue(withIdentifier: "settingPush", sender: indexPath)
            }
        }
        self.userCenter.showTable()
    }
    
    @IBAction func moreBarItemDidClick(_ sender: Any) {
        self.navigationController?.view.addSubview(self.bubbleView)
        self.bubbleView.mas_makeConstraints { (make) in
            _ = make?.right.equalTo()(self.navigationController?.view.mas_right)
            _ = make?.top.equalTo()(self.navigationController?.mas_topLayoutGuide)?.with().offset()(40)
            _ = make?.width.equalTo()(83)
            _ = make?.height.equalTo()(0)
        }
        self.navigationController?.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5) {
            self.bubbleView.mas_remakeConstraints({ (make) in
                _ = make?.right.equalTo()(self.navigationController?.view.mas_right)
                _ = make?.top.equalTo()(self.navigationController?.mas_topLayoutGuide)?.with().offset()(40)
                _ = make?.width.equalTo()(83)
                _ = make?.height.equalTo()(106)
            })
            self.navigationController?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func moreActionBtnDidClick(_ sender: UIButton) {
        self.dismissBubbleView()
    }
    
    @IBAction func orderTypeBtnDidClick(_ sender: UIButton) {
        self.currentBtn = sender
        for i in 1...3 {
            let btn = sender.superview?.viewWithTag(i) as! UIButton
            btn.isSelected = false
        }
        sender.isSelected = true
        UIView.animate(withDuration: 0.5) {
            self.selectBtnLineLeading.constant = CGFloat(sender.tag - 1) * Helpers.screanSize().width / 3
            self.view.layoutIfNeeded()
        }
        if CLLocationManager.locationServicesEnabled() {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    @IBAction func userInfoDidTap(_ sender: Any) {
        if self.userCenter.superview != nil {
            self.userCenter.dismissTable({
                self.performSegue(withIdentifier: "userInfoPush", sender: sender)
            })
        }
    }
    
    // MARK:- Network
    func requestOrderList() {
        SVProgressHUD.show()
        var dic:NSDictionary?
        if self.currentBtn?.tag == 3 {
            dic = ["is_qu":"1","state":"3","longitude":String((location?.coordinate.longitude)!),"latitude":String((location?.coordinate.latitude)!)]
        }else if self.currentBtn?.tag == 1{
            dic = ["is_qu":"0","state":"1","longitude":String((location?.coordinate.longitude)!),"latitude":String((location?.coordinate.latitude)!)]
        }else{
            dic = ["is_qu":"1","state":"3","longitude":String((location?.coordinate.longitude)!),"latitude":String((location?.coordinate.latitude)!)]
        }
        NetworkModel.request(dic!, url: "/store_order_list") { (dic) in
            SVProgressHUD.dismiss()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.orderList = (dic as! NSDictionary)["list"] as? [NSDictionary]
                self.tableView.reloadData()
            }else{
                self.orderList = nil
                self.tableView.reloadData()
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestAcceptOrder(_ dic:NSDictionary){
        SVProgressHUD.show()
        NetworkModel.request(["order_number":(dic["order_number"] as! String),"b_user_id":UserModel.shareInstance.userId], url: "/the_meet") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.requestOrderList()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestAcceptGoods(_ dic:NSDictionary){
        SVProgressHUD.show()
        NetworkModel.request(["order_number":(dic["order_number"] as! String),"b_user_id":UserModel.shareInstance.userId,"c_pick_longitude":String((location?.coordinate.longitude)!),"c_pick_latitude":String((location?.coordinate.latitude)!)], url: "/confirm_pickup") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.acceptGoodsDic = nil
                self.requestOrderList()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestArriveShop() -> Void {
        SVProgressHUD.show()
        NetworkModel.request(["order_number":(self.arriveShopDic?["order_number"] as! String),"up_store_longitude":String((location?.coordinate.longitude)!),"up_store_latitude":String((location?.coordinate.latitude)!)], url: "/the_up_store") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.arriveShopDic = nil
                self.requestOrderList()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestUploadImg() -> Void {
        UploadNetwork.request(["order_number":(self.completeOrderDic?["order_number"] as! String),"c_servi_longitude":String((location?.coordinate.longitude)!),"c_servi_latitude":String((location?.coordinate.latitude)!)], data: (self.completePhotos?[0])!, paramName: "servi_img", url: "/confirm_service") { (dic) in
            SVProgressHUD.dismiss()
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.completeOrderDic = nil
                self.completePhotos = nil
                self.requestOrderList()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestUserInfo() -> Void {
        if UserDefaults.standard.object(forKey: "MNIQUE") != nil {
            SVProgressHUD.show()
            NetworkModel.request(["mnique":UserDefaults.standard.object(forKey: "MNIQUE") as! String], url: "/user_info") { (dic) in
                SVProgressHUD.dismiss()
                let dict = dic as! NSDictionary
                let userDefault = UserDefaults.standard
                if Int(dict["code"] as! String) == 200 {
                    UserModel.shareInstance.logout()
                    if !(((dict["info"] as! NSDictionary)["for_address"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["for_address"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["for_address"] as! String), forKey: "ADDRESS")
                    }
                    if !(((dict["info"] as! NSDictionary)["gender"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["gender"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["gender"] as! String), forKey: "GENDER")
                    }
                    if !(((dict["info"] as! NSDictionary)["head_graphic"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["head_graphic"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["head_graphic"] as! String), forKey: "AVATAR")
                    }
                    if !(((dict["info"] as! NSDictionary)["is_bess"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["is_bess"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["is_bess"] as! String), forKey: "BESS")
                    }
                    if !(((dict["info"] as! NSDictionary)["mnique"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["mnique"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["mnique"] as! String), forKey: "MNIQUE")
                    }
                    if !(((dict["info"] as! NSDictionary)["money"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["money"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["money"] as! String), forKey: "MONEY")
                    }
                    if !(((dict["info"] as! NSDictionary)["user_id"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["user_id"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["user_id"] as! String), forKey: "USERID")
                    }
                    if !(((dict["info"] as! NSDictionary)["user_name"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["user_name"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["user_name"] as! String), forKey: "USERNAME")
                    }
                    if !(((dict["info"] as! NSDictionary)["user_phone"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["user_phone"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["user_phone"] as! String), forKey: "USERPHONE")
                    }
                    if !(((dict["info"] as! NSDictionary)["start"] as! NSObject).isKind(of: NSNull.self)) &&  ((dict["info"] as! NSDictionary)["start"] as! String).characters.count > 0{
                        userDefault.set(((dict["info"] as! NSDictionary)["start"] as! String), forKey: "WORKSTATUS")
                    }
                    userDefault.synchronize()
                    if UserModel.shareInstance.workStatus == "1" {
                        self.workStatus.text = "开工"
                        self.workStatusImg.image = UIImage(named: "main-work-state-0")
                    }else{
                        self.workStatus.text = "忙碌"
                        self.workStatusImg.image = UIImage(named: "main-work-state-1")
                    }
                }else{
                    SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
                }
            }
        }
    }
    
}
