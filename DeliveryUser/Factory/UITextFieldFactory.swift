//
//  UITextFieldFactory.swift
//  LocalUser
//
//  Created by YunTu on 2016/12/20.
//  Copyright © 2016年 果儿. All rights reserved.
//

import UIKit

class UITextFieldFactory: UITextField {
    
    var left:CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(editDidChange(_:)), for: .editingChanged)
    }
    
    override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))
    }
    
    func editDidChange(_ sender:UITextField) -> Void {
        
    }

}

class PhoneTextField: UITextFieldFactory {
    
    @IBInspectable var leftIcon:UIImage?
    @IBInspectable var leftEdge:CGFloat = 28
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let imgBg = UIImageView.init(image: leftIcon)
        imgBg.frame = CGRect(x: 0, y: 0, width: (leftIcon?.size.width)! + leftEdge, height: self.bounds.size.height)
        imgBg.contentMode = .center
        self.leftView = imgBg
        self.leftViewMode = .always
        left = imgBg.frame.size.width
        self.addTarget(self, action: #selector(textFieldDidBeginEdit(_:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidBeginEdit(_:)), for: .editingDidEnd)
    }
    
    func textFieldDidBeginEdit(_ sender:UITextField) {
//        self.setNeedsDisplay()
    }
    
}

class registPhoneTextField: PhoneTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func textFieldDidBeginEdit(_ sender: UITextField) {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)
        context.setLineWidth(1)
        context.setAllowsAntialiasing(true)
        if self.isEditing {
            context.setStrokeColor(red: 168.0 / 255.0, green: 214.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
        }else{
            context.setStrokeColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0)
        }
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: self.bounds.size.height - 1))
        context.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - 1))
        context.strokePath()
    }

}

class CodeTextField: registPhoneTextField {
    
    var sendCodeBtn:UIButton?
    var count = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: self.frame.size.height))
        sendCodeBtn = UIButton(type: .custom)
        rightView.addSubview(sendCodeBtn!)
        sendCodeBtn?.frame = rightView.frame
        sendCodeBtn?.setTitle("发送验证码", for: .normal)
        sendCodeBtn?.setTitleColor(UIColor.colorWithHexString(hex: "7eaf2d"), for: .normal)
        sendCodeBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.rightView = rightView
        self.rightViewMode = .always
    }
    
    func startCount() -> Void {
        count = 60
        sendCodeBtn?.isUserInteractionEnabled = false
        sendCodeBtn?.setTitle(String(count) + "秒后再试", for: .normal)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown(_:)), userInfo: nil, repeats: true)
    }
    
    func countDown(_ time:Timer) -> Void {
        count = count - 1
        if count <= 0 {
            time.invalidate()
            sendCodeBtn?.setTitle("发送验证码", for: .normal)
            sendCodeBtn?.isUserInteractionEnabled = true
            return
        }
        sendCodeBtn?.setTitle(String(count) + "秒后再试", for: .normal)
    }

    
}
