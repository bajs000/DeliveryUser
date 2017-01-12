//
//  UserInfoViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/11.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class UserInfoViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var userInfo:NSDictionary?
    var titleArr:[[String:String]] = [["title":"头像","detail":"","icon":""],
                                      ["title":"姓名","detail":"","icon":""],
                                      ["title":"绑定手机号","detail":"","icon":""],
                                      ["title":"结算信息","detail":"","icon":""]]
    
    override func viewDidLoad() {
        self.title = "我的账户"
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentify = ""
        if indexPath.row == 0 {
            cellIdentify = "headerCell"
        }else{
            cellIdentify = "Cell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentify, for: indexPath)
        if indexPath.row == 0 {
            cell.viewWithTag(2)?.layer.cornerRadius = 28
            (cell.viewWithTag(2) as! UIImageView).sd_setImage(with: URL(string: Helpers.baseImgUrl() + self.titleArr[indexPath.row]["icon"]!), placeholderImage: UIImage(named: "order-default-sender"))
        }else{
            (cell.viewWithTag(2) as! UILabel).text = self.titleArr[indexPath.row]["detail"]
        }
        (cell.viewWithTag(1) as! UILabel).text = self.titleArr[indexPath.row]["title"]
        
        if indexPath.row == 2 {
            if ((cell.viewWithTag(2) as! UILabel).text?.characters.count)! > 7 {
                (cell.viewWithTag(2) as! UILabel).text = (((cell.viewWithTag(2) as! UILabel).text)! as NSString).replacingCharacters(in: NSMakeRange(3, 4), with: "****")
            }
        }
        
        cell.viewWithTag(3)?.isHidden = false
        if indexPath.row == 3 {
            cell.viewWithTag(3)?.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
        }else if indexPath.row == 1 || indexPath.row == 3 {
            self.performSegue(withIdentifier: "updatePush", sender: indexPath)
        }
    }

    // MARK: - UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.requestUploadAvatar(info[UIImagePickerControllerOriginalImage] as! UIImage)
        self.dismiss(animated: true, completion: nil)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updatePush" {
            let vc = segue.destination as! UpdateViewController
            if (sender as! IndexPath).row == 1 {
                vc.type = .name
            }else{
                vc.type = .bank
            }
        }
    }

    func requestUserInfo() -> Void {
        SVProgressHUD.show()
        NetworkModel.request(["mnique":UserModel.shareInstance.mnique], url: "/user_info") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                SVProgressHUD.dismiss()
                self.userInfo = (dic as! NSDictionary)["info"] as? NSDictionary
                self.titleArr = [["title":"头像","detail":"","icon":(self.userInfo?["head_graphic"] as! String)],
                            ["title":"姓名","detail":(self.userInfo?["user_name"] as! String),"icon":""],
                            ["title":"绑定手机号","detail":(self.userInfo?["user_phone"] as! String),"icon":""],
                            ["title":"结算信息","detail":"","icon":""]]
                self.tableView.reloadData()
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestUploadAvatar(_ image:UIImage) {
        SVProgressHUD.show()
        UploadNetwork.request(["mnique":UserModel.shareInstance.mnique], data: image,paramName: "head_graphic", url: "/user_edit") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.requestUserInfo()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UPDATEINFO"), object: nil)
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
}
