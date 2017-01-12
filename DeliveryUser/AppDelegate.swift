//
//  AppDelegate.swift
//  DeliveryUser
//
//  Created by YunTu on 2017/1/9.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var _mapManager: BMKMapManager?
    var locationManager: CLLocationManager?
    var count = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        // 要使用百度地图，请先启动BaiduMapManager
        _mapManager = BMKMapManager()
        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
        let ret = _mapManager?.start("CFayr3XHFPcWnWAt6kifb89AsQd9EGAi", generalDelegate: self)
        if ret == false {
            NSLog("manager start failed!")
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager.init()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.distanceFilter = 200
            locationManager?.requestWhenInUseAuthorization()
        }
        
        // 定义需要计时的时间
        var timeCount = 0
        // 在global线程里创建一个时间源
        let codeTimer = DispatchSource.makeTimerSource(queue:      DispatchQueue.main)
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.scheduleRepeating(deadline: .now(), interval: .seconds(10))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: {
            // 每秒计时一次
            timeCount = timeCount + 1
            // 时间到了取消时间源
            if timeCount <= 0 {
                codeTimer.cancel()
            }
            // 返回主线程处理一些事件，更新UI等等
            if UserModel.shareInstance.mnique.characters.count > 0 && UserModel.shareInstance.workStatus == "1" {
                self.count = 0
                self.locationManager?.startUpdatingLocation()
            }else{
                print("no jurisdiction")
            }
        })
        // 启动时间源
        codeTimer.resume()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - BMKGeneralDelegate
    func onGetNetworkState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("联网成功");
        }
        else{
            NSLog("联网失败，错误代码：Error\(iError)");
        }
    }
    
    func onGetPermissionState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("授权成功");
        }
        else{
            NSLog("授权失败，错误代码：Error\(iError)");
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if  status == .authorizedWhenInUse {
//            manager.startUpdatingLocation()
        }else{
            SVProgressHUD.showError(withStatus: "请到设置里面打开定位，我们才能给你提供更好的服务")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if count <= 1 {
            let dateFormat = DateFormatter.init()
            dateFormat.dateFormat = "HH:mm:ss"
            print(dateFormat.string(from: Date()) + " upload location")
            let location = locations.last
            NetworkModel.request(["b_user_id":UserModel.shareInstance.userId,"longitude":String((location?.coordinate.longitude)!),"latitude":String((location?.coordinate.latitude)!)], url: "/store_always_lon", complete: { (dic) in
                print("upload location success")
            })
        }
    }
}

