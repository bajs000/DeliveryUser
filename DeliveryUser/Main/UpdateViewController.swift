//
//  UpdateViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/11.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

enum UpdateType {
    case name
    case bank
}

class UpdateViewController: UITableViewController {

    var titleArr:[[String:String]]?
    var type:UpdateType?{
        didSet{
            if type == .name {
                self.title = "姓名"
                titleArr = [["title":"","detail":"","placeholder":""]]
            }else{
                self.title = "结算信息"
                titleArr = [["title":"持  卡  人","detail":"","placeholder":""],
                            ["title":"卡     号","detail":"","placeholder":""],
                            ["title":"选择银行","detail":"","placeholder":""],
                            ["title":"开户行名称","detail":"","placeholder":""]]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "修改", style: .plain, target: self, action: #selector(updateBtnDidClick(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == .name {
            return 1
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentify = ""
        if self.type == .name{
            cellIdentify = "nameCell"
        }else{
            cellIdentify = "Cell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentify, for: indexPath)
        if self.type == .name {
            
        }else{
            (cell.viewWithTag(1) as! UILabel).text = titleArr?[indexPath.row]["title"]
        }
        (cell.viewWithTag(2) as! UITextField).addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return cell
    }
    
    func textFieldDidChange(_ sender: UITextField) {
        let cell = Helpers.findSuperViewClass(UITableViewCell.self, with: sender)
        let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
        var dic = titleArr?[(indexPath?.row)!]
        dic?["detail"] = sender.text
        titleArr?.remove(at: (indexPath?.row)!)
        titleArr?.insert(dic!, at: (indexPath?.row)!)
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
    
    func updateBtnDidClick(_ sender: UIBarButtonItem) -> Void {
        self.requestUpdate()
    }
    
    func requestUpdate() -> Void {
        SVProgressHUD.show()
        var dic:NSDictionary?
        if type == .name {
            dic = ["user_name":(titleArr?[0]["detail"])!,"mnique":UserModel.shareInstance.mnique]
        }else{
            // TODO:- 未完成
            SVProgressHUD.showError(withStatus: "开发中....")
            return
        }
        NetworkModel.request(dic!, url: "/user_edit") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UPDATEINFO"), object: nil)
                _ = self.navigationController?.popViewController(animated: true)
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }

}
