//
//  StatisticsViewController.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/10.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    @IBOutlet weak var riderBg: UIView!
    @IBOutlet weak var totalCycle: UIView!
    @IBOutlet weak var rightCycle: UIView!
    @IBOutlet weak var complainCycle: UIView!
    @IBOutlet var titleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的统计"
        self.riderBg.layer.cornerRadius = 40
        self.totalCycle.layer.cornerRadius = 33.5
        self.rightCycle.layer.cornerRadius = 33.5
        self.complainCycle.layer.cornerRadius = 33.5
        
        self.totalCycle.layer.borderColor = UIColor.colorWithHexString(hex: "FF960E").cgColor
        self.totalCycle.layer.borderWidth = 1
        self.rightCycle.layer.borderColor = UIColor.colorWithHexString(hex: "FF960E").cgColor
        self.rightCycle.layer.borderWidth = 1
        self.complainCycle.layer.borderColor = UIColor.colorWithHexString(hex: "FF960E").cgColor
        self.complainCycle.layer.borderWidth = 1
        
        self.navigationItem.titleView = self.titleView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func timeSelected(_ sender: UIButton) {
        for i in 1...3 {
            (sender.superview?.viewWithTag(i) as! UIButton).isSelected = false
            (sender.superview?.viewWithTag(i) as! UIButton).titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        sender.isSelected = true
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    
}
