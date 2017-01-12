//
//  UserCenterView.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/10.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SDWebImage

class UserCenterView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarBg: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var workStautsImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var accessImg: UIImageView!
    @IBOutlet weak var tableViewLeading: NSLayoutConstraint!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    
    var userCenterTableDidSelected:((_ tableView:UITableView, _ indexPath: IndexPath) -> Void)?
    
    var titleArr:[[String:String]] = [["title":"历史订单","icon":"user-order"],
                                      ["title":"我的统计","icon":"user-statistics"],
                                      ["title":"消息通知","icon":"user-msg"],
                                      ["title":"资料阅读","icon":"user-data"],
                                      ["title":"代收贷款","icon":"user-price"],
                                      ["title":"系统设置","icon":"main-setting"]]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessImg.image = Helpers.image(self.accessImg.image!, with: UIColor.white)
        self.avatarBg.layer.cornerRadius = 35.5
        self.avatar.layer.cornerRadius = 28.5
        self.tableViewLeading.constant = -(Helpers.screanSize().width - 35)
        self.tableViewWidth.constant = Helpers.screanSize().width - 35
        
    }
    
    func showTable() -> Void {
        self.avatar.sd_setImage(with: URL(string: UserModel.shareInstance.avatar), placeholderImage: UIImage(named: "main-user-default-icon"))
        self.userName.text = UserModel.shareInstance.userName
        self.phoneNum.text = (UserModel.shareInstance.userPhone as NSString).replacingCharacters(in: NSMakeRange(3, 4), with: "****")
        if UserModel.shareInstance.workStatus == "1" {
            self.workStautsImg.image = UIImage(named: "main-work-state-0")
        }else{
            self.workStautsImg.image = UIImage(named: "main-work-state-1")
        }
        UIView.animate(withDuration: 0.5) { 
            self.tableViewLeading.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    func dismissTable(_ complete:(() -> Void)?) {
        if self.superview != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewLeading.constant = -(Helpers.screanSize().width - 35)
                self.layoutIfNeeded()
            }) { (finish) in
                self.removeFromSuperview()
                if complete != nil {
                    complete!()
                }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func tapDidClick(_ sender: Any) {
        self.dismissTable(nil)
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
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
        (cell.viewWithTag(1) as! UIImageView).image = UIImage(named: titleArr[indexPath.row]["icon"]!)
        (cell.viewWithTag(2) as! UILabel).text = titleArr[indexPath.row]["title"]
        cell.viewWithTag(3)?.isHidden = false
        if indexPath.row == titleArr.count - 1 {
            cell.viewWithTag(3)?.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissTable {
            self.userCenterTableDidSelected!(tableView,indexPath)
        }
    }

}
