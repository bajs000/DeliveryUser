//
//  RegistViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/9.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit

class RegistViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var protocolLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backBtn.setImage(Helpers.image(self.backBtn.currentImage!, with: UIColor.colorWithHexString(hex: "333333")), for: .normal)
        self.registBtn.layer.cornerRadius = 20
        let tempStr = NSMutableAttributedString(string: "点击注册即视为已阅读并同意《用户协议》")
        tempStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorWithHexString(hex: "eca300"), range: NSMakeRange(13, 6))
        self.protocolLabel.attributedText = tempStr
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
    
    @IBAction func backBtnDidClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

}
