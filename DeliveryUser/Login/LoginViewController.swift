//
//  LoginViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/9.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userName: PhoneTextField!
    @IBOutlet weak var userPwd: PhoneTextField!
    @IBOutlet weak var logoTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.layer.cornerRadius = 25
        self.loginBtn.layer.borderColor = UIColor.white.cgColor
        self.loginBtn.layer.borderWidth = 1
        
        self.userName.layer.cornerRadius = 25
        self.userPwd.layer.cornerRadius = 25
        
        if UserModel.shareInstance.mnique.characters.count > 0 {
            self.performSegue(withIdentifier: "autoLogin", sender: nil)
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardShow(_ notification:Notification) -> Void {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.logoTop.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardHide(_ notification:Notification) -> Void {
        UIView.animate(withDuration: 0.75, animations: ({
            self.logoTop.constant = 90
            self.view.layoutIfNeeded()
        }), completion: {(_ finish:Bool) -> Void in
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    @IBAction func tapToHideKeyboard(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    @IBAction func loginBtnDidClick(_ sender: Any) {
        if self.userName.text?.characters.count != 11 {
            SVProgressHUD.showError(withStatus: "请正确输入手机号")
            return
        }
        if (self.userPwd.text?.characters.count)! < 6 {
            SVProgressHUD.showError(withStatus: "密码不能少于6位")
            return
        }
        self.requestLogin()
    }
    
    
    func requestLogin() {
        SVProgressHUD.show()
        NetworkModel.request(["user_phone":(self.userName.text)!,"password":(self.userPwd.text)!,"is_bess":"2"], url: "/logo") { (dic) in
            SVProgressHUD.dismiss()
            if Int((dic as! NSDictionary)["code"] as! String) == 200 {
                UserDefaults.standard.set((dic as! NSDictionary)["user_id"], forKey: "USERID")
                UserDefaults.standard.set((dic as! NSDictionary)["mnique"], forKey: "MNIQUE")
                UserDefaults.standard.synchronize()
                self.performSegue(withIdentifier: "mainPush", sender: nil)
            }else{
                SVProgressHUD.showError(withStatus: (dic as! NSDictionary)["msg"] as! String)
            }
        }
    }
    
}
