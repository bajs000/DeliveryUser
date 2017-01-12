//
//  OrderFinishViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/12.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class OrderFinishViewController: UITableViewController {

    var orderInfo:NSDictionary?
    var orderDetail:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "订单详情"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.requestOrderDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.orderDetail == nil {
            return 0
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentify = ""
        if indexPath.section == 0 {
            cellIdentify = "headerCell"
        }else if indexPath.section == 1 {
            cellIdentify = "goodsCell"
        }else if indexPath.section == 2 {
            cellIdentify = "placeCell"
        }else if indexPath.section == 3 {
            cellIdentify = "orderCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentify, for: indexPath)
        switch indexPath.section{
        case 0:
            (cell.viewWithTag(1) as! UIImageView).layer.cornerRadius = 26.5
            if self.orderDetail?["u_info"] != nil  && (self.orderDetail?["u_info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["u_info"] as! NSDictionary
                if dic["head_graphic"] != nil && !(dic["head_graphic"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(1) as! UIImageView).sd_setImage(with: URL(string: Helpers.baseImgUrl() + (dic["head_graphic"] as! String)), placeholderImage: UIImage(named: "order-default-sender"))
                }
                if dic["user_name"] != nil && !(dic["user_name"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(2) as! UILabel).text = dic["user_name"] as? String
                }else{
                    (cell.viewWithTag(2) as! UILabel).text = "游客"
                }
            }
            
            if self.orderDetail?["info"] != nil  && (self.orderDetail?["info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["info"] as! NSDictionary
                if dic["money"] != nil && !(dic["money"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(3) as! UILabel).text = "收益：" + (dic["money"] as! String) + "元"
                    let tempStr = NSMutableAttributedString(string: ((cell.viewWithTag(3) as! UILabel).text)!)
                    tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(3, ((cell.viewWithTag(3) as! UILabel).text?.characters.count)! - 3))
                    (cell.viewWithTag(3) as! UILabel).attributedText = tempStr
                }else{
                    (cell.viewWithTag(3) as! UILabel).text = "收益："
                }
                if dic["star"] != nil && !(dic["star"] as! NSObject).isKind(of: NSNull.self){
                    self.showStar(Int(dic["star"] as! String)!, at: cell.viewWithTag(20)!)
                }else{
                    self.showStar(0, at: cell.viewWithTag(20)!)
                }
            }
            break
        case 1:
            if self.orderDetail?["info"] != nil  && (self.orderDetail?["info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["info"] as! NSDictionary
                if dic["goods_name"] != nil && !(dic["goods_name"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(1) as! UILabel).text = (dic["goods_name"] as! String)
                }else{
                    (cell.viewWithTag(1) as! UILabel).text = "无"
                }
                if dic["dilometers"] != nil && !(dic["dilometers"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(2) as! UILabel).text = (dic["dilometers"] as! String) + "km"
                }else{
                    (cell.viewWithTag(2) as! UILabel).text = "0km"
                }
                var sum:Double = 0
                if dic["money"] != nil && !(dic["money"] as! NSObject).isKind(of: NSNull.self) {
                    sum = sum + Double(dic["money"] as! String)!
                    (cell.viewWithTag(3) as! UILabel).text = dic["money"] as! String + "元"
                }else{
                    (cell.viewWithTag(3) as! UILabel).text = "0元"
                }
                if dic["ds_money"] != nil && !(dic["ds_money"] as! NSObject).isKind(of: NSNull.self) {
                    sum = sum + Double(dic["ds_money"] as! String)!
                    (cell.viewWithTag(4) as! UILabel).text = (dic["ds_money"] as! String) + "元"
                }else{
                    (cell.viewWithTag(4) as! UILabel).text = "0元"
                }
                (cell.viewWithTag(5) as! UILabel).text = "应付：" + (NSString(format: "%.2f", sum) as String)
                let tempStr = NSMutableAttributedString(string: ((cell.viewWithTag(5) as! UILabel).text)!)
                tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "ff7800"), range: NSMakeRange(3, ((cell.viewWithTag(5) as! UILabel).text?.characters.count)! - 3))
                (cell.viewWithTag(5) as! UILabel).attributedText = tempStr
            }
            break
        case 2:
            if self.orderDetail?["info"] != nil  && (self.orderDetail?["info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["info"] as! NSDictionary
                if dic["time"] != nil && !(dic["time"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(1) as! UILabel).text = "下单时间：" + (dic["time"] as! String)
                }else{
                    (cell.viewWithTag(1) as! UILabel).text = "下单时间：无"
                }
                if dic["up_store_time"] != nil && !(dic["up_store_time"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(3) as! UILabel).text = "到店时间：" + (dic["up_store_time"] as! String)
                }else{
                    (cell.viewWithTag(3) as! UILabel).text = "到店时间：无"
                }
                if dic["c_pick_time"] != nil && !(dic["c_pick_time"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(4) as! UILabel).text = "取件时间：" + (dic["c_pick_time"] as! String)
                }else{
                    (cell.viewWithTag(4) as! UILabel).text = "取件时间：无"
                }
                if dic["c_servi_time"] != nil && !(dic["c_servi_time"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(5) as! UILabel).text = "送达时间：" + (dic["c_servi_time"] as! String)
                }else{
                    (cell.viewWithTag(5) as! UILabel).text = "送达时间：无"
                }
                if Int(dic["type"] as! String) == 0 {
                    (cell.viewWithTag(10) as! UILabel).text = "购买地址："
                    if dic["buy_address"] != nil && !(dic["buy_address"] as! NSObject).isKind(of: NSNull.self) {
                        (cell.viewWithTag(9) as! UILabel).text = dic["buy_address"] as? String
                    }else{
                        (cell.viewWithTag(9) as! UILabel).text = "无"
                    }
                }else if Int(dic["type"] as! String) == 1 {
                    (cell.viewWithTag(10) as! UILabel).text = "发货地址："
                    if dic["de_address"] != nil && !(dic["de_address"] as! NSObject).isKind(of: NSNull.self) {
                        (cell.viewWithTag(9) as! UILabel).text = dic["de_address"] as? String
                    }else{
                        (cell.viewWithTag(9) as! UILabel).text = "无"
                    }
                }else{
                    (cell.viewWithTag(10) as! UILabel).text = "发货地址："
                }
            }
            if self.orderDetail?["b_u_info"] != nil  && (self.orderDetail?["b_u_info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["b_u_info"] as! NSDictionary
                if dic["reg_time"] != nil && !(dic["reg_time"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(2) as! UILabel).text = "接单时间：" + (dic["reg_time"] as! String)
                }else{
                    (cell.viewWithTag(2) as! UILabel).text = "接单时间：无"
                }
                if dic["for_address"] != nil && !(dic["for_address"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(8) as! UILabel).text = dic["for_address"] as? String
                }else{
                    (cell.viewWithTag(8) as! UILabel).text = "无"
                }
            }
            if self.orderDetail?["u_info"] != nil  && (self.orderDetail?["u_info"] as! NSObject).isKind(of: NSDictionary.self) {
                let dic = self.orderDetail?["u_info"] as! NSDictionary
                if dic["user_name"] != nil && !(dic["user_name"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(6) as! UILabel).text = dic["user_name"] as? String
                }else{
                    (cell.viewWithTag(6) as! UILabel).text = "游客"
                }
                if dic["user_phone"] != nil && !(dic["user_phone"] as! NSObject).isKind(of: NSNull.self) {
                    (cell.viewWithTag(7) as! UILabel).text = dic["user_phone"] as? String
                    (cell.viewWithTag(7) as! UILabel).text = (((cell.viewWithTag(7) as! UILabel).text)! as NSString).replacingCharacters(in: NSMakeRange(3, 4), with: "****")
                }else{
                    (cell.viewWithTag(7) as! UILabel).text = "无"
                }
            }
            break
        case 3:
            let dic = self.orderDetail?["info"] as? NSDictionary
            (cell.viewWithTag(1) as! UILabel).text = "订单编号：" + (dic?["order_number"] as! String)
            if dic?["payment"] != nil && !(dic?["payment"] as! NSObject).isKind(of: NSNull.self) && !(dic?["payment"] as! NSObject).isKind(of: NSNull.self){
                (cell.viewWithTag(2) as! UILabel).text = "支付方式：" + (dic?["payment"] as! String)
            }else{
                (cell.viewWithTag(2) as! UILabel).text = "支付方式："
            }
            (cell.viewWithTag(3) as! UILabel).text = "下单时间：" + (dic?["time"] as! String)
            if dic?["remarks"] != nil && !(dic?["remarks"] as! NSObject).isKind(of: NSNull.self) && (dic?["remarks"] as! String).characters.count > 0 {
                (cell.viewWithTag(4) as! UILabel).text = "订单备注：" + (dic?["remarks"] as! String)
            }else{
                (cell.viewWithTag(4) as! UILabel).text = "订单备注："
            }
            break
        default:
            break
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func requestOrderDetail() {
        SVProgressHUD.show()
        NetworkModel.request(["order_number":(self.orderInfo?["order_number"] as! String)], url: "/user_order_details") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.orderDetail = (dic as! NSDictionary)
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
            
        }
    }

}
