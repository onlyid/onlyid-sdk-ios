//
//  OnlyID_SDK.swift
//  OnlyID_SDK
//
//  Created by 梁庭宾 on 2017/9/19.
//  Copyright © 2017年 OnlyID. All rights reserved.
//

import UIKit

@objc public class OnlyID: NSObject {
    @objc static public func auth(_ clientId: String, delegate: AuthDelegate, state: String = "empty", themeDark: Bool = false, viewZoomed: Bool = false, scene: String = "login") {
        let viewController = AuthViewController(clientId: clientId, delegate: delegate, state: state, themeDark: themeDark, viewZoomed: viewZoomed, scene: scene)
        let navController = UINavigationController(rootViewController: viewController)
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            fatalError("keyWindow或rootViewController为nil")
        }
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.present(navController, animated: true, completion: nil)
        }
        else {
            rootViewController.present(navController, animated: true, completion: nil)
        }
    }
}

@objc public protocol AuthDelegate {
    func didReceiveAuthResp(errCode: ErrCode, code: String?, state: String?)
}

@objc public enum ErrCode: Int {
    case ok, networkErr, cancel
}
