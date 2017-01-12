//
//  OrderListViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/10.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendFinishLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var chargMoneyLabel: UILabel!
    
    var orderList = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.title = "历史订单"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "order-calendar"), style: .plain, target: self, action: #selector(orderCalendarDidClick(_:)))
        self.requestHistory()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.orderList.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let dic = self.orderList[indexPath.section]
        if dic["rec_time"] != nil && !(dic["rec_time"] as! NSObject).isKind(of: NSNull.self) {
            (cell.viewWithTag(1) as! UILabel).text = dic["rec_time"] as! String + "送达"
        }else{
            (cell.viewWithTag(1) as! UILabel).text = "未知时间送达"
        }
        var img:UIImage?
        var typeName = ""
        var typeColor:UIColor?
        if Int(dic["type"] as! String) == 0 {
            img = UIImage(named: "main-btn-0")
            typeName = "代购"
            typeColor = UIColor.colorWithHexString(hex: "54ccff")
        }else if Int(dic["type"] as! String) == 1 {
            img = UIImage(named: "main-btn-1")
            typeName = "配送"
            typeColor = UIColor.colorWithHexString(hex: "ff9b2b")
        }else{
            img = UIImage(named: "main-btn-2")
            typeName = "定制"
            typeColor = UIColor.colorWithHexString(hex: "f76969")
        }
        (cell.viewWithTag(2) as! UIImageView).image = img
        (cell.viewWithTag(3) as! UILabel).text = typeName
        (cell.viewWithTag(3) as! UILabel).textColor = typeColor
        if dic["remarks"] != nil && !(dic["remarks"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(4) as! UILabel).text = (dic["remarks"] as! String)
        }else{
            (cell.viewWithTag(4) as! UILabel).text = ""
        }
        if dic["buy_address"] != nil && !(dic["buy_address"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(5) as! UILabel).text = "始发地：" + (dic["buy_address"] as! String)
        }else{
            (cell.viewWithTag(5) as! UILabel).text = "始发地："
        }
        if dic["de_address"] != nil && !(dic["de_address"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(6) as! UILabel).text = "目的地：" + (dic["de_address"] as! String)
        }else{
            (cell.viewWithTag(6) as! UILabel).text = "目的地："
        }
        if dic["money"] != nil && !(dic["money"] as! NSObject).isKind(of: NSNull.self){
            (cell.viewWithTag(7) as! UILabel).text = "应付：" + (dic["money"] as! String) + "元"
            let tempStr = NSMutableAttributedString(string: ((cell.viewWithTag(7) as! UILabel).text)!)
            tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(3, ((cell.viewWithTag(7) as! UILabel).text?.characters.count)! - 3))
            (cell.viewWithTag(7) as! UILabel).attributedText = tempStr
        }else{
            (cell.viewWithTag(7) as! UILabel).text = "应付："
        }
        if dic["star"] != nil && !(dic["star"] as! NSObject).isKind(of: NSNull.self){
            self.showStar(Int(dic["star"] as! String)!, at: cell.viewWithTag(20)!)
        }else{
            self.showStar(0, at: cell.viewWithTag(20)!)
        }
        return cell
    }
    
    func showStar(_ count:Int ,at view:UIView) -> Void {
        for i in 21...25 {
            let img = view.viewWithTag(i) as! UIImageView
            img.image = UIImage(named: "order-star-close")
        }
        if count > 0 {
            for i in 21...(21 + count) {
                let img = view.viewWithTag(i) as! UIImageView
                img.image = UIImage(named: "order-star-light")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailPush", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPush" {
            let dic = self.orderList[(sender as! IndexPath).section]
            let vc = segue.destination as! OrderFinishViewController
            vc.orderInfo = dic
        }
    }
    
    
    func orderCalendarDidClick(_ sender: UIBarButtonItem) {
        
    }

    func requestHistory() -> Void {
        SVProgressHUD.show()
        NetworkModel.request(["b_user_id":UserModel.shareInstance.userId], url: "/store_order_list") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.orderList = (dic as! NSDictionary)["list"] as! [NSDictionary]
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                if (dic as! NSDictionary)["ok_sum"] != nil && !((dic as! NSDictionary)["ok_sum"] as! NSObject).isKind(of: NSNull.self){
                    self.sendFinishLabel.text = (dic as! NSDictionary)["ok_sum"] as? String
                }else{
                    self.sendFinishLabel.text = "0"
                }
                if (dic as! NSDictionary)["cancell_sum"] != nil && !((dic as! NSDictionary)["cancell_sum"] as! NSObject).isKind(of: NSNull.self){
                    self.cancelLabel.text = (dic as! NSDictionary)["cancell_sum"] as? String
                }else{
                    self.cancelLabel.text = "0"
                }
                if (dic as! NSDictionary)["colle_pay_sum"] != nil && !((dic as! NSDictionary)["colle_pay_sum"] as! NSObject).isKind(of: NSNull.self){
                    self.chargMoneyLabel.text = (dic as! NSDictionary)["colle_pay_sum"] as? String
                }else{
                    self.chargMoneyLabel.text = "0"
                }
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
}
