//
//  RegistViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/9.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegistViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var phoneNum: registPhoneTextField!
    @IBOutlet weak var codeNum: CodeTextField!
    @IBOutlet weak var passwordNum: registPhoneTextField!
    @IBOutlet weak var sureNum: registPhoneTextField!
    
    var verify:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backBtn.setImage(Helpers.image(self.backBtn.currentImage!, with: UIColor.colorWithHexString(hex: "333333")), for: .normal)
        self.registBtn.layer.cornerRadius = 20
        let tempStr = NSMutableAttributedString(string: "点击注册即视为已阅读并同意《用户协议》")
        tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "eca300"), range: NSMakeRange(13, 6))
        self.protocolLabel.attributedText = tempStr
        
        self.codeNum.sendCodeBtn?.addTarget(self, action: #selector(verifyBtnDidClick), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func verifyBtnDidClick() -> Void {
        if self.phoneNum.text?.characters.count != 11 {
            SVProgressHUD.showError(withStatus: "请正确输入手机号")
            return
        }
        self.requestVerify()
    }
    
    @IBAction func backBtnDidClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    @IBAction func registBtnDidClick(_ sender: Any) {
        if self.verify == nil {
            SVProgressHUD.showError(withStatus: "请先发送验证码")
            return
        }
        if self.verify != self.codeNum.text {
            SVProgressHUD.showError(withStatus: "请正确输入验证码")
            return
        }
        if (self.passwordNum.text?.characters.count)! < 6 {
            SVProgressHUD.showError(withStatus: "请输入6位以上密码")
            return
        }
        if self.passwordNum.text != self.sureNum.text {
            SVProgressHUD.showError(withStatus: "两次密码不一致")
            return
        }
        self.requestRegist()
    }
    
    func requestVerify() -> Void {
        SVProgressHUD.show()
        NetworkModel.request(["phone":phoneNum.text ?? "","is_bess":"2"], url: "/verify") { (dic) in
            SVProgressHUD.dismiss()
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                self.codeNum.startCount()
                self.verify = (dic as! NSDictionary)["verify"] as? String
                print(dic)
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
    func requestRegist() -> Void {
        var dic:NSDictionary?
        dic = ["phone":phoneNum.text!,"is_bess":"2","password":passwordNum.text!]
        SVProgressHUD.show()
        NetworkModel.request(dic!, url: "/register") { (dic) in
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                SVProgressHUD.dismiss()
                UserDefaults.standard.set((dic as! NSDictionary)["user_id"], forKey: "USERID")
                UserDefaults.standard.set((dic as! NSDictionary)["mnique"], forKey: "MNIQUE")
                UserDefaults.standard.synchronize()
                _ = self.navigationController?.popToRootViewController(animated: true)
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
}
